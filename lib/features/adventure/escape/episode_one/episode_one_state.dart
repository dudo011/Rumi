import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'episode_one_puzzles.dart';

enum EpisodeOneScene {
  centralGarden,
  pond,
  clockflowerGrove,
  fountain,
  greenhouse,
}

enum EpisodeOneItem { starLens, silverRibbon, starKey, moonHandle }

enum EpisodeOneClue { wetTracks, silverFurTrail }

extension EpisodeOneItemMetadata on EpisodeOneItem {
  String get label {
    return switch (this) {
      EpisodeOneItem.starLens => '별무늬 렌즈',
      EpisodeOneItem.silverRibbon => '은빛 바람끈',
      EpisodeOneItem.starKey => '별열쇠',
      EpisodeOneItem.moonHandle => '달빛 손잡이',
    };
  }
}

extension EpisodeOneClueMetadata on EpisodeOneClue {
  String get label {
    return switch (this) {
      EpisodeOneClue.wetTracks => '바람 뒤의 젖은 발자국',
      EpisodeOneClue.silverFurTrail => '은빛 털과 접힌 잎',
    };
  }

  String get description {
    return switch (this) {
      EpisodeOneClue.wetTracks => '둥근 발자국은 바람 자국 위에 남았고 분수대 방향으로 이어졌어요.',
      EpisodeOneClue.silverFurTrail =>
        '분수대 뒤의 은빛 털과 접힌 잎은 포포가 바람 뒤에 씨앗을 따라 온실 방향으로 이동했음을 보여줘요.',
    };
  }
}

extension EpisodeOneSceneMetadata on EpisodeOneScene {
  String get label {
    return switch (this) {
      EpisodeOneScene.centralGarden => '중앙 정원',
      EpisodeOneScene.pond => '반짝이는 연못',
      EpisodeOneScene.clockflowerGrove => '시계꽃 숲',
      EpisodeOneScene.fountain => '분수대',
      EpisodeOneScene.greenhouse => '달빛 온실',
    };
  }

  String get objective {
    return switch (this) {
      EpisodeOneScene.centralGarden => '빈 별받침대 주변을 살펴보세요.',
      EpisodeOneScene.pond => '별 모양 홈이 있는 연못의 돌거울을 살펴보세요.',
      EpisodeOneScene.clockflowerGrove => '서로 다른 간격으로 피는 두 시계꽃과 시간고리를 살펴보세요.',
      EpisodeOneScene.fountain => '멈춘 바람바퀴와 잠긴 관리 상자를 살펴보세요.',
      EpisodeOneScene.greenhouse => '손잡이가 빠진 달빛 온실 문을 살펴보세요.',
    };
  }
}

@immutable
class EpisodeOneSnapshot {
  EpisodeOneSnapshot({
    required this.currentScene,
    required Set<EpisodeOneScene> visitedScenes,
    required List<EpisodeOneScene> history,
    required this.fittingFallenPiece,
    required this.fallenPieceFitted,
    required this.pedestalCloseUpOpen,
    required List<int> pedestalCupCounts,
    required this.pedestalMechanismAnimating,
    required this.pedestalSolved,
    required Set<EpisodeOneItem> inventory,
    required this.selectedItem,
    required this.pondLensInstalling,
    required this.pondLensInstalled,
    required this.pondCloseUpOpen,
    required this.pondTrackProgress,
    required this.pondTrackAnimating,
    required this.pondSolved,
    required this.clockflowerCloseUpOpen,
    required this.clockflowerSelection,
    required this.clockflowerAnimating,
    required this.clockflowerSolved,
    required this.fountainWheelRepairing,
    required this.fountainWheelRepaired,
    required this.fountainStoneSelection,
    required this.fountainStoneAnimating,
    required this.fountainStarKeyRevealed,
    required this.fountainStarKeyCollected,
    required this.fountainChestOpening,
    required this.fountainChestOpened,
    required Set<EpisodeOneClue> clues,
    required this.inputLocked,
    required this.message,
  }) : visitedScenes = UnmodifiableSetView(visitedScenes),
       history = UnmodifiableListView(history),
       pedestalCupCounts = UnmodifiableListView(pedestalCupCounts),
       inventory = UnmodifiableSetView(inventory),
       clues = UnmodifiableSetView(clues);

