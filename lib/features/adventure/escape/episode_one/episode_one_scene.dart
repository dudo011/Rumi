import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'episode_one_puzzles.dart';
import 'episode_one_state.dart';

class EpisodeOneSceneComponent extends PositionComponent with TapCallbacks {
  EpisodeOneSceneComponent({required this.controller});

  final EpisodeOneStateController controller;

  double _pieceAnimationProgress = 0;
  double _pedestalAnimationProgress = 0;

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
      _pieceAnimationProgress = math.min(
        1,
        _pieceAnimationProgress + dt / 0.6,
      );
      if (_pieceAnimationProgress >= 1) {
        controller.completeFittingFallenPiece();
      }
    } else {
      _pieceAnimationProgress = snapshot.fallenPieceFitted ? 1 : 0;
    }

    if (snapshot.pedestalMechanismAnimating) {
      _pedestalAnimationProgress = math.min(
        1,
        _pedestalAnimationProgress + dt / 2,
      );
      if (_pedestalAnimationProgress >= 1) {
        controller.completePedestalMechanism();
      }
    } else {
      _pedestalAnimationProgress = snapshot.pedestalSolved ? 1 : 0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final point = event.localPosition.toOffset();
    final snapshot = controller.value;
    if (snapshot.inputLocked) return;

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

    final plusRects = _cupPlusRects;
    final minusRects = _cupMinusRects;
    for (var index = 0; index < PedestalBalancePuzzle.cupCount; index++) {
      if (plusRects[index].contains(point)) {
        controller.addDustToCup(index);
        return;
      }
      if (minusRects[index].contains(point)) {
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
      _drawDestinationScene(canvas, snapshot.currentScene);
    }
  }

  bool get _compact => size.x < 520 || size.y < 720;

  Rect get _pedestalRect {
    return Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.48),
      width: math.min(size.x * 0.25, 190).toDouble(),
      height: math.min(size.y * 0.23, 170).toDouble(),
    );
  }

  Rect get _fallenPieceRect {
    return Rect.fromCenter(
      center: Offset(size.x * 0.39, size.y * 0.65),
      width: 72,
      height: 64,
    );
  }

  Map<EpisodeOneScene, Rect> get _gardenTargets {
    final cardWidth = math.min(size.x * 0.28, 210).toDouble();
    final cardHeight = math.min(size.y * 0.12, 88).toDouble();

    return {
      EpisodeOneScene.pond: Rect.fromCenter(
        center: Offset(size.x * 0.17, size.y * 0.49),
        width: cardWidth,
        height: cardHeight,
      ),
      EpisodeOneScene.clockflowerGrove: Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.25),
        width: cardWidth,
        height: cardHeight,
      ),
      EpisodeOneScene.fountain: Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.73),
        width: cardWidth,
        height: cardHeight,
      ),
      EpisodeOneScene.greenhouse: Rect.fromCenter(
        center: Offset(size.x * 0.83, size.y * 0.49),
        width: cardWidth,
        height: cardHeight,
      ),
    };
  }

  Rect get _returnButton {
    return Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.76),
      width: math.min(size.x * 0.62, 380).toDouble(),
      height: 58,
    );
  }

  Rect get _pedestalBackButton {
    return Rect.fromLTWH(18, size.y - 78, 132, 52);
  }

  Rect get _pedestalResetButton {
    return Rect.fromLTWH(size.x - 150, size.y - 78, 132, 52);
  }

  List<Rect> get _cupRects {
    final cupWidth = math.min(size.x * 0.2, 126).toDouble();
    final cupHeight = math.min(size.y * 0.25, 190).toDouble();
    return List.generate(PedestalBalancePuzzle.cupCount, (index) {
      final centerX = size.x * (0.25 + index * 0.25);
      return Rect.fromCenter(
        center: Offset(centerX, size.y * 0.55),
        width: cupWidth,
        height: cupHeight,
      );
    });
  }

  List<Rect> get _cupPlusRects {
    return _cupRects
        .map(
          (cup) => Rect.fromCenter(
            center: Offset(cup.center.dx, cup.bottom + 30),
            width: 52,
            height: 44,
          ),
        )
        .toList(growable: false);
  }

  List<Rect> get _cupMinusRects {
    return _cupRects
        .map(
          (cup) => Rect.fromCenter(
            center: Offset(cup.center.dx, cup.top - 24),
            width: 52,
            height: 40,
          ),
        )
        .toList(growable: false);
  }

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
    for (var index = 0; index < 22; index++) {
      final x = size.x * ((index * 37 % 97) / 100);
      final y = size.y * (0.12 + ((index * 23 % 42) / 100));
      final radius = 1.3 + index % 3;
      canvas.drawCircle(
        Offset(x, y),
        radius,
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
          ? '균형이 돌아오자 두 갈래 별길이 다시 빛나기 시작했어요.'
          : '강한 바람이 지나간 뒤 별받침대가 비어 버렸어요.',
      Offset(size.x * 0.5, size.y * 0.19),
      fontSize: _compact ? 11 : 14,
      color: const Color(0xFFD6E8E2),
      align: TextAlign.center,
      maxWidth: size.x * 0.76,
    );

    _drawGardenPaths(canvas, snapshot);
    _drawGardenPlants(canvas, snapshot);
    _drawPedestal(canvas, snapshot);
    _drawFallenPiece(canvas, snapshot);

    for (final entry in _gardenTargets.entries) {
      final available = controller.canNavigateTo(entry.key);
      final visited = snapshot.visitedScenes.contains(entry.key);
      _drawSceneCard(
        canvas,
        entry.value,
        scene: entry.key,
        available: available,
        visited: visited,
        pathsUnlocked: snapshot.gardenPathsUnlocked,
      );
    }
  }

  void _drawGardenPaths(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final center = _pedestalRect.center;
    final targetCenters = _gardenTargets.map(
      (scene, rect) => MapEntry(scene, rect.center),
    );
    for (final entry in targetCenters.entries) {
      final unlocked = controller.canNavigateTo(entry.key);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          (center.dx + entry.value.dx) / 2,
          (center.dy + entry.value.dy) / 2 + 16,
          entry.value.dx,
          entry.value.dy,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = unlocked
              ? const Color(0x88FFE39A)
              : const Color(0x334E8075)
          ..style = PaintingStyle.stroke
          ..strokeWidth = unlocked ? 5 : 3,
      );
    }

    if (snapshot.pedestalSolved) {
      canvas.drawCircle(
        center,
        88,
        Paint()
          ..color = const Color(0x22FFE695)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  void _drawGardenPlants(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final ground = Path()
      ..moveTo(0, size.y * 0.68)
      ..quadraticBezierTo(
        size.x * 0.5,
        size.y * 0.58,
        size.x,
        size.y * 0.68,
      )
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(ground, Paint()..color = const Color(0x66356A45));

    for (var index = 0; index < 12; index++) {
      final x = size.x * (0.05 + (index % 6) * 0.18);
      final y = size.y * (0.78 + (index % 2) * 0.06);
      canvas.drawLine(
        Offset(x, y + 22),
        Offset(x, y),
        Paint()
          ..color = const Color(0xFF7BAA72)
          ..strokeWidth = 4,
      );
      canvas.drawCircle(
        Offset(x, y),
        7 + index % 3,
        Paint()
          ..color = snapshot.pedestalSolved
              ? const Color(0xFFFFC5E0)
              : const Color(0xFF746278),
      );
    }
  }

  void _drawPedestal(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final rect = _pedestalRect;
    final glow = snapshot.fallenPieceFitted
        ? const Color(0x66FFE695)
        : const Color(0x225F6B7A);
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top + 36),
      54,
      Paint()
        ..color = glow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

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

    final slotCenter = Offset(rect.center.dx, rect.top + 36);
    canvas.drawArc(
      Rect.fromCircle(center: slotCenter, radius: 28),
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
      Offset(rect.center.dx, rect.center.dy + 28),
      fontSize: _compact ? 13 : 16,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: rect.width - 12,
    );
    _drawText(
      canvas,
      snapshot.fallenPieceFitted ? '눌러서 안쪽 보기' : '조각 하나가 비어 있어요',
      Offset(rect.center.dx, rect.center.dy + 51),
      fontSize: _compact ? 9 : 11,
      color: const Color(0xFFE7DDE9),
      align: TextAlign.center,
      maxWidth: rect.width - 16,
    );
  }

  void _drawFallenPiece(Canvas canvas, EpisodeOneSnapshot snapshot) {
    if (snapshot.fallenPieceFitted && !snapshot.fittingFallenPiece) {
      _drawCrescentPiece(
        canvas,
        Offset(_pedestalRect.center.dx, _pedestalRect.top + 36),
        22,
      );
      return;
    }

    final start = _fallenPieceRect.center;
    final end = Offset(_pedestalRect.center.dx, _pedestalRect.top + 36);
    final eased = Curves.easeInOutCubic.transform(_pieceAnimationProgress);
    final position = Offset.lerp(start, end, eased) ?? start;

    canvas.drawCircle(
      position,
      34,
      Paint()
        ..color = const Color(0x44FFE695)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    _drawCrescentPiece(canvas, position, 22);
    if (!snapshot.fittingFallenPiece) {
      _drawText(
        canvas,
        '떨어진 별조각',
        Offset(position.dx, position.dy + 36),
        fontSize: _compact ? 10 : 12,
        color: const Color(0xFFFFEEB7),
        weight: FontWeight.w800,
        align: TextAlign.center,
        maxWidth: 100,
      );
    }
  }

  void _drawCrescentPiece(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFFFFDC72),
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.45, center.dy - radius * 0.18),
      radius * 0.82,
      Paint()..color = const Color(0xFF6E527A),
    );
  }

  void _drawPedestalCloseUp(
    Canvas canvas,
    EpisodeOneSnapshot snapshot,
  ) {
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
          : '가운데 별가루 12개를 세 컵에 같은 수만큼 나누세요.',
      Offset(size.x * 0.5, size.y * 0.19),
      fontSize: _compact ? 11 : 14,
      color: const Color(0xFFE4DAE9),
      align: TextAlign.center,
      maxWidth: size.x * 0.82,
    );

    _drawDustReservoir(canvas, snapshot);
    _drawBalanceCups(canvas, snapshot);
    _drawPedestalMechanism(canvas, snapshot);

    _drawButton(
      canvas,
      _pedestalBackButton,
      '정원으로',
      enabled: !snapshot.inputLocked,
    );
    _drawButton(
      canvas,
      _pedestalResetButton,
      '별가루 되돌리기',
      enabled: !snapshot.inputLocked && !snapshot.pedestalSolved,
    );
  }

  void _drawDustReservoir(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final reservoir = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.29),
      width: math.min(size.x * 0.72, 500).toDouble(),
      height: 72,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(reservoir, const Radius.circular(24)),
      Paint()..color = const Color(0x773A2E4A),
    );
    _drawText(
      canvas,
      '남은 별가루 ${snapshot.remainingPedestalDust}개',
      Offset(reservoir.left + 14, reservoir.top + 9),
      fontSize: 12,
      color: const Color(0xFFFFEEB7),
      weight: FontWeight.w800,
      maxWidth: 130,
    );

    final startX = reservoir.center.dx - 88;
    for (var index = 0; index < snapshot.remainingPedestalDust; index++) {
      final row = index ~/ 6;
      final column = index % 6;
      final position = Offset(startX + column * 34, reservoir.top + 43 + row * 20);
      canvas.drawCircle(
        position,
        6,
        Paint()..color = const Color(0xFFFFD968),
      );
    }
  }

  void _drawBalanceCups(Canvas canvas, EpisodeOneSnapshot snapshot) {
    final cups = _cupRects;
    final plusRects = _cupPlusRects;
    final minusRects = _cupMinusRects;
    final maxCount = snapshot.pedestalCupCounts.fold<int>(
      0,
      (maxValue, count) => math.max(maxValue, count),
    );

    for (var index = 0; index < cups.length; index++) {
      final cup = cups[index];
      final count = snapshot.pedestalCupCounts[index];
      final levelDifference = (maxCount - count) * 5.0;
      final shiftedCup = cup.shift(Offset(0, levelDifference));

      final cupPath = Path()
        ..moveTo(shiftedCup.left + 8, shiftedCup.top + 20)
        ..lineTo(shiftedCup.right - 8, shiftedCup.top + 20)
        ..lineTo(shiftedCup.right - 22, shiftedCup.bottom)
        ..lineTo(shiftedCup.left + 22, shiftedCup.bottom)
        ..close();
      canvas.drawPath(
        cupPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD9C7E0), Color(0xFF7D668A)],
          ).createShader(shiftedCup),
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
        final column = dust % 2;
        final row = dust ~/ 2;
        canvas.drawCircle(
          Offset(
            shiftedCup.center.dx + (column == 0 ? -12 : 12),
            shiftedCup.bottom - 24 - row * 22,
          ),
          8,
          Paint()..color = const Color(0xFFFFD968),
        );
      }

      _drawText(
        canvas,
        '${index + 1}번 컵 · $count개',
        Offset(shiftedCup.center.dx, shiftedCup.center.dy + 2),
        fontSize: _compact ? 10 : 13,
        color: const Color(0xFF332A45),
        weight: FontWeight.w900,
        align: TextAlign.center,
        maxWidth: shiftedCup.width - 16,
      );

      _drawButton(
        canvas,
        minusRects[index],
        '−',
        enabled: !snapshot.inputLocked && !snapshot.pedestalSolved,
      );
      _drawButton(
        canvas,
        plusRects[index],
        '+',
        enabled: !snapshot.inputLocked &&
            !snapshot.pedestalSolved &&
            snapshot.remainingPedestalDust > 0,
      );
    }
  }

  void _drawPedestalMechanism(
    Canvas canvas,
    EpisodeOneSnapshot snapshot,
  ) {
    if (!snapshot.pedestalMechanismAnimating && !snapshot.pedestalSolved) {
      return;
    }

    final center = Offset(size.x * 0.5, size.y * 0.83);
    final progress = snapshot.pedestalSolved ? 1.0 : _pedestalAnimationProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 42),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..color = const Color(0xFFFFE39A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    if (snapshot.pedestalSolved || progress > 0.72) {
      final lensRadius = 22 + 5 * math.sin(progress * math.pi);
      canvas.drawCircle(
        center,
        lensRadius + 12,
        Paint()
          ..color = const Color(0x44FFF0A8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(
        center,
        lensRadius,
        Paint()
          ..color = const Color(0xAA7BD9E5)
          ..style = PaintingStyle.fill,
      );
      _drawStar(canvas, center, lensRadius * 0.65);
    }
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

  void _drawDestinationScene(Canvas canvas, EpisodeOneScene scene) {
    _drawText(
      canvas,
      scene.label,
      Offset(size.x * 0.5, size.y * 0.19),
      fontSize: _compact ? 23 : 31,
      weight: FontWeight.w900,
      align: TextAlign.center,
      maxWidth: size.x * 0.8,
    );

    final focus = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.48),
      width: math.min(size.x * 0.66, 510).toDouble(),
      height: math.min(size.y * 0.34, 270).toDouble(),
    );
    _drawDestinationObject(canvas, scene, focus);

    _drawText(
      canvas,
      _placeholderFor(scene),
      Offset(focus.center.dx, focus.bottom + 36),
      fontSize: _compact ? 11 : 14,
      color: const Color(0xFFE0E7E5),
      weight: FontWeight.w700,
      align: TextAlign.center,
      maxWidth: size.x * 0.75,
    );
    _drawButton(canvas, _returnButton, '중앙 정원으로 돌아가기');
  }

  void _drawDestinationObject(
    Canvas canvas,
    EpisodeOneScene scene,
    Rect focus,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(38)),
      Paint()..color = const Color(0x443B5263),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(38)),
      Paint()
        ..color = const Color(0x99FFE7A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final center = focus.center;
    switch (scene) {
      case EpisodeOneScene.pond:
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: focus.width * 0.72,
            height: focus.height * 0.42,
          ),
          Paint()..color = const Color(0xAA66C9DA),
        );
        _drawStar(canvas, center, 34);
        break;
      case EpisodeOneScene.clockflowerGrove:
        canvas.drawCircle(
          Offset(center.dx - 48, center.dy),
          40,
          Paint()..color = const Color(0xFF77B9F2),
        );
        canvas.drawCircle(
          Offset(center.dx + 48, center.dy),
          40,
          Paint()..color = const Color(0xFFFFD86E),
        );
        canvas.drawCircle(
          center,
          72,
          Paint()
            ..color = const Color(0x88FFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
        break;
      case EpisodeOneScene.fountain:
        canvas.drawCircle(
          center,
          72,
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
        final house = Rect.fromCenter(
          center: center,
          width: focus.width * 0.5,
          height: focus.height * 0.65,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(house, const Radius.circular(28)),
          Paint()..color = const Color(0x4477D4B0),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(house, const Radius.circular(28)),
          Paint()
            ..color = const Color(0xFFB9E8D3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 28),
          math.pi * 0.15,
          math.pi * 1.7,
          false,
          Paint()
            ..color = const Color(0xFFFFE4A0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8,
        );
        break;
      case EpisodeOneScene.centralGarden:
        break;
    }
  }

  String _placeholderFor(EpisodeOneScene scene) {
    return switch (scene) {
      EpisodeOneScene.centralGarden => '',
      EpisodeOneScene.pond => '별무늬 렌즈가 맞을 것 같은 돌거울이 수면을 바라보고 있어요.',
      EpisodeOneScene.clockflowerGrove => '파란 꽃과 노란 꽃이 서로 다른 간격으로 열리고 있어요.',
      EpisodeOneScene.fountain => '바람바퀴의 끈이 끊어져 있고 관리 상자는 굳게 잠겨 있어요.',
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
