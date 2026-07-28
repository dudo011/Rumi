import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one_v3/episode_one_v3_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one_v3/episode_one_v3_state.dart';

void main() {
  test('네 개 연쇄 퍼즐을 완료하면 학습 활동 14개와 단서 6개를 얻는다', () {
    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);

    _completeEpisode(controller);

    expect(controller.value.completed, isTrue);
    expect(controller.value.stage, EpisodeOneV3Stage.completed);
    expect(controller.value.completedActivities.length, 14);
    expect(controller.value.clues.length, 6);
    expect(controller.value.clues, contains(EpisodeOneV3Clue.silverFur));
    expect(controller.value.learningProgressLabel, '학습 활동 14/14');
  });

  test('발자국 퍼즐은 필터·시작점·간격·방향 경로를 모두 요구한다', () {
    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);
    controller.restoreCheckpoint(3);

    controller.toggleFilter('dew');
    controller.toggleFilter('stencil');
    expect(controller.submitCurrent(), isFalse);
    controller.toggleFilter('starlight');
    expect(controller.submitCurrent(), isTrue);

    controller.toggleNumber(1);
    expect(controller.submitCurrent(), isFalse);
    controller.toggleNumber(2);
    expect(controller.submitCurrent(), isTrue);

    controller.testValue(4);
    controller.testValue(6);
    expect(controller.submitCurrent(), isFalse);
    controller.testValue(5);
    expect(controller.submitCurrent(), isTrue);

    controller.selectTrackNode(0);
    controller.selectTrackNode(4);
    expect(controller.value.trackPath, const [0]);
    expect(controller.value.totalErrors, greaterThan(0));

    for (final node in const [6, 12, 18, 24]) {
      controller.selectTrackNode(node);
    }
    expect(controller.submitCurrent(), isTrue);
    expect(controller.value.completedActivities, contains(13));
    expect(controller.value.clues, contains(EpisodeOneV3Clue.roundFootprints));
  });

  test('대형 퍼즐 체크포인트를 다음 장소의 시작 상태로 복원한다', () {
    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);

    controller.restoreCheckpoint(1);
    expect(controller.value.stage, EpisodeOneV3Stage.identifyFlowerpot);
    expect(controller.value.completedActivities.length, 5);
    expect(controller.value.clues.length, 2);

    controller.restoreCheckpoint(2);
    expect(controller.value.stage, EpisodeOneV3Stage.arrangeTwentyFour);
    expect(controller.value.completedActivities.length, 9);
    expect(
      controller.value.inventory,
      contains(EpisodeOneV3Item.twentyFourSeeds),
    );

    controller.restoreCheckpoint(3);
    expect(controller.value.stage, EpisodeOneV3Stage.useTraceFilters);
    expect(controller.value.completedActivities.length, 12);
    expect(controller.value.inventory, contains(EpisodeOneV3Item.dewLens));
  });

  test('현재 입력 되돌리기는 대형 퍼즐 진행이 아니라 마지막 선택만 취소한다', () {
    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);

    controller.toggleText('crescent');
    expect(controller.value.selectedTexts, contains('crescent'));
    expect(controller.undoCurrentInput(), isTrue);
    expect(controller.value.selectedTexts, isEmpty);
    expect(controller.value.stage, EpisodeOneV3Stage.identifyFragment);
  });

  testWidgets('설치형 앱 안전영역 안에 HUD와 메시지 바를 배치한다', (tester) async {
    const screenSize = Size(360, 640);
    const safePadding = EdgeInsets.fromLTRB(0, 28, 0, 24);

    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: screenSize,
            padding: safePadding,
            viewPadding: safePadding,
          ),
          child: EpisodeOneV3Screen(controller: controller),
        ),
      ),
    );
    await tester.pump();

    final undo = find.byKey(const Key('episode-one-v3-undo'));
    final messageBar = find.byKey(const Key('episode-one-v3-message-bar'));

    expect(find.byKey(const Key('episode-one-v3-screen')), findsOneWidget);
    expect(undo, findsOneWidget);
    expect(messageBar, findsOneWidget);
    expect(tester.getTopLeft(undo).dy, greaterThanOrEqualTo(28));
    expect(tester.getBottomRight(messageBar).dy, lessThanOrEqualTo(616));
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('시스템 뒤로가기는 Episode를 종료하지 않는다', (tester) async {
    final controller = EpisodeOneV3Controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneV3Screen(controller: controller)),
    );
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('episode-one-v3-screen')), findsOneWidget);
    expect(find.textContaining('단서 6개를 모두 찾기 전에는'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _completeEpisode(EpisodeOneV3Controller controller) {
  controller.toggleText('crescent');
  expect(controller.submitCurrent(), isTrue);

  for (final value in const [2, 3, 4, 5]) {
    controller.testValue(value);
  }
  expect(controller.submitCurrent(), isTrue);

  _selectNumbers(controller, const [1, 2, 3, 4, 6, 12]);
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['1×12', '2×6', '3×4']);
  expect(controller.submitCurrent(), isTrue);

  for (final number in EpisodeOneV3Controller.orderedTwelve) {
    controller.selectOrderedNumber(number);
  }
  expect(controller.submitCurrent(), isTrue);

  controller.toggleText('pot6');
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['rim7', 'soil5', 'tile6']);
  expect(controller.submitCurrent(), isTrue);

  _selectNumbers(controller, const [1, 2, 3, 6, 9, 18]);
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['18×1', '9×2', '6×3']);
  expect(controller.submitCurrent(), isTrue);

  controller.toggleNumber(6);
  expect(controller.submitCurrent(), isTrue);

  controller.toggleNumber(4);
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['1×24', '2×12', '3×8', '4×6']);
  expect(controller.submitCurrent(), isTrue);

  _selectNumbers(controller, const [1, 2, 3, 4, 6, 8, 12, 24]);
  expect(controller.submitCurrent(), isTrue);

  for (final glyph in EpisodeOneV3Controller.correctStorageGlyphs) {
    controller.selectOrderedText(glyph);
  }
  expect(controller.submitCurrent(), isTrue);

  controller.toggleText('C');
  controller.testValue(5);
  expect(controller.submitCurrent(), isTrue);

  for (final filter in const ['dew', 'stencil', 'starlight']) {
    controller.toggleFilter(filter);
  }
  expect(controller.submitCurrent(), isTrue);

  controller.toggleNumber(2);
  expect(controller.submitCurrent(), isTrue);

  for (final interval in const [4, 5, 6]) {
    controller.testValue(interval);
  }
  expect(controller.submitCurrent(), isTrue);

  for (final node in EpisodeOneV3Controller.correctTrackPath) {
    controller.selectTrackNode(node);
  }
  expect(controller.submitCurrent(), isTrue);

  for (final card in EpisodeOneV3Controller.correctEvidenceOrder) {
    controller.selectEvidenceCard(card);
  }
  expect(controller.submitCurrent(), isTrue);

  controller.toggleText('B');
  expect(controller.submitCurrent(), isTrue);
}

void _selectNumbers(EpisodeOneV3Controller controller, List<int> numbers) {
  for (final number in numbers) {
    controller.toggleNumber(number);
  }
}

void _selectTexts(EpisodeOneV3Controller controller, List<String> texts) {
  for (final text in texts) {
    controller.toggleText(text);
  }
}