  factory EpisodeOneSnapshot.initial() {
    return EpisodeOneSnapshot(
      currentScene: EpisodeOneScene.centralGarden,
      visitedScenes: {EpisodeOneScene.centralGarden},
      history: const [EpisodeOneScene.centralGarden],
      fittingFallenPiece: false,
      fallenPieceFitted: false,
      pedestalCloseUpOpen: false,
      pedestalCupCounts: const [0, 0, 0],
      pedestalMechanismAnimating: false,
      pedestalSolved: false,
      inventory: const {},
      selectedItem: null,
      pondLensInstalling: false,
      pondLensInstalled: false,
      pondCloseUpOpen: false,
      pondTrackProgress: 0,
      pondTrackAnimating: false,
      pondSolved: false,
      clockflowerCloseUpOpen: false,
      clockflowerSelection: null,
      clockflowerAnimating: false,
      clockflowerSolved: false,
      fountainWheelRepairing: false,
      fountainWheelRepaired: false,
      fountainStoneSelection: null,
      fountainStoneAnimating: false,
      fountainStarKeyRevealed: false,
      fountainStarKeyCollected: false,
      fountainChestOpening: false,
      fountainChestOpened: false,
      clues: const {},
      inputLocked: false,
      message: '받침대 아래에서 희미하게 흔들리는 별조각을 찾아보세요.',
    );
  }

  final EpisodeOneScene currentScene;
  final Set<EpisodeOneScene> visitedScenes;
  final List<EpisodeOneScene> history;
  final bool fittingFallenPiece;
  final bool fallenPieceFitted;
  final bool pedestalCloseUpOpen;
  final List<int> pedestalCupCounts;
  final bool pedestalMechanismAnimating;
  final bool pedestalSolved;
  final Set<EpisodeOneItem> inventory;
  final EpisodeOneItem? selectedItem;
  final bool pondLensInstalling;
  final bool pondLensInstalled;
  final bool pondCloseUpOpen;
  final int pondTrackProgress;
  final bool pondTrackAnimating;
  final bool pondSolved;
  final bool clockflowerCloseUpOpen;
  final int? clockflowerSelection;
  final bool clockflowerAnimating;
  final bool clockflowerSolved;
  final bool fountainWheelRepairing;
  final bool fountainWheelRepaired;
  final int? fountainStoneSelection;
  final bool fountainStoneAnimating;
  final bool fountainStarKeyRevealed;
  final bool fountainStarKeyCollected;
  final bool fountainChestOpening;
  final bool fountainChestOpened;
  final Set<EpisodeOneClue> clues;
  final bool inputLocked;
  final String message;

  int get remainingPedestalDust =>
      PedestalBalancePuzzle.remainingDust(pedestalCupCounts);

  bool get gardenPathsUnlocked => pedestalSolved;

  bool get fountainSolved => fountainChestOpened;

  bool get closeUpOpen =>
      pedestalCloseUpOpen || pondCloseUpOpen || clockflowerCloseUpOpen;

  String get displayLabel {
    if (pedestalCloseUpOpen) return '별받침대 균형 장치';
    if (pondCloseUpOpen) return '연못의 기억 흔적';
    if (clockflowerCloseUpOpen) return '시계꽃 시간고리';
    return currentScene.label;
  }

