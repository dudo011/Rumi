import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Future<void> waitForUi(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> startInvestigation(WidgetTester tester) async {
    await waitForUi(tester);
    expect(find.text('🌟 별빛 씨앗이 사라졌어요!'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-investigation')));
    await waitForUi(tester);
  }

  Future<void> solveSingleChoice(
    WidgetTester tester,
    String puzzleKey,
    int correctIndex,
  ) async {
    await tester.tap(find.byKey(Key('$puzzleKey-option-$correctIndex')));
    await tester.pump();
    await tester.tap(find.byKey(Key('$puzzleKey-check-answer')));
    await waitForUi(tester);
    expect(find.text('✨ 새로운 증거 발견!'), findsOneWidget);
    await tester.tap(find.textContaining('수첩에 저장'));
    await waitForUi(tester);
  }

  Future<void> reachDeduction(WidgetTester tester) async {
    await tester.tap(find.byTooltip('빈 별받침대 조사'));
    await waitForUi(tester);
    await solveSingleChoice(tester, 'scratch', 1);

    expect(find.byTooltip('오른쪽 길의 작은 발자국 조사'), findsOneWidget);
    await tester.tap(find.byTooltip('오른쪽 길의 작은 발자국 조사'));
    await waitForUi(tester);
    await solveSingleChoice(tester, 'footprints', 2);

    expect(find.byTooltip('분수대의 잠긴 상자 조사'), findsOneWidget);
    await tester.tap(find.byTooltip('분수대의 잠긴 상자 조사'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('최근에 움직인 물건'), findsOneWidget);

    await tester.tap(find.byTooltip('작은 돌 아래 조사'));
    await waitForUi(tester);
    await tester.tap(find.text('열쇠 챙기기'));
    await waitForUi(tester);

    await tester.tap(find.byTooltip('분수대의 잠긴 상자 조사'));
    await waitForUi(tester);
    for (final value in [1, 2, 3, 4, 6]) {
      await tester.tap(find.byKey(Key('factor-$value')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('check-puzzle-answer')));
    await waitForUi(tester);
    expect(find.text('✨ 새로운 증거 발견!'), findsOneWidget);
    await tester.tap(find.textContaining('수첩에 저장'));
    await waitForUi(tester);
  }

  testWidgets('스토리 질문에서 시작해 증거가 단계적으로 열린다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );
    await startInvestigation(tester);

    expect(find.textContaining('현재 생각 · 아직 모르겠다'), findsOneWidget);
    expect(find.byTooltip('빈 별받침대 조사'), findsOneWidget);
    expect(find.byTooltip('오른쪽 길의 작은 발자국 조사'), findsNothing);
    expect(find.byTooltip('분수대의 잠긴 상자 조사'), findsNothing);

    await tester.tap(find.byTooltip('빈 별받침대 조사'));
    await waitForUi(tester);
    expect(find.text('긁힌 별가루 해석'), findsOneWidget);
    await solveSingleChoice(tester, 'scratch', 1);

    expect(find.textContaining('씨앗이 오른쪽으로 밀려난 것 같다'), findsOneWidget);
    expect(find.byTooltip('오른쪽 길의 작은 발자국 조사'), findsOneWidget);
  });

  testWidgets('세 증거를 연결해 올바른 가설로 사건을 해결한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var continued = false;
    await tester.pumpWidget(
      MaterialApp(
        home: GardenExplorationScreen(onContinue: (_) => continued = true),
      ),
    );
    await startInvestigation(tester);
    await reachDeduction(tester);

    expect(find.text('🕵️ 정원에서 무슨 일이 있었을까요?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('deduction-option-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('check-deduction')));
    await waitForUi(tester);

    expect(find.text('🌸 사건 해결!'), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-resolution')));
    await waitForUi(tester);

    expect(find.text('별빛 씨앗의 비밀을 밝혀냈어요!'), findsOneWidget);
    expect(find.text('다음 모험 보기'), findsOneWidget);
    await tester.tap(find.text('다음 모험 보기'));
    expect(continued, isTrue);
  });

  testWidgets('작은 화면에서도 시작 화면과 목표 표시가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );
    await startInvestigation(tester);

    expect(find.text('사라진 별빛 씨앗'), findsOneWidget);
    expect(find.textContaining('현재 목표'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
