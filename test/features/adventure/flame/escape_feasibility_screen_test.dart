import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rumi/features/adventure/flame/escape_feasibility_screen.dart';

void main() {
  test('기술 검증 상태는 초기 인벤토리와 진행 메시지를 보존한다', () {
    const state = EscapeLabState(
      inventory: {EscapeLabItem.flower},
      selected: null,
      message: '등불을 조사하세요.',
      completed: {},
      inputLocked: false,
      lifecycle: '실행 중',
    );

    expect(state.inventory, contains(EscapeLabItem.flower));
    expect(state.selected, isNull);
    expect(state.inputLocked, isFalse);
    expect(state.message, '등불을 조사하세요.');
  });

  test('기술 검증 화면은 독립 StatefulWidget으로 제공된다', () {
    expect(const EscapeFeasibilityScreen(), isA<StatefulWidget>());
  });
}