  String get objective {
    if (pedestalCloseUpOpen) {
      if (pedestalSolved) {
        return '별무늬 렌즈를 얻었어요. 중앙 정원으로 돌아가세요.';
      }
      if (pedestalMechanismAnimating) {
        return '세 균형컵이 맞춰지며 받침대 장치가 움직이고 있어요.';
      }
      return '별가루 12개를 세 균형컵에 똑같이 나누세요.';
    }

    if (pondCloseUpOpen) {
      if (pondSolved) {
        return '젖은 발자국이 분수대 방향으로 이어져요.';
      }
      if (pondTrackAnimating) {
        return '네 발자국이 물빛 선으로 이어지고 있어요.';
      }
      return '둥근 발바닥과 작은 발가락이 있는 흔적을 순서대로 찾으세요.';
    }

    if (clockflowerCloseUpOpen) {
      if (clockflowerSolved) {
        return '은빛 바람끈을 얻었어요. 분수대 장치에 사용할 수 있어요.';
      }
      if (clockflowerAnimating) {
        return '두 시계꽃이 함께 열리며 가지의 바람끈이 풀리고 있어요.';
      }
      return '4칸과 6칸마다 피는 두 꽃이 처음 함께 피는 칸을 찾으세요.';
    }

    if (currentScene == EpisodeOneScene.pond) {
      if (pondLensInstalling) {
        return '별무늬 렌즈가 돌거울의 빈 홈에 맞춰지고 있어요.';
      }
      if (!pondLensInstalled) {
        return selectedItem == EpisodeOneItem.starLens
            ? '선택한 별무늬 렌즈를 돌거울에 사용하세요.'
            : '별 모양 홈에 맞는 아이템을 선택하세요.';
      }
      if (!pondSolved) {
        return '기억거울에 나타난 흔적을 확대 조사하세요.';
      }
      return '기록된 젖은 발자국 단서를 다시 확인할 수 있어요.';
    }

    if (currentScene == EpisodeOneScene.clockflowerGrove) {
      if (clockflowerSolved) {
        return '12번째 칸이 빛나고 있어요. 은빛 바람끈을 확인하세요.';
      }
      return '두 시계꽃과 12칸 시간고리를 확대 조사하세요.';
    }

    if (currentScene == EpisodeOneScene.fountain) {
      if (fountainWheelRepairing) {
        return '은빛 바람끈이 끊어진 바람바퀴 고리에 묶이고 있어요.';
      }
      if (!fountainWheelRepaired) {
        return selectedItem == EpisodeOneItem.silverRibbon
            ? '선택한 은빛 바람끈으로 바람바퀴를 고치세요.'
            : '바람바퀴의 끊어진 부분을 묶을 긴 물건이 필요해요.';
      }
      if (!pondSolved) {
        return '연못의 젖은 발자국 단서를 먼저 확인하면 돌의 흔적을 구분할 수 있어요.';
      }
      if (!fountainStarKeyRevealed) {
        return '연못에서 본 젖은 발자국과 같은 흔적이 있는 돌을 찾으세요.';
      }
      if (!fountainStarKeyCollected) {
        return '세 번째 돌 아래에 나타난 별열쇠를 챙기세요.';
      }
      if (fountainChestOpening) {
        return '별열쇠가 관리 상자의 자물쇠를 열고 있어요.';
      }
      if (!fountainChestOpened) {
        return selectedItem == EpisodeOneItem.starKey
            ? '선택한 별열쇠를 관리 상자에 사용하세요.'
            : '별열쇠를 선택해 관리 상자를 여세요.';
      }
      return '달빛 손잡이와 포포의 이동 흔적을 확인했어요.';
    }

    if (currentScene != EpisodeOneScene.centralGarden) {
      return currentScene.objective;
    }
    if (fittingFallenPiece) {
      return '별조각이 받침대의 빈 홈으로 이동하고 있어요.';
    }
    if (!fallenPieceFitted) {
      return '받침대 아래 떨어진 별조각을 찾아 맞춰 보세요.';
    }
    if (!pedestalSolved) {
      return '조각이 맞춰진 별받침대의 안쪽 장치를 조사하세요.';
    }
    if (!pondSolved && !clockflowerSolved) {
      return '연못과 시계꽃 숲을 원하는 순서로 조사하세요.';
    }
    if (!pondSolved) {
      return '연못에서 별무늬 렌즈를 사용해 발자국 단서를 찾으세요.';
    }
    if (!clockflowerSolved) {
      return '시계꽃 숲에서 두 꽃이 함께 피는 첫 시간을 찾으세요.';
    }
    if (!fountainSolved) {
      return '분수대에서 젖은 발자국과 은빛 바람끈을 함께 사용하세요.';
    }
    return '달빛 손잡이를 들고 온실 문을 조사하세요.';
  }

  String get progressLabel {
    if (currentScene == EpisodeOneScene.fountain) {
      if (fountainChestOpened) return '달빛 손잡이 획득';
      if (fountainChestOpening) return '관리 상자 개방 중';
      if (fountainStarKeyCollected) return '별열쇠 획득';
      if (fountainStarKeyRevealed) return '숨은 열쇠 발견';
      if (fountainWheelRepaired) return '바람바퀴 수리 완료';
      return '분수대 장치 조사';
    }
    if (pondSolved && clockflowerSolved) return '연못·숲 조사 완료';
    if (clockflowerSolved) return '은빛 바람끈 획득';
    if (clockflowerCloseUpOpen) {
      return clockflowerSelection == null
          ? '시간고리 조사'
          : '선택 ${clockflowerSelection!}/12';
    }
    if (pondSolved) return '연못 단서 ${clues.length}/1';
    if (pondCloseUpOpen) {
      return '발자국 $pondTrackProgress/${PondTrackPuzzle.correctOrder.length}';
    }
    if (pondLensInstalled) return '기억거울 활성화';
    if (selectedItem != null) return '${selectedItem!.label} 선택';
    if (pedestalSolved) return '별무늬 렌즈 획득';
    if (pedestalCloseUpOpen) {
      return '별가루 ${PedestalBalancePuzzle.totalDust - remainingPedestalDust}/${PedestalBalancePuzzle.totalDust}';
    }
    if (fallenPieceFitted) return '별조각 결합 완료';
    return '받침대 준비 전';
  }

