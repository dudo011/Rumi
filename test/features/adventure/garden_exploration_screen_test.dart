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

  testWidgets('별받침대 장면은 선택 후 재시도할 수 있는 구조를 제공한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen());
    await start(tester);

    await tester.tap(find.byKey(const Key('pedestal-hotspot')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('별가루 12개를 3개씩'), findsOneWidget);
    expect(find.byKey(const Key('scratch-option-3')), findsOneWidget);
    expect(find.byKey(const Key('scratch-option-4')), findsOneWidget);
    expect(find.byKey(const Key('scratch-option-6')), findsOneWidget);

    final checkButton = tester.widget<FilledButton>(
      find.byKey(const Key('scratch-check-answer')),
    );
    expect(checkButton.onPressed, isNull);
    expect(find.text('증거 0/3'), findsOneWidget);
  });

  testWidgets('상자와 돌은 발자국 증거 전에는 나타나지 않는다', (tester) async {
    await tester.pumpWidget(buildScreen());
    await start(tester);

    expect(find.byKey(const Key('chest-hotspot')), findsNothing);
    expect(find.byKey(const Key('move-stone')), findsNothing);
  });

  testWidgets('확대 장면은 팝업이 아니라 화면 전환으로 표시된다', (tester) async {
    await tester.pumpWidget(buildScreen());
    await start(tester);

    await tester.tap(find.byKey(const Key('pedestal-hotspot')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('별받침대 확대 조사'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const Key('scratch-check-answer')), findsOneWidget);
  });
}
