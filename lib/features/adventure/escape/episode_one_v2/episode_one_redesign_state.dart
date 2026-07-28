import 'dart:collection';

import 'package:flutter/foundation.dart';

enum EpisodeOneRedesignActivity {
  fitFallenPiece,
  testTwelveGroups,
  findTwelveDivisors,
  pairTwelveFactors,
  orderTwelveDivisors,
  arrangeEighteen,
  removeDuplicatePairs,
  findMissingDivisor,
  removeNonDivisor,
  arrangeTwentyFour,
  findTwentyFourDivisors,
  rejectFalseRecord,
  chooseFootprintPath,
  orderEvidence,
}

enum EpisodeOneRedesignClue {
  fallenPiece,
  twelveStardust,
  eighteenScratches,
  twentyFourSeeds,
  roundFootprints,
  silverFur,
}

extension EpisodeOneRedesignClueMetadata on EpisodeOneRedesignClue {
  String get label => switch (this) {
    EpisodeOneRedesignClue.fallenPiece => '떨어진 받침대 조각',
    EpisodeOneRedesignClue.twelveStardust => '12개의 별가루 기록',
    EpisodeOneRedesignClue.eighteenScratches => '오른쪽으로 이어진 18개 긁힘',
    EpisodeOneRedesignClue.twentyFourSeeds => '24개의 별꽃 씨앗',
    EpisodeOneRedesignClue.roundFootprints => '씨앗 뒤에서 시작된 둥근 발자국',
    EpisodeOneRedesignClue.silverFur => '연못가의 젖은 은빛 털',
  };

  String get description => switch (this) {
    EpisodeOneRedesignClue.fallenPiece =>
      '조각은 받침대 오른쪽 홈에서 떨어졌고, 강한 바람이 장치를 흔들었다는 것을 보여줘요.',
    EpisodeOneRedesignClue.twelveStardust =>
      '12개의 별가루는 1·2·3·4·6·12개씩 남김없이 묶을 수 있었어요.',
    EpisodeOneRedesignClue.eighteenScratches =>
      '18개의 긁힘은 위로 들린 흔적이 아니라 받침대 오른쪽으로 밀린 흔적이에요.',
    EpisodeOneRedesignClue.twentyFourSeeds =>
      '쓰러진 화분의 씨앗 24개는 여러 개의 같은 배열을 만들 수 있었어요.',
    EpisodeOneRedesignClue.roundFootprints =>
      '발자국은 받침대에서 시작하지 않고 씨앗이 떨어진 자리 뒤에서 시작됐어요.',
    EpisodeOneRedesignClue.silverFur =>
      '젖은 은빛 털은 작은 생물이 반짝이는 연못 쪽으로 이동했음을 보여줘요.',
  };
}

extension EpisodeOneRedesignActivityMetadata on EpisodeOneRedesignActivity {
  String get sceneLabel => switch (this) {
    EpisodeOneRedesignActivity.fitFallenPiece => '중앙 정원',
    EpisodeOneRedesignActivity.testTwelveGroups ||
    EpisodeOneRedesignActivity.findTwelveDivisors ||
    EpisodeOneRedesignActivity.pairTwelveFactors ||
    EpisodeOneRedesignActivity.orderTwelveDivisors => '별받침대 내부',
    EpisodeOneRedesignActivity.arrangeEighteen ||
    EpisodeOneRedesignActivity.removeDuplicatePairs ||
    EpisodeOneRedesignActivity.findMissingDivisor ||
    EpisodeOneRedesignActivity.removeNonDivisor => '쓰러진 별꽃 화단',
    EpisodeOneRedesignActivity.arrangeTwentyFour ||
    EpisodeOneRedesignActivity.findTwentyFourDivisors ||
    EpisodeOneRedesignActivity.rejectFalseRecord => '정원사 도구 보관소',
    EpisodeOneRedesignActivity.chooseFootprintPath ||
    EpisodeOneRedesignActivity.orderEvidence => '반짝이는 연못 입구',
  };

