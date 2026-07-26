import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/question_bank.dart';

void main() {
  test('약수와 배수 문제 은행은 15개의 유효한 문제를 제공한다', () {
    expect(divisorMultipleQuestions, hasLength(15));

    for (final question in divisorMultipleQuestions) {
      expect(question.options, hasLength(4));
      expect(question.correctIndex, inInclusiveRange(0, 3));
      expect(question.hints.length, greaterThanOrEqualTo(2));
      expect(question.explanation, isNotEmpty);
    }
  });
}
