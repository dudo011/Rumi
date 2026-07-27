import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'episode_one_puzzles.dart';
import 'episode_one_state.dart';

class EpisodeOneSceneComponent extends PositionComponent with TapCallbacks {
  EpisodeOneSceneComponent({required this.controller});

  final EpisodeOneStateController controller;

  double _pieceProgress = 0;
  double _mechanismProgress = 0;

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
  void update(double dt) {
    super.update(dt);
    final snapshot = controller.value;

    if (snapshot.fittingFallenPiece) {
      _pieceProgress = math.min(1, _pieceProgress + dt / 0.6).toDouble();
      if (_pieceProgress >= 1) {
        controller.completeFittingFallenPiece();
      }
    } else {
      _pieceProgress = snapshot.fallenPieceFitted ? 1 : 0;
    }

    if (snapshot.pedestalMechanismAnimating) {
      _mechanismProgress =
          math.min(1, _mechanismProgress + dt / 2).toDouble();
      if (_mechanismProgress >= 1) {
        controller.completePedestalMechanism();
      }
    } else {
      _mechanismProgress = snapshot.pedestalSolved ? 1 : 0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final snapshot = controller.value;
    if (snapshot.inputLocked) return;

    final point = event.localPosition.toOffset();
    if (snapshot.pedestalCloseUpOpen) {
      _handlePedestalTap(point);
      return;
    }

    if (snapshot.currentScene == EpisodeOneScene.centralGarden) {
      if (!snapshot.fallenPieceFitted && _fallenPieceRect.contains(point)) {
        controller.startFittingFallenPiece();
        return;
      }
      if (_pedestalRect.contains(point)) {
        controller.openPedestal();
        return;
      }
      for (final entry in _gardenTargets.entries) {
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

  void _handlePedestalTap(Offset point) {
    if (_pedestalBackButton.contains(point)) {
      controller.closePedestal();
      return;
    }
    if (_pedestalResetButton.contains(point)) {
      controller.resetPedestalDistribution();
      return;
    }

    final plus = _cupPlusRects;
    final minus = _cupMinusRects;
    for (var index = 0; index < PedestalBalancePuzzle.cupCount; index++) {
      if (plus[index].contains(point)) {
        controller.addDustToCup(index);
        return;
      }
      if (minus[index].contains(point)) {
        controller.removeDustFromCup(index);
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final snapshot = controller.value;

    if (snapshot.pedestalCloseUpOpen) {
      _drawPedestalCloseUp(canvas, snapshot);
      return;
    }

    _drawBackground(canvas, snapshot.currentScene);
    if (snapshot.currentScene == EpisodeOneScene.centralGarden) {
      _drawCentralGarden(canvas, snapshot);
    } else {
      _drawDestination(canvas, snapshot.currentScene);
    }
  }

  bool get _compact => size.x < 520 || size.y < 720;

  Rect get _pedestalRect => Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.48),
        width: math.min(size.x * 0.26, 190).toDouble(),
        height: math.min(size.y * 0.22, 165).toDouble(),
      );

  Rect get _fallenPieceRect => Rect.fromCenter(
        center: Offset(size.x * 0.39, size.y * 0.65),
        width: 72,
        height: 64,
      );

  Rect get _returnButton => Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.76),
        width: math.min(size.x * 0.62, 380).toDouble(),
        height: 58,
      );

  Rect get _pedestalBackButton =>
      Rect.fromLTWH(18, size.y - 76, 126, 50);

  Rect get _pedestalResetButton =>
      Rect.fromLTWH(size.x - 150, size.y - 76, 132, 50);

  Map<EpisodeOneScene, Rect> get _gardenTargets {
    final width = math.min(size.x * 0.28, 210).toDouble();
    final height = math.min(size.y * 0.12, 86).toDouble();
    return {
      EpisodeOneScene.pond: Rect.fromCenter(
        center: Offset(size.x * 0.17, size.y * 0.49),
        width: width,
        height: height,
      ),
      EpisodeOneScene.clockflowerGrove: Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.25),
        width: width,
        height: height,
      ),
      EpisodeOneScene.fountain: Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.73),
        width: width,
        height: height,
      ),
      EpisodeOneScene.greenhouse: Rect.fromCenter(
        center: Offset(size.x * 0.83, size.y * 0.49),
        width: width,
        height: height,
      ),
    };
  }

  List<Rect> get _cupRects {
    final width = math.min(size.x * 0.2, 126).toDouble();
    final height = math.min(size.y * 0.24, 180).toDouble();
    return List.generate(3, (index) {
      return Rect.fromCenter(
        center: Offset(size.x * (0.25 + index * 0.25), size.y * 0.56),
        width: width,
        height: height,
      );
    });
  }

  List<Rect> get _cupPlusRects => _cupRects
      .map(
        (cup) => Rect.fromCenter(
          center: Offset(cup.center.dx, cup.bottom + 28),
          width: 52,
          height: 42,
        ),
      )
      .toList(growable: false);

  List<Rect> get _cupMinusRects => _cupRects
      .map(
        (cup) => Rect.fromCenter(
          center: Offset(cup.center.dx, cup.top - 22),
          width: 52,
          height: 38,
        ),
      )
      .toList(growable: false);

  void _drawBackground(Canvas canvas, EpisodeOneScene scene) {
    final rect = Offset.zero & Size(size.x, size.y);
    final colors = switch (scene) {
      EpisodeOneScene.centralGarden => const [
          Color(0xFF111D2C),
          Color(0xFF174D45),
          Color(0xFF0B211B),
        ],
      EpisodeOneScene.pond => const [
          Color(0xFF10283E),
          Color(0xFF1D6470),
          Color(0xFF0B2632),
        ],
      EpisodeOneScene.clockflowerGrove => const [
          Color(0xFF271D45),
          Color(0xFF554474),
          Color(0xFF132925),
        ],
      EpisodeOneScene.fountain => const [
          Color(0xFF1A2C41),
          Color(0xFF3C6470),
          Color(0xFF14252C),
        ],
      EpisodeOneScene.greenhouse => const [
          Color(0xFF2D2042),
          Color(0xFF735D78),
          Color(0xFF172925),
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
    for (var index = 0; index < 20; index++) {
      final point = Offset(
        size.x * ((index * 37 % 97) / 100),
        size.y * (0.12 + ((index * 23 % 42) / 100)),
      );
      canvas.drawCircle(
        point,
        1.2 + index % 3,
        Paint()..color = const Color(0x66FFF0B0),
      );
    }
  }

  void _drawCentralGarden(Canvas canvas, EpisodeOneSnapshot snapshot) {
    _drawText(
      canvas,
      '사라진 별빛 씨앗',
      Offset(size.x * 0.5, size.y * 0.14),
      fontSize: _compact ? 20 : 27,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: size.x * 0.76,
    );
    _drawText(
      canvas,
      snapshot.pedestalSolved
          ? '균형이 돌아오자 연못과 시계꽃 숲의 별길이 켜졌어요.'
          : '강한 바람이 지나간 뒤 별받침대가 비어 버렸어요.',
      Offset(size.x * 0.5, size.y * 0.19),
      fontSize: _compact ? 11 : 14,
      color: const Color(0xFFD6E8E2),
      align: TextAlign.center,
      maxWidth: size.x * 0.76,
    );

    _drawGardenGround(canvas, snapshot);
    _drawGardenPaths(canvas);
    _drawPedestal(canvas, snapshot);
    _drawFallenPiece(canvas, snapshot);

    for (final entry in _gardenTargets.entries) {
      _drawSceneCard(
        canvas,
        entry.value,
        scene: entry.key,
        available: controller.canNavigateTo(entry.key),
        visited: snapshot.visitedScenes.contains(entry.key),
        pathsUnlocked: snapshot.gardenPathsUnlocked,
      );
    }
  }

  void _drawGardenGround(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final ground = Path()
      ..moveTo(0, size.y * 0.68)
      ..quadraticBezierTo(size.x * 0.5, size.y * 0.58, size.x, size.y * 0.68)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(ground, Paint()..color = const Color(0x66356A45));

    for (var index = 0; index < 10; index++) {
      final x = size.x * (0.06 + (index % 5) * 0.22);
      final y = size.y * (0.79 + (index % 2) * 0.06);
      canvas.drawLine(
        Offset(x, y + 20),
        Offset(x, y),
        Paint()
          ..color = const Color(0xFF7BAA72)
          ..strokeWidth = 4,
      );
      canvas.drawCircle(
        Offset(x, y),
        7 + index % 2,
        Paint()
          ..color = snapshot.pedestalSolved
              ? const Color(0xFFFFC5E0)
              : const Color(0xFF746278),
      );
    }
  }

  void _drawGardenPaths(Canvas canvas) {
    final center = _pedestalRect.center;
    for (final entry in _gardenTargets.entries) {
      final target = entry.value.center;
      final available = controller.canNavigateTo(entry.key);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          (center.dx + target.dx) / 2,
          (center.dy + target.dy) / 2 + 14,
          target.dx,
          target.dy,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = available
              ? const Color(0x88FFE39A)
              : const Color(0x334E8075)
          ..style = PaintingStyle.stroke
          ..strokeWidth = available ? 5 : 3,
      );
    }
  }

  void _drawPedestal(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final rect = _pedestalRect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(32)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9579A0), Color(0xFF4B405F)],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(32)),
      Paint()
        ..color = snapshot.fallenPieceFitted
            ? const Color(0xFFFFE59A)
            : const Color(0x88C5B5CF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final slot = Offset(rect.center.dx, rect.top + 35);
    canvas.drawArc(
      Rect.fromCircle(center: slot, radius: 28),
      math.pi * 0.15,
      math.pi * 1.7,
      false,
      Paint()
        ..color = const Color(0xFF332A45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    _drawText(
      canvas,
      snapshot.fallenPieceFitted ? '별받침대 조사' : '빈 별받침대',
      Offset(rect.center.dx, rect.center.dy + 26),
      fontSize: _compact ? 13 : 16,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: rect.width - 12,
    );
    _drawText(
      canvas,
      snapshot.fallenPieceFitted ? '눌러서 안쪽 보기' : '반달 조각이 비어 있어요',
      Offset(rect.center.dx, rect.center.dy + 49),
      fontSize: _compact ? 9 : 11,
      color: const Color(0xFFE7DDE9),
      align: TextAlign.center,
      maxWidth: rect.width - 16,
    );
  }

  void _drawFallenPiece(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final start = _fallenPieceRect.center;
    final end = Offset(_pedestalRect.center.dx, _pedestalRect.top + 35);
    final position = snapshot.fallenPieceFitted
        ? end
        : (Offset.lerp(
              start,
              end,
              Curves.easeInOutCubic.transform(_pieceProgress),
            ) ??
            start);

    _drawCrescent(canvas, position, 22);
    if (!snapshot.fallenPieceFitted && !snapshot.fittingFallenPiece) {
      _drawText(
        canvas,
        '떨어진 별조각',
        Offset(position.dx, position.dy + 34),
        fontSize: _compact ? 10 : 12,
        color: const Color(0xFFFFEEB7),
        weight: FontWeight.w800,
        align: TextAlign.center,
        maxWidth: 100,
      );
    }
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFDC72));
    canvas.drawCircle(
      Offset(center.dx + radius * 0.45, center.dy - radius * 0.18),
      radius * 0.82,
      Paint()..color = const Color(0xFF6E527A),
    );
  }

  void _drawPedestalCloseUp(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.1,
          colors: [Color(0xFF66507A), Color(0xFF263649), Color(0xFF0E1821)],
        ).createShader(rect),
    );
    _drawStars(canvas);

    _drawText(
      canvas,
      '별받침대 균형 장치',
      Offset(size.x * 0.5, size.y * 0.13),
      fontSize: _compact ? 20 : 28,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: size.x * 0.8,
    );
    _drawText(
      canvas,
      snapshot.pedestalSolved
          ? '세 컵의 균형이 맞아 별길이 다시 켜졌어요.'
          : '별가루 12개를 세 컵에 같은 수만큼 나누세요.',
      Offset(size.x * 0.5, size.y * 0.19),
      fontSize: _compact ? 11 : 14,
      color: const Color(0xFFE4DAE9),
      align: TextAlign.center,
      maxWidth: size.x * 0.82,
    );

    _drawDustReservoir(canvas, snapshot);
    _drawCups(canvas, snapshot);
    _drawMechanism(canvas, snapshot);
    _drawButton(
      canvas,
      _pedestalBackButton,
      '정원으로',
      enabled: !snapshot.inputLocked,
    );
    _drawButton(
      canvas,
      _pedestalResetButton,
      '모두 되돌리기',
      enabled: !snapshot.inputLocked && !snapshot.pedestalSolved,
    );
  }

  void _drawDustReservoir(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final box = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.29),
      width: math.min(size.x * 0.72, 500).toDouble(),
      height: 72,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(22)),
      Paint()..color = const Color(0x773A2E4A),
    );
    _drawText(
      canvas,
      '남은 별가루 ${snapshot.remainingPedestalDust}개',
      Offset(box.left + 12, box.top + 8),
      fontSize: 12,
      color: const Color(0xFFFFEEB7),
      weight: FontWeight.w800,
      maxWidth: 140,
    );

    final startX = box.center.dx - 86;
    for (var index = 0; index < snapshot.remainingPedestalDust; index++) {
      final row = index ~/ 6;
      final column = index % 6;
      canvas.drawCircle(
        Offset(startX + column * 34, box.top + 42 + row * 20),
        6,
        Paint()..color = const Color(0xFFFFD968),
      );
    }
  }

  void _drawCups(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final cups = _cupRects;
    final maxCount = snapshot.pedestalCupCounts.reduce(
      (first, second) => first > second ? first : second,
    );

    for (var index = 0; index < cups.length; index++) {
      final count = snapshot.pedestalCupCounts[index];
      final shifted = cups[index].shift(
        Offset(0, (maxCount - count) * 5.0),
      );
      final cupPath = Path()
        ..moveTo(shifted.left + 8, shifted.top + 18)
        ..lineTo(shifted.right - 8, shifted.top + 18)
        ..lineTo(shifted.right - 20, shifted.bottom)
        ..lineTo(shifted.left + 20, shifted.bottom)
        ..close();

      canvas.drawPath(
        cupPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD9C7E0), Color(0xFF7D668A)],
          ).createShader(shifted),
      );
      canvas.drawPath(
        cupPath,
        Paint()
          ..color = snapshot.pedestalSolved
              ? const Color(0xFFFFE39A)
              : const Color(0x99F1E8F4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      for (var dust = 0; dust < count; dust++) {
        canvas.drawCircle(
          Offset(
            shifted.center.dx + (dust.isEven ? -12 : 12),
            shifted.bottom - 24 - (dust ~/ 2) * 22,
          ),
          8,
          Paint()..color = const Color(0xFFFFD968),
        );
      }

      _drawText(
        canvas,
        '${index + 1}번 · $count개',
        Offset(shifted.center.dx, shifted.center.dy + 2),
        fontSize: _compact ? 10 : 13,
        color: const Color(0xFF332A45),
        weight: FontWeight.w900,
        align: TextAlign.center,
        maxWidth: shifted.width - 12,
      );
      _drawButton(
        canvas,
        _cupMinusRects[index],
        '−',
        enabled: !snapshot.inputLocked && !snapshot.pedestalSolved,
      );
      _drawButton(
        canvas,
        _cupPlusRects[index],
        '+',
        enabled: !snapshot.inputLocked &&
            !snapshot.pedestalSolved &&
            snapshot.remainingPedestalDust > 0,
      );
    }
  }

  void _drawMechanism(Canvas canvas, EpisodeOneSnapshot snapshot) {
    if (!snapshot.pedestalMechanismAnimating && !snapshot.pedestalSolved) {
      return;
    }

    final center = Offset(size.x * 0.5, size.y * 0.83);
    final progress = snapshot.pedestalSolved ? 1.0 : _mechanismProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 40),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = const Color(0xFFFFE39A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    if (snapshot.pedestalSolved || progress > 0.7) {
      canvas.drawCircle(
        center,
        24,
        Paint()..color = const Color(0xAA7BD9E5),
      );
      _drawStar(canvas, center, 16);
    }
  }

  void _drawDestination(Canvas canvas, EpisodeOneScene scene) {
    _drawText(
      canvas,
      scene.label,
      Offset(size.x * 0.5, size.y * 0.2),
      fontSize: _compact ? 23 : 31,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: size.x * 0.8,
    );

    final focus = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.48),
      width: math.min(size.x * 0.66, 500).toDouble(),
      height: math.min(size.y * 0.34, 260).toDouble(),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(36)),
      Paint()..color = const Color(0x443B5263),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(36)),
      Paint()
        ..color = const Color(0x99FFE7A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawDestinationSymbol(canvas, scene, focus.center);
    _drawText(
      canvas,
      _destinationDescription(scene),
      Offset(focus.center.dx, focus.bottom + 36),
      fontSize: _compact ? 11 : 14,
      color: const Color(0xFFE0E7E5),
      weight: FontWeight.w700,
      align: TextAlign.center,
      maxWidth: size.x * 0.75,
    );
    _drawButton(canvas, _returnButton, '중앙 정원으로 돌아가기');
  }

  void _drawDestinationSymbol(
    Canvas canvas,
    EpisodeOneScene scene,
    Offset center,
  ) {
    switch (scene) {
      case EpisodeOneScene.pond:
        canvas.drawOval(
          Rect.fromCenter(center: center, width: 210, height: 90),
          Paint()..color = const Color(0xAA66C9DA),
        );
        _drawStar(canvas, center, 32);
        break;
      case EpisodeOneScene.clockflowerGrove:
        canvas.drawCircle(
          Offset(center.dx - 48, center.dy),
          38,
          Paint()..color = const Color(0xFF77B9F2),
        );
        canvas.drawCircle(
          Offset(center.dx + 48, center.dy),
          38,
          Paint()..color = const Color(0xFFFFD86E),
        );
        break;
      case EpisodeOneScene.fountain:
        canvas.drawCircle(
          center,
          70,
          Paint()
            ..color = const Color(0xFF94C8D2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - 68),
          Offset(center.dx, center.dy + 18),
          Paint()
            ..color = const Color(0xFFCEE9EC)
            ..strokeWidth = 8,
        );
        break;
      case EpisodeOneScene.greenhouse:
        final house = Rect.fromCenter(center: center, width: 170, height: 150);
        canvas.drawRRect(
          RRect.fromRectAndRadius(house, const Radius.circular(26)),
          Paint()..color = const Color(0x4477D4B0),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(house, const Radius.circular(26)),
          Paint()
            ..color = const Color(0xFFB9E8D3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5,
        );
        _drawCrescent(canvas, center, 24);
        break;
      case EpisodeOneScene.centralGarden:
        break;
    }
  }

  String _destinationDescription(EpisodeOneScene scene) {
    return switch (scene) {
      EpisodeOneScene.centralGarden => '',
      EpisodeOneScene.pond => '별무늬 렌즈가 맞을 것 같은 돌거울이 수면을 바라보고 있어요.',
      EpisodeOneScene.clockflowerGrove => '파란 꽃과 노란 꽃이 서로 다른 간격으로 열리고 있어요.',
      EpisodeOneScene.fountain => '바람바퀴의 끈이 끊어져 있고 관리 상자는 잠겨 있어요.',
      EpisodeOneScene.greenhouse => '문에는 손잡이가 빠진 초승달 모양의 빈 홈이 있어요.',
    };
  }

  void _drawSceneCard(
    Canvas canvas,
    Rect rect, {
    required EpisodeOneScene scene,
    required bool available,
    required bool visited,
    required bool pathsUnlocked,
  }) {
    final status = switch (scene) {
      EpisodeOneScene.pond || EpisodeOneScene.clockflowerGrove =>
        pathsUnlocked ? (visited ? '조사함' : '별길 열림') : '별길 잠김',
      EpisodeOneScene.fountain => visited ? '조사함' : '장치 멈춤',
      EpisodeOneScene.greenhouse => visited ? '조사함' : '손잡이 없음',
      EpisodeOneScene.centralGarden => '',
    };

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = !available
            ? const Color(0xBB202D36)
            : visited
                ? const Color(0xCC4D8B7A)
                : const Color(0xCC304E58),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = !available
            ? const Color(0x557A8B89)
            : visited
                ? const Color(0xFFFFE39A)
                : const Color(0xAA8BD5C5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      '${visited ? '✓ ' : ''}${scene.label}',
      Offset(rect.center.dx, rect.center.dy - 10),
      fontSize: _compact ? 11 : 15,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: rect.width - 14,
    );
    _drawText(
      canvas,
      status,
      Offset(rect.center.dx, rect.center.dy + 14),
      fontSize: _compact ? 8 : 10,
      color: available
          ? const Color(0xFFFFE9AB)
          : const Color(0xFFAAB9B5),
      weight: FontWeight.w700,
      align: TextAlign.center,
      maxWidth: rect.width - 12,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final angle = -math.pi / 2 + index * math.pi / 5;
      final pointRadius = index.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * pointRadius,
        center.dy + math.sin(angle) * pointRadius,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFE27C));
  }

  void _drawButton(
    Canvas canvas,
    Rect rect,
    String label, {
    bool enabled = true,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = enabled
            ? const Color(0xFFEBCB78)
            : const Color(0xFF59656A),
    );
    _drawText(
      canvas,
      label,
      rect.center,
      fontSize: label.length <= 2 ? 24 : (_compact ? 12 : 15),
      color: enabled ? const Color(0xFF302440) : const Color(0xFFB8C1C3),
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: rect.width - 14,
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
