import 'dart:collection';

import 'package:flutter/foundation.dart';

enum EpisodeOneScene {
  centralGarden,
  pond,
  clockflowerGrove,
  fountain,
  greenhouse,
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
      EpisodeOneScene.centralGarden => '별받침대와 네 방향의 장소를 살펴보세요.',
      EpisodeOneScene.pond => '연못 장면의 중심 오브젝트 위치를 확인하세요.',
      EpisodeOneScene.clockflowerGrove => '시계꽃 숲 장면의 이동과 상태 유지를 확인하세요.',
      EpisodeOneScene.fountain => '분수대 장면을 확인한 뒤 중앙 정원으로 돌아가세요.',
      EpisodeOneScene.greenhouse => '온실 장면의 문과 확대 조사 위치를 확인하세요.',
    };
  }
}

@immutable
class EpisodeOneSnapshot {
  EpisodeOneSnapshot({
    required this.currentScene,
    required Set<EpisodeOneScene> visitedScenes,
    required List<EpisodeOneScene> history,
  })  : visitedScenes = UnmodifiableSetView(visitedScenes),
        history = UnmodifiableListView(history);

  factory EpisodeOneSnapshot.initial() {
    return EpisodeOneSnapshot(
      currentScene: EpisodeOneScene.centralGarden,
      visitedScenes: {EpisodeOneScene.centralGarden},
      history: const [EpisodeOneScene.centralGarden],
    );
  }

  final EpisodeOneScene currentScene;
  final Set<EpisodeOneScene> visitedScenes;
  final List<EpisodeOneScene> history;

  String get objective => currentScene.objective;
}

class EpisodeOneStateController extends ValueNotifier<EpisodeOneSnapshot> {
  EpisodeOneStateController() : super(EpisodeOneSnapshot.initial());

  void navigateTo(EpisodeOneScene scene) {
    if (scene == value.currentScene) return;

    final visited = {...value.visitedScenes, scene};
    final history = [...value.history, scene];
    value = EpisodeOneSnapshot(
      currentScene: scene,
      visitedScenes: visited,
      history: history,
    );
  }

  void returnToGarden() {
    navigateTo(EpisodeOneScene.centralGarden);
  }

  void reset() {
    value = EpisodeOneSnapshot.initial();
  }
}