  EpisodeOneSnapshot copyWith({
    EpisodeOneScene? currentScene,
    Set<EpisodeOneScene>? visitedScenes,
    List<EpisodeOneScene>? history,
    bool? fittingFallenPiece,
    bool? fallenPieceFitted,
    bool? pedestalCloseUpOpen,
    List<int>? pedestalCupCounts,
    bool? pedestalMechanismAnimating,
    bool? pedestalSolved,
    Set<EpisodeOneItem>? inventory,
    EpisodeOneItem? selectedItem,
    bool clearSelectedItem = false,
    bool? pondLensInstalling,
    bool? pondLensInstalled,
    bool? pondCloseUpOpen,
    int? pondTrackProgress,
    bool? pondTrackAnimating,
    bool? pondSolved,
    bool? clockflowerCloseUpOpen,
    int? clockflowerSelection,
    bool clearClockflowerSelection = false,
    bool? clockflowerAnimating,
    bool? clockflowerSolved,
    bool? fountainWheelRepairing,
    bool? fountainWheelRepaired,
    int? fountainStoneSelection,
    bool clearFountainStoneSelection = false,
    bool? fountainStoneAnimating,
    bool? fountainStarKeyRevealed,
    bool? fountainStarKeyCollected,
    bool? fountainChestOpening,
    bool? fountainChestOpened,
    Set<EpisodeOneClue>? clues,
    bool? inputLocked,
    String? message,
  }) {
    return EpisodeOneSnapshot(
      currentScene: currentScene ?? this.currentScene,
      visitedScenes: visitedScenes ?? this.visitedScenes,
      history: history ?? this.history,
      fittingFallenPiece: fittingFallenPiece ?? this.fittingFallenPiece,
      fallenPieceFitted: fallenPieceFitted ?? this.fallenPieceFitted,
      pedestalCloseUpOpen: pedestalCloseUpOpen ?? this.pedestalCloseUpOpen,
      pedestalCupCounts: pedestalCupCounts ?? this.pedestalCupCounts,
      pedestalMechanismAnimating:
          pedestalMechanismAnimating ?? this.pedestalMechanismAnimating,
      pedestalSolved: pedestalSolved ?? this.pedestalSolved,
      inventory: inventory ?? this.inventory,
      selectedItem: clearSelectedItem
          ? null
          : (selectedItem ?? this.selectedItem),
      pondLensInstalling: pondLensInstalling ?? this.pondLensInstalling,
      pondLensInstalled: pondLensInstalled ?? this.pondLensInstalled,
      pondCloseUpOpen: pondCloseUpOpen ?? this.pondCloseUpOpen,
      pondTrackProgress: pondTrackProgress ?? this.pondTrackProgress,
      pondTrackAnimating: pondTrackAnimating ?? this.pondTrackAnimating,
      pondSolved: pondSolved ?? this.pondSolved,
      clockflowerCloseUpOpen:
          clockflowerCloseUpOpen ?? this.clockflowerCloseUpOpen,
      clockflowerSelection: clearClockflowerSelection
          ? null
          : (clockflowerSelection ?? this.clockflowerSelection),
      clockflowerAnimating: clockflowerAnimating ?? this.clockflowerAnimating,
      clockflowerSolved: clockflowerSolved ?? this.clockflowerSolved,
      fountainWheelRepairing:
          fountainWheelRepairing ?? this.fountainWheelRepairing,
      fountainWheelRepaired:
          fountainWheelRepaired ?? this.fountainWheelRepaired,
      fountainStoneSelection: clearFountainStoneSelection
          ? null
          : (fountainStoneSelection ?? this.fountainStoneSelection),
      fountainStoneAnimating:
          fountainStoneAnimating ?? this.fountainStoneAnimating,
      fountainStarKeyRevealed:
          fountainStarKeyRevealed ?? this.fountainStarKeyRevealed,
      fountainStarKeyCollected:
          fountainStarKeyCollected ?? this.fountainStarKeyCollected,
      fountainChestOpening: fountainChestOpening ?? this.fountainChestOpening,
      fountainChestOpened: fountainChestOpened ?? this.fountainChestOpened,
      clues: clues ?? this.clues,
      inputLocked: inputLocked ?? this.inputLocked,
      message: message ?? this.message,
    );
  }
}

