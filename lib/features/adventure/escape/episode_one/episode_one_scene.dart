import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'episode_one_state.dart';

class EpisodeOneSceneComponent extends PositionComponent with TapCallbacks {
  EpisodeOneSceneComponent({required this.controller});

  final EpisodeOneStateController controller;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final point = event.localPosition.toOffset();
    final scene = controller.value.currentScene;

    if (scene == EpisodeOneScene.centralGarden) {
      final targets = _gardenTargets;
      for (final entry in targets.entries) {
        if (entry.value.contains(point)) {
          controller.navigateTo(entry.key);
          return;
        }
      }
      return;
    }

    if (_returnButton.contains(point)) {
      controller.returnToGarden();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final scene = controller.value.currentScene;
    _drawBackground(canvas, scene);

    if (scene == EpisodeOneScene.centralGarden) {
      _drawCentralGarden(canvas);
    } else {
      _drawDestinationScene(canvas, scene);
    }
  }

  Map<EpisodeOneScene, Rect> get _gardenTargets {
    final cardWidth = math.min(size.x * 0.28, 220).toDouble();
    final cardHeight = math.min(size.y * 0.13, 96).toDouble();

    return {
      EpisodeOneScene.pond: Rect.fromCenter(
        center: Offset(size.x * 0.18, size.y * 0.5),
        width: cardWidth,
        height: cardHeight,
      ),
      EpisodeOneScene.clockflowerGrove: Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.25),
        width: cardWidth,
        height: cardHeight,
      ),
      EpisodeOneScene.fountain: Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.72),
        width: cardWidth,
        height: cardHeight,
      ),
      EpisodeOneScene.greenhouse: Rect.fromCenter(
        center: Offset(size.x * 0.82, size.y * 0.5),
        width: cardWidth,
        height: cardHeight,
      ),
    };
  }

  Rect get _returnButton {
    return Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.77),
      width: math.min(size.x * 0.56, 360).toDouble(),
      height: 58,
    );
  }

  void _drawBackground(Canvas canvas, EpisodeOneScene scene) {
    final rect = Offset.zero & Size(size.x, size.y);
    final colors = switch (scene) {
      EpisodeOneScene.centralGarden => const [
          Color(0xFF172B3A),
          Color(0xFF174D45),
          Color(0xFF0D281F),
        ],
      EpisodeOneScene.pond => const [
          Color(0xFF153247),
          Color(0xFF1C5A67),
          Color(0xFF102D3A),
        ],
      EpisodeOneScene.clockflowerGrove => const [
          Color(0xFF2B244A),
          Color(0xFF4A3D68),
          Color(0xFF152C2A),
        ],
      EpisodeOneScene.fountain => const [
          Color(0xFF213247),
          Color(0xFF385B65),
          Color(0xFF18272E),
        ],
      EpisodeOneScene.greenhouse => const [
          Color(0xFF302344),
          Color(0xFF65506C),
          Color(0xFF1B2C29),
        ],
    };

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );

    _drawStars(canvas);
  }

  void _drawStars(Canvas canvas) {
    final paint = Paint()..color = const Color(0x66FFF3B8);
    for (var index = 0; index < 18; index++) {
      final x = size.x * ((index * 37 % 97) / 100);
      final y = size.y * (0.12 + ((index * 23 % 48) / 100));
      canvas.drawCircle(Offset(x, y), 1.6 + index % 3, paint);
    }
  }

  void _drawCentralGarden(Canvas canvas) {
    _drawText(
      canvas,
      'Episode 1 장면 이동 기반',
      Offset(size.x * 0.5, size.y * 0.15),
      fontSize: 26,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: size.x * 0.8,
    );
    _drawText(
      canvas,
      '현재 단계에서는 네 장소를 모두 열어 장면 전환과 상태 유지만 확인합니다.',
      Offset(size.x * 0.5, size.y * 0.2),
      fontSize: 14,
      color: const Color(0xFFD6E8E2),
      align: TextAlign.center,
      maxWidth: size.x * 0.78,
    );

    final pedestal = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.49),
      width: math.min(size.x * 0.24, 180).toDouble(),
      height: math.min(size.y * 0.2, 150).toDouble(),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pedestal, const Radius.circular(32)),
      Paint()..color = const Color(0xCC8A6B91),
    );
    canvas.drawCircle(
      Offset(size.x * 0.5, pedestal.top + 26),
      30,
      Paint()..color = const Color(0xFFFFE695),
    );
    _drawText(
      canvas,
      '빈 별받침대',
      Offset(size.x * 0.5, pedestal.center.dy + 24),
      fontSize: 16,
      weight: FontWeight.w800,
      align: TextAlign.center,
      maxWidth: pedestal.width - 12,
    );

    final targets = _gardenTargets;
    for (final entry in targets.entries) {
      final visited = controller.value.visitedScenes.contains(entry.key);
      _drawSceneCard(
        canvas,
        entry.value,
        label: entry.key.label,
        visited: visited,
      );
    }
  }

  void _drawDestinationScene(Canvas canvas, EpisodeOneScene scene) {
    _drawText(
      canvas,
      scene.label,
      Offset(size.x * 0.5, size.y * 0.2),
      fontSize: 30,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: size.x * 0.8,
    );

    final focus = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.48),
      width: math.min(size.x * 0.62, 500).toDouble(),
      height: math.min(size.y * 0.32, 260).toDouble(),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(36)),
      Paint()..color = const Color(0x663B5263),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(36)),
      Paint()
        ..color = const Color(0x99FFE7A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    _drawText(
      canvas,
      _placeholderFor(scene),
      focus.center,
      fontSize: 18,
      color: const Color(0xFFF4F0E8),
      weight: FontWeight.w700,
      align: TextAlign.center,
      maxWidth: focus.width - 48,
    );

    _drawButton(canvas, _returnButton, '중앙 정원으로 돌아가기');
  }

  String _placeholderFor(EpisodeOneScene scene) {
    return switch (scene) {
      EpisodeOneScene.centralGarden => '',
      EpisodeOneScene.pond => '별거울과 젖은 발자국이 들어갈 장면 영역',
      EpisodeOneScene.clockflowerGrove => '12칸 시간고리와 두 시계꽃이 들어갈 장면 영역',
      EpisodeOneScene.fountain => '바람바퀴, 소용돌이 돌과 관리 상자가 들어갈 장면 영역',
      EpisodeOneScene.greenhouse => '달빛 문과 화단 균형 장치가 들어갈 장면 영역',
    };
  }

  void _drawSceneCard(
    Canvas canvas,
    Rect rect, {
    required String label,
    required bool visited,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = visited
            ? const Color(0xCC4D8B7A)
            : const Color(0xBB273F4B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = visited
            ? const Color(0xFFFFE39A)
            : const Color(0x778BD5C5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      visited ? '✓ $label' : label,
      rect.center,
      fontSize: 16,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: rect.width - 18,
    );
  }

  void _drawButton(Canvas canvas, Rect rect, String label) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      Paint()..color = const Color(0xFFEBCB78),
    );
    _drawText(
      canvas,
      label,
      rect.center,
      fontSize: 16,
      color: const Color(0xFF302440),
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: rect.width - 20,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchor, {
    required double fontSize,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w600,
    TextAlign align = TextAlign.left,
    double? maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1.35,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? size.x);

    final offset = align == TextAlign.center
        ? Offset(anchor.dx - painter.width / 2, anchor.dy - painter.height / 2)
        : anchor;
    painter.paint(canvas, offset);
  }
}
