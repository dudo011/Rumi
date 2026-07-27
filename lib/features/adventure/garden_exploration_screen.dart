import 'package:flutter/material.dart';

import 'flame/pedestal_flame_prototype_screen.dart';
import 'garden_mystery_v2_screen.dart';

/// 기존 모험은 유지하면서 Flame 단일 장면 프로토타입을 비교 체험할 수 있게 한다.
/// Flame 분석 오류 수정 후 CI와 웹 배포를 다시 실행한다.
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
              key: const Key('open-flame-pedestal-prototype'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD96A),
                foregroundColor: const Color(0xFF302440),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                elevation: 10,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PedestalFlamePrototypeScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.sports_esports_rounded),
              label: const Text(
                'Flame 별받침대 체험',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
