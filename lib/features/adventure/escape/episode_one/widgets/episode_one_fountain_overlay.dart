import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../episode_one_state.dart';

class EpisodeOneFountainOverlay extends StatelessWidget {
  const EpisodeOneFountainOverlay({required this.controller, super.key});

  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EpisodeOneSnapshot>(
      valueListenable: controller,
      builder: (context, snapshot, _) {
        if (snapshot.currentScene != EpisodeOneScene.fountain) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.transparent,
          child: Container(
            key: const Key('episode-one-fountain-overlay'),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xF0274052), Color(0xF011282E)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x8894D9E5)),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 18),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 88),
                child: _FountainContent(
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

class _FountainContent extends StatelessWidget {
  const _FountainContent({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '멈춘 분수대',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          snapshot.fountainSolved
              ? '관리 상자가 열리고 온실 방향으로 이어지는 흔적이 드러났어요.'
              : '시계꽃 숲의 물건과 연못에서 본 흔적을 함께 사용하세요.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD9E9E7),
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _WheelSection(snapshot: snapshot, controller: controller),
        const SizedBox(height: 12),
        _StoneSection(snapshot: snapshot, controller: controller),
        const SizedBox(height: 12),
        _ChestSection(snapshot: snapshot, controller: controller),
        if (snapshot.fountainChestOpened) ...[
          const SizedBox(height: 12),
          const _EvidenceSection(),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('episode-one-fountain-return-garden'),
            onPressed: snapshot.inputLocked ? null : controller.returnToGarden,
            icon: const Icon(Icons.park_rounded),
            label: const Text('중앙 정원으로 돌아가기'),
          ),
        ),
      ],
    );
  }
}

