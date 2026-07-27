import 'package:flutter/material.dart';

import 'flame/episode_1_flame_screen.dart';
import 'garden_mystery_v2_screen.dart';

/// 기존 모험은 유지하면서 Flame 1단계 전체 체험판을 비교할 수 있게 한다.
/// 전체 상호작용 검증용 빌드 진입점이다.
class GardenExplorationScreen extends StatelessWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GardenMysteryV2Screen(onContinue: onContinue),
        Positioned(
          left: 16,
          bottom: 18,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('open-flame-episode-one'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD96A),
                foregroundColor: const Color(0xFF302440),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                elevation: 10,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EpisodeOneFlameScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.sports_esports_rounded),
              label: const Text(
                'Flame 1단계 전체 체험',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
