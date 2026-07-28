import 'dart:collection';

import 'package:flutter/foundation.dart';

enum EpisodeOneV3Stage {
  identifyFragment,
  testTwelveGroups,
  revealTwelveDivisors,
  pairTwelveFactors,
  orderTwelveDivisors,
  identifyFlowerpot,
  assembleScratches,
  arrangeEighteen,
  removeDuplicateEighteen,
  findMissingEighteen,
  rejectNonDivisorEighteen,
  arrangeTwentyFour,
  mapTwentyFourPins,
  orderStorageGlyphs,
  rejectFalseRecord,
  useTraceFilters,
  chooseTrackStart,
  testTrackIntervals,
  connectFootprints,
  orderEvidence,
  chooseConclusion,
  completed,
}

enum EpisodeOneV3Clue {
  fallenPiece,
  twelveStardust,
  eighteenScratches,
  twentyFourSeeds,
  roundFootprints,
  silverFur,
}

enum EpisodeOneV3Item {
  rightLeafGlyph,
  twentyFourSeeds,
  dewLens,
  leafStencil,
  starlightLamp,
}

extension EpisodeOneV3ClueMetadata on EpisodeOneV3Clue {
  String get label => switch (this) {
    EpisodeOneV3Clue.fallenPiece => '떨어진 받침대 조각',
    EpisodeOneV3Clue.twelveStardust => '12개의 별가루 기록',
    EpisodeOneV3Clue.eighteenScratches => '오른쪽으로 이어진 18개 긁힘',
    EpisodeOneV3Clue.twentyFourSeeds => '24개의 별꽃 씨앗',
    EpisodeOneV3Clue.roundFootprints => '씨앗 뒤에서 시작된 둥근 발자국',
    EpisodeOneV3Clue.silverFur => '연못가의 젖은 은빛 털',
  };

  String get description => switch (this) {
    EpisodeOneV3Clue.fallenPiece =>
      '받침대 오른쪽 홈에서 떨어진 조각이에요. 강한 바람이 장치를 흔든 흔적이 남아 있어요.',
    EpisodeOneV3Clue.twelveStardust =>
      '별가루 12개는 1·2·3·4·6·12개씩 남김없이 배열할 수 있었고 장치는 오른쪽을 가리켰어요.',
    EpisodeOneV3Clue.eighteenScratches =>
      '화분과 바닥에 흩어진 긁힘 18개를 복원하자 씨앗이 오른쪽으로 밀린 방향이 드러났어요.',
    EpisodeOneV3Clue.twentyFourSeeds =>
      '별꽃 씨앗 24개는 1×24, 2×12, 3×8, 4×6 배열을 만들 수 있었어요.',
    EpisodeOneV3Clue.roundFootprints =>
      '작은 둥근 발자국은 받침대 아래가 아니라 씨앗이 떨어진 지점 뒤에서 시작했어요.',
    EpisodeOneV3Clue.silverFur =>
      '오른쪽의 젖은 돌 끝에서 은빛 털이 발견됐어요. 작은 생물이 연못 쪽으로 이동한 흔적이에요.',
  };
}

extension EpisodeOneV3ItemMetadata on EpisodeOneV3Item {
  String get label => switch (this) {
    EpisodeOneV3Item.rightLeafGlyph => '오른쪽 여섯 잎 문양',
    EpisodeOneV3Item.twentyFourSeeds => '별꽃 씨앗 24개',
    EpisodeOneV3Item.dewLens => '물방울 렌즈',
    EpisodeOneV3Item.leafStencil => '잎사귀 흔적틀',
    EpisodeOneV3Item.starlightLamp => '별가루 조명',
  };
}

extension EpisodeOneV3StageMetadata on EpisodeOneV3Stage {
  String get sceneLabel => switch (this) {
    EpisodeOneV3Stage.identifyFragment ||
    EpisodeOneV3Stage.testTwelveGroups ||
    EpisodeOneV3Stage.revealTwelveDivisors ||
    EpisodeOneV3Stage.pairTwelveFactors ||
    EpisodeOneV3Stage.orderTwelveDivisors => '중앙 정원 · 별받침대',
    EpisodeOneV3Stage.identifyFlowerpot ||
    EpisodeOneV3Stage.assembleScratches ||
    EpisodeOneV3Stage.arrangeEighteen ||
    EpisodeOneV3Stage.removeDuplicateEighteen ||
    EpisodeOneV3Stage.findMissingEighteen ||
    EpisodeOneV3Stage.rejectNonDivisorEighteen => '쓰러진 별꽃 화단',
    EpisodeOneV3Stage.arrangeTwentyFour ||
    EpisodeOneV3Stage.mapTwentyFourPins ||
    EpisodeOneV3Stage.orderStorageGlyphs ||
    EpisodeOneV3Stage.rejectFalseRecord => '정원사 도구 보관소',
    EpisodeOneV3Stage.useTraceFilters ||
    EpisodeOneV3Stage.chooseTrackStart ||
    EpisodeOneV3Stage.testTrackIntervals ||
    EpisodeOneV3Stage.connectFootprints ||
    EpisodeOneV3Stage.orderEvidence ||
    EpisodeOneV3Stage.chooseConclusion ||
    EpisodeOneV3Stage.completed => '반짝이는 연못 입구',
  };

