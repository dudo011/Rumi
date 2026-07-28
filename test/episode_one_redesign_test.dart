import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one_v2/episode_one_redesign_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one_v2/episode_one_redesign_state.dart';

void main() {
  test('필수 학습 활동 14개를 완료하면 단서 6개와 중간 결론을 얻는다', () {
    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);

    _completeRequiredActivities(controller);

    expect(controller.value.completed, isTrue);
    expect(controller.value.progressLabel, '필수 활동 14/14');
    expect(controller.value.clues.length, 6);
    expect(controller.value.clues, contains(EpisodeOneRedesignClue.silverFur));
    expect(controller.value.message, contains('씨앗이 먼저 떨어졌고'));
  });

  test('두 번 틀리면 보강 힌트를 제안하고 진행 보상은 차감하지 않는다', () {
    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);

    controller.fitFallenPiece();
    expect(
      controller.value.activity,
      EpisodeOneRedesignActivity.testTwelveGroups,
    );

    expect(controller.submitCurrent(), isFalse);
    expect(controller.submitCurrent(), isFalse);
    expect(controller.value.supportSuggested, isTrue);
    expect(controller.value.totalErrors, 2);

    controller.requestHint();
    expect(controller.value.hintLevel, 1);
    expect(controller.value.message, contains('남는지'));
  });

  test('선택 도전에서 30의 약수를 모두 찾으면 별도장을 얻는다', () {
    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);

    _completeRequiredActivities(controller);
    controller.openChallenge();
    for (final number in const [1, 2, 3, 5, 6, 10, 15, 30]) {
      controller.toggleNumber(number);
    }

    expect(controller.submitChallenge(), isTrue);
    expect(controller.value.challengeCompleted, isTrue);
    expect(controller.value.message, contains('별도장'));
  });

  testWidgets('설치형 앱 안전영역 안에 HUD와 메시지 바를 배치한다', (tester) async {
    const screenSize = Size(360, 640);
    const safePadding = EdgeInsets.fromLTRB(0, 28, 0, 24);

    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: screenSize,
            padding: safePadding,
            viewPadding: safePadding,
          ),
          child: EpisodeOneRedesignScreen(controller: controller),
        ),
      ),
    );
    await tester.pump();

    final backButton = find.byKey(const Key('episode-one-v2-back'));
    final messageBar = find.byKey(const Key('episode-one-v2-message-bar'));

    expect(backButton, findsOneWidget);
    expect(messageBar, findsOneWidget);
    expect(tester.getTopLeft(backButton).dy, greaterThanOrEqualTo(28));
    expect(tester.getBottomRight(messageBar).dy, lessThanOrEqualTo(616));
    expect(find.byKey(const Key('episode-one-v2-activity-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('첫 별조각을 누르면 두 번째 학습 활동으로 이어진다', (tester) async {
    final controller = EpisodeOneRedesignController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: EpisodeOneRedesignScreen(controller: controller)),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('episode-one-v2-fallen-piece')));
    await tester.pump();

    expect(controller.value.activityIndex, 1);
    expect(find.byKey(const Key('episode-one-v2-activity-2')), findsOneWidget);
    expect(
      controller.value.clues,
      contains(EpisodeOneRedesignClue.fallenPiece),
    );
    expect(tester.takeException(), isNull);
  });
}

void _completeRequiredActivities(EpisodeOneRedesignController controller) {
  expect(controller.fitFallenPiece(), isTrue);

  for (final size in const [2, 3, 4, 5]) {
    controller.testGroupSize(size);
  }
  expect(controller.submitCurrent(), isTrue);

  _selectNumbers(controller, const [1, 2, 3, 4, 6, 12]);
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['1×12', '2×6', '3×4']);
  expect(controller.submitCurrent(), isTrue);

  for (final number in EpisodeOneRedesignController.orderedTwelve) {
    controller.selectOrderedNumber(number);
  }
  expect(controller.submitCurrent(), isTrue);

  _selectNumbers(controller, const [1, 2, 3, 6, 9, 18]);
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['6×3', '9×2', '18×1']);
  expect(controller.submitCurrent(), isTrue);

  controller.toggleNumber(6);
  expect(controller.submitCurrent(), isTrue);

  controller.toggleNumber(4);
  expect(controller.submitCurrent(), isTrue);

  _selectTexts(controller, const ['1×24', '2×12', '3×8', '4×6']);
  expect(controller.submitCurrent(), isTrue);

  _selectNumbers(controller, const [1, 2, 3, 4, 6, 8, 12, 24]);
  expect(controller.submitCurrent(), isTrue);

  controller.toggleText('C');
  expect(controller.submitCurrent(), isTrue);

  controller.toggleNumber(6);
  expect(controller.submitCurrent(), isTrue);

  for (final card in EpisodeOneRedesignController.correctTimeline) {
    controller.selectTimelineCard(card);
  }
  controller.toggleText('B');
  expect(controller.submitCurrent(), isTrue);
}

void _selectNumbers(
  EpisodeOneRedesignController controller,
  List<int> numbers,
) {
  for (final number in numbers) {
    controller.toggleNumber(number);
  }
}

void _selectTexts(EpisodeOneRedesignController controller, List<String> texts) {
  for (final text in texts) {
    controller.toggleText(text);
  }
}
