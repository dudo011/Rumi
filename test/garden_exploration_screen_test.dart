import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  testWidgets('캐릭터를 움직여 중앙 정원의 세 조사 대상을 발견한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var continued = false;
    await tester.pumpWidget(
      MaterialApp(
        home: GardenExplorationScreen(
          onContinue: (_) => continued = true,
        ),
      ),
    );

    expect(find.text('발견 0/3'), findsOneWidget);
    await tester.tap(find.byTooltip('조사하기'));
    await tester.pump();
    expect(find.textContaining('꽃루미: 기다렸어'), findsOneWidget);

    for (var index = 0; index < 10; index++) {
      await tester.tap(find.byTooltip('위로 이동'));
      await tester.pump();
    }
    await tester.tap(find.byTooltip('조사하기'));
    await tester.pump();
    expect(find.textContaining('빈 별받침대'), findsOneWidget);

    for (var index = 0; index < 6; index++) {
      await tester.tap(find.byTooltip('오른쪽으로 이동'));
      await tester.pump();
    }
    for (var index = 0; index < 4; index++) {
      await tester.tap(find.byTooltip('위로 이동'));
      await tester.pump();
    }
    await tester.tap(find.byTooltip('조사하기'));
    await tester.pump();

    expect(find.text('발견 3/3'), findsOneWidget);
    expect(find.text('중앙 정원의 흔적을 모두 찾았어요!'), findsOneWidget);
    await tester.tap(find.text('연못으로'));
    expect(continued, isTrue);
  });

  testWidgets('방향 패드와 조사 버튼은 명확한 조작 이름을 제공한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GardenExplorationScreen(onContinue: (_) {}),
      ),
    );

    expect(find.byTooltip('위로 이동'), findsOneWidget);
    expect(find.byTooltip('아래로 이동'), findsOneWidget);
    expect(find.byTooltip('왼쪽으로 이동'), findsOneWidget);
    expect(find.byTooltip('오른쪽으로 이동'), findsOneWidget);
    expect(find.byTooltip('조사하기'), findsOneWidget);
    expect(find.bySemanticsLabel('플레이어 캐릭터'), findsOneWidget);
  });
}