class _WheelSection extends StatelessWidget {
  const _WheelSection({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '1. 바람바퀴 수리',
      complete: snapshot.fountainWheelRepaired,
      child: Column(
        children: [
          SizedBox(
            height: 122,
            child: Center(
              child: snapshot.fountainWheelRepairing
                  ? TweenAnimationBuilder<double>(
                      key: const ValueKey('fountain-wheel-repairing'),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1300),
                      onEnd: controller.completeFountainWheelRepair,
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * math.pi * 3,
                          child: Transform.scale(
                            scale: 0.88 + value * 0.12,
                            child: child,
                          ),
                        );
                      },
                      child: const _Pinwheel(repaired: true),
                    )
                  : AnimatedRotation(
                      turns: snapshot.fountainWheelRepaired ? 1 : 0,
                      duration: const Duration(milliseconds: 900),
                      child: _Pinwheel(
                        repaired: snapshot.fountainWheelRepaired,
                      ),
                    ),
            ),
          ),
          Text(
            snapshot.fountainWheelRepaired
                ? '은빛 바람끈이 고리를 단단히 묶고 있어요.'
                : '바람바퀴의 끈이 끊어져 움직이지 않아요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD9E9E7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('episode-one-use-ribbon-on-wheel'),
              onPressed: snapshot.inputLocked || snapshot.fountainWheelRepaired
                  ? null
                  : controller.useSelectedItemOnFountainWheel,
              icon: const Icon(Icons.air_rounded),
              label: Text(
                snapshot.fountainWheelRepaired
                    ? '바람바퀴 수리 완료'
                    : '선택한 아이템으로 수리',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoneSection extends StatelessWidget {
  const _StoneSection({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '2. 흔적이 있는 돌 찾기',
      complete: snapshot.fountainStarKeyRevealed,
      child: Column(
        children: [
          Text(
            !snapshot.fountainWheelRepaired
                ? '바람바퀴를 고치면 돌을 덮은 먼지가 사라져요.'
                : !snapshot.pondSolved
                    ? '연못의 젖은 발자국 단서가 있어야 흔적을 비교할 수 있어요.'
                    : '연못에서 본 작은 발가락이 있는 젖은 흔적과 같은 돌을 고르세요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD9E9E7),
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var stone = 1; stone <= 3; stone++) ...[
                Expanded(
                  child: _StoneButton(
                    stoneNumber: stone,
                    selected: snapshot.fountainStoneSelection == stone,
                    enabled: snapshot.fountainWheelRepaired &&
                        !snapshot.inputLocked &&
                        !snapshot.fountainStarKeyRevealed,
                    onTap: () => controller.selectFountainStone(stone),
                  ),
                ),
                if (stone != 3) const SizedBox(width: 8),
              ],
            ],
          ),
          if (snapshot.fountainStoneAnimating) ...[
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              key: const ValueKey('fountain-stone-reveal-animation'),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              onEnd: controller.completeFountainStoneReveal,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(value * 34, 0),
                  child: Opacity(opacity: 0.4 + value * 0.6, child: child),
                );
              },
              child: const _KeyRevealCard(revealed: false),
            ),
          ] else if (snapshot.fountainStarKeyRevealed) ...[
            const SizedBox(height: 12),
            _KeyRevealCard(
              revealed: true,
              collected: snapshot.fountainStarKeyCollected,
              onCollect: snapshot.fountainStarKeyCollected
                  ? null
                  : controller.collectFountainStarKey,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChestSection extends StatelessWidget {
  const _ChestSection({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '3. 관리 상자 열기',
      complete: snapshot.fountainChestOpened,
      child: Column(
        children: [
          if (snapshot.fountainChestOpening)
            TweenAnimationBuilder<double>(
              key: const ValueKey('fountain-chest-opening-animation'),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              onEnd: controller.completeFountainChestOpening,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + value * 0.1,
                  child: Opacity(opacity: 0.45 + value * 0.55, child: child),
                );
              },
              child: const _Chest(open: true),
            )
          else
            _Chest(open: snapshot.fountainChestOpened),
          const SizedBox(height: 8),
          Text(
            snapshot.fountainChestOpened
                ? '상자 안에서 달빛 손잡이가 떠올랐어요.'
                : snapshot.fountainStarKeyCollected
                    ? '별열쇠를 선택해 별 모양 자물쇠에 사용하세요.'
                    : '상자에는 별 모양 자물쇠가 걸려 있어요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD9E9E7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('episode-one-use-key-on-chest'),
              onPressed: snapshot.inputLocked || snapshot.fountainChestOpened
                  ? null
                  : controller.useSelectedItemOnFountainChest,
              icon: const Icon(Icons.key_rounded),
              label: Text(
                snapshot.fountainChestOpened
                    ? '관리 상자 개방 완료'
                    : '선택한 아이템으로 열기',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('episode-one-fountain-evidence'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x665FE3C0), Color(0x665E4B7A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE39A), width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.nights_stay_rounded, color: Color(0xFFFFE39A), size: 34),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '달빛 손잡이와 새 단서 획득',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '바람바퀴 뒤의 은빛 털과 접힌 잎은 포포가 씨앗을 따라 온실 쪽으로 이동했음을 보여줘요.',
                  style: TextStyle(
                    color: Color(0xFFD9E9E7),
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.complete,
    required this.child,
  });

  final String title;
  final bool complete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: complete ? const Color(0x554B8B79) : const Color(0x553B4D59),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: complete ? const Color(0xFFFFE39A) : const Color(0x557AC9D4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                complete ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 18,
                color: complete
                    ? const Color(0xFFFFE39A)
                    : const Color(0xFF9FD5D9),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Pinwheel extends StatelessWidget {
  const _Pinwheel({required this.repaired});

  final bool repaired;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 104,
      child: CustomPaint(painter: _PinwheelPainter(repaired: repaired)),
    );
  }
}

class _PinwheelPainter extends CustomPainter {
  const _PinwheelPainter({required this.repaired});

  final bool repaired;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = const [
      Color(0xFF8BD8E5),
      Color(0xFFFFD77A),
      Color(0xFFB6A2E8),
      Color(0xFF86D6A8),
    ];

    for (var index = 0; index < 4; index++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(index * math.pi / 2);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(42, -12, 44, -44)
        ..quadraticBezierTo(12, -42, 0, 0)
        ..close();
      paint.color = colors[index];
      canvas.drawPath(path, paint);
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      10,
      Paint()..color = const Color(0xFFFFE39A),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 10),
      Offset(center.dx, size.height),
      Paint()
        ..color = const Color(0xFFB7CAD0)
        ..strokeWidth = 7,
    );
    if (repaired) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 18),
        0,
        math.pi * 1.5,
        false,
        Paint()
          ..color = const Color(0xFFF0F4F6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PinwheelPainter oldDelegate) {
    return oldDelegate.repaired != repaired;
  }
}

class _StoneButton extends StatelessWidget {
  const _StoneButton({
    required this.stoneNumber,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int stoneNumber;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mark = switch (stoneNumber) {
      1 => Icons.water_drop_rounded,
      2 => Icons.air_rounded,
      3 => Icons.pets_rounded,
      _ => Icons.circle,
    };
    return InkWell(
      key: Key('episode-one-fountain-stone-$stoneNumber'),
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 92,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0x6687D8E5)
              : const Color(0xCC56656B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFFFFE39A)
                : const Color(0x778FAEB4),
            width: selected ? 3 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mark, color: const Color(0xFFDCE9E5), size: 30),
            const SizedBox(height: 5),
            Text(
              '$stoneNumber번 돌',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyRevealCard extends StatelessWidget {
  const _KeyRevealCard({
    required this.revealed,
    this.collected = false,
    this.onCollect,
  });

  final bool revealed;
  final bool collected;
  final VoidCallback? onCollect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x554F6071),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x99FFE39A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, color: Color(0xFFFFE39A), size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              collected
                  ? '별열쇠를 인벤토리에 보관했어요.'
                  : revealed
                      ? '세 번째 돌 아래에서 별열쇠를 발견했어요.'
                      : '돌 아래에서 별빛이 새어 나오고 있어요.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (revealed && !collected)
            TextButton(
              key: const Key('episode-one-collect-star-key'),
              onPressed: onCollect,
              child: const Text('챙기기'),
            ),
        ],
      ),
    );
  }
}

class _Chest extends StatelessWidget {
  const _Chest({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: open ? 5 : 30,
            child: Transform.rotate(
              angle: open ? -0.18 : 0,
              child: Container(
                width: 150,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF80634F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD98A), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            child: Container(
              width: 150,
              height: 65,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF6A4D42),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD98A), width: 2),
                boxShadow: open
                    ? const [
                        BoxShadow(color: Color(0xAAE7D1FF), blurRadius: 24),
                      ]
                    : null,
              ),
              child: Icon(
                open ? Icons.nights_stay_rounded : Icons.lock_rounded,
                color: const Color(0xFFFFE39A),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
