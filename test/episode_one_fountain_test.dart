import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_escape_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_puzzles.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_state.dart';

void main() {
  test('분수대 돌 선택은 연못 단서가 있어야 성공할 수 있다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    _solveOpeningAndPedestal(controller);
    controller.closePedestal();
    _solveClockflower(controller);
    controller.closeClockflowerRing();
    controller.returnToGarden();
    controller.navigateTo(EpisodeOneScene.fountain);

    controller.selectItem(EpisodeOneItem.silverRibbon);
    expect(controller.useSelectedItemOnFountainWheel(), isTrue);
    controller.completeFountainWheelRepair();

    controller.selectFountainStone(3);

    expect(controller.value.fountainStoneAnimating, isFalse);
    expect(controller.value.fountainStarKeyRevealed, isFalse);
    expect(controller.value.message, contains('연못'));
  });

  test('P4는 바람끈·젖은 발자국·별열쇠를 연결해 달빛 손잡이를 준다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    _prepareFountain(controller);

    expect(controller.value.inventory, contains(EpisodeOneItem.silverRibbon));
    controller.selectItem(EpisodeOneItem.silverRibbon);
    expect(controller.useSelectedItemOnFountainWheel(), isTrue);
    expect(controller.value.fountainWheelRepairing, isTrue);
    expect(controller.value.inputLocked, isTrue);
    expect(
      controller.value.inventory,
      isNot(contains(EpisodeOneItem.silverRibbon)),
    );

    controller.completeFountainWheelRepair();
    expect(controller.value.fountainWheelRepaired, isTrue);
    expect(controller.value.inputLocked, isFalse);

    controller.selectFountainStone(1);
    expect(controller.value.fountainStoneSelection, 1);
    expect(controller.value.fountainStoneAnimating, isFalse);
    expect(controller.value.message, contains('다르네요'));

    controller.selectFountainStone(3);
    expect(controller.value.fountainStoneAnimating, isTrue);
    expect(controller.value.inputLocked, isTrue);
    controller.completeFountainStoneReveal();

    expect(controller.value.fountainStarKeyRevealed, isTrue);
    expect(controller.value.fountainStarKeyCollected, isFalse);
    controller.collectFountainStarKey();
    expect(controller.value.fountainStarKeyCollected, isTrue);
    expect(controller.value.inventory, contains(EpisodeOneItem.starKey));

    expect(controller.useSelectedItemOnFountainChest(), isFalse);
    expect(controller.value.message, contains('먼저 선택'));
    controller.selectItem(EpisodeOneItem.starKey);
    expect(controller.useSelectedItemOnFountainChest(), isTrue);
    expect(controller.value.fountainChestOpening, isTrue);
    expect(controller.value.inputLocked, isTrue);
    expect(controller.value.inventory, isNot(contains(EpisodeOneItem.starKey)));

    controller.completeFountainChestOpening();

    expect(controller.value.fountainSolved, isTrue);
    expect(controller.value.inputLocked, isFalse);
    expect(controller.value.inventory, contains(EpisodeOneItem.moonHandle));
    expect(
      controller.value.clues,
      containsAll({
        EpisodeOneClue.wetTracks,
        EpisodeOneClue.silverFurTrail,
      }),
    );
    expect(controller.value.progressLabel, '달빛 손잡이 획득');
  });

  test('잘못된 아이템은 분수대에서 사라지지 않는다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    _solveOpeningAndPedestal(controller);
    controller.closePedestal();
    controller.navigateTo(EpisodeOneScene.fountain);
    controller.selectItem(EpisodeOneItem.starLens);

    expect(controller.useSelectedItemOnFountainWheel(), isFalse);
    expect(controller.value.inventory, contains(EpisodeOneItem.starLens));
    expect(controller.value.selectedItem, EpisodeOneItem.starLens);
    expect(controller.value.fountainWheelRepairing, isFalse);
  });

  testWidgets('분수대 화면에서 P4 전체 연쇄 조작을 완료할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareFountain(controller);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-fountain-overlay')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('episode-one-item-silverRibbon')));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('episode-one-use-ribbon-on-wheel')),
    );
    await tester.pump();
    expect(controller.value.fountainWheelRepairing, isTrue);

    await tester.pump(const Duration(milliseconds: 1400));
    expect(controller.value.fountainWheelRepaired, isTrue);

    final thirdStone = find.byKey(const Key('episode-one-fountain-stone-3'));
    await tester.ensureVisible(thirdStone);
    await tester.tap(thirdStone);
    await tester.pump();
    expect(controller.value.fountainStoneAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(controller.value.fountainStarKeyRevealed, isTrue);

    final collectKey = find.byKey(const Key('episode-one-collect-star-key'));
    await tester.ensureVisible(collectKey);
    await tester.tap(collectKey);
    await tester.pump();
    expect(controller.value.inventory, contains(EpisodeOneItem.starKey));

    await tester.tap(find.byKey(const Key('episode-one-item-starKey')));
    await tester.pump();

    final chestButton = find.byKey(const Key('episode-one-use-key-on-chest'));
    await tester.ensureVisible(chestButton);
    await tester.tap(chestButton);
    await tester.pump();
    expect(controller.value.fountainChestOpening, isTrue);

    await tester.pump(const Duration(milliseconds: 1600));
    expect(controller.value.fountainSolved, isTrue);
    expect(
      find.byKey(const Key('episode-one-item-moonHandle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-fountain-evidence')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 분수대 연쇄 장면이 스크롤되고 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareFountain(controller);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-fountain-overlay')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('episode-one-inventory')), findsOneWidget);
    expect(
      find.byKey(const Key('episode-one-foundation-status')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

void _prepareFountain(EpisodeOneStateController controller) {
  _solveOpeningAndPedestal(controller);
  controller.closePedestal();
  _solvePond(controller);
  controller.closePondMirror();
  controller.returnToGarden();
  _solveClockflower(controller);
  controller.closeClockflowerRing();
  controller.returnToGarden();
  expect(controller.navigateTo(EpisodeOneScene.fountain), isTrue);
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

  controller.completePedestalMechanism();
}

void _solvePond(EpisodeOneStateController controller) {
  expect(controller.navigateTo(EpisodeOneScene.pond), isTrue);
  controller.selectItem(EpisodeOneItem.starLens);
  expect(controller.useSelectedItemOnPondMirror(), isTrue);
  controller.completePondLensInstallation();
  for (final trackIndex in PondTrackPuzzle.correctOrder) {
    controller.selectPondTrack(trackIndex);
  }
  controller.completePondTrackAnimation();
}

void _solveClockflower(EpisodeOneStateController controller) {
  expect(controller.navigateTo(EpisodeOneScene.clockflowerGrove), isTrue);
  expect(controller.openClockflowerRing(), isTrue);
  controller.selectClockflowerStep(12);
  controller.completeClockflowerAnimation();
}
