import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rumi/app/app.dart';

void main() {
  testWidgets('스플래시 화면에 별정원 소개가 표시된다', (tester) async {
    await tester.pumpWidget(const RumiApp());

    expect(find.text('루미아의 별정원'), findsOneWidget);
    expect(find.text('마음속 작은 용기가 별이 되는 곳'), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });

  testWidgets('작은 화면에서도 스플래시 화면이 표시된다', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RumiApp());

    expect(find.text('루미아의 별정원'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
