import 'package:flutter/material.dart';

import '../episode_one_puzzles.dart';
import '../episode_one_state.dart';

class EpisodeOneGreenhouseOverlay extends StatelessWidget {
  const EpisodeOneGreenhouseOverlay({required this.controller, super.key});

  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EpisodeOneSnapshot>(
      valueListenable: controller,
      builder: (context, snapshot, _) {
        if (snapshot.currentScene != EpisodeOneScene.greenhouse) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.transparent,
          child: Container(
            key: const Key('episode-one-greenhouse-overlay'),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xF049385F), Color(0xF016302B)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x889ADCC5)),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 18),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 88),
                child: snapshot.greenhouseDoorOpened
                    ? _GreenhouseInterior(
                        snapshot: snapshot,
                        controller: controller,
                      )
                    : _GreenhouseDoor(
                        snapshot: snapshot,
                        controller: controller,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GreenhouseDoor extends StatelessWidget {
  const _GreenhouseDoor({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '달빛 온실',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '문 한가운데 초승달 모양 손잡이가 빠져 있어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFDCE9E5),
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 260,
          child: Center(
            child: snapshot.greenhouseDoorOpening
                ? TweenAnimationBuilder<double>(
                    key: const ValueKey('greenhouse-door-opening-animation'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    onEnd: controller.completeGreenhouseDoorOpening,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.94 + value * 0.06,
                        child: Opacity(
                          opacity: 0.55 + value * 0.45,
                          child: Transform.rotate(
                            angle: value * 1.57,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: const _MoonDoor(opening: true),
                  )
                : const _MoonDoor(opening: false),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0x553B4D59),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            snapshot.selectedItem == EpisodeOneItem.moonHandle
                ? '선택한 달빛 손잡이가 초승달 모양 홈과 정확히 맞을 것 같아요.'
                : '분수대 관리 상자에서 얻은 달빛 손잡이가 필요해요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('episode-one-use-handle-on-greenhouse'),
            onPressed: snapshot.inputLocked
                ? null
                : controller.useSelectedItemOnGreenhouseDoor,
            icon: const Icon(Icons.nights_stay_rounded),
            label: const Text(
              '선택한 아이템으로 문 열기',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('episode-one-greenhouse-return-garden'),
            onPressed: snapshot.inputLocked ? null : controller.returnToGarden,
            icon: const Icon(Icons.park_rounded),
            label: const Text('중앙 정원으로 돌아가기'),
          ),
        ),
      ],
    );
  }
}

class _GreenhouseInterior extends StatelessWidget {
  const _GreenhouseInterior({
    required this.snapshot,
    required this.controller,
  });

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '달빛 화단 균형 장치',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '별 18개와 달 24개를 남김없이 똑같이 나눌 수 있는 가장 많은 화단을 찾으세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFDCE9E5),
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _EnergyCard(
                icon: Icons.auto_awesome_rounded,
                label: '별 에너지',
                count: 18,
                color: Color(0xFFFFD96A),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _EnergyCard(
                icon: Icons.nights_stay_rounded,
                label: '달 에너지',
                count: 24,
                color: Color(0xFFB8A8F4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _BedChoicePanel(snapshot: snapshot, controller: controller),
        const SizedBox(height: 14),
        _DistributionPreview(snapshot: snapshot),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: snapshot.greenhouseBalanceAnimating
              ? TweenAnimationBuilder<double>(
                  key: const ValueKey('greenhouse-balance-animation'),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1800),
                  onEnd: controller.completeGreenhouseBalanceAnimation,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + value * 0.1,
                      child: Opacity(opacity: 0.45 + value * 0.55, child: child),
                    );
                  },
                  child: const _DiscoveryCard(discovered: false),
                )
              : snapshot.seedFound
                  ? const _DiscoveryCard(
                      key: ValueKey('greenhouse-seed-found'),
                      discovered: true,
                    )
                  : _FeedbackCard(selection: snapshot.greenhouseBedSelection),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('episode-one-greenhouse-interior-return'),
            onPressed: snapshot.inputLocked ? null : controller.returnToGarden,
            icon: const Icon(Icons.park_rounded),
            label: const Text('중앙 정원으로 돌아가기'),
          ),
        ),
      ],
    );
  }
}