class EpisodeOneStateController extends ValueNotifier<EpisodeOneSnapshot> {
  EpisodeOneStateController() : super(EpisodeOneSnapshot.initial());

  bool canNavigateTo(EpisodeOneScene scene) {
    if (value.inputLocked || value.closeUpOpen) return false;
    if (scene == EpisodeOneScene.centralGarden) return true;
    if (scene == EpisodeOneScene.pond ||
        scene == EpisodeOneScene.clockflowerGrove) {
      return value.gardenPathsUnlocked;
    }
    return true;
  }

  bool navigateTo(EpisodeOneScene scene) {
    if (scene == value.currentScene) return true;
    if (!canNavigateTo(scene)) {
      final message = switch (scene) {
        EpisodeOneScene.pond || EpisodeOneScene.clockflowerGrove =>
          '별받침대의 균형 장치를 먼저 작동시키면 이 방향의 별길이 밝아질 것 같아요.',
        _ => '지금은 다른 장면으로 이동할 수 없어요.',
      };
      value = value.copyWith(message: message);
      return false;
    }

    final visited = {...value.visitedScenes, scene};
    final history = [...value.history, scene];
    value = value.copyWith(
      currentScene: scene,
      visitedScenes: visited,
      history: history,
      message: switch (scene) {
        EpisodeOneScene.pond => '연못의 돌거울 중앙에 별 모양 홈이 비어 있어요.',
        EpisodeOneScene.clockflowerGrove =>
          '파란 꽃은 4칸마다, 노란 꽃은 6칸마다 잠깐씩 열리고 있어요.',
        EpisodeOneScene.fountain =>
          value.fountainSolved
              ? '열린 관리 상자와 포포가 남긴 흔적을 다시 확인할 수 있어요.'
              : '바람바퀴의 끈이 끊어져 있고 관리 상자는 굳게 잠겨 있어요.',
        _ => scene.objective,
      },
    );
    return true;
  }

  void returnToGarden() {
    if (value.inputLocked) return;
    if (value.pedestalCloseUpOpen) {
      closePedestal();
      return;
    }
    if (value.pondCloseUpOpen) {
      closePondMirror();
      return;
    }
    if (value.clockflowerCloseUpOpen) {
      closeClockflowerRing();
      return;
    }
    navigateTo(EpisodeOneScene.centralGarden);
  }

  bool startFittingFallenPiece() {
    if (value.inputLocked ||
        value.currentScene != EpisodeOneScene.centralGarden ||
        value.fallenPieceFitted ||
        value.fittingFallenPiece) {
      return false;
    }
    value = value.copyWith(
      fittingFallenPiece: true,
      inputLocked: true,
      message: '별조각이 같은 모양의 빈 홈을 향해 떠오르고 있어요.',
    );
    return true;
  }

  void completeFittingFallenPiece() {
    if (!value.fittingFallenPiece) return;
    value = value.copyWith(
      fittingFallenPiece: false,
      fallenPieceFitted: true,
      inputLocked: false,
      message: '조각이 맞춰지자 받침대 안쪽에서 작은 기계음이 들렸어요.',
    );
  }

  bool openPedestal() {
    if (value.inputLocked ||
        value.currentScene != EpisodeOneScene.centralGarden) {
      return false;
    }
    if (!value.fallenPieceFitted) {
      value = value.copyWith(message: '받침대의 반달 모양 홈에 맞는 조각이 먼저 필요해요.');
      return false;
    }
    value = value.copyWith(
      pedestalCloseUpOpen: true,
      message: value.pedestalSolved
          ? '세 균형컵과 별무늬 렌즈가 있던 자리를 다시 확인할 수 있어요.'
          : PedestalBalancePuzzle.feedback(value.pedestalCupCounts),
    );
    return true;
  }

  void closePedestal() {
    if (value.inputLocked) return;
    value = value.copyWith(
      pedestalCloseUpOpen: false,
      message: value.pedestalSolved
          ? '별무늬 렌즈를 얻었어요. 연못과 시계꽃 숲의 별길이 밝아졌어요.'
          : '별받침대의 균형 장치를 다시 조사할 수 있어요.',
    );
  }

