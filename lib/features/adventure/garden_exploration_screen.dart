import 'package:flutter/material.dart';

import 'garden_mystery_screen.dart';

/// 기존 호출부와의 호환성을 유지하면서 새 몰입형 조사 화면을 사용한다.
class GardenExplorationScreen extends StatelessWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  Widget build(BuildContext context) {
    return GardenMysteryScreen(onContinue: onContinue);
  }
}
