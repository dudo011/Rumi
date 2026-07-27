import 'package:flutter/material.dart';

import 'escape/episode_one/episode_one_escape_screen.dart';
import 'flame/episode_1_flame_screen.dart';
import 'flame/escape_feasibility_screen.dart';
import 'garden_mystery_v2_screen.dart';

enum _DevelopmentPreview { episodeOne, flamePrototype, feasibilityLab }

/// 기존 모험은 유지하면서 개발 중인 Flame 화면을 비교할 수 있게 한다.
class GardenExplorationScreen extends StatelessWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GardenMysteryV2Screen(onContinue: onContinue),
        Positioned(
          right: 10,
          top: 68,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<_DevelopmentPreview>(
                key: const Key('open-development-preview-menu'),
                tooltip: '개발 화면 선택',
                icon: const Icon(Icons.developer_mode_rounded),
                onSelected: (preview) {
                  final Widget screen = switch (preview) {
                    _DevelopmentPreview.episodeOne =>
                      const EpisodeOneEscapeScreen(),
                    _DevelopmentPreview.flamePrototype =>
                      const EpisodeOneFlameScreen(),
                    _DevelopmentPreview.feasibilityLab =>
                      const EscapeFeasibilityScreen(),
                  };
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: (_) => screen));
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _DevelopmentPreview.episodeOne,
                    child: ListTile(
                      key: Key('open-episode-one-escape-foundation'),
                      leading: Icon(Icons.watch_later_outlined),
                      title: Text('새 방탈출 P0·P1·P2·P3 체험'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _DevelopmentPreview.flamePrototype,
                    child: ListTile(
                      key: Key('open-flame-episode-one'),
                      leading: Icon(Icons.sports_esports_rounded),
                      title: Text('Flame 1단계 전체 체험'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _DevelopmentPreview.feasibilityLab,
                    child: ListTile(
                      key: Key('open-flame-feasibility-lab'),
                      leading: Icon(Icons.science_rounded),
                      title: Text('방탈출 기술 검증'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
