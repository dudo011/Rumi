import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_escape_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_puzzles.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_state.dart';

void main() {
  test('P1은 별가루 12개를 4·4·4로 나눈 경우에만 해결된다', () {
    expect(PedestalBalancePuzzle.isSolved([4, 4, 4]), isTrue);
    expect(PedestalBalancePuzzle.isSolved([5, 4, 3]), isFalse);
    expect(PedestalBalancePuzzle.isSolved([4, 4, 3]), isFalse);
    expect(PedestalBalancePuzzle.remainingDust([2, 3, 4]), 3);
  });

  test('P0와 P1 완료 전후에 실제 경로 잠금 상태가 달라진다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    expect(controller.value.currentScene, EpisodeOneScene.centralGarden);
    expect(controller.canNavigateTo(EpisodeOneScene.pond), isFalse);
    expect(controller.canNavigateTo(EpisodeOneScene.clockflowerGrove), isFalse);
    expect(controller.canNavigateTo(EpisodeOneScene.fountain), isTrue);
    expect(controller.canNavigateTo(EpisodeOneScene.greenhouse), isTrue);

    expect(controller.navigateTo(EpisodeOneScene.pond), isFalse);
    expect(controller.value.currentScene, EpisodeOneScene.centralGarden);
    expect(controller.value.message, contains('균형 장치'));

    expect(controller.startFittingFallenPiece(), isTrue);
    expect(controller.value.inputLocked, isTrue);
    controller.completeFittingFallenPiece();
    expect(controller.value.fallenPieceFitted, isTrue);
    expect(controller.value.inputLocked, isFalse);

    expect(controller.openPedestal(), isTrue);
    for (var cup = 0; cup < 3; cup++) {
      for (var dust = 0; dust < 4; dust++) {
        controller.addDustToCup(cup);
      }
    }

    expect(controller.value.pedestalCupCounts, [4, 4, 4]);
    expect(controller.value.pedestalMechanismAnimating, isTrue);
    expect(controller.value.inputLocked, isTrue);

    controller.completePedestalMechanism();

    expect(controller.value.pedestalSolved, isTrue);
    expect(controller.value.inventory, contains(EpisodeOneItem.starLens));
    expect(controller.canNavigateTo(EpisodeOneScene.pond), isFalse);

    controller.closePedestal();
    expect(controller.canNavigateTo(EpisodeOneScene.pond), isTrue);
    expect(controller.navigateTo(EpisodeOneScene.clockflowerGrove), isTrue);
    expect(
      controller.value.visitedScenes,
      containsAll({
        EpisodeOneScene.centralGarden,
        EpisodeOneScene.clockflowerGrove,
      }),
    );
  });

  test('불균형 배치는 유지한 채 별가루를 다시 옮길 수 있다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    controller.startFittingFallenPiece();
    controller.completeFittingFallenPiece();
    controller.openPedestal();

    for (var dust = 0; dust < 5; dust++) {
      controller.addDustToCup(0);
    }
    for (var dust = 0; dust < 4; dust++) {
      controller.addDustToCup(1);
    }
    for (var dust = 0; dust < 3; dust++) {
      controller.addDustToCup(2);
    }

    expect(controller.value.pedestalMechanismAnimating, isFalse);
    expect(controller.value.pedestalCupCounts, [5, 4, 3]);
    expect(controller.value.message, contains('무게가 아직 달라요'));

    controller.removeDustFromCup(0);
    controller.addDustToCup(2);

    expect(controller.value.pedestalCupCounts, [4, 4, 4]);
    expect(controller.value.pedestalMechanismAnimating, isTrue);
  });

  testWidgets('Episode 1 HUD가 P0·P1 진행 상태를 반영한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('중앙 정원'), findsOneWidget);
    expect(
      find.byKey(const Key('episode-one-foundation-status')),
      findsOneWidget,
    );
    expect(find.text('받침대 준비 전'), findsOneWidget);

    controller.startFittingFallenPiece();
    controller.completeFittingFallenPiece();
    controller.openPedestal();
    await tester.pump();

    expect(find.text('별받침대 균형 장치'), findsOneWidget);
    expect(find.textContaining('별가루 0/12'), findsOneWidget);

    for (var cup = 0; cup < 3; cup++) {
      for (var dust = 0; dust < 4; dust++) {
        controller.addDustToCup(cup);
      }
    }
    controller.completePedestalMechanism();
    controller.closePedestal();
    controller.navigateTo(EpisodeOneScene.clockflowerGrove);
    await tester.pump();

    expect(find.text('시계꽃 숲'), findsOneWidget);
    expect(find.text('별무늬 렌즈 획득'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 Episode 1 HUD가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EpisodeOneEscapeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-current-objective')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-foundation-status')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('episode-one-progress-label')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
