import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/core/storage/progress_store.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_escape_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_puzzles.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_state.dart';

void main() {
  testWidgets('최종 추리 오답은 증거 기반 피드백 후 다시 선택할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    final store = _FakeProgressStore();
    addTearDown(controller.dispose);
    _prepareFinale(controller);

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeOneEscapeScreen(controller: controller, store: store),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-final-deduction')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-finale-evidence-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-finale-evidence-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-finale-evidence-3')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('episode-one-hypothesis-0')));
    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));
    await tester.pump();

    expect(
      find.byKey(const Key('episode-one-deduction-wrong')),
      findsOneWidget,
    );
    expect(find.textContaining('바람이 분 뒤'), findsOneWidget);
    expect(store.completeCalls, 0);

    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));
    await tester.pump();

    expect(
      find.byKey(const Key('episode-one-deduction-wrong')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('정답 추리 후 별빛 꽃이 피고 110 XP가 한 번만 기록된다', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    final store = _FakeProgressStore();
    addTearDown(controller.dispose);
    _prepareFinale(controller);

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeOneEscapeScreen(controller: controller, store: store),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('episode-one-hypothesis-1')));
    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));
    await tester.pump();

    expect(
      find.byKey(const Key('episode-one-deduction-correct')),
      findsOneWidget,
    );
    expect(find.textContaining('포포는 차가워진 씨앗'), findsOneWidget);

    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));
    await tester.pump();

    expect(
      find.byKey(const Key('episode-one-finale-blooming')),
      findsOneWidget,
    );
    expect(store.completeCalls, 1);
    expect(store.lastEarnedExperience, 110);

    await tester.pump(const Duration(milliseconds: 3400));
    await tester.pump();

    expect(
      find.byKey(const Key('episode-one-finale-ending')),
      findsOneWidget,
    );
    expect(find.text('Episode 1 사건 해결!'), findsOneWidget);
    expect(find.textContaining('+110 XP'), findsOneWidget);
    expect(find.textContaining('꽃숲 3단계'), findsOneWidget);
    expect(
      find.byKey(const Key('episode-one-finale-progress-record')),
      findsOneWidget,
    );
    expect(find.textContaining('완료한 모험 2회'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(store.completeCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('완료 기록 실패 시 재시도해 결말로 이동할 수 있다', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    final store = _FakeProgressStore(failFirstCompletion: true);
    addTearDown(controller.dispose);
    _prepareFinale(controller);

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeOneEscapeScreen(controller: controller, store: store),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('episode-one-hypothesis-1')));
    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('episode-one-deduction-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3400));
    await tester.pump();

    expect(
      find.byKey(const Key('episode-one-finale-save-error')),
      findsOneWidget,
    );
    expect(store.completeCalls, 1);

    await tester.tap(find.byKey(const Key('episode-one-retry-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(store.completeCalls, 2);
    expect(
      find.byKey(const Key('episode-one-finale-ending')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 최종 추리 화면이 스크롤되고 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);
    _prepareFinale(controller);

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeOneEscapeScreen(
          controller: controller,
          store: _FakeProgressStore(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('episode-one-finale-overlay')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('episode-one-final-deduction')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeProgressStore extends ProgressStore {
  _FakeProgressStore({this.failFirstCompletion = false});

  final bool failFirstCompletion;
  int completeCalls = 0;
  int? lastEarnedExperience;

  @override
  Future<PlayerProgress> completeAdventure({
    required int earnedExperience,
  }) async {
    completeCalls++;
    lastEarnedExperience = earnedExperience;
    if (failFirstCompletion && completeCalls == 1) {
      throw StateError('temporary save failure');
    }
    return PlayerProgress(
      nickname: '별지기',
      experience: 210,
      completedAdventures: 2,
    );
  }
}

void _prepareFinale(EpisodeOneStateController controller) {
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
  controller.selectItem(EpisodeOneItem.moonHandle);
  expect(controller.useSelectedItemOnGreenhouseDoor(), isTrue);
  controller.completeGreenhouseDoorOpening();
  controller.selectGreenhouseBedCount(6);
  controller.completeGreenhouseBalanceAnimation();

  expect(controller.value.seedFound, isTrue);
  expect(controller.value.clues, contains(EpisodeOneClue.warmNest));
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
