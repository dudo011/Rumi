import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../episode_one_puzzles.dart';
import '../episode_one_state.dart';

class EpisodeOneClockflowerOverlay extends StatelessWidget {
  const EpisodeOneClockflowerOverlay({required this.controller, super.key});

  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EpisodeOneSnapshot>(
      valueListenable: controller,
      builder: (context, snapshot, _) {
        if (snapshot.currentScene != EpisodeOneScene.clockflowerGrove) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.transparent,
          child: Container(
            key: const Key('episode-one-clockflower-overlay'),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xF0342850), Color(0xF016302C)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0x887AC9B4)),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 18),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 82),
                child: snapshot.clockflowerCloseUpOpen
                    ? _ClockflowerRingView(
                        snapshot: snapshot,
                        controller: controller,
                      )
                    : _ClockflowerGroveView(
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

class _ClockflowerGroveView extends StatelessWidget {
  const _ClockflowerGroveView({
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
          '시계꽃 숲',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          snapshot.clockflowerSolved
              ? '12번째 칸이 빛나고 두 꽃이 같은 박자로 흔들리고 있어요.'
              : '파란 꽃과 노란 꽃이 서로 다른 간격으로 잠깐씩 열리고 있어요.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFDCE9E5),
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Clockflower(
              color: const Color(0xFF79BDF0),
              label: '파란 시계꽃',
              intervalLabel: '4칸마다 개화',
              open: snapshot.clockflowerSolved,
            ),
            _Clockflower(
              color: const Color(0xFFFFD66E),
              label: '노란 시계꽃',
              intervalLabel: '6칸마다 개화',
              open: snapshot.clockflowerSolved,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x553F5266),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                snapshot.clockflowerSolved
                    ? Icons.air_rounded
                    : Icons.schedule_rounded,
                color: const Color(0xFFFFE39A),
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                snapshot.clockflowerSolved
                    ? '은빛 바람끈을 얻었어요.'
                    : '12칸 시간고리에서 두 꽃이 처음 함께 피는 칸을 찾아보세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('episode-one-open-clockflower-ring'),
            onPressed: snapshot.inputLocked
                ? null
                : controller.openClockflowerRing,
            icon: const Icon(Icons.watch_later_outlined),
            label: Text(
              snapshot.clockflowerSolved ? '시간고리 다시 보기' : '12칸 시간고리 조사',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('episode-one-clockflower-return-garden'),
            onPressed: snapshot.inputLocked ? null : controller.returnToGarden,
            icon: const Icon(Icons.park_rounded),
            label: const Text('중앙 정원으로 돌아가기'),
          ),
        ),
      ],
    );
  }
}

class _ClockflowerRingView extends StatelessWidget {
  const _ClockflowerRingView({
    required this.snapshot,
    required this.controller,
  });

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    final selected = snapshot.clockflowerSelection;
    final blueOpen = selected != null && ClockflowerPuzzle.blueOpensAt(selected);
    final yellowOpen =
        selected != null && ClockflowerPuzzle.yellowOpensAt(selected);

