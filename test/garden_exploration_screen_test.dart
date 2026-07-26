import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Future<void> solveCluePuzzle(
    WidgetTester tester, {
    required String tooltip,
    required String keyPrefix,
    required int correctIndex,
    required String clueTitle,
  }) async {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('$keyPrefix-option-$correctIndex')), findsOneWidget);
    expect(find.text('✨ 새로운 단서 발견!'), findsNothing);

    await tester.tap(find.byKey(Key('$keyPrefix-option-$correctIndex')));
    await tester.pump();
    await tester.tap(find.byKey(Key('$keyPrefix-check')));
    await tester.pumpAndSettle();

    expect(find.text('✨ 새로운 단서 발견!'), findsOneWidget);
    expect(find.text(clueTitle), findsOneWidget);
    await tester.tap(find.textContaining('수첩에 저장'));
    await tester.pumpAndSettle();
  }

  Future<void> solveChestPuzzle(WidgetTester tester) async {
    await tester.tap(find.byTooltip('작은 돌 아래 조사'));
    await tester.pumpAndSettle();
    expect(find.text('🔑 낡은 별열쇠 발견!'), findsOneWidget);

    await tester.tap(find.text('열쇠 챙기기'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('분수대의 잠긴 상자 조사'));
    await tester.pumpAndSettle();
    expect(find.text('별빛 암호판'), findsOneWidget);

    for (final value in [1, 2, 3, 4, 6]) {
      await tester.tap(find.byKey(Key('factor-$value')));
      await tester.pump();
    }

    await tester.tap(find.byKey(const Key('check-puzzle-answer')));
    await tester.pumpAndSettle();
    expect(find.text('✨ 새로운 단서 발견!'), findsOneWidget);
    expect(find.text('상자 속 은빛 털'), findsOneWidget);

    await tester.tap(find.textContaining('수첩에 저장'));
    await tester.pumpAndSettle();
  }

  testWidgets('사건 현장의 핵심 단서 세 개를 문제와 함께 수집하고 다음 장면으로 이동한다',
      (tester) async {
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

    await solveCluePuzzle(
      tester,
      tooltip: '빈 별받침대 조사',
      keyPrefix: 'scratch-puzzle',
      correctIndex: 1,
      clueTitle: '오른쪽으로 난 긁힌 자국',
    );
    await solveCluePuzzle(
      tester,
      tooltip: '작은 발자국 조사',
      keyPrefix: 'footprints-puzzle',
      correctIndex: 2,
      clueTitle: '작고 둥근 발자국',
    );
    await solveChestPuzzle(tester);

    expect(find.text('단서 3/3'), findsOneWidget);
    expect(find.text('단서 3개를 모두 찾았어요!'), findsOneWidget);
    await tester.tap(find.text('연못으로 추적'));
    expect(continued, isTrue);
  });

  testWidgets('정답 전에는 단서가 수첩에 저장되지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );

    await tester.tap(find.byTooltip('빈 별받침대 조사'));
    await tester.pumpAndSettle();

    expect(find.text('별가루 묶음'), findsOneWidget);
    expect(find.text('단서 0/3'), findsOneWidget);
    expect(find.text('✨ 새로운 단서 발견!'), findsNothing);
  });

  testWidgets('단서 수첩은 찾은 단서와 잠긴 단서를 구분한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );

    await solveCluePuzzle(
      tester,
      tooltip: '빈 별받침대 조사',
      keyPrefix: 'scratch-puzzle',
      correctIndex: 1,
      clueTitle: '오른쪽으로 난 긁힌 자국',
    );
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
    expect(find.byTooltip('분수대의 잠긴 상자 조사'), findsOneWidget);
    expect(find.byTooltip('작은 돌 아래 조사'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
