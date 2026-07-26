import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Widget buildScreen() {
    return MaterialApp(
      home: GardenExplorationScreen(onContinue: (_) {}),
    );
  }

  Future<void> start(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('start-investigation')));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('처음에는 핵심 진행 지점이 단계적으로 숨겨진다', (tester) async {
    await tester.pumpWidget(buildScreen());
    await start(tester);

    expect(find.byTooltip('빈 별받침대 조사'), findsOneWidget);
    expect(find.byTooltip('오른쪽 길의 작은 발자국 조사'), findsNothing);
    expect(find.byTooltip('분수대의 잠긴 상자 조사'), findsNothing);
    expect(find.byTooltip('한쪽으로 누운 꽃밭 조사'), findsOneWidget);
    expect(find.byTooltip('연못의 떠다니는 잎 조사'), findsOneWidget);
  });

  testWidgets('오답은 실패시키지 않고 이야기형 힌트를 제공한다', (tester) async {
    await tester.pumpWidget(buildScreen());
    await start(tester);

    await tester.tap(find.byTooltip('빈 별받침대 조사'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('scratch-option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('scratch-check-answer')));
    await tester.pump();

    expect(find.byKey(const Key('scratch-feedback')), findsOneWidget);
    expect(find.textContaining('12 ÷ 3'), findsOneWidget);
    expect(find.text('증거 0/3'), findsOneWidget);
  });

  testWidgets('상자는 발자국을 추적하기 전에는 나타나지 않는다', (tester) async {
    await tester.pumpWidget(buildScreen());
    await start(tester);

    expect(find.byTooltip('분수대의 잠긴 상자 조사'), findsNothing);
    expect(find.byTooltip('작은 돌 아래 조사'), findsOneWidget);

    await tester.tap(find.byTooltip('작은 돌 아래 조사'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('평범한 돌'), findsOneWidget);
    expect(find.text('🔑 낡은 별열쇠 발견!'), findsNothing);
  });
}