    return Column(
      children: [
        const Text(
          '시계꽃 시간고리',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '파란 꽃은 4칸마다, 노란 꽃은 6칸마다 열려요.\n두 꽃이 처음 함께 피는 칸을 누르세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFDCE9E5),
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Clockflower(
              color: const Color(0xFF79BDF0),
              label: '파란 꽃',
              intervalLabel: '4 · 8 · 12',
              open: snapshot.clockflowerSolved || blueOpen,
              compact: true,
            ),
            _Clockflower(
              color: const Color(0xFFFFD66E),
              label: '노란 꽃',
              intervalLabel: '6 · 12',
              open: snapshot.clockflowerSolved || yellowOpen,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final dimension = math.min(constraints.maxWidth, 300.0);
            return SizedBox.square(
              dimension: dimension,
              child: _TimeRing(
                snapshot: snapshot,
                controller: controller,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: snapshot.clockflowerAnimating
              ? TweenAnimationBuilder<double>(
                  key: const ValueKey('clockflower-success-animation'),
                  tween: Tween(begin: 0.82, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  onEnd: controller.completeClockflowerAnimation,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: const _ClockflowerSuccessCard(
                    title: '두 꽃이 함께 피었어요!',
                    subtitle: '가지의 은빛 바람끈이 풀려 내려오고 있어요.',
                  ),
                )
              : snapshot.clockflowerSolved
                  ? const _ClockflowerSuccessCard(
                      key: ValueKey('clockflower-solved'),
                      title: '은빛 바람끈 획득',
                      subtitle: '분수대의 멈춘 바람바퀴를 고칠 수 있을 것 같아요.',
                    )
                  : Container(
                      key: ValueKey(selected),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x553F5266),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        selected == null
                            ? '시간고리의 칸을 하나 선택해 보세요.'
                            : ClockflowerPuzzle.feedback(selected),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('episode-one-close-clockflower-ring'),
            onPressed: snapshot.inputLocked
                ? null
                : controller.closeClockflowerRing,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('시계꽃 숲 전체 보기'),
          ),
        ),
      ],
    );
  }
}

class _TimeRing extends StatelessWidget {
  const _TimeRing({required this.snapshot, required this.controller});

  final EpisodeOneSnapshot snapshot;
  final EpisodeOneStateController controller;

  @override
  Widget build(BuildContext context) {
    final selected = snapshot.clockflowerSelection;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = side / 2;
        final radius = side * 0.39;
        final buttonSize = side < 260 ? 36.0 : 42.0;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(
                  selectedStep: selected,
                  solved: snapshot.clockflowerSolved,
                ),
              ),
            ),
            Center(
              child: Container(
                width: side * 0.34,
                height: side * 0.34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xCC223B3A),
                  border: Border.all(color: const Color(0x8878DFC3)),
                ),
                child: Text(
                  snapshot.clockflowerSolved
                      ? '함께 개화\n12번째 칸'
                      : selected == null
                          ? '첫 공통\n개화 칸'
                          : '$selected번째 칸',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            for (var step = 1; step <= ClockflowerPuzzle.ringSize; step++)
              _positionedStep(
                step: step,
                center: center,
                radius: radius,
                buttonSize: buttonSize,
                selected: selected,
              ),
          ],
        );
      },
    );
  }

  Widget _positionedStep({
    required int step,
    required double center,
    required double radius,
    required double buttonSize,
    required int? selected,
  }) {
    final angle = -math.pi / 2 + (step - 1) * math.pi * 2 / 12;
    final left = center + math.cos(angle) * radius - buttonSize / 2;
    final top = center + math.sin(angle) * radius - buttonSize / 2;
    final isSelected = selected == step ||
        (snapshot.clockflowerSolved && step == ClockflowerPuzzle.firstCommonStep);
    final blueMark = selected != null &&
        step <= selected &&
        ClockflowerPuzzle.blueOpensAt(step);
    final yellowMark = selected != null &&
        step <= selected &&
        ClockflowerPuzzle.yellowOpensAt(step);

    return Positioned(
      left: left,
      top: top,
      width: buttonSize,
      height: buttonSize,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '시간고리 $step번째 칸',
        child: InkWell(
          key: Key('episode-one-clock-step-$step'),
          customBorder: const CircleBorder(),
          onTap: snapshot.inputLocked || snapshot.clockflowerSolved
              ? null
              : () => controller.selectClockflowerStep(step),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFFFFE39A)
                  : const Color(0xDD425866),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0x8878DFC3),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? const [BoxShadow(color: Color(0x99FFE39A), blurRadius: 12)]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$step',
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF302440)
                        : Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (blueMark)
                  const Positioned(
                    left: 4,
                    bottom: 4,
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF79BDF0),
                    ),
                  ),
                if (yellowMark)
                  const Positioned(
                    right: 4,
                    bottom: 4,
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFFFFD66E),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.selectedStep, required this.solved});

  final int? selectedStep;
  final bool solved;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.39;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0x6678DFC3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    final selection = solved ? ClockflowerPuzzle.firstCommonStep : selectedStep;
    if (selection == null) return;

    for (var step = 1; step <= selection; step++) {
      final angle = -math.pi / 2 + (step - 1) * math.pi * 2 / 12;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (ClockflowerPuzzle.blueOpensAt(step)) {
        canvas.drawLine(
          center,
          point,
          Paint()
            ..color = const Color(0x5579BDF0)
            ..strokeWidth = 3,
        );
      }
      if (ClockflowerPuzzle.yellowOpensAt(step)) {
        canvas.drawLine(
          center,
          point,
          Paint()
            ..color = const Color(0x55FFD66E)
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.selectedStep != selectedStep || oldDelegate.solved != solved;
  }
}

class _Clockflower extends StatelessWidget {
  const _Clockflower({
    required this.color,
    required this.label,
    required this.intervalLabel,
    required this.open,
    this.compact = false,
  });

  final Color color;
  final String label;
  final String intervalLabel;
  final bool open;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 78.0 : 102.0;
    return SizedBox(
      width: compact ? 120 : 140,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: open ? color : color.withValues(alpha: 0.3),
              border: Border.all(
                color: open ? Colors.white : color.withValues(alpha: 0.55),
                width: open ? 5 : 2,
              ),
              boxShadow: open
                  ? [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 22)]
                  : null,
            ),
            child: Icon(
              open ? Icons.filter_vintage_rounded : Icons.brightness_1_rounded,
              color: open ? Colors.white : color.withValues(alpha: 0.7),
              size: compact ? 48 : 62,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            intervalLabel,
            style: const TextStyle(
              color: Color(0xFFD2E1DC),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockflowerSuccessCard extends StatelessWidget {
  const _ClockflowerSuccessCard({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x665FE3C0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE39A), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.air_rounded, color: Color(0xFFFFE39A), size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFDCE9E5),
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