  String get title => switch (this) {
    EpisodeOneRedesignActivity.fitFallenPiece => '떨어진 별조각',
    EpisodeOneRedesignActivity.testTwelveGroups => '남김없이 묶이는 수',
    EpisodeOneRedesignActivity.findTwelveDivisors => '12의 약수 받침대',
    EpisodeOneRedesignActivity.pairTwelveFactors => '깨진 곱셈 짝',
    EpisodeOneRedesignActivity.orderTwelveDivisors => '방향판 숫자 홈',
    EpisodeOneRedesignActivity.arrangeEighteen => '18개의 긁힌 별가루',
    EpisodeOneRedesignActivity.removeDuplicatePairs => '뒤집혀 적힌 기록',
    EpisodeOneRedesignActivity.findMissingDivisor => '6번 화분의 빈칸',
    EpisodeOneRedesignActivity.removeNonDivisor => '약수가 아닌 숫자 잎',
    EpisodeOneRedesignActivity.arrangeTwentyFour => '24개 씨앗 건조판',
    EpisodeOneRedesignActivity.findTwentyFourDivisors => '보관소의 여덟 잠금핀',
    EpisodeOneRedesignActivity.rejectFalseRecord => '잘못된 정원사 기록',
    EpisodeOneRedesignActivity.chooseFootprintPath => '진짜 발자국 경로',
    EpisodeOneRedesignActivity.orderEvidence => '사건 순서 복원',
  };

  String get objective => switch (this) {
    EpisodeOneRedesignActivity.fitFallenPiece =>
      '받침대 아래의 조각을 같은 모양의 홈에 맞춰 보세요.',
    EpisodeOneRedesignActivity.testTwelveGroups =>
      '12개의 별가루를 2·3·4·5개씩 묶어 보고 남는 수를 확인하세요.',
    EpisodeOneRedesignActivity.findTwelveDivisors =>
      '12개를 남김없이 놓을 수 있는 받침대를 모두 선택하세요.',
    EpisodeOneRedesignActivity.pairTwelveFactors =>
      '곱해서 12가 되는 세 쌍을 모두 연결하세요.',
    EpisodeOneRedesignActivity.orderTwelveDivisors =>
      '12의 약수를 작은 수부터 차례대로 눌러 방향판을 여세요.',
    EpisodeOneRedesignActivity.arrangeEighteen =>
      '18개의 흔적을 남김없이 같은 줄로 만들 수 있는 줄 수를 고르세요.',
    EpisodeOneRedesignActivity.removeDuplicatePairs =>
      '앞에서 이미 적힌 곱셈 짝을 뒤집어 쓴 기록을 골라 겹치세요.',
    EpisodeOneRedesignActivity.findMissingDivisor =>
      '1, 2, 3, □, 9, 18에서 빠진 약수를 찾으세요.',
    EpisodeOneRedesignActivity.removeNonDivisor =>
      '2, 3, 4, 6, 9 중 18의 약수가 아닌 숫자 잎을 제거하세요.',
    EpisodeOneRedesignActivity.arrangeTwentyFour =>
      '24개의 씨앗을 남김없이 배열할 수 있는 곱셈 짝을 모두 고르세요.',
    EpisodeOneRedesignActivity.findTwentyFourDivisors =>
      '24의 약수를 빠짐없이 선택해 여덟 잠금핀을 여세요.',
    EpisodeOneRedesignActivity.rejectFalseRecord =>
      '약수의 뜻과 맞지 않는 정원사의 기록을 찾으세요.',
    EpisodeOneRedesignActivity.chooseFootprintPath =>
      '24칸을 정확히 지나고 오른쪽 흔적과 일치하는 경로를 찾으세요.',
    EpisodeOneRedesignActivity.orderEvidence =>
      '발견한 증거를 시간 순서로 배열하고 확실한 결론을 고르세요.',
  };
}

