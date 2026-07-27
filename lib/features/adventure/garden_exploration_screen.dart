import 'package:flutter/material.dart';

import 'escape/episode_one/episode_one_escape_screen.dart';
import 'flame/episode_1_flame_screen.dart';
import 'flame/escape_feasibility_screen.dart';
import 'garden_mystery_v2_screen.dart';

/// 기존 모험은 유지하면서 Flame 프로토타입을 비교할 수 있게 한다.
class GardenExplorationScreen extends StatelessWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GardenMysteryV2Screen(onContinue: onContinue),
        Positioned(
          right: 16,
          top: 18,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('open-flame-feasibility-lab'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF78DFC3),
                foregroundColor: const Color(0xFF17332D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                elevation: 10,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EscapeFeasibilityScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.science_rounded),
              label: const Text(
                '방탈출 기술 검증',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 84,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('open-episode-one-escape-foundation'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8BE0C4),
                foregroundColor: const Color(0xFF17332D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                elevation: 10,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EpisodeOneEscapeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.account_tree_rounded),
              label: const Text(
                '새 방탈출 기반 체험',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 18,
          child: SafeArea(
            child: FilledButton.icon(
              key: const Key('open-flame-episode-one'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD96A),
                foregroundColor: const Color(0xFF302440),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
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