  void addDustToCup(int cupIndex) {
    if (!_canEditPedestal(cupIndex)) return;
    if (value.remainingPedestalDust <= 0) {
      value = value.copyWith(
        message: PedestalBalancePuzzle.feedback(value.pedestalCupCounts),
      );
      return;
    }

    final cups = [...value.pedestalCupCounts];
    cups[cupIndex]++;
    final solved = PedestalBalancePuzzle.isSolved(cups);
    value = value.copyWith(
      pedestalCupCounts: cups,
      pedestalMechanismAnimating: solved,
      inputLocked: solved,
      message: PedestalBalancePuzzle.feedback(cups),
    );
  }

  void removeDustFromCup(int cupIndex) {
    if (!_canEditPedestal(cupIndex)) return;
    final cups = [...value.pedestalCupCounts];
    if (cups[cupIndex] == 0) {
      value = value.copyWith(message: '이 컵에는 되돌릴 별가루가 없어요.');
      return;
    }
    cups[cupIndex]--;
    value = value.copyWith(
      pedestalCupCounts: cups,
      message: PedestalBalancePuzzle.feedback(cups),
    );
  }

  void resetPedestalDistribution() {
    if (value.inputLocked ||
        !value.pedestalCloseUpOpen ||
        value.pedestalSolved) {
      return;
    }
    value = value.copyWith(
      pedestalCupCounts: const [0, 0, 0],
      message: '별가루를 저장부로 모두 되돌렸어요.',
    );
  }

  void completePedestalMechanism() {
    if (!value.pedestalMechanismAnimating) return;
    value = value.copyWith(
      pedestalMechanismAnimating: false,
      pedestalSolved: true,
      inventory: {...value.inventory, EpisodeOneItem.starLens},
      inputLocked: false,
      message: '별무늬 렌즈를 얻었어요. 연못과 시계꽃 숲의 별길이 밝아졌어요!',
    );
  }

  void selectItem(EpisodeOneItem item) {
    if (value.inputLocked || !value.inventory.contains(item)) return;
    if (value.selectedItem == item) {
      value = value.copyWith(
        clearSelectedItem: true,
        message: '${item.label} 선택을 해제했어요.',
      );
      return;
    }
    value = value.copyWith(
      selectedItem: item,
      message: '${item.label}을 선택했어요. 모양이 맞는 곳에 사용해 보세요.',
    );
  }

  bool useSelectedItemOnPondMirror() {
    if (value.inputLocked || value.currentScene != EpisodeOneScene.pond) {
      return false;
    }
    if (value.pondLensInstalled) {
      value = value.copyWith(
        pondCloseUpOpen: true,
        message: value.pondSolved
            ? '완성된 발자국 경로를 다시 확인할 수 있어요.'
            : '둥근 발바닥과 작은 발가락이 있는 흔적을 순서대로 찾으세요.',
      );
      return true;
    }
    if (value.selectedItem != EpisodeOneItem.starLens) {
      value = value.copyWith(
        message: value.inventory.contains(EpisodeOneItem.starLens)
            ? '인벤토리에서 별무늬 렌즈를 먼저 선택하세요.'
            : '돌거울의 별 모양 홈에 맞는 물건이 필요해요.',
      );
      return false;
    }

    final inventory = {...value.inventory}..remove(EpisodeOneItem.starLens);
    value = value.copyWith(
      inventory: inventory,
      clearSelectedItem: true,
      pondLensInstalling: true,
      inputLocked: true,
      message: '별무늬 렌즈가 돌거울의 빈 홈에 맞춰지고 있어요.',
    );
    return true;
  }

  void completePondLensInstallation() {
    if (!value.pondLensInstalling) return;
    value = value.copyWith(
      pondLensInstalling: false,
      pondLensInstalled: true,
      pondCloseUpOpen: true,
      inputLocked: false,
      message: '별무늬 렌즈가 맞춰지자 과거의 흔적이 수면에 나타났어요.',
    );
  }

  void closePondMirror() {
    if (value.inputLocked) return;
    value = value.copyWith(
      pondCloseUpOpen: false,
      message: value.pondSolved
          ? '젖은 발자국 단서를 수첩에 기록했어요.'
          : '별거울의 흔적을 다시 확대 조사할 수 있어요.',
    );
  }

