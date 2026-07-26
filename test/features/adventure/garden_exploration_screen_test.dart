import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Widget buildScreen() {
    return MaterialApp(
      home: GardenExplorationScreen(onContinue: (_) {}),
    );
  }

  testWidgets('열쇠를 찾기 전에는 상자가 열리지 않는다', (tester) async {
    await tester.pumpWidget(buildScreen());

    await tester.tap(find.byTooltip('분수대의 잠긴 상자 조사'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('별 모양 열쇠구멍'), findsOneWidget);
    expect(find.text('별빛 암호판'), findsNothing);
  });

  testWidgets('열쇠를 찾은 뒤 상자에서 약수 퍼즐을 풀 수 있다', (tester) async {
    await tester.pumpWidget(buildScreen());

    await tester.tap(find.byTooltip('작은 돌 아래 조사'));
    await tester.pumpAndSettle();
    expect(find.text('🔑 낡은 별열쇠 발견!'), findsOneWidget);

    await tester.tap(find.text('열쇠 챙기기'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.key_rounded), findsWidgets);

    await tester.tap(find.byTooltip('분수대의 잠긴 상자 조사'));
    await tester.pumpAndSettle();
    expect(find.text('별빛 암호판'), findsOneWidget);
    expect(find.text('12의 약수를 모두 선택하세요.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('factor-5')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('check-puzzle-answer')));
    await tester.pump();
    expect(find.byKey(const Key('puzzle-feedback')), findsOneWidget);

    await tester.tap(find.byKey(const Key('factor-5')));
    await tester.pump();
    for (final value in [1, 2, 3, 4, 6]) {
      await tester.tap(find.byKey(Key('factor-$value')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('check-puzzle-answer')));
    await tester.pumpAndSettle();

    expect(find.text('✨ 새로운 단서 발견!'), findsOneWidget);
    expect(find.text('상자 속 은빛 털'), findsOneWidget);
  });

  testWidgets('작은 화면에서도 탐색 화면이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen());

    expect(find.text('사라진 별빛 씨앗'), findsOneWidget);
    expect(find.byTooltip('분수대의 잠긴 상자 조사'), findsOneWidget);
    expect(find.byTooltip('작은 돌 아래 조사'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
