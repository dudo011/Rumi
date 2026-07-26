import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Future<void> collectClue(
    WidgetTester tester,
    String tooltip,
    String title,
  ) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pumpAndSettle();
    expect(find.text('✨ 새로운 단서 발견!'), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    await tester.tap(find.textContaining('수첩에 저장'));
    await tester.pumpAndSettle();
  }

  testWidgets('사건 현장의 핵심 단서 세 개를 수집하고 다음 장면으로 이동한다', (tester) async {
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

    expect(find.text('단서 0/3'), findsOneWidget);
    expect(find.byTooltip('졸고 있는 개구리 조사'), findsOneWidget);

    await tester.tap(find.byTooltip('졸고 있는 개구리 조사'));
    await tester.pump();
    expect(find.textContaining('아무것도 못 봤대요'), findsOneWidget);
    expect(find.text('단서 0/3'), findsOneWidget);

    await collectClue(tester, '빈 별받침대 조사', '오른쪽으로 난 긁힌 자국');
    await collectClue(tester, '작은 발자국 조사', '작고 둥근 발자국');
    await collectClue(tester, '울타리의 은빛 털 조사', '울타리의 은빛 털');

    expect(find.text('단서 3/3'), findsOneWidget);
    expect(find.text('단서 3개를 모두 찾았어요!'), findsOneWidget);
    await tester.tap(find.text('연못으로 추적'));
    expect(continued, isTrue);
  });

  testWidgets('단서 수첩은 찾은 단서와 잠긴 단서를 구분한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );

    await collectClue(tester, '빈 별받침대 조사', '오른쪽으로 난 긁힌 자국');
    await tester.tap(find.text('단서 1/3'));
    await tester.pumpAndSettle();

    expect(find.text('별지기의 단서 수첩'), findsOneWidget);
    expect(find.text('오른쪽으로 난 긁힌 자국'), findsOneWidget);
    expect(find.text('아직 찾지 못한 단서'), findsNWidgets(2));
  });

  testWidgets('작은 화면에서도 조사 대상과 단서 안내가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );

    expect(find.byTooltip('빈 별받침대 조사'), findsOneWidget);
    expect(find.byTooltip('작은 발자국 조사'), findsOneWidget);
    expect(find.byTooltip('울타리의 은빛 털 조사'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