  void selectPondTrack(int trackIndex) {
    if (value.inputLocked ||
        !value.pondCloseUpOpen ||
        value.pondSolved ||
        trackIndex < 0 ||
        trackIndex >= 7) {
      return;
    }

    if (!PondTrackPuzzle.isExpectedTrack(
      selectedIndex: trackIndex,
      progress: value.pondTrackProgress,
    )) {
      value = value.copyWith(
        message: PondTrackPuzzle.incorrectFeedback(
          selectedIndex: trackIndex,
          progress: value.pondTrackProgress,
        ),
      );
      return;
    }

    final nextProgress = value.pondTrackProgress + 1;
    final completed = PondTrackPuzzle.isCompleted(nextProgress);
    value = value.copyWith(
      pondTrackProgress: nextProgress,
      pondTrackAnimating: completed,
      inputLocked: completed,
      message: completed
          ? '네 발자국이 하나의 물빛 경로로 이어지고 있어요.'
          : '젖은 발자국이 물빛 선으로 이어졌어요.',
    );
  }

  void completePondTrackAnimation() {
    if (!value.pondTrackAnimating) return;
    value = value.copyWith(
      pondTrackAnimating: false,
      pondSolved: true,
      clues: {...value.clues, EpisodeOneClue.wetTracks},
      inputLocked: false,
      message: '발자국은 바람 자국 위에 남았고 분수대 방향으로 이어졌어요.',
    );
  }

  bool openClockflowerRing() {
    if (value.inputLocked ||
        value.currentScene != EpisodeOneScene.clockflowerGrove) {
      return false;
    }
    value = value.copyWith(
      clockflowerCloseUpOpen: true,
      message: value.clockflowerSolved
          ? '12번째 칸과 두 꽃의 공통 개화 흔적을 다시 확인할 수 있어요.'
          : '파란 꽃은 4칸마다, 노란 꽃은 6칸마다 열려요.',
    );
    return true;
  }

  void closeClockflowerRing() {
    if (value.inputLocked) return;
    value = value.copyWith(
      clockflowerCloseUpOpen: false,
      message: value.clockflowerSolved
          ? '은빛 바람끈을 얻었어요. 분수대의 멈춘 바람바퀴에 맞을 것 같아요.'
          : '두 꽃이 처음 함께 피는 칸을 다시 조사할 수 있어요.',
    );
  }

  void selectClockflowerStep(int step) {
    if (value.inputLocked ||
        !value.clockflowerCloseUpOpen ||
        value.clockflowerSolved ||
        !ClockflowerPuzzle.isValidStep(step)) {
      return;
    }

    final solved = ClockflowerPuzzle.isSolved(step);
    value = value.copyWith(
      clockflowerSelection: step,
      clockflowerAnimating: solved,
      inputLocked: solved,
      message: ClockflowerPuzzle.feedback(step),
    );
  }

  void completeClockflowerAnimation() {
    if (!value.clockflowerAnimating) return;
    value = value.copyWith(
      clockflowerAnimating: false,
      clockflowerSolved: true,
      inventory: {...value.inventory, EpisodeOneItem.silverRibbon},
      inputLocked: false,
      message: '두 꽃이 함께 피고 가지에서 은빛 바람끈이 내려왔어요.',
    );
  }

  bool useSelectedItemOnFountainWheel() {
    if (value.inputLocked || value.currentScene != EpisodeOneScene.fountain) {
      return false;
    }
    if (value.fountainWheelRepaired) {
      value = value.copyWith(message: '바람바퀴는 은빛 바람끈으로 단단히 고쳐졌어요.');
      return true;
    }
    if (value.selectedItem != EpisodeOneItem.silverRibbon) {
      value = value.copyWith(
        message: value.inventory.contains(EpisodeOneItem.silverRibbon)
            ? '인벤토리에서 은빛 바람끈을 먼저 선택하세요.'
            : '끊어진 바람바퀴를 묶을 수 있는 길고 튼튼한 물건이 필요해요.',
      );
      return false;
    }

    final inventory = {...value.inventory}..remove(EpisodeOneItem.silverRibbon);
    value = value.copyWith(
      inventory: inventory,
      clearSelectedItem: true,
      fountainWheelRepairing: true,
      inputLocked: true,
      message: '은빛 바람끈이 끊어진 고리에 단단히 묶이고 있어요.',
    );
    return true;
  }

  void completeFountainWheelRepair() {
    if (!value.fountainWheelRepairing) return;
    value = value.copyWith(
      fountainWheelRepairing: false,
      fountainWheelRepaired: true,
      inputLocked: false,
      message: value.pondSolved
          ? '바람바퀴가 돌며 세 돌의 먼지가 날아갔어요. 연못에서 본 흔적을 찾으세요.'
          : '바람바퀴가 돌며 세 돌의 먼지가 날아갔어요. 어떤 흔적이 중요한지 연못에서 확인해 보세요.',
    );
  }

