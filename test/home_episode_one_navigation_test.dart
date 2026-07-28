import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rumi/features/home/home_screen.dart';

void main() {
  testWidgets('메인 화면에서 연쇄 방탈출 Episode 1로 직접 이동한다', (tester) async {
    SharedPreferences.setMockInitialValues({'player_nickname': '루나'});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('사건 조사하기'), findsOneWidget);
    expect(find.text('연쇄 퍼즐 4개'), findsOneWidget);
    await tester.tap(find.text('사건 조사하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('episode-one-v3-screen')), findsOneWidget);
    expect(find.byKey(const Key('episode-one-v3-undo')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    expect(find.byKey(const Key('episode-one-v2-screen')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