class _MoonDoor extends StatelessWidget {
  const _MoonDoor({required this.opening});

  final bool opening;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xAA75C8B0), Color(0xAA5D4C78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
        border: Border.all(
          color: opening ? const Color(0xFFFFE39A) : const Color(0xFFB9E8D3),
          width: 5,
        ),
        boxShadow: opening
            ? const [BoxShadow(color: Color(0x99FFE39A), blurRadius: 28)]
            : null,
      ),
      child: Center(
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x66302A46),
            border: Border.all(color: const Color(0xFFFFE39A), width: 3),
          ),
          child: const Icon(
            Icons.nights_stay_rounded,
            color: Color(0xFFFFE39A),
            size: 46,
          ),
        ),
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '$count개',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BedChoicePanel extends StatelessWidget {
  const _BedChoicePanel({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0x553B4D59),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text(
            '화단 수 선택',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final bedCount in GreenhouseBalancePuzzle.choices)
                ChoiceChip(
                  key: Key('episode-one-greenhouse-bed-$bedCount'),
                  label: Text('$bedCount개'),
                  selected: snapshot.greenhouseBedSelection == bedCount,
                  onSelected: snapshot.inputLocked || snapshot.seedFound
                      ? null
                      : (_) => controller.selectGreenhouseBedCount(bedCount),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributionPreview extends StatelessWidget {
  const _DistributionPreview({required this.snapshot});

  final EpisodeOneSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final selection = snapshot.greenhouseBedSelection;
    if (selection == null) {
      return const _EmptyPreview();
    }

    final starPerBed = GreenhouseBalancePuzzle.starPerBed(selection);
    final moonPerBed = GreenhouseBalancePuzzle.moonPerBed(selection);
    final starRemainder = GreenhouseBalancePuzzle.starRemainder(selection);
    final moonRemainder = GreenhouseBalancePuzzle.moonRemainder(selection);

    return Container(
      key: const Key('episode-one-greenhouse-distribution'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x55314C47),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: snapshot.seedFound
              ? const Color(0xFFFFE39A)
              : const Color(0x5578DFC3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$selection개 화단에 자동 분배',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '화단마다 별 $starPerBed개 · 달 $moonPerBed개',
            style: const TextStyle(
              color: Color(0xFFDCE9E5),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '남은 별 $starRemainder개 · 남은 달 $moonRemainder개',
            style: TextStyle(
              color: starRemainder == 0 && moonRemainder == 0
                  ? const Color(0xFF9EF0D3)
                  : const Color(0xFFFFC59A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [
              for (var index = 0; index < selection; index++)
                Container(
                  width: 42,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0x665A8C78),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x88A7E8D0)),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x443B4D59),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '화단 수를 선택하면 별과 달 에너지가 자동으로 나뉘어요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFDCE9E5),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.selection});

  final int? selection;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(selection),
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0x553F5266),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        selection == null
            ? '두 에너지를 모두 나눌 수 있는 가장 많은 화단을 선택하세요.'
            : GreenhouseBalancePuzzle.feedback(selection!),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({required this.discovered, super.key});

  final bool discovered;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('episode-one-greenhouse-discovery'),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x775FE3C0), Color(0x77785F92)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE39A), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFE39A),
                size: 36,
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFB9D8D0),
                child: Icon(
                  discovered ? Icons.pets_rounded : Icons.lock_open_rounded,
                  color: const Color(0xFF4D4563),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            discovered ? '별빛 씨앗과 포포 발견' : '이끼 보관대가 열리고 있어요',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            discovered
                ? '씨앗은 따뜻한 달빛 이끼 위에 잎으로 감싸여 있었어요. 포포는 씨앗이 얼지 않도록 지키고 있었어요.'
                : '여섯 화단의 빛이 차례로 켜지고 안쪽 보관대가 올라오고 있어요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDCE9E5),
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
