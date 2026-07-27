import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'episode_one_scene.dart';
import 'episode_one_state.dart';

class EpisodeOneEscapeGame extends FlameGame {
  EpisodeOneEscapeGame({required this.controller});

  final EpisodeOneStateController controller;

  @override
  Color backgroundColor() => const Color(0xFF08141C);

  @override
  Future<void> onLoad() async {
    await add(EpisodeOneSceneComponent(controller: controller));
  }
}