@immutable
class EpisodeOneRedesignSnapshot {
  EpisodeOneRedesignSnapshot({
    required this.activityIndex,
    required Set<int> selectedNumbers,
    required Set<String> selectedTexts,
    required List<int> orderedNumbers,
    required List<int> timelineOrder,
    required Set<int> testedGroupSizes,
    required Set<EpisodeOneRedesignClue> clues,
    required this.activityErrors,
    required this.totalErrors,
    required this.hintLevel,
    required this.message,
    required this.completed,
    required this.challengeOpen,
    required this.challengeCompleted,
  }) : selectedNumbers = UnmodifiableSetView(selectedNumbers),
       selectedTexts = UnmodifiableSetView(selectedTexts),
       orderedNumbers = UnmodifiableListView(orderedNumbers),
       timelineOrder = UnmodifiableListView(timelineOrder),
       testedGroupSizes = UnmodifiableSetView(testedGroupSizes),
       clues = UnmodifiableSetView(clues);

  factory EpisodeOneRedesignSnapshot.initial() {
    return EpisodeOneRedesignSnapshot(
      activityIndex: 0,
      selectedNumbers: const {},
      selectedTexts: const {},
      orderedNumbers: const [],
      timelineOrder: const [],
      testedGroupSizes: const {},
      clues: const {},
      activityErrors: 0,
      totalErrors: 0,
      hintLevel: 0,
      message: '강한 은하 바람 뒤, 받침대 아래에서 반달 모양 조각이 흔들리고 있어요.',
      completed: false,
      challengeOpen: false,
      challengeCompleted: false,
    );
  }

  final int activityIndex;
  final Set<int> selectedNumbers;
  final Set<String> selectedTexts;
  final List<int> orderedNumbers;
  final List<int> timelineOrder;
  final Set<int> testedGroupSizes;
  final Set<EpisodeOneRedesignClue> clues;
  final int activityErrors;
  final int totalErrors;
  final int hintLevel;
  final String message;
  final bool completed;
  final bool challengeOpen;
  final bool challengeCompleted;

  EpisodeOneRedesignActivity get activity =>
      EpisodeOneRedesignActivity.values[activityIndex.clamp(0, 13)];

  int get completedActivityCount => completed ? 14 : activityIndex;

  String get progressLabel => completed
      ? '필수 활동 14/14'
      : '필수 활동 ${activityIndex + 1}/14';

  bool get supportSuggested => activityErrors >= 2;

  String get sceneLabel => completed ? '반짝이는 연못 입구' : activity.sceneLabel;

  String get title => completed ? '중앙 정원의 흔적을 찾았어요' : activity.title;

  String get objective => completed
      ? '연못 아래의 잠긴 수문이 다음 조사를 기다리고 있어요.'
      : activity.objective;

  EpisodeOneRedesignSnapshot copyWith({
    int? activityIndex,
    Set<int>? selectedNumbers,
    Set<String>? selectedTexts,
    List<int>? orderedNumbers,
    List<int>? timelineOrder,
    Set<int>? testedGroupSizes,
    Set<EpisodeOneRedesignClue>? clues,
    int? activityErrors,
    int? totalErrors,
    int? hintLevel,
    String? message,
    bool? completed,
    bool? challengeOpen,
    bool? challengeCompleted,
  }) {
    return EpisodeOneRedesignSnapshot(
      activityIndex: activityIndex ?? this.activityIndex,
      selectedNumbers: selectedNumbers ?? this.selectedNumbers,
      selectedTexts: selectedTexts ?? this.selectedTexts,
      orderedNumbers: orderedNumbers ?? this.orderedNumbers,
      timelineOrder: timelineOrder ?? this.timelineOrder,
      testedGroupSizes: testedGroupSizes ?? this.testedGroupSizes,
      clues: clues ?? this.clues,
      activityErrors: activityErrors ?? this.activityErrors,
      totalErrors: totalErrors ?? this.totalErrors,
      hintLevel: hintLevel ?? this.hintLevel,
      message: message ?? this.message,
      completed: completed ?? this.completed,
      challengeOpen: challengeOpen ?? this.challengeOpen,
      challengeCompleted: challengeCompleted ?? this.challengeCompleted,
    );
  }
}

