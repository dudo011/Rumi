import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rumi/app/app.dart';
import 'package:rumi/features/onboarding/nickname_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('스플래시 화면에 별정원 소개가 표시된다', (tester) async {
    await tester.pumpWidget(const RumiApp());

    expect(find.text('루미아의 별정원'), findsOneWidget);
    expect(find.text('마음속 작은 용기가 별이 되는 곳'), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('작은 화면에서도 스플래시 화면이 표시된다', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const RumiApp());

    expect(find.text('루미아의 별정원'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('스플래시 후 닉네임 입력 화면으로 이동한다', (tester) async {
    await tester.pumpWidget(const RumiApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.byType(NicknameScreen), findsOneWidget);
    expect(find.text('별지기님을 만나서 반가워요!'), findsOneWidget);
    expect(find.text('닉네임 입력'), findsOneWidget);
  });

  testWidgets('올바른 닉네임을 입력하면 꽃루미를 만난다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NicknameScreen()),
    );

    final button = find.widgetWithText(FilledButton, '별지기 시작하기');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '별하');
    await tester.pump();

    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('별하 별지기님, 안녕!'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('player_nickname'), '별하');

    await tester.tap(find.text('꽃루미와 함께하기'));
    await tester.pumpAndSettle();
    expect(find.text('별하 별지기님'), findsOneWidget);
    expect(find.text('사라진 별빛 씨앗'), findsOneWidget);
  });

  testWidgets('저장된 닉네임이 있으면 메인 화면으로 이동한다', (tester) async {
    SharedPreferences.setMockInitialValues({'player_nickname': '루나'});
    await tester.pumpWidget(const RumiApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('루나 별지기님'), findsOneWidget);
    expect(find.text('사라진 별빛 씨앗'), findsOneWidget);
  });
}
