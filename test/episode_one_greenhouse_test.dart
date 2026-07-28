import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_escape_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_puzzles.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_state.dart';

void main() {
  test('P5는 별 18개와 달 24개를 가장 많은 6개 화단에 나눈다', () {
    expect(GreenhouseBalancePuzzle.choices, [2, 3, 4, 6, 8]);
    expect(GreenhouseBalancePuzzle.dividesBoth(2), isTrue);
    expect(GreenhouseBalancePuzzle.dividesBoth(3), isTrue);
    expect(GreenhouseBalancePuzzle.dividesBoth(4), isFalse);
    expect(GreenhouseBalancePuzzle.isSolved(6), isTrue);
    expect(GreenhouseBalancePuzzle.starPerBed(6), 3);
    expect(GreenhouseBalancePuzzle.moonPerBed(6), 4);
    expect(GreenhouseBalancePuzzle.starRemainder(4), 2);
    expect(GreenhouseBalancePuzzle.feedback(2), contains('더 많은'));
    expect(GreenhouseBalancePuzzle.feedback(3), contains('가장 많은'));
  });

  test('달빛 손잡이와 P5를 연결해 씨앗과 포포를 발견한다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareGreenhouse(controller);

    expect(controller.useSelectedItemOnGreenhouseDoor(), isFalse);
    expect(controller.value.inventory, contains(EpisodeOneItem.moonHandle));
    expect(controller.value.message, contains('먼저 선택'));

    controller.selectItem(EpisodeOneItem.moonHandle);
    expect(controller.useSelectedItemOnGreenhouseDoor(), isTrue);
    expect(controller.value.greenhouseDoorOpening, isTrue);
    expect(controller.value.inputLocked, isTrue);
    expect(
      controller.value.inventory,
      isNot(contains(EpisodeOneItem.moonHandle)),
    );

    controller.completeGreenhouseDoorOpening();
    expect(controller.value.greenhouseDoorOpened, isTrue);
    expect(controller.value.inputLocked, isFalse);

    controller.selectGreenhouseBedCount(2);
    expect(controller.value.greenhouseBedSelection, 2);
    expect(controller.value.greenhouseBalanceAnimating, isFalse);
    expect(controller.value.message, contains('더 많은'));

    controller.selectGreenhouseBedCount(4);
    expect(controller.value.greenhouseBedSelection, 4);
    expect(controller.value.message, contains('2개 남았'));

    controller.selectGreenhouseBedCount(6);
    expect(controller.value.greenhouseBalanceAnimating, isTrue);
    expect(controller.value.inputLocked, isTrue);

    controller.completeGreenhouseBalanceAnimation();
    expect(controller.value.seedFound, isTrue);
    expect(controller.value.greenhouseSolved, isTrue);
    expect(controller.value.inputLocked, isFalse);
    expect(controller.value.clues, contains(EpisodeOneClue.warmNest));
    expect(controller.value.progressLabel, '씨앗과 포포 발견');
  });

  test('잘못된 아이템은 온실 문에서 사라지지 않는다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    _solveOpeningAndPedestal(controller);
    controller.closePedestal();
    controller.navigateTo(EpisodeOneScene.greenhouse);
    controller.selectItem(EpisodeOneItem.starLens);

    expect(controller.useSelectedItemOnGreenhouseDoor(), isFalse);
    expect(controller.value.inventory, contains(EpisodeOneItem.starLens));
    expect(controller.value.selectedItem, EpisodeOneItem.starLens);
    expect(controller.value.greenhouseDoorOpening, isFalse);
  });

  testWidgets('온실 화면에서 문 개방과 P5 전체 조작을 완료할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareGreenhouse(controller);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-greenhouse-overlay')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('episode-one-item-moonHandle')));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('episode-one-use-handle-on-greenhouse')),
    );
    await tester.pump();
    expect(controller.value.greenhouseDoorOpening, isTrue);

    await tester.pump(const Duration(milliseconds: 1600));
    expect(controller.value.greenhouseDoorOpened, isTrue);

    final twoBeds = find.byKey(const Key('episode-one-greenhouse-bed-2'));
    await tester.ensureVisible(twoBeds);
    await tester.tap(twoBeds);
    await tester.pump();
    expect(controller.value.greenhouseBedSelection, 2);

    final sixBeds = find.byKey(const Key('episode-one-greenhouse-bed-6'));
    await tester.ensureVisible(sixBeds);
    await tester.tap(sixBeds);
    await tester.pump();
    expect(controller.value.greenhouseBalanceAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 1900));
    expect(controller.value.seedFound, isTrue);
    expect(
      find.byKey(const Key('episode-one-greenhouse-discovery')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('온실의 마지막 증거를 단서 수첩에서 확인할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareGreenhouse(controller);
    controller.selectItem(EpisodeOneItem.moonHandle);
    controller.useSelectedItemOnGreenhouseDoor();
    controller.completeGreenhouseDoorOpening();
    controller.selectGreenhouseBedCount(6);
    controller.completeGreenhouseBalanceAnimation();

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('episode-one-clue-notebook')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(EpisodeOneClue.warmNest.label), findsOneWidget);
    expect(find.byKey(const Key('episode-one-clue-warmNest')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 온실 장면이 스크롤되고 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareGreenhouse(controller);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneEscapeScreen(controller: controller)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-greenhouse-overlay')),
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

void _prepareGreenhouse(EpisodeOneStateController controller) {
  _solveOpeningAndPedestal(controller);
  controller.closePedestal();
  _solvePond(controller);
  controller.closePondMirror();
  controller.returnToGarden();
  _solveClockflower(controller);
  controller.closeClockflowerRing();
  controller.returnToGarden();
  _solveFountain(controller);
  controller.returnToGarden();
  expect(controller.navigateTo(EpisodeOneScene.greenhouse), isTrue);
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

void _solveFountain(EpisodeOneStateController controller) {
  expect(controller.navigateTo(EpisodeOneScene.fountain), isTrue);
  controller.selectItem(EpisodeOneItem.silverRibbon);
  expect(controller.useSelectedItemOnFountainWheel(), isTrue);
  controller.completeFountainWheelRepair();
  controller.selectFountainStone(3);
  controller.completeFountainStoneReveal();
  controller.collectFountainStarKey();
  controller.selectItem(EpisodeOneItem.starKey);
  expect(controller.useSelectedItemOnFountainChest(), isTrue);
  controller.completeFountainChestOpening();
}