class EpisodeOneRedesignController
    extends ValueNotifier<EpisodeOneRedesignSnapshot> {
  EpisodeOneRedesignController()
    : super(EpisodeOneRedesignSnapshot.initial());

  static const orderedTwelve = [1, 2, 3, 4, 6, 12];
  static const correctTimeline = [1, 2, 3, 4, 5];

  void reset() {
    value = EpisodeOneRedesignSnapshot.initial();
  }

  bool fitFallenPiece() {
    if (value.completed ||
        value.activity != EpisodeOneRedesignActivity.fitFallenPiece) {
      return false;
    }
    _advance(
      message: '조각이 맞춰지자 받침대 안에서 별가루 12개가 나타났어요.',
      clue: EpisodeOneRedesignClue.fallenPiece,
    );
    return true;
  }

  void testGroupSize(int size) {
    if (value.activity != EpisodeOneRedesignActivity.testTwelveGroups ||
        !const {2, 3, 4, 5}.contains(size)) {
      return;
    }
    final remainder = 12 % size;
    value = value.copyWith(
      testedGroupSizes: {...value.testedGroupSizes, size},
      message: remainder == 0
          ? '$size개씩 묶으니 별가루가 하나도 남지 않았어요.'
          : '$size개씩 묶으니 별가루가 $remainder개 남았어요. 이 수는 12의 약수가 아니에요.',
    );
  }

  void toggleNumber(int number) {
    if (value.completed && value.challengeOpen) {
      final selected = {...value.selectedNumbers};
      selected.contains(number) ? selected.remove(number) : selected.add(number);
      value = value.copyWith(selectedNumbers: selected);
      return;
    }
    final activity = value.activity;
    if (activity == EpisodeOneRedesignActivity.orderTwelveDivisors) {
      selectOrderedNumber(number);
      return;
    }
    if (activity == EpisodeOneRedesignActivity.findMissingDivisor ||
        activity == EpisodeOneRedesignActivity.removeNonDivisor ||
        activity == EpisodeOneRedesignActivity.chooseFootprintPath) {
      value = value.copyWith(selectedNumbers: {number});
      return;
    }
    final selected = {...value.selectedNumbers};
    selected.contains(number) ? selected.remove(number) : selected.add(number);
    value = value.copyWith(selectedNumbers: selected);
  }

  void toggleText(String text) {
    if (value.completed) return;
    final activity = value.activity;
    if (activity == EpisodeOneRedesignActivity.rejectFalseRecord ||
        activity == EpisodeOneRedesignActivity.orderEvidence) {
      value = value.copyWith(selectedTexts: {text});
      return;
    }
    final selected = {...value.selectedTexts};
    selected.contains(text) ? selected.remove(text) : selected.add(text);
    value = value.copyWith(selectedTexts: selected);
  }

  void selectOrderedNumber(int number) {
    if (value.activity != EpisodeOneRedesignActivity.orderTwelveDivisors) return;
    final expectedIndex = value.orderedNumbers.length;
    if (expectedIndex >= orderedTwelve.length) return;
    if (number != orderedTwelve[expectedIndex]) {
      _recordError('작은 수부터 살펴보세요. 곱셈 짝을 따라가면 빠뜨리지 않을 수 있어요.');
      return;
    }
    value = value.copyWith(
      orderedNumbers: [...value.orderedNumbers, number],
      message: number == 12
          ? '모든 숫자 홈이 채워졌어요. 방향판을 작동시켜 보세요.'
          : '$number을(를) 올바른 자리에 놓았어요.',
    );
  }

  void selectTimelineCard(int card) {
    if (value.activity != EpisodeOneRedesignActivity.orderEvidence ||
        card < 1 ||
        card > 5 ||
        value.timelineOrder.contains(card)) {
      return;
    }
    final expected = correctTimeline[value.timelineOrder.length];
    if (card != expected) {
      _recordError('그 일보다 먼저 일어난 흔적이 있어요. 받침대에서 시작해 다시 살펴보세요.');
      return;
    }
    value = value.copyWith(
      timelineOrder: [...value.timelineOrder, card],
      message: card == 5
          ? '사건 순서를 모두 복원했어요. 이제 확실히 말할 수 있는 결론을 고르세요.'
          : '증거 카드 $card번을 올바른 순서에 놓았어요.',
    );
  }

  bool submitCurrent() {
    if (value.completed) return false;
    return switch (value.activity) {
      EpisodeOneRedesignActivity.fitFallenPiece => fitFallenPiece(),
      EpisodeOneRedesignActivity.testTwelveGroups => _submitGroupExperiment(),
      EpisodeOneRedesignActivity.findTwelveDivisors => _submitNumbers(
        const {1, 2, 3, 4, 6, 12},
        '12개를 남김없이 놓을 수 있는 여섯 받침대가 모두 빛났어요.',
      ),
      EpisodeOneRedesignActivity.pairTwelveFactors => _submitTexts(
        const {'1×12', '2×6', '3×4'},
        '세 곱셈 짝이 맞물리며 받침대의 두 번째 고리가 열렸어요.',
      ),
      EpisodeOneRedesignActivity.orderTwelveDivisors =>
        _submitOrderedTwelve(),
      EpisodeOneRedesignActivity.arrangeEighteen => _submitNumbers(
        const {1, 2, 3, 6, 9, 18},
        '18개의 흔적이 가능한 배열마다 같은 방향을 가리켰어요.',
      ),
      EpisodeOneRedesignActivity.removeDuplicatePairs => _submitTexts(
        const {'6×3', '9×2', '18×1'},
        '뒤집어 적힌 세 기록을 겹치자 곱셈 짝이 세 개로 정리됐어요.',
      ),
      EpisodeOneRedesignActivity.findMissingDivisor => _submitNumbers(
        const {6},
        '빠진 수 6을 넣자 6번 화분의 잠금이 풀렸어요.',
      ),
      EpisodeOneRedesignActivity.removeNonDivisor => _submitNumbers(
        const {4},
        '18개를 4개씩 묶으면 2개가 남았어요. 숫자 잎 4를 제거했어요.',
        clue: EpisodeOneRedesignClue.eighteenScratches,
      ),
      EpisodeOneRedesignActivity.arrangeTwentyFour => _submitTexts(
        const {'1×24', '2×12', '3×8', '4×6'},
        '24개의 씨앗이 네 가지 직사각형 배열을 만들었어요.',
      ),
      EpisodeOneRedesignActivity.findTwentyFourDivisors => _submitNumbers(
        const {1, 2, 3, 4, 6, 8, 12, 24},
        '여덟 약수 홈이 모두 채워지며 도구 보관소가 열렸어요.',
        clue: EpisodeOneRedesignClue.twentyFourSeeds,
      ),
      EpisodeOneRedesignActivity.rejectFalseRecord => _submitTexts(
        const {'C'},
        '작다는 이유만으로 약수가 될 수는 없어요. 잘못된 기록 뒤에서 발자국 판을 찾았어요.',
      ),
      EpisodeOneRedesignActivity.chooseFootprintPath => _submitNumbers(
        const {6},
        '6칸 경로는 24칸을 남김없이 지나며 오른쪽 긁힘 방향과도 일치했어요.',
        clue: EpisodeOneRedesignClue.roundFootprints,
      ),
      EpisodeOneRedesignActivity.orderEvidence => _submitEvidence(),
    };
  }

  void requestHint() {
    if (value.completed) return;
    final nextLevel = (value.hintLevel + 1).clamp(1, 3);
    value = value.copyWith(
      hintLevel: nextLevel,
      message: _hintFor(value.activity, nextLevel),
    );
  }

  void openChallenge() {
    if (!value.completed || value.challengeCompleted) return;
    value = value.copyWith(
      challengeOpen: true,
      selectedNumbers: const {},
      message: '도전 기록: 30의 약수를 모두 찾아 정원사의 별도장을 완성하세요.',
    );
  }

  bool submitChallenge() {
    if (!value.completed || !value.challengeOpen) return false;
    const expected = {1, 2, 3, 5, 6, 10, 15, 30};
    if (!setEquals(value.selectedNumbers, expected)) {
      value = value.copyWith(
        message: '30이 되는 곱셈 짝을 1부터 차례로 확인해 보세요.',
      );
      return false;
    }
    value = value.copyWith(
      challengeOpen: false,
      challengeCompleted: true,
      selectedNumbers: const {},
      message: '30의 약수를 모두 찾아 정원사의 별도장을 완성했어요!',
    );
    return true;
  }

  bool _submitGroupExperiment() {
    if (!value.testedGroupSizes.containsAll(const {2, 3, 4, 5})) {
      _recordError('2·3·4·5개씩 묶는 실험을 모두 해 보세요. 남는 별가루도 중요한 단서예요.');
      return false;
    }
    _advance(message: '2·3·4개씩은 남지 않았고, 5개씩은 2개가 남았어요.');
    return true;
  }

  bool _submitNumbers(
    Set<int> expected,
    String successMessage, {
    EpisodeOneRedesignClue? clue,
  }) {
    if (!setEquals(value.selectedNumbers, expected)) {
      _recordError('선택한 수로 실제 물건을 나누었을 때 남는 것이 없는지 다시 확인해 보세요.');
      return false;
    }
    _advance(message: successMessage, clue: clue);
    return true;
  }

  bool _submitTexts(Set<String> expected, String successMessage) {
    if (!setEquals(value.selectedTexts, expected)) {
      _recordError('곱해서 원래 수가 되는지, 또는 앞에서 이미 본 짝인지 다시 확인해 보세요.');
      return false;
    }
    _advance(message: successMessage);
    return true;
  }

  bool _submitOrderedTwelve() {
    if (!listEquals(value.orderedNumbers, orderedTwelve)) {
      _recordError('12의 약수를 작은 수부터 모두 놓아야 방향판이 움직여요.');
      return false;
    }
    _advance(
      message: '방향판이 오른쪽을 가리키며 화단 쪽 별길이 밝아졌어요.',
      clue: EpisodeOneRedesignClue.twelveStardust,
    );
    return true;
  }

  bool _submitEvidence() {
    if (!listEquals(value.timelineOrder, correctTimeline)) {
      _recordError('증거 카드를 먼저 시간 순서로 모두 놓아 보세요.');
      return false;
    }
    if (!setEquals(value.selectedTexts, const {'B'})) {
      _recordError('확인한 사실과 아직 확인하지 못한 추측을 구분해 보세요.');
      return false;
    }
    value = value.copyWith(
      selectedNumbers: const {},
      selectedTexts: const {},
      clues: {...value.clues, EpisodeOneRedesignClue.silverFur},
      completed: true,
      activityErrors: 0,
      hintLevel: 0,
      message: '씨앗이 먼저 떨어졌고 작은 생물이 그 뒤를 따라갔어요. 연못가에서 젖은 은빛 털도 발견했어요.',
    );
    return true;
  }

  void _recordError(String message) {
    final errors = value.activityErrors + 1;
    value = value.copyWith(
      activityErrors: errors,
      totalErrors: value.totalErrors + 1,
      message: errors >= 2
          ? '$message 꽃루미의 힌트를 열어도 진행이나 보상은 줄지 않아요.'
          : message,
    );
  }

  void _advance({
    required String message,
    EpisodeOneRedesignClue? clue,
  }) {
    final nextIndex = value.activityIndex + 1;
    value = value.copyWith(
      activityIndex: nextIndex.clamp(0, 13),
      selectedNumbers: const {},
      selectedTexts: const {},
      orderedNumbers: const [],
      timelineOrder: const [],
      testedGroupSizes: const {},
      clues: clue == null ? value.clues : {...value.clues, clue},
      activityErrors: 0,
      hintLevel: 0,
      message: message,
    );
  }

  String _hintFor(EpisodeOneRedesignActivity activity, int level) {
    final hints = switch (activity) {
      EpisodeOneRedesignActivity.fitFallenPiece => const [
        '받침대 아래에서 다른 모양의 물건을 찾아보세요.',
        '반달 모양 조각과 받침대 오른쪽 홈을 비교해 보세요.',
        '화면의 떨어진 별조각을 눌러 홈에 맞추세요.',
      ],
      EpisodeOneRedesignActivity.testTwelveGroups => const [
        '별가루가 남는지 확인하는 것이 목표예요.',
        '12를 2·3·4·5로 각각 나눈 나머지를 살펴보세요.',
        '2, 3, 4는 남지 않고 5는 2가 남아요.',
      ],
      EpisodeOneRedesignActivity.findTwelveDivisors => const [
        '12개를 남김없이 놓을 수 있는 칸 수를 찾으세요.',
        '곱해서 12가 되는 두 수를 찾아보세요.',
        '1·2·3·4·6·12를 선택하세요.',
      ],
      EpisodeOneRedesignActivity.pairTwelveFactors => const [
        '각 카드의 두 수를 곱해 보세요.',
        '작은 수 1, 2, 3부터 짝을 찾아보세요.',
        '1×12, 2×6, 3×4를 선택하세요.',
      ],
      EpisodeOneRedesignActivity.orderTwelveDivisors => const [
        '찾은 약수를 작은 수부터 놓으세요.',
        '1 다음에는 2, 3, 4가 이어져요.',
        '1, 2, 3, 4, 6, 12 순서예요.',
      ],
      EpisodeOneRedesignActivity.arrangeEighteen => const [
        '18개가 남지 않는 줄 수를 찾으세요.',
        '곱해서 18이 되는 수를 모두 떠올려 보세요.',
        '1·2·3·6·9·18을 선택하세요.',
      ],
      EpisodeOneRedesignActivity.removeDuplicatePairs => const [
        '곱셈 순서만 바뀐 카드를 찾으세요.',
        '1×18의 뒤집힌 카드는 18×1이에요.',
        '6×3, 9×2, 18×1을 선택하세요.',
      ],
      EpisodeOneRedesignActivity.findMissingDivisor => const [
        '3과 9 사이의 약수가 비어 있어요.',
        '3과 짝이 되어 18이 되는 수를 찾으세요.',
        '정답은 6이에요.',
      ],
      EpisodeOneRedesignActivity.removeNonDivisor => const [
        '18을 나누었을 때 남는 수를 찾으세요.',
        '18을 4개씩 묶으면 2개가 남아요.',
        '숫자 잎 4를 선택하세요.',
      ],
      EpisodeOneRedesignActivity.arrangeTwentyFour => const [
        '곱해서 24가 되는 배열만 고르세요.',
        '1, 2, 3, 4부터 각각의 짝을 찾으세요.',
        '1×24, 2×12, 3×8, 4×6이에요.',
      ],
      EpisodeOneRedesignActivity.findTwentyFourDivisors => const [
        '앞에서 만든 네 곱셈 짝의 모든 수를 모으세요.',
        '각 곱셈 카드의 왼쪽과 오른쪽 수를 모두 선택하세요.',
        '1·2·3·4·6·8·12·24를 선택하세요.',
      ],
      EpisodeOneRedesignActivity.rejectFalseRecord => const [
        '약수는 단순히 원래 수보다 작은 수가 아니에요.',
        '나누어떨어지거나 곱셈 짝을 이루는 설명인지 확인하세요.',
        '기록 C가 잘못됐어요.',
      ],
      EpisodeOneRedesignActivity.chooseFootprintPath => const [
        '24칸을 남김없이 지나야 해요.',
        '4와 6은 가능하지만, 앞에서 본 긁힘은 오른쪽의 6칸 길을 가리켜요.',
        '6칸마다 이어지는 경로를 선택하세요.',
      ],
      EpisodeOneRedesignActivity.orderEvidence => const [
        '바람이 먼저였고 발자국은 씨앗이 떨어진 뒤에 생겼어요.',
        '카드를 1부터 5까지 놓은 뒤, 확인한 사실만 고르세요.',
        '순서는 1·2·3·4·5이고 결론은 B예요.',
      ],
    };
    return hints[level - 1];
  }
}