  String get title => switch (this) {
    EpisodeOneV3Stage.identifyFragment => '멈춘 받침대의 빈 홈',
    EpisodeOneV3Stage.testTwelveGroups => '별가루가 남기는 반응',
    EpisodeOneV3Stage.revealTwelveDivisors => '빛난 별자리 조각',
    EpisodeOneV3Stage.pairTwelveFactors => '깨진 회전판',
    EpisodeOneV3Stage.orderTwelveDivisors => '별자리 읽는 순서',
    EpisodeOneV3Stage.identifyFlowerpot => '여섯 화분의 문양',
    EpisodeOneV3Stage.assembleScratches => '세 곳에 흩어진 긁힘',
    EpisodeOneV3Stage.arrangeEighteen => '복원된 흔적판',
    EpisodeOneV3Stage.removeDuplicateEighteen => '뒤집힌 정원사 기록',
    EpisodeOneV3Stage.findMissingEighteen => '지워진 곱셈 짝',
    EpisodeOneV3Stage.rejectNonDivisorEighteen => '화분 속 숫자 잎',
    EpisodeOneV3Stage.arrangeTwentyFour => '씨앗 건조판',
    EpisodeOneV3Stage.mapTwentyFourPins => '여덟 개의 잠금핀',
    EpisodeOneV3Stage.orderStorageGlyphs => '문양 암호의 순서',
    EpisodeOneV3Stage.rejectFalseRecord => '의심스러운 정원사 기록',
    EpisodeOneV3Stage.useTraceFilters => '겹쳐진 세 종류의 흔적',
    EpisodeOneV3Stage.chooseTrackStart => '발자국의 시작점',
    EpisodeOneV3Stage.testTrackIntervals => '24개의 별돌',
    EpisodeOneV3Stage.connectFootprints => '젖은 발자국 연결',
    EpisodeOneV3Stage.orderEvidence => '사건의 시간 순서',
    EpisodeOneV3Stage.chooseConclusion => '증거와 추측',
    EpisodeOneV3Stage.completed => '중앙 정원의 흔적을 밝혔어요',
  };

  String get objective => switch (this) {
    EpisodeOneV3Stage.identifyFragment => '주변 물체를 조사해 받침대 오른쪽 홈에 맞는 조각을 찾으세요.',
    EpisodeOneV3Stage.testTwelveGroups => '네 묶음판을 모두 시험하고 별가루가 남는 방식을 기록하세요.',
    EpisodeOneV3Stage.revealTwelveDivisors => '실험과 벽화를 함께 보고 빛나야 할 별자리 조각을 찾으세요.',
    EpisodeOneV3Stage.pairTwelveFactors => '같은 별가루 수를 만드는 문양끼리 마주 보게 연결하세요.',
    EpisodeOneV3Stage.orderTwelveDivisors => '작은 별에서 큰 별로 이어지는 길을 복원하세요.',
    EpisodeOneV3Stage.identifyFlowerpot => '받침대가 남긴 문양과 같은 화분을 찾아보세요.',
    EpisodeOneV3Stage.assembleScratches => '화분 테두리·흙·바닥의 흔적 조각을 하나로 겹치세요.',
    EpisodeOneV3Stage.arrangeEighteen => '복원한 흔적이 남김없이 들어가는 배열을 모두 시험하세요.',
    EpisodeOneV3Stage.removeDuplicateEighteen => '바람 방향 때문에 뒤집혀 기록된 같은 배열을 겹쳐 보세요.',
    EpisodeOneV3Stage.findMissingEighteen => '지워진 곱셈 짝을 복원해 잠긴 화분을 찾으세요.',
    EpisodeOneV3Stage.rejectNonDivisorEighteen => '흔적을 남김없이 나누지 못하는 숫자 잎을 찾아내세요.',
    EpisodeOneV3Stage.arrangeTwentyFour => '24개의 씨앗이 빈칸 없이 들어가는 건조판을 모두 찾으세요.',
    EpisodeOneV3Stage.mapTwentyFourPins => '네 건조판의 두 변을 이용해 여덟 잠금핀을 밝히세요.',
    EpisodeOneV3Stage.orderStorageGlyphs => '이전 단서로 네 문양을 누를 순서를 결정하세요.',
    EpisodeOneV3Stage.rejectFalseRecord => '의심스러운 기록을 실제 씨앗 배열로 검증하세요.',
    EpisodeOneV3Stage.useTraceFilters => '세 도구를 사용해 씨앗선·젖은 발자국·장화 자국을 분리하세요.',
    EpisodeOneV3Stage.chooseTrackStart => '사건 순서와 맞는 둥근 발자국의 시작점을 표시하세요.',
    EpisodeOneV3Stage.testTrackIntervals => '4·5·6칸 간격을 모두 시험해 끝까지 이어지는 후보를 남기세요.',
    EpisodeOneV3Stage.connectFootprints => '수학 조건과 현장 단서를 모두 만족하는 발자국만 순서대로 연결하세요.',
    EpisodeOneV3Stage.orderEvidence => '발견한 다섯 사건 카드를 원인과 결과에 맞게 배열하세요.',
    EpisodeOneV3Stage.chooseConclusion => '확인된 증거만으로 말할 수 있는 결론을 고르세요.',
    EpisodeOneV3Stage.completed => '연못 아래의 잠긴 수문이 다음 조사를 기다리고 있어요.',
  };
}

