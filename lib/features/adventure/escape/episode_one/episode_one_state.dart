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

enum EpisodeOneItem { starLens }

extension EpisodeOneItemMetadata on EpisodeOneItem {
  String get label {
    return switch (this) {
      EpisodeOneItem.starLens => '별무늬 렌즈',
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
      EpisodeOneScene.clockflowerGrove => '서로 다른 간격으로 피는 두 시계꽃을 관찰하세요.',
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
    required this.inputLocked,
    required this.message,
  })  : visitedScenes = UnmodifiableSetView(visitedScenes),
        history = UnmodifiableListView(history),
        pedestalCupCounts = UnmodifiableListView(pedestalCupCounts),
        inventory = UnmodifiableSetView(inventory);

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
  final bool inputLocked;
  final String message;

  int get remainingPedestalDust =>
      PedestalBalancePuzzle.remainingDust(pedestalCupCounts);

  bool get gardenPathsUnlocked => pedestalSolved;

  String get displayLabel {
    if (pedestalCloseUpOpen) return '별받침대 균형 장치';
    return currentScene.label;
  }

  String get objective {
    if (pedestalCloseUpOpen) {
      if (pedestalSolved) {
        return '별무늬 렌즈를 챙기고 중앙 정원으로 돌아가세요.';
      }
      if (pedestalMechanismAnimating) {
        return '세 균형컵이 맞춰지며 받침대 장치가 움직이고 있어요.';
      }
      return '별가루 12개를 세 균형컵에 똑같이 나누세요.';
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
    return '연못과 시계꽃 숲에서 바람과 발자국 단서를 찾아보세요.';
  }

  String get progressLabel {
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
    bool? inputLocked,
    String? message,
  }) {
    return EpisodeOneSnapshot(
      currentScene: currentScene ?? this.currentScene,
      visitedScenes: visitedScenes ?? this.visitedScenes,
      history: history ?? this.history,
      fittingFallenPiece: fittingFallenPiece ?? this.fittingFallenPiece,
      fallenPieceFitted: fallenPieceFitted ?? this.fallenPieceFitted,
      pedestalCloseUpOpen:
          pedestalCloseUpOpen ?? this.pedestalCloseUpOpen,
      pedestalCupCounts: pedestalCupCounts ?? this.pedestalCupCounts,
      pedestalMechanismAnimating:
          pedestalMechanismAnimating ?? this.pedestalMechanismAnimating,
      pedestalSolved: pedestalSolved ?? this.pedestalSolved,
      inventory: inventory ?? this.inventory,
      inputLocked: inputLocked ?? this.inputLocked,
      message: message ?? this.message,
    );
  }
}

class EpisodeOneStateController extends ValueNotifier<EpisodeOneSnapshot> {
  EpisodeOneStateController() : super(EpisodeOneSnapshot.initial());

  bool canNavigateTo(EpisodeOneScene scene) {
    if (value.inputLocked || value.pedestalCloseUpOpen) return false;
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
      message: scene.objective,
    );
    return true;
  }

  void returnToGarden() {
    if (value.inputLocked) return;
    if (value.pedestalCloseUpOpen) {
      closePedestal();
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
      value = value.copyWith(
        message: '받침대의 반달 모양 홈에 맞는 조각이 먼저 필요해요.',
      );
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
