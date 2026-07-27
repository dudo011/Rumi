import 'package:flutter/material.dart';

import 'garden_mystery_v2_screen.dart';

/// 기존 호출부와의 호환성을 유지하면서 직접 조작형 조사 화면을 사용한다.
/// 2026-07-27: 인터랙티브 별받침대 장면 배포 재실행.
class GardenExplorationScreen extends StatelessWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  Widget build(BuildContext context) {
    return GardenMysteryV2Screen(onContinue: onContinue);
  }
}