@immutable
class EpisodeOneV3Snapshot {
  EpisodeOneV3Snapshot({
    required this.stage,
    required Set<int> selectedNumbers,
    required Set<String> selectedTexts,
    required List<int> orderedNumbers,
    required List<String> orderedTexts,
    required Set<int> testedValues,
    required Set<String> activeFilters,
    required List<int> trackPath,
    required List<String> evidenceOrder,
    required Set<int> completedActivities,
    required Set<EpisodeOneV3Clue> clues,
    required Set<EpisodeOneV3Item> inventory,
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
       orderedTexts = UnmodifiableListView(orderedTexts),
       testedValues = UnmodifiableSetView(testedValues),
       activeFilters = UnmodifiableSetView(activeFilters),
       trackPath = UnmodifiableListView(trackPath),
       evidenceOrder = UnmodifiableListView(evidenceOrder),
       completedActivities = UnmodifiableSetView(completedActivities),
       clues = UnmodifiableSetView(clues),
       inventory = UnmodifiableSetView(inventory);

  factory EpisodeOneV3Snapshot.initial() {
    return EpisodeOneV3Snapshot(
      stage: EpisodeOneV3Stage.identifyFragment,
      selectedNumbers: const {},
      selectedTexts: const {},
      orderedNumbers: const [],
      orderedTexts: const [],
      testedValues: const {},
      activeFilters: const {},
      trackPath: const [],
      evidenceOrder: const [],
      completedActivities: const {},
      clues: const {},
      inventory: const {},
      activityErrors: 0,
      totalErrors: 0,
      hintLevel: 0,
      message: '강한 은하 바람 뒤, 별받침대 오른쪽 홈이 비어 있어요. 주변 물체의 모양과 긁힘을 비교해 보세요.',
      completed: false,
      challengeOpen: false,
      challengeCompleted: false,
    );
  }

  final EpisodeOneV3Stage stage;
  final Set<int> selectedNumbers;
  final Set<String> selectedTexts;
  final List<int> orderedNumbers;
  final List<String> orderedTexts;
  final Set<int> testedValues;
  final Set<String> activeFilters;
  final List<int> trackPath;
  final List<String> evidenceOrder;
  final Set<int> completedActivities;
  final Set<EpisodeOneV3Clue> clues;
  final Set<EpisodeOneV3Item> inventory;
  final int activityErrors;
  final int totalErrors;
  final int hintLevel;
  final String message;
  final bool completed;
  final bool challengeOpen;
  final bool challengeCompleted;

  int get macroPuzzleIndex {
    final index = stage.index;
    if (index <= EpisodeOneV3Stage.orderTwelveDivisors.index) return 1;
    if (index <= EpisodeOneV3Stage.rejectNonDivisorEighteen.index) return 2;
    if (index <= EpisodeOneV3Stage.rejectFalseRecord.index) return 3;
    return 4;
  }

  String get macroProgressLabel => completed ? '대형 퍼즐 4/4' : '대형 퍼즐 $macroPuzzleIndex/4';

  String get learningProgressLabel => '학습 활동 ${completedActivities.length}/14';

  bool get supportSuggested => activityErrors >= 2;

  bool get canUndoCurrentInput =>
      selectedNumbers.isNotEmpty ||
      selectedTexts.isNotEmpty ||
      orderedNumbers.isNotEmpty ||
      orderedTexts.isNotEmpty ||
      testedValues.isNotEmpty ||
      activeFilters.isNotEmpty ||
      trackPath.isNotEmpty ||
      evidenceOrder.isNotEmpty;

  EpisodeOneV3Snapshot copyWith({
    EpisodeOneV3Stage? stage,
    Set<int>? selectedNumbers,
    Set<String>? selectedTexts,
    List<int>? orderedNumbers,
    List<String>? orderedTexts,
    Set<int>? testedValues,
    Set<String>? activeFilters,
    List<int>? trackPath,
    List<String>? evidenceOrder,
    Set<int>? completedActivities,
    Set<EpisodeOneV3Clue>? clues,
    Set<EpisodeOneV3Item>? inventory,
    int? activityErrors,
    int? totalErrors,
    int? hintLevel,
    String? message,
    bool? completed,
    bool? challengeOpen,
    bool? challengeCompleted,
  }) {
    return EpisodeOneV3Snapshot(
      stage: stage ?? this.stage,
      selectedNumbers: selectedNumbers ?? this.selectedNumbers,
      selectedTexts: selectedTexts ?? this.selectedTexts,
      orderedNumbers: orderedNumbers ?? this.orderedNumbers,
      orderedTexts: orderedTexts ?? this.orderedTexts,
      testedValues: testedValues ?? this.testedValues,
      activeFilters: activeFilters ?? this.activeFilters,
      trackPath: trackPath ?? this.trackPath,
      evidenceOrder: evidenceOrder ?? this.evidenceOrder,
      completedActivities: completedActivities ?? this.completedActivities,
      clues: clues ?? this.clues,
      inventory: inventory ?? this.inventory,
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

class EpisodeOneV3Controller extends ValueNotifier<EpisodeOneV3Snapshot> {
  EpisodeOneV3Controller() : super(EpisodeOneV3Snapshot.initial());

  static const orderedTwelve = [1, 2, 3, 4, 6, 12];
  static const correctStorageGlyphs = ['star', 'moon', 'leaf', 'drop'];
  static const correctTrackPath = [0, 6, 12, 18, 24];
  static const correctEvidenceOrder = ['wind', 'piece', 'seed', 'tracks', 'pond'];

  void reset() {
    value = EpisodeOneV3Snapshot.initial();
  }

  void restoreCheckpoint(int checkpoint) {
    if (checkpoint <= 0) {
      reset();
      return;
    }
    if (checkpoint == 1) {
      value = EpisodeOneV3Snapshot.initial().copyWith(
        stage: EpisodeOneV3Stage.identifyFlowerpot,
        completedActivities: const {1, 2, 3, 4, 5},
        clues: const {EpisodeOneV3Clue.fallenPiece, EpisodeOneV3Clue.twelveStardust},
        inventory: const {EpisodeOneV3Item.rightLeafGlyph},
        message: '별받침대가 가리킨 오른쪽 화단에서 여섯 잎 문양과 같은 화분을 찾아보세요.',
      );
      return;
    }
    if (checkpoint == 2) {
      value = EpisodeOneV3Snapshot.initial().copyWith(
        stage: EpisodeOneV3Stage.arrangeTwentyFour,
        completedActivities: const {1, 2, 3, 4, 5, 6, 7, 8, 9},
        clues: const {
          EpisodeOneV3Clue.fallenPiece,
          EpisodeOneV3Clue.twelveStardust,
          EpisodeOneV3Clue.eighteenScratches,
        },
        inventory: const {EpisodeOneV3Item.rightLeafGlyph, EpisodeOneV3Item.twentyFourSeeds},
        message: '화분에서 찾은 씨앗 24개를 건조판에 배열해 보관소 잠금을 풀어 보세요.',
      );
      return;
    }
    value = EpisodeOneV3Snapshot.initial().copyWith(
      stage: EpisodeOneV3Stage.useTraceFilters,
      completedActivities: const {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
      clues: const {
        EpisodeOneV3Clue.fallenPiece,
        EpisodeOneV3Clue.twelveStardust,
        EpisodeOneV3Clue.eighteenScratches,
        EpisodeOneV3Clue.twentyFourSeeds,
      },
      inventory: const {
        EpisodeOneV3Item.rightLeafGlyph,
        EpisodeOneV3Item.twentyFourSeeds,
        EpisodeOneV3Item.dewLens,
        EpisodeOneV3Item.leafStencil,
        EpisodeOneV3Item.starlightLamp,
      },
      message: '보관소에서 찾은 세 도구를 겹쳐 사용해 연못 입구의 흔적을 분리하세요.',
    );
  }

  bool undoCurrentInput() {
    final snapshot = value;
    if (!snapshot.canUndoCurrentInput) return false;
    if (snapshot.evidenceOrder.isNotEmpty) {
      final updated = [...snapshot.evidenceOrder]..removeLast();
      value = snapshot.copyWith(evidenceOrder: updated, message: '방금 놓은 사건 카드를 되돌렸어요.');
      return true;
    }
    if (snapshot.trackPath.isNotEmpty) {
      final updated = [...snapshot.trackPath]..removeLast();
      value = snapshot.copyWith(trackPath: updated, message: '방금 연결한 발자국을 되돌렸어요.');
      return true;
    }
    if (snapshot.orderedTexts.isNotEmpty) {
      final updated = [...snapshot.orderedTexts]..removeLast();
      value = snapshot.copyWith(orderedTexts: updated, message: '방금 입력한 문양을 되돌렸어요.');
      return true;
    }
    if (snapshot.orderedNumbers.isNotEmpty) {
      final updated = [...snapshot.orderedNumbers]..removeLast();
      value = snapshot.copyWith(orderedNumbers: updated, message: '방금 놓은 숫자를 되돌렸어요.');
      return true;
    }
    if (snapshot.selectedTexts.isNotEmpty) {
      final updated = {...snapshot.selectedTexts}..remove(snapshot.selectedTexts.last);
      value = snapshot.copyWith(selectedTexts: updated, message: '방금 선택한 기록을 되돌렸어요.');
      return true;
    }
    if (snapshot.selectedNumbers.isNotEmpty) {
      final updated = {...snapshot.selectedNumbers}..remove(snapshot.selectedNumbers.last);
      value = snapshot.copyWith(selectedNumbers: updated, message: '방금 선택한 수를 되돌렸어요.');
      return true;
    }
    if (snapshot.activeFilters.isNotEmpty) {
      final updated = {...snapshot.activeFilters}..remove(snapshot.activeFilters.last);
      value = snapshot.copyWith(activeFilters: updated, message: '방금 사용한 흔적 도구를 치웠어요.');
      return true;
    }
    final updated = {...snapshot.testedValues}..remove(snapshot.testedValues.last);
    value = snapshot.copyWith(testedValues: updated, message: '방금 한 실험을 되돌렸어요.');
    return true;
  }

  void toggleNumber(int number) {
    if (value.completed && value.challengeOpen) {
      final selected = {...value.selectedNumbers};
      selected.contains(number) ? selected.remove(number) : selected.add(number);
      value = value.copyWith(selectedNumbers: selected);
      return;
    }
    if (value.stage == EpisodeOneV3Stage.orderTwelveDivisors) {
      selectOrderedNumber(number);
      return;
    }
    if (value.stage == EpisodeOneV3Stage.chooseTrackStart ||
        value.stage == EpisodeOneV3Stage.findMissingEighteen ||
        value.stage == EpisodeOneV3Stage.rejectNonDivisorEighteen) {
      value = value.copyWith(selectedNumbers: {number});
      return;
    }
    final selected = {...value.selectedNumbers};
    selected.contains(number) ? selected.remove(number) : selected.add(number);
    value = value.copyWith(selectedNumbers: selected);
  }

  void toggleText(String text) {
    if (value.stage == EpisodeOneV3Stage.identifyFragment ||
        value.stage == EpisodeOneV3Stage.identifyFlowerpot ||
        value.stage == EpisodeOneV3Stage.rejectFalseRecord ||
        value.stage == EpisodeOneV3Stage.chooseConclusion) {
      value = value.copyWith(selectedTexts: {text});
      return;
    }
    final selected = {...value.selectedTexts};
    selected.contains(text) ? selected.remove(text) : selected.add(text);
    value = value.copyWith(selectedTexts: selected);
  }

  void testValue(int valueToTest) {
    final stage = value.stage;
    if (stage != EpisodeOneV3Stage.testTwelveGroups &&
        stage != EpisodeOneV3Stage.testTrackIntervals &&
        stage != EpisodeOneV3Stage.rejectFalseRecord) {
      return;
    }
    final tested = {...value.testedValues, valueToTest};
    var feedback = '장치의 반응을 기록했어요.';
    if (stage == EpisodeOneV3Stage.testTwelveGroups) {
      final remainder = 12 % valueToTest;
      feedback = remainder == 0
          ? '$valueToTest개씩 놓으니 별가루가 하나도 남지 않았어요.'
          : '$valueToTest개씩 놓으니 별가루가 $remainder개 남았어요.';
    } else if (stage == EpisodeOneV3Stage.testTrackIntervals) {
      final remainder = 24 % valueToTest;
      feedback = remainder == 0
          ? '$valueToTest칸 간격은 24번째 돌까지 정확히 이어져요.'
          : '$valueToTest칸 간격은 끝에 $remainder칸이 남아 경로가 끊겨요.';
    } else {
      feedback = '5칸 시험판에 씨앗을 놓으니 4개가 남았어요. 기록 C의 설명과 맞지 않아요.';
    }
    value = value.copyWith(testedValues: tested, message: feedback);
  }

  void toggleFilter(String filter) {
    if (value.stage != EpisodeOneV3Stage.useTraceFilters) return;
    final filters = {...value.activeFilters};
    filters.contains(filter) ? filters.remove(filter) : filters.add(filter);
    value = value.copyWith(
      activeFilters: filters,
      message: switch (filter) {
        'dew' => '물방울 렌즈가 젖은 둥근 흔적을 밝히고 있어요.',
        'stencil' => '잎사귀 흔적틀이 큰 장화 자국을 따로 표시했어요.',
        _ => '별가루 조명이 오래된 씨앗 이동선을 드러냈어요.',
      },
    );
  }

  void selectOrderedNumber(int number) {
    if (value.stage != EpisodeOneV3Stage.orderTwelveDivisors) return;
    final expectedIndex = value.orderedNumbers.length;
    if (expectedIndex >= orderedTwelve.length) return;
    if (number != orderedTwelve[expectedIndex]) {
      _recordError('작은 별에서 큰 별로 이어지는 방향과 곱셈 짝을 다시 비교해 보세요.');
      return;
    }
    value = value.copyWith(
      orderedNumbers: [...value.orderedNumbers, number],
      message: number == 12 ? '여섯 별자리 조각이 하나의 오른쪽 길을 만들었어요.' : '$number 문양이 올바른 자리에 놓였어요.',
    );
  }

  void selectOrderedText(String text) {
    if (value.stage != EpisodeOneV3Stage.orderStorageGlyphs) return;
    final expectedIndex = value.orderedTexts.length;
    if (expectedIndex >= correctStorageGlyphs.length) return;
    if (text != correctStorageGlyphs[expectedIndex]) {
      _recordError('건조판의 짧은 변이 작은 순서와 오른쪽 진행 방향을 함께 살펴보세요.');
      return;
    }
    value = value.copyWith(
      orderedTexts: [...value.orderedTexts, text],
      message: expectedIndex == correctStorageGlyphs.length - 1
          ? '네 문양이 맞물리며 보관소 문이 열릴 준비를 마쳤어요.'
          : '문양 하나가 올바른 순서로 빛났어요.',
    );
  }

  void selectTrackNode(int node) {
    if (value.stage != EpisodeOneV3Stage.connectFootprints) return;
    final expectedIndex = value.trackPath.length;
    if (expectedIndex >= correctTrackPath.length) return;
    if (node != correctTrackPath[expectedIndex]) {
      _recordError(_trackContradiction(node));
      return;
    }
    value = value.copyWith(
      trackPath: [...value.trackPath, node],
      message: node == 24
          ? '둥근 발자국이 오른쪽의 젖은 돌까지 일정한 6칸 간격으로 이어졌어요.'
          : '$node번째 별돌의 젖은 발자국을 연결했어요.',
    );
  }

  void selectEvidenceCard(String card) {
    if (value.stage != EpisodeOneV3Stage.orderEvidence) return;
    final expectedIndex = value.evidenceOrder.length;
    if (expectedIndex >= correctEvidenceOrder.length) return;
    if (card != correctEvidenceOrder[expectedIndex]) {
      _recordError('그 장면보다 먼저 일어난 원인이 있어요. 받침대와 씨앗의 시작점을 다시 비교해 보세요.');
      return;
    }
    value = value.copyWith(
      evidenceOrder: [...value.evidenceOrder, card],
      message: expectedIndex == correctEvidenceOrder.length - 1
          ? '사건의 시간 순서가 모두 이어졌어요.'
          : '사건 카드 하나를 올바른 순서에 놓았어요.',
    );
  }

  bool submitCurrent() {
    if (value.completed) return false;
    return switch (value.stage) {
      EpisodeOneV3Stage.identifyFragment => _submitText(
          const {'crescent'},
          next: EpisodeOneV3Stage.testTwelveGroups,
          message: '반달 조각이 오른쪽 홈에 맞자 받침대 안에서 별가루 12개가 나타났어요.',
          activity: 1,
          clue: EpisodeOneV3Clue.fallenPiece,
        ),
      EpisodeOneV3Stage.testTwelveGroups => _submitTests(
          const {2, 3, 4, 5},
          next: EpisodeOneV3Stage.revealTwelveDivisors,
          message: '2·3·4개씩은 남지 않았고 5개씩은 2개가 남았어요. 벽화의 숨은 배치도 확인할 수 있어요.',
          activity: 2,
        ),
      EpisodeOneV3Stage.revealTwelveDivisors => _submitNumbers(
          const {1, 2, 3, 4, 6, 12},
          next: EpisodeOneV3Stage.pairTwelveFactors,
          message: '남김없이 빛나는 여섯 별자리 조각을 모두 찾았어요.',
          activity: 3,
        ),
      EpisodeOneV3Stage.pairTwelveFactors => _submitText(
          const {'1×12', '2×6', '3×4'},
          next: EpisodeOneV3Stage.orderTwelveDivisors,
          message: '세 곱셈 짝이 회전판의 서로 마주 보는 홈에 맞았어요.',
          activity: 4,
        ),
      EpisodeOneV3Stage.orderTwelveDivisors => _submitOrderedNumbers(
          orderedTwelve,
          next: EpisodeOneV3Stage.identifyFlowerpot,
          message: '받침대가 오른쪽의 여섯 잎 화분을 가리켰어요.',
          activity: 5,
          clue: EpisodeOneV3Clue.twelveStardust,
          item: EpisodeOneV3Item.rightLeafGlyph,
        ),
      EpisodeOneV3Stage.identifyFlowerpot => _submitText(
          const {'pot6'},
          next: EpisodeOneV3Stage.assembleScratches,
          message: '여섯 잎 문양의 화분 테두리와 흙, 바닥에 같은 긁힘 조각이 흩어져 있어요.',
        ),
      EpisodeOneV3Stage.assembleScratches => _submitText(
          const {'rim7', 'soil5', 'tile6'},
          next: EpisodeOneV3Stage.arrangeEighteen,
          message: '세 조각을 겹치자 18개의 긁힘과 오른쪽으로 밀린 방향이 드러났어요.',
        ),
      EpisodeOneV3Stage.arrangeEighteen => _submitNumbers(
          const {1, 2, 3, 6, 9, 18},
          next: EpisodeOneV3Stage.removeDuplicateEighteen,
          message: '18개의 흔적이 남김없이 들어가는 배열을 모두 확인했어요.',
          activity: 6,
        ),
      EpisodeOneV3Stage.removeDuplicateEighteen => _submitText(
          const {'18×1', '9×2', '6×3'},
          next: EpisodeOneV3Stage.findMissingEighteen,
          message: '방향만 뒤집힌 세 기록을 겹치자 원래 곱셈 짝 세 개가 남았어요.',
          activity: 7,
        ),
      EpisodeOneV3Stage.findMissingEighteen => _submitNumbers(
          const {6},
          next: EpisodeOneV3Stage.rejectNonDivisorEighteen,
          message: '3과 짝이 되는 6을 복원하자 6번 화분의 안쪽 칸이 열렸어요.',
          activity: 8,
        ),
      EpisodeOneV3Stage.rejectNonDivisorEighteen => _submitNumbers(
          const {4},
          next: EpisodeOneV3Stage.arrangeTwentyFour,
          message: '4개씩 묶으면 2개가 남았어요. 숫자 잎 4를 치우자 별꽃 씨앗 24개가 나타났어요.',
          activity: 9,
          clue: EpisodeOneV3Clue.eighteenScratches,
          item: EpisodeOneV3Item.twentyFourSeeds,
        ),
      EpisodeOneV3Stage.arrangeTwentyFour => _submitText(
          const {'1×24', '2×12', '3×8', '4×6'},
          next: EpisodeOneV3Stage.mapTwentyFourPins,
          message: '네 건조판이 모두 빈칸 없이 채워지고 가장자리 문양을 드러냈어요.',
          activity: 10,
        ),
      EpisodeOneV3Stage.mapTwentyFourPins => _submitNumbers(
          const {1, 2, 3, 4, 6, 8, 12, 24},
          next: EpisodeOneV3Stage.orderStorageGlyphs,
          message: '네 배열의 두 변을 모아 여덟 잠금핀을 모두 밝혔어요.',
          activity: 11,
        ),
      EpisodeOneV3Stage.orderStorageGlyphs => _submitOrderedTexts(
          correctStorageGlyphs,
          next: EpisodeOneV3Stage.rejectFalseRecord,
          message: '작은 변 1·2·3·4의 순서로 문양을 누르자 보관소가 열렸어요.',
        ),
      EpisodeOneV3Stage.rejectFalseRecord => _submitFalseRecord(),
      EpisodeOneV3Stage.useTraceFilters => _submitFilters(),
      EpisodeOneV3Stage.chooseTrackStart => _submitNumbers(
          const {2},
          next: EpisodeOneV3Stage.testTrackIntervals,
          message: '둥근 발자국은 받침대가 아니라 씨앗이 떨어진 지점 뒤에서 시작했어요.',
        ),
      EpisodeOneV3Stage.testTrackIntervals => _submitTests(
          const {4, 5, 6},
          next: EpisodeOneV3Stage.connectFootprints,
          message: '5칸 길은 끊겼고 4칸과 6칸 길이 남았어요. 방향과 젖은 흔적을 함께 비교해야 해요.',
        ),
      EpisodeOneV3Stage.connectFootprints => _submitTrackPath(),
      EpisodeOneV3Stage.orderEvidence => _submitEvidenceOrder(),
      EpisodeOneV3Stage.chooseConclusion => _submitConclusion(),
      EpisodeOneV3Stage.completed => false,
    };
  }

  void requestHint() {
    if (value.completed) return;
    final level = (value.hintLevel + 1).clamp(1, 3).toInt();
    value = value.copyWith(hintLevel: level, message: _hintFor(value.stage, level));
  }

  void openChallenge() {
    if (!value.completed || value.challengeCompleted) return;
    value = value.copyWith(
      challengeOpen: true,
      selectedNumbers: const {},
      message: '정원사의 별도장: 30의 약수를 모두 찾아보세요.',
    );
  }

  bool submitChallenge() {
    if (!value.completed || !value.challengeOpen) return false;
    const expected = {1, 2, 3, 5, 6, 10, 15, 30};
    if (!setEquals(value.selectedNumbers, expected)) {
      value = value.copyWith(message: '30이 되는 곱셈 짝을 작은 수부터 다시 확인해 보세요.');
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

  bool _submitFalseRecord() {
    if (!setEquals(value.selectedTexts, const {'C'})) {
      _recordError('작다는 이유만으로 나머지 없이 나뉘는 것은 아니에요. 실제 배열로 확인할 기록을 골라 보세요.');
      return false;
    }
    if (!value.testedValues.contains(5)) {
      _recordError('의심스러운 기록을 고른 뒤 5칸 시험판에 씨앗 24개를 직접 놓아 보세요.');
      return false;
    }
    _advance(
      next: EpisodeOneV3Stage.useTraceFilters,
      message: '기록 C의 반례를 확인했어요. 기록 뒤에서 물방울 렌즈와 흔적틀, 별가루 조명을 찾았어요.',
      activity: 12,
      clue: EpisodeOneV3Clue.twentyFourSeeds,
      items: const {
        EpisodeOneV3Item.dewLens,
        EpisodeOneV3Item.leafStencil,
        EpisodeOneV3Item.starlightLamp,
      },
    );
    return true;
  }

  bool _submitFilters() {
    if (!value.activeFilters.containsAll(const {'dew', 'stencil', 'starlight'})) {
      _recordError('한 가지 도구만으로는 흔적이 겹쳐 보여요. 세 도구의 결과를 모두 비교해 보세요.');
      return false;
    }
    _advance(
      next: EpisodeOneV3Stage.chooseTrackStart,
      message: '씨앗 이동선, 젖은 둥근 발자국, 큰 장화 자국이 서로 다른 층으로 분리됐어요.',
    );
    return true;
  }

  bool _submitTrackPath() {
    if (!listEquals(value.trackPath, correctTrackPath)) {
      _recordError('간격, 오른쪽 방향, 젖은 돌과 시작 시점을 모두 만족하는 흔적을 순서대로 연결하세요.');
      return false;
    }
    _advance(
      next: EpisodeOneV3Stage.orderEvidence,
      message: '6칸 간격의 젖은 발자국이 씨앗이 떨어진 곳에서 연못까지 이어졌어요.',
      activity: 13,
      clue: EpisodeOneV3Clue.roundFootprints,
    );
    return true;
  }

  bool _submitEvidenceOrder() {
    if (!listEquals(value.evidenceOrder, correctEvidenceOrder)) {
      _recordError('바람이 원인이 되고, 발자국은 씨앗이 떨어진 뒤에 나타났어요.');
      return false;
    }
    _advance(
      next: EpisodeOneV3Stage.chooseConclusion,
      message: '다섯 사건 카드가 원인과 결과에 맞게 이어졌어요. 이제 확인된 사실만 골라보세요.',
    );
    return true;
  }

  bool _submitConclusion() {
    if (!setEquals(value.selectedTexts, const {'B'})) {
      _recordError('발자국의 주인이 씨앗을 훔쳤다는 증거는 아직 없어요. 확인된 사실과 추측을 구분하세요.');
      return false;
    }
    value = value.copyWith(
      stage: EpisodeOneV3Stage.completed,
      selectedTexts: const {},
      completedActivities: {...value.completedActivities, 14},
      clues: {...value.clues, EpisodeOneV3Clue.silverFur},
      completed: true,
      activityErrors: 0,
      hintLevel: 0,
      message: '씨앗이 먼저 떨어졌고 작은 생물이 그 뒤를 따라갔어요. 연못 끝에서 젖은 은빛 털과 잠긴 수문 문양을 발견했어요.',
    );
    return true;
  }

  bool _submitText(
    Set<String> expected, {
    required EpisodeOneV3Stage next,
    required String message,
    int? activity,
    EpisodeOneV3Clue? clue,
    EpisodeOneV3Item? item,
  }) {
    if (!setEquals(value.selectedTexts, expected)) {
      _recordError('모양, 방향 또는 앞에서 확인한 기록과 일치하는지 다시 살펴보세요.');
      return false;
    }
    _advance(next: next, message: message, activity: activity, clue: clue, item: item);
    return true;
  }

  bool _submitNumbers(
    Set<int> expected, {
    required EpisodeOneV3Stage next,
    required String message,
    int? activity,
    EpisodeOneV3Clue? clue,
    EpisodeOneV3Item? item,
  }) {
    if (!setEquals(value.selectedNumbers, expected)) {
      _recordError('실제 물건이 남지 않는지, 또는 이전 단서와 방향이 맞는지 다시 확인해 보세요.');
      return false;
    }
    _advance(next: next, message: message, activity: activity, clue: clue, item: item);
    return true;
  }

  bool _submitTests(
    Set<int> expected, {
    required EpisodeOneV3Stage next,
    required String message,
    int? activity,
  }) {
    if (!value.testedValues.containsAll(expected)) {
      _recordError('결론을 내리기 전에 모든 후보를 직접 시험해 반응을 기록하세요.');
      return false;
    }
    _advance(next: next, message: message, activity: activity);
    return true;
  }

  bool _submitOrderedNumbers(
    List<int> expected, {
    required EpisodeOneV3Stage next,
    required String message,
    int? activity,
    EpisodeOneV3Clue? clue,
    EpisodeOneV3Item? item,
  }) {
    if (!listEquals(value.orderedNumbers, expected)) {
      _recordError('별자리 조각을 작은 수부터 빠짐없이 이어야 장치가 움직여요.');
      return false;
    }
    _advance(next: next, message: message, activity: activity, clue: clue, item: item);
    return true;
  }

  bool _submitOrderedTexts(
    List<String> expected, {
    required EpisodeOneV3Stage next,
    required String message,
  }) {
    if (!listEquals(value.orderedTexts, expected)) {
      _recordError('건조판의 짧은 변과 이전 방향 단서를 함께 사용해 문양 순서를 정하세요.');
      return false;
    }
    _advance(next: next, message: message);
    return true;
  }

  void _advance({
    required EpisodeOneV3Stage next,
    required String message,
    int? activity,
    EpisodeOneV3Clue? clue,
    EpisodeOneV3Item? item,
    Set<EpisodeOneV3Item>? items,
  }) {
    final inventory = {...value.inventory};
    if (item != null) inventory.add(item);
    if (items != null) inventory.addAll(items);
    value = value.copyWith(
      stage: next,
      selectedNumbers: const {},
      selectedTexts: const {},
      orderedNumbers: const [],
      orderedTexts: const [],
      testedValues: const {},
      activeFilters: const {},
      trackPath: const [],
      evidenceOrder: const [],
      completedActivities: activity == null ? value.completedActivities : {...value.completedActivities, activity},
      clues: clue == null ? value.clues : {...value.clues, clue},
      inventory: inventory,
      activityErrors: 0,
      hintLevel: 0,
      message: message,
    );
  }

  void _recordError(String message) {
    final errors = value.activityErrors + 1;
    value = value.copyWith(
      activityErrors: errors,
      totalErrors: value.totalErrors + 1,
      message: errors >= 2 ? '$message 꽃루미의 힌트를 사용해도 진행과 보상은 줄지 않아요.' : message,
    );
  }

  String _trackContradiction(int node) {
    if (node % 5 == 0 && node != 0) {
      return '이 돌은 5칸 흔적에 가까워요. 마지막 별돌까지 간격이 맞지 않았던 경로예요.';
    }
    if (node % 4 == 0) {
      return '간격은 맞을 수 있지만 이 돌은 왼쪽의 마른 길이에요. 오른쪽 긁힘과 젖은 흔적을 확인하세요.';
    }
    return '이 흔적은 앞뒤 발자국과 일정한 간격을 만들지 못해요.';
  }

  String _hintFor(EpisodeOneV3Stage stage, int level) {
    final hints = switch (stage) {
      EpisodeOneV3Stage.identifyFragment => const ['받침대 오른쪽 홈의 테두리와 주변 물체의 모양을 비교하세요.', '홈에는 반달 모양의 긁힘이 이어져 있어요.', '반달 별조각을 선택해 확인하세요.'],
      EpisodeOneV3Stage.testTwelveGroups => const ['성공한 묶음뿐 아니라 남는 별가루도 중요한 기록이에요.', '12를 2·3·4·5로 각각 나눈 나머지를 비교하세요.', '네 묶음판을 모두 시험하세요.'],
      EpisodeOneV3Stage.revealTwelveDivisors => const ['실험에 없던 1개와 12개 배치는 벽화에 남아 있어요.', '곱해서 12가 되는 두 수를 모아 보세요.', '1·2·3·4·6·12 문양을 선택하세요.'],
      EpisodeOneV3Stage.pairTwelveFactors => const ['서로 마주 보는 두 수를 곱하면 같은 별가루 수가 되어야 해요.', '작은 수 1, 2, 3부터 짝을 찾으세요.', '1×12, 2×6, 3×4를 연결하세요.'],
      EpisodeOneV3Stage.orderTwelveDivisors => const ['회전판의 작은 별이 시작점이에요.', '찾은 수를 작은 순서로 놓으세요.', '1, 2, 3, 4, 6, 12 순서예요.'],
      EpisodeOneV3Stage.identifyFlowerpot => const ['받침대가 남긴 잎 문양의 개수를 세어 보세요.', '오른쪽 화단에서 잎이 여섯 개인 문양을 찾으세요.', '6번 화분을 선택하세요.'],
      EpisodeOneV3Stage.assembleScratches => const ['긁힘은 화분에만 있지 않아요.', '테두리 7개, 흙 5개, 바닥 6개를 모두 겹쳐 보세요.', '세 흔적 조각을 모두 선택하세요.'],
      EpisodeOneV3Stage.arrangeEighteen => const ['18개가 남지 않는 배열만 기록하세요.', '곱해서 18이 되는 수를 모아 보세요.', '1·2·3·6·9·18을 선택하세요.'],
      EpisodeOneV3Stage.removeDuplicateEighteen => const ['곱셈 순서만 바뀐 기록은 같은 배열이에요.', '1×18, 2×9, 3×6의 뒤집힌 기록을 찾으세요.', '18×1, 9×2, 6×3을 선택하세요.'],
      EpisodeOneV3Stage.findMissingEighteen => const ['3과 짝이 되어 18을 만드는 수가 지워졌어요.', '18÷3을 생각해 보세요.', '6을 선택하세요.'],
      EpisodeOneV3Stage.rejectNonDivisorEighteen => const ['18개를 나누었을 때 남는 숫자 잎을 찾으세요.', '4개씩 놓으면 2개가 남아요.', '4를 선택하세요.'],
      EpisodeOneV3Stage.arrangeTwentyFour => const ['건조판의 두 변을 곱해 24가 되는지 확인하세요.', '짧은 변 1, 2, 3, 4의 짝을 찾으세요.', '1×24, 2×12, 3×8, 4×6을 선택하세요.'],
      EpisodeOneV3Stage.mapTwentyFourPins => const ['네 배열의 양쪽 변에 있는 모든 수가 필요해요.', '중복을 제거하고 작은 수부터 모으세요.', '1·2·3·4·6·8·12·24를 선택하세요.'],
      EpisodeOneV3Stage.orderStorageGlyphs => const ['문양 순서는 건조판의 짧은 변 순서와 같아요.', '작은 변 1, 2, 3, 4를 오른쪽 방향으로 읽으세요.', '별, 달, 잎, 물방울 순서예요.'],
      EpisodeOneV3Stage.rejectFalseRecord => const ['원래 수보다 작다는 것만으로 약수가 되지는 않아요.', '기록 C를 고르고 5칸 시험판을 사용하세요.', '기록 C와 5칸 시험을 선택하세요.'],
      EpisodeOneV3Stage.useTraceFilters => const ['한 도구는 젖은 흔적, 다른 도구는 크기, 또 다른 도구는 오래된 선을 보여줘요.', '세 도구의 결과를 겹쳐 비교하세요.', '물방울 렌즈, 흔적틀, 별가루 조명을 모두 사용하세요.'],
      EpisodeOneV3Stage.chooseTrackStart => const ['둥근 발자국은 씨앗이 떨어지기 전에는 보이지 않아요.', '받침대 아래가 아니라 씨앗이 바닥에 닿은 지점을 찾으세요.', '두 번째 시작점을 선택하세요.'],
      EpisodeOneV3Stage.testTrackIntervals => const ['끝까지 이어지는지 직접 확인해야 해요.', '24를 4, 5, 6으로 나눈 나머지를 비교하세요.', '4·5·6칸 간격을 모두 시험하세요.'],
      EpisodeOneV3Stage.connectFootprints => const ['수학적으로 가능한 길이 두 개 남아 있어요.', '오른쪽 방향이고 젖은 돌로 이어지는 6칸 길을 찾으세요.', '0, 6, 12, 18, 24 순서로 연결하세요.'],
      EpisodeOneV3Stage.orderEvidence => const ['원인이 먼저, 그 결과가 뒤에 와야 해요.', '바람, 조각, 씨앗, 발자국, 연못 순서로 생각하세요.', '바람→조각→씨앗→발자국→연못 순서예요.'],
      EpisodeOneV3Stage.chooseConclusion => const ['확인한 사실과 아직 확인하지 못한 범인 추측을 구분하세요.', '발자국은 씨앗이 떨어진 뒤에 시작했어요.', '결론 B를 선택하세요.'],
      EpisodeOneV3Stage.completed => const ['Episode 1 조사가 끝났어요.', '연못 아래의 수문은 Episode 2에서 열 수 있어요.', '정원으로 돌아가 다음 모험을 준비하세요.'],
    };
    return hints[level - 1];
  }
}
