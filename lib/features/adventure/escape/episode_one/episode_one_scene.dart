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
  double _pedestalProgress = 0;
  double _pondLensProgress = 0;
  double _pondTrackProgress = 0;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
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
      _pedestalProgress = math.min(1, _pedestalProgress + dt / 2).toDouble();
      if (_pedestalProgress >= 1) {
        controller.completePedestalMechanism();
      }
    } else {
      _pedestalProgress = snapshot.pedestalSolved ? 1 : 0;
    }

    if (snapshot.pondLensInstalling) {
      _pondLensProgress = math.min(1, _pondLensProgress + dt / 0.9).toDouble();
      if (_pondLensProgress >= 1) {
        controller.completePondLensInstallation();
      }
    } else {
      _pondLensProgress = snapshot.pondLensInstalled ? 1 : 0;
    }

    if (snapshot.pondTrackAnimating) {
      _pondTrackProgress = math
          .min(1, _pondTrackProgress + dt / 1.2)
          .toDouble();
      if (_pondTrackProgress >= 1) {
        controller.completePondTrackAnimation();
      }
    } else {
      _pondTrackProgress = snapshot.pondSolved ? 1 : 0;
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
    if (snapshot.pondCloseUpOpen) {
      _handlePondTrackTap(point);
      return;
    }

    if (snapshot.currentScene == EpisodeOneScene.centralGarden) {
      _handleGardenTap(point);
      return;
    }
    if (snapshot.currentScene == EpisodeOneScene.pond) {
      if (_pondMirrorRect.contains(point)) {
        controller.useSelectedItemOnPondMirror();
        return;
      }
      if (_returnButton.contains(point)) {
        controller.returnToGarden();
      }
      return;
    }

    if (_returnButton.contains(point)) {
      controller.returnToGarden();
    }
  }

  void _handleGardenTap(Offset point) {
    final snapshot = controller.value;
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
  }

  void _handlePedestalTap(Offset point) {
    if (_closeUpBackButton.contains(point)) {
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

  void _handlePondTrackTap(Offset point) {
    if (_closeUpBackButton.contains(point)) {
      controller.closePondMirror();
      return;
    }
    for (var index = 0; index < _pondTrackRects.length; index++) {
      if (_pondTrackRects[index].contains(point)) {
        controller.selectPondTrack(index);
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final snapshot = controller.value;

    _drawBackground(canvas, snapshot.currentScene);

    if (snapshot.pedestalCloseUpOpen) {
      _drawPedestalCloseUp(canvas, snapshot);
      return;
    }
    if (snapshot.pondCloseUpOpen) {
      _drawPondTracks(canvas, snapshot);
      return;
    }

    if (snapshot.currentScene == EpisodeOneScene.centralGarden) {
      _drawCentralGarden(canvas, snapshot);
      return;
    }
    if (snapshot.currentScene == EpisodeOneScene.pond) {
      _drawPond(canvas, snapshot);
      return;
    }
    _drawPlaceholderScene(canvas, snapshot.currentScene);
  }

  bool get _compact => size.x < 520 || size.y < 720;

  Rect get _pedestalRect => Rect.fromCenter(
    center: Offset(size.x * 0.5, size.y * 0.48),
    width: math.min(size.x * 0.26, 190).toDouble(),
    height: math.min(size.y * 0.22, 165).toDouble(),
  );

  Rect get _fallenPieceRect => Rect.fromCenter(
    center: Offset(size.x * 0.39, size.y * 0.65),
    width: 76,
    height: 68,
  );

  Rect get _returnButton => Rect.fromCenter(
    center: Offset(size.x * 0.5, size.y * 0.76),
    width: math.min(size.x * 0.62, 380).toDouble(),
    height: 52,
  );

  Rect get _closeUpBackButton => Rect.fromCenter(
    center: Offset(size.x * 0.18, size.y * 0.77),
    width: math.min(size.x * 0.28, 160).toDouble(),
    height: 48,
  );

  Rect get _pedestalResetButton => Rect.fromCenter(
    center: Offset(size.x * 0.82, size.y * 0.77),
    width: math.min(size.x * 0.32, 178).toDouble(),
    height: 48,
  );

  Rect get _pondMirrorRect => Rect.fromCenter(
    center: Offset(size.x * 0.5, size.y * 0.49),
    width: math.min(size.x * 0.64, 480).toDouble(),
    height: math.min(size.y * 0.38, 270).toDouble(),
  );

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
    final height = math.min(size.y * 0.23, 172).toDouble();
    return List.generate(3, (index) {
      return Rect.fromCenter(
        center: Offset(size.x * (0.25 + index * 0.25), size.y * 0.52),
        width: width,
        height: height,
      );
    });
  }

  List<Rect> get _cupPlusRects => _cupRects
      .map(
        (cup) => Rect.fromCenter(
          center: Offset(cup.center.dx, cup.bottom + 27),
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

  List<Rect> get _pondTrackRects {
    final points = [
      Offset(size.x * 0.17, size.y * 0.34),
      Offset(size.x * 0.39, size.y * 0.34),
      Offset(size.x * 0.30, size.y * 0.48),
      Offset(size.x * 0.56, size.y * 0.46),
      Offset(size.x * 0.48, size.y * 0.61),
      Offset(size.x * 0.74, size.y * 0.59),
      Offset(size.x * 0.69, size.y * 0.72),
    ];
    final radius = _compact ? 25.0 : 32.0;
    return points
        .map((point) => Rect.fromCircle(center: point, radius: radius))
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
        Color(0xFF0C273E),
        Color(0xFF1D6872),
        Color(0xFF082631),
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
    for (var index = 0; index < 20; index++) {
      canvas.drawCircle(
        Offset(
          size.x * ((index * 37 % 97) / 100),
          size.y * (0.12 + ((index * 23 % 42) / 100)),
        ),
        1.2 + index % 3,
        Paint()..color = const Color(0x66FFF0B0),
      );
    }
  }

  void _drawCentralGarden(Canvas canvas, EpisodeOneSnapshot snapshot) {
    _drawTitle(
      canvas,
      '사라진 별빛 씨앗',
      snapshot.pedestalSolved
          ? '연못과 시계꽃 숲으로 이어지는 별길이 켜졌어요.'
          : '강한 은하 바람 뒤 별빛 씨앗이 사라졌어요.',
    );

    final ground = Path()
      ..moveTo(0, size.y * 0.68)
      ..quadraticBezierTo(size.x * 0.5, size.y * 0.58, size.x, size.y * 0.68)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(ground, Paint()..color = const Color(0x66356A45));

    for (final entry in _gardenTargets.entries) {
      final available = controller.canNavigateTo(entry.key);
      final solved = entry.key == EpisodeOneScene.pond && snapshot.pondSolved;
      canvas.drawLine(
        _pedestalRect.center,
        entry.value.center,
        Paint()
          ..color = available
              ? const Color(0x88FFE39A)
              : const Color(0x334E8075)
          ..strokeWidth = available ? 5 : 3,
      );
      _drawSceneCard(
        canvas,
        entry.value,
        entry.key.label,
        available
            ? solved
                  ? '단서 기록됨'
                  : '조사하기'
            : '별길 잠김',
        available: available,
        solved: solved,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(_pedestalRect, const Radius.circular(30)),
      Paint()..color = const Color(0xCC665276),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(_pedestalRect, const Radius.circular(30)),
      Paint()
        ..color = snapshot.fallenPieceFitted
            ? const Color(0xFFFFE39A)
            : const Color(0x889D91A6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      snapshot.fallenPieceFitted ? '별받침대 조사' : '빈 별받침대',
      Offset(_pedestalRect.center.dx, _pedestalRect.center.dy + 30),
      fontSize: _compact ? 12 : 15,
      center: true,
      bold: true,
      maxWidth: _pedestalRect.width - 12,
    );

    final start = _fallenPieceRect.center;
    final end = Offset(_pedestalRect.center.dx, _pedestalRect.top + 34);
    final position = snapshot.fallenPieceFitted
        ? end
        : (Offset.lerp(
                start,
                end,
                Curves.easeInOut.transform(_pieceProgress),
              ) ??
              start);
    _drawCrescent(canvas, position, 22);
    if (!snapshot.fallenPieceFitted && !snapshot.fittingFallenPiece) {
      _drawText(
        canvas,
        '떨어진 별조각',
        Offset(position.dx, position.dy + 34),
        fontSize: 11,
        center: true,
        color: const Color(0xFFFFE7A0),
        bold: true,
        maxWidth: 100,
      );
    }
  }

  void _drawPedestalCloseUp(Canvas canvas, EpisodeOneSnapshot snapshot) {
    _drawTitle(
      canvas,
      '별받침대 균형 장치',
      snapshot.pedestalSolved
          ? '세 균형컵의 높이가 같아져 별길이 켜졌어요.'
          : '별가루 12개를 세 균형컵에 같은 수만큼 나누세요.',
    );

    _drawText(
      canvas,
      '남은 별가루 ${snapshot.remainingPedestalDust}개',
      Offset(size.x * 0.5, size.y * 0.27),
      fontSize: 15,
      center: true,
      bold: true,
    );

    final maxCount = snapshot.pedestalCupCounts.reduce(math.max);
    for (var index = 0; index < 3; index++) {
      final rect = _cupRects[index].shift(
        Offset(0, (maxCount - snapshot.pedestalCupCounts[index]) * 5),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)),
        Paint()..color = const Color(0xCC9B83A8),
      );
      _drawText(
        canvas,
        '${index + 1}번 컵\n${snapshot.pedestalCupCounts[index]}개',
        rect.center,
        fontSize: _compact ? 11 : 14,
        center: true,
        bold: true,
        maxWidth: rect.width - 10,
      );
      _drawButton(
        canvas,
        _cupMinusRects[index],
        '−',
        enabled: !snapshot.pedestalSolved && !snapshot.inputLocked,
      );
      _drawButton(
        canvas,
        _cupPlusRects[index],
        '+',
        enabled:
            !snapshot.pedestalSolved &&
            !snapshot.inputLocked &&
            snapshot.remainingPedestalDust > 0,
      );
    }

    if (snapshot.pedestalMechanismAnimating || snapshot.pedestalSolved) {
      final center = Offset(size.x * 0.5, size.y * 0.70);
      final progress = snapshot.pedestalSolved ? 1.0 : _pedestalProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 38),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = const Color(0xFFFFE39A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8,
      );
      if (snapshot.pedestalSolved || progress > 0.7) {
        canvas.drawCircle(center, 24, Paint()..color = const Color(0xFF7BD9E5));
        _drawStar(canvas, center, 16);
      }
    }

    _drawButton(
      canvas,
      _closeUpBackButton,
      '정원으로',
      enabled: !snapshot.inputLocked,
    );
    _drawButton(
      canvas,
      _pedestalResetButton,
      '모두 되돌리기',
      enabled: !snapshot.pedestalSolved && !snapshot.inputLocked,
    );
  }

  void _drawPond(Canvas canvas, EpisodeOneSnapshot snapshot) {
    _drawTitle(
      canvas,
      '반짝이는 연못',
      snapshot.pondLensInstalled
          ? '별거울이 과거의 흔적을 수면 위에 비추고 있어요.'
          : '돌거울 중앙에 별 모양 홈이 비어 있어요.',
    );

    final mirror = _pondMirrorRect;
    canvas.drawOval(
      Rect.fromCenter(
        center: mirror.center,
        width: mirror.width * 0.9,
        height: mirror.height * 0.62,
      ),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFB8F3F1), Color(0xFF4FA9BF), Color(0xFF225A78)],
        ).createShader(mirror),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: mirror.center,
        width: mirror.width * 0.9,
        height: mirror.height * 0.62,
      ),
      Paint()
        ..color = const Color(0xAAE7FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    final lensStart = Offset(size.x * 0.77, size.y * 0.72);
    final lensEnd = mirror.center;
    if (snapshot.pondLensInstalling || snapshot.pondLensInstalled) {
      final progress = snapshot.pondLensInstalled ? 1.0 : _pondLensProgress;
      final position = Offset.lerp(
        lensStart,
        lensEnd,
        Curves.easeInOut.transform(progress),
      )!;
      canvas.drawCircle(
        position,
        44,
        Paint()
          ..color = const Color(0x447DEAF0)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(position, 32, Paint()..color = const Color(0xCC7BD9E5));
      _drawStar(canvas, position, 20);
    } else {
      canvas.drawCircle(
        mirror.center,
        39,
        Paint()
          ..color = const Color(0xAA163B50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
      _drawStarOutline(canvas, mirror.center, 24);
    }

    if (snapshot.pondLensInstalled) {
      for (var index = 0; index < 4; index++) {
        final x = mirror.left + mirror.width * (0.23 + index * 0.18);
        canvas.drawCircle(
          Offset(x, mirror.center.dy + math.sin(index.toDouble()) * 18),
          8,
          Paint()..color = const Color(0xAAFFE39A),
        );
      }
    }

    _drawText(
      canvas,
      snapshot.pondLensInstalled
          ? snapshot.pondSolved
                ? '완성된 기억 흔적 다시 보기'
                : '기억 흔적 확대 조사'
          : snapshot.selectedItem == EpisodeOneItem.starLens
          ? '선택한 별무늬 렌즈 사용'
          : '인벤토리에서 렌즈 선택',
      Offset(mirror.center.dx, mirror.bottom - 24),
      fontSize: _compact ? 12 : 16,
      center: true,
      bold: true,
      maxWidth: mirror.width * 0.8,
    );
    _drawButton(canvas, _returnButton, '중앙 정원으로 돌아가기');
  }

  void _drawPondTracks(Canvas canvas, EpisodeOneSnapshot snapshot) {
    _drawTitle(
      canvas,
      '연못의 기억 흔적',
      snapshot.pondSolved
          ? '젖은 발자국이 분수대 방향으로 이어져요.'
          : '둥근 발바닥과 작은 발가락이 있는 흔적을 시작점부터 누르세요.',
    );

    final order = PondTrackPuzzle.correctOrder;
    final foundCount = snapshot.pondTrackProgress;
    for (var step = 1; step < foundCount; step++) {
      final previous = _pondTrackRects[order[step - 1]].center;
      final current = _pondTrackRects[order[step]].center;
      canvas.drawLine(
        previous,
        current,
        Paint()
          ..color = const Color(0xFFFFE39A)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    if (snapshot.pondTrackAnimating) {
      final first = _pondTrackRects[order.first].center;
      final last = _pondTrackRects[order.last].center;
      final movingPoint = Offset.lerp(first, last, _pondTrackProgress)!;
      canvas.drawCircle(
        movingPoint,
        26,
        Paint()
          ..color = const Color(0x66FFE39A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    for (var index = 0; index < _pondTrackRects.length; index++) {
      final orderIndex = order.indexOf(index);
      final found = orderIndex >= 0 && orderIndex < foundCount;
      if (PondTrackPuzzle.isRealFootprint(index)) {
        _drawFootprint(
          canvas,
          _pondTrackRects[index],
          found: found,
          solved: snapshot.pondSolved,
        );
      } else {
        _drawWindMark(canvas, _pondTrackRects[index]);
      }
    }

    _drawText(
      canvas,
      snapshot.pondSolved
          ? EpisodeOneClue.wetTracks.description
          : '찾은 발자국 $foundCount/${order.length}',
      Offset(size.x * 0.5, size.y * 0.82),
      fontSize: _compact ? 11 : 14,
      center: true,
      bold: true,
      maxWidth: size.x * 0.72,
      color: const Color(0xFFFFEDB2),
    );
    _drawButton(
      canvas,
      _closeUpBackButton,
      '연못으로',
      enabled: !snapshot.inputLocked,
    );
  }

  void _drawFootprint(
    Canvas canvas,
    Rect rect, {
    required bool found,
    required bool solved,
  }) {
    final color = found || solved
        ? const Color(0xFFFFE39A)
        : const Color(0xAA8ADBE8);
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center,
        width: rect.width * 0.72,
        height: rect.height * 0.88,
      ),
      Paint()..color = color,
    );
    final toeRadius = math.max(3.0, rect.width * 0.09);
    for (var toe = 0; toe < 3; toe++) {
      canvas.drawCircle(
        Offset(
          rect.center.dx + (toe - 1) * toeRadius * 1.8,
          rect.top + toeRadius * 1.2,
        ),
        toeRadius,
        Paint()..color = color,
      );
    }
  }

  void _drawWindMark(Canvas canvas, Rect rect) {
    final center = rect.center;
    final paint = Paint()
      ..color = const Color(0xAA829099)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: rect.width * 0.34),
      -math.pi * 0.2,
      math.pi * 1.35,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - rect.width * 0.28, center.dy + rect.height * 0.18),
      Offset(center.dx + rect.width * 0.30, center.dy + rect.height * 0.24),
      paint,
    );
  }

  void _drawPlaceholderScene(Canvas canvas, EpisodeOneScene scene) {
    _drawTitle(canvas, scene.label, scene.objective);
    final rect = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.49),
      width: math.min(size.x * 0.62, 470).toDouble(),
      height: math.min(size.y * 0.34, 250).toDouble(),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(34)),
      Paint()..color = const Color(0x55465A68),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(34)),
      Paint()
        ..color = const Color(0x99FFE39A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      '다음 구현 단계에서 이 장소의 퍼즐이 열립니다.',
      rect.center,
      fontSize: _compact ? 13 : 16,
      center: true,
      bold: true,
      maxWidth: rect.width * 0.8,
    );
    _drawButton(canvas, _returnButton, '중앙 정원으로 돌아가기');
  }

  void _drawTitle(Canvas canvas, String title, String subtitle) {
    _drawText(
      canvas,
      title,
      Offset(size.x * 0.5, size.y * 0.14),
      fontSize: _compact ? 20 : 28,
      center: true,
      bold: true,
      maxWidth: size.x * 0.78,
    );
    _drawText(
      canvas,
      subtitle,
      Offset(size.x * 0.5, size.y * 0.20),
      fontSize: _compact ? 10 : 13,
      center: true,
      color: const Color(0xFFD7E8E2),
      maxWidth: size.x * 0.78,
    );
  }

  void _drawSceneCard(
    Canvas canvas,
    Rect rect,
    String title,
    String status, {
    required bool available,
    required bool solved,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = solved
            ? const Color(0xCC4D8B7A)
            : available
            ? const Color(0xCC304E58)
            : const Color(0xBB202D36),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()
        ..color = solved
            ? const Color(0xFFFFE39A)
            : available
            ? const Color(0xAA8BD5C5)
            : const Color(0x557A8B89)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawText(
      canvas,
      '${solved ? '✓ ' : ''}$title',
      Offset(rect.center.dx, rect.center.dy - 10),
      fontSize: _compact ? 10 : 14,
      center: true,
      bold: true,
      maxWidth: rect.width - 12,
    );
    _drawText(
      canvas,
      status,
      Offset(rect.center.dx, rect.center.dy + 14),
      fontSize: _compact ? 8 : 10,
      center: true,
      color: available ? const Color(0xFFFFE9AB) : const Color(0xFFAAB9B5),
      bold: true,
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
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      Paint()
        ..color = enabled ? const Color(0xFFEBCB78) : const Color(0xFF59656A),
    );
    _drawText(
      canvas,
      label,
      rect.center,
      fontSize: label.length <= 2 ? 24 : (_compact ? 11 : 14),
      center: true,
      color: enabled ? const Color(0xFF302440) : const Color(0xFFB8C1C3),
      bold: true,
      maxWidth: rect.width - 12,
    );
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFDC72));
    canvas.drawCircle(
      Offset(center.dx + radius * 0.45, center.dy - radius * 0.18),
      radius * 0.82,
      Paint()..color = const Color(0xFF6E527A),
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

  void _drawStarOutline(Canvas canvas, Offset center, double radius) {
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
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF88C5D1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchor, {
    required double fontSize,
    Color color = Colors.white,
    bool bold = false,
    bool center = false,
    double? maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          height: 1.35,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
    )..layout(maxWidth: maxWidth ?? size.x);

    final offset = center
        ? Offset(anchor.dx - painter.width / 2, anchor.dy - painter.height / 2)
        : anchor;
    painter.paint(canvas, offset);
  }
}
