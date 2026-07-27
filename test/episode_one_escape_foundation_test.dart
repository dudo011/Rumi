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

  test('P3은 0·2·4·6 순서의 실제 발자국만 허용한다', () {
    expect(PondTrackPuzzle.correctOrder, [0, 2, 4, 6]);
    expect(
      PondTrackPuzzle.isExpectedTrack(selectedIndex: 0, progress: 0),
      isTrue,
    );
    expect(
      PondTrackPuzzle.isExpectedTrack(selectedIndex: 2, progress: 1),
      isTrue,
    );
    expect(
      PondTrackPuzzle.isExpectedTrack(selectedIndex: 1, progress: 0),
      isFalse,
    );
    expect(PondTrackPuzzle.isRealFootprint(4), isTrue);
    expect(PondTrackPuzzle.isRealFootprint(5), isFalse);
    expect(PondTrackPuzzle.isCompleted(4), isTrue);
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

    _solveOpeningAndPedestal(controller);

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

  test('별무늬 렌즈를 사용해 연못 기억거울과 P3 단서를 해결한다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    _solveOpeningAndPedestal(controller);
    controller.closePedestal();
    expect(controller.navigateTo(EpisodeOneScene.pond), isTrue);

    expect(controller.useSelectedItemOnPondMirror(), isFalse);
    expect(controller.value.inventory, contains(EpisodeOneItem.starLens));
    expect(controller.value.message, contains('먼저 선택'));

    controller.selectItem(EpisodeOneItem.starLens);
    expect(controller.value.selectedItem, EpisodeOneItem.starLens);
    expect(controller.useSelectedItemOnPondMirror(), isTrue);
    expect(controller.value.pondLensInstalling, isTrue);
    expect(controller.value.inputLocked, isTrue);
    expect(controller.value.inventory, isEmpty);
    expect(controller.value.selectedItem, isNull);

    controller.completePondLensInstallation();
    expect(controller.value.pondLensInstalled, isTrue);
    expect(controller.value.pondCloseUpOpen, isTrue);
    expect(controller.value.inputLocked, isFalse);

    controller.selectPondTrack(1);
    expect(controller.value.pondTrackProgress, 0);
    expect(controller.value.message, contains('바람'));

    for (final trackIndex in PondTrackPuzzle.correctOrder) {
      controller.selectPondTrack(trackIndex);
    }

    expect(controller.value.pondTrackProgress, 4);
    expect(controller.value.pondTrackAnimating, isTrue);
    expect(controller.value.inputLocked, isTrue);

    controller.completePondTrackAnimation();
    expect(controller.value.pondSolved, isTrue);
    expect(controller.value.inputLocked, isFalse);
    expect(controller.value.clues, contains(EpisodeOneClue.wetTracks));
    expect(controller.value.progressLabel, contains('연못 단서'));
  });

  testWidgets('인벤토리에서 별무늬 렌즈를 선택하고 해제할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _solveOpeningAndPedestal(controller);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final lensFinder = find.byKey(const Key('episode-one-item-starLens'));
    expect(find.byKey(const Key('episode-one-inventory')), findsOneWidget);
    expect(lensFinder, findsOneWidget);

    await tester.tap(lensFinder);
    await tester.pump();
    expect(controller.value.selectedItem, EpisodeOneItem.starLens);
    expect(find.text('별무늬 렌즈 선택'), findsOneWidget);

    await tester.tap(lensFinder);
    await tester.pump();
    expect(controller.value.selectedItem, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('연못 단서를 수첩에서 확인할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _solveOpeningAndPedestal(controller);
    controller.closePedestal();
    controller.navigateTo(EpisodeOneScene.pond);
    controller.selectItem(EpisodeOneItem.starLens);
    controller.useSelectedItemOnPondMirror();
    controller.completePondLensInstallation();
    for (final trackIndex in PondTrackPuzzle.correctOrder) {
      controller.selectPondTrack(trackIndex);
    }
    controller.completePondTrackAnimation();

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('episode-one-clue-notebook')));
    await tester.pumpAndSettle();

    expect(find.text('별지기의 단서 수첩'), findsOneWidget);
    expect(find.text(EpisodeOneClue.wetTracks.label), findsOneWidget);
    expect(
      find.byKey(const Key('episode-one-clue-wetTracks')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 HUD와 인벤토리가 넘치지 않는다', (tester) async {
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
    expect(find.byKey(const Key('episode-one-inventory')), findsOneWidget);
    expect(find.byKey(const Key('episode-one-clue-notebook')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _solveOpeningAndPedestal(EpisodeOneStateController controller) {
  expect(controller.startFittingFallenPiece(), isTrue);
  controller.completeFittingFallenPiece();
  expect(controller.openPedestal(), isTrue);

  for (var cup = 0; cup < 3; cup++) {
    for (var dust = 0; dust < 4; dust++) {
      controller.addDustToCup(cup);
    }
  }

  expect(controller.value.pedestalMechanismAnimating, isTrue);
  controller.completePedestalMechanism();
}
