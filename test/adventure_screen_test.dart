import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/adventure_screen.dart';
import 'package:rumi/features/adventure/question_bank.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'player_nickname': '별하'});
  });

  testWidgets('힌트를 보고 문제를 풀면 결과와 경험치를 보여준다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdventureScreen(questions: [divisorMultipleQuestions.first]),
      ),
    );

    await tester.tap(find.text('힌트 보기'));
    await tester.pump();
    expect(find.textContaining('12를 나누어떨어지게'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('정답 확인'));
    await tester.pump();
    expect(find.text('멋져요! 용기 있게 풀어냈어요.'), findsOneWidget);

    await tester.tap(find.text('모험 완료'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 모험 완료!'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('+30 XP'), findsOneWidget);
  });
}