  void selectFountainStone(int stoneNumber) {
    if (value.inputLocked ||
        value.currentScene != EpisodeOneScene.fountain ||
        stoneNumber < 1 ||
        stoneNumber > 3 ||
        value.fountainStarKeyRevealed) {
      return;
    }
    if (!value.fountainWheelRepaired) {
      value = value.copyWith(message: '바람바퀴를 먼저 고치면 돌을 덮은 먼지가 사라질 것 같아요.');
      return;
    }
    if (!value.pondSolved) {
      value = value.copyWith(
        fountainStoneSelection: stoneNumber,
        message: '연못의 젖은 발자국을 먼저 확인해야 어떤 돌의 흔적이 같은지 알 수 있어요.',
      );
      return;
    }
    if (stoneNumber != 3) {
      value = value.copyWith(
        fountainStoneSelection: stoneNumber,
        message: '연못에서 본 젖은 발자국 모양과 다르네요.',
      );
      return;
    }

    value = value.copyWith(
      fountainStoneSelection: stoneNumber,
      fountainStoneAnimating: true,
      inputLocked: true,
      message: '세 번째 돌이 옆으로 움직이며 아래에서 별빛이 새어 나오고 있어요.',
    );
  }

  void completeFountainStoneReveal() {
    if (!value.fountainStoneAnimating) return;
    value = value.copyWith(
      fountainStoneAnimating: false,
      fountainStarKeyRevealed: true,
      inputLocked: false,
      message: '젖은 발자국이 있던 세 번째 돌 아래에서 별열쇠를 발견했어요.',
    );
  }

  void collectFountainStarKey() {
    if (value.inputLocked ||
        !value.fountainStarKeyRevealed ||
        value.fountainStarKeyCollected) {
      return;
    }
    value = value.copyWith(
      fountainStarKeyCollected: true,
      inventory: {...value.inventory, EpisodeOneItem.starKey},
      message: '별열쇠를 챙겼어요. 관리 상자의 별 모양 자물쇠와 맞을 것 같아요.',
    );
  }

  bool useSelectedItemOnFountainChest() {
    if (value.inputLocked || value.currentScene != EpisodeOneScene.fountain) {
      return false;
    }
    if (value.fountainChestOpened) {
      value = value.copyWith(message: '관리 상자는 이미 열려 있고 안쪽이 달빛으로 빛나고 있어요.');
      return true;
    }
    if (!value.fountainStarKeyCollected) {
      value = value.copyWith(message: '관리 상자의 별 모양 자물쇠에 맞는 열쇠를 먼저 찾아야 해요.');
      return false;
    }
    if (value.selectedItem != EpisodeOneItem.starKey) {
      value = value.copyWith(
        message: value.inventory.contains(EpisodeOneItem.starKey)
            ? '인벤토리에서 별열쇠를 먼저 선택하세요.'
            : '별 모양 자물쇠에 맞는 열쇠가 필요해요.',
      );
      return false;
    }

    final inventory = {...value.inventory}..remove(EpisodeOneItem.starKey);
    value = value.copyWith(
      inventory: inventory,
      clearSelectedItem: true,
      fountainChestOpening: true,
      inputLocked: true,
      message: '별열쇠가 자물쇠에 들어가며 별 문양이 차례로 켜지고 있어요.',
    );
    return true;
  }

  void completeFountainChestOpening() {
    if (!value.fountainChestOpening) return;
    value = value.copyWith(
      fountainChestOpening: false,
      fountainChestOpened: true,
      inventory: {...value.inventory, EpisodeOneItem.moonHandle},
      clues: {...value.clues, EpisodeOneClue.silverFurTrail},
      inputLocked: false,
      message: '달빛 손잡이를 얻고, 가시나무에 걸린 은빛 털과 접힌 잎을 수첩에 기록했어요.',
    );
  }

  void showMessage(String message) {
    if (value.inputLocked) return;
    value = value.copyWith(message: message);
  }

  bool _canEditPedestal(int cupIndex) {
    return cupIndex >= 0 &&
        cupIndex < PedestalBalancePuzzle.cupCount &&
        value.pedestalCloseUpOpen &&
        !value.inputLocked &&
        !value.pedestalSolved;
  }

  void reset() {
    value = EpisodeOneSnapshot.initial();
  }
}
