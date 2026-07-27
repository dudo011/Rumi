import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rumi/features/adventure/flame/escape_feasibility_screen.dart';

void main() {
  testWidgets('Flame 방탈출 기술 검증 화면은 인벤토리와 힌트 오버레이를 제공한다',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: EscapeFeasibilityScreen()),
    );
    await tester.pump();

    expect(find.text('Flame 방탈출 기술 검증실'), findsOneWidget);
    expect(find.text('가방'), findsOneWidget);
    expect(find.text('꽃잎'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('escape-lab-hint')));
    await tester.pump();

    expect(find.text('기술 검증 힌트'), findsOneWidget);
    expect(find.byKey(const Key('escape-lab-hint-close')), findsOneWidget);

    await tester.tap(find.byKey(const Key('escape-lab-hint-close')));
    await tester.pump();
    expect(find.text('기술 검증 힌트'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
