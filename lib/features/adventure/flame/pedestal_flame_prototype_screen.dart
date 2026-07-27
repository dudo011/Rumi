import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PedestalFlamePrototypeScreen extends StatefulWidget {
  const PedestalFlamePrototypeScreen({super.key});

  @override
  State<PedestalFlamePrototypeScreen> createState() =>
      _PedestalFlamePrototypeScreenState();
}

class _PedestalFlamePrototypeScreenState
    extends State<PedestalFlamePrototypeScreen> {
  late final PedestalPrototypeGame _game;

  @override
  void initState() {
    super.initState();
    _game = PedestalPrototypeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GameWidget<PedestalPrototypeGame>(game: _game),
            ),
            Positioned(
              left: 12,
              top: 10,
              child: IconButton.filledTonal(
                tooltip: 'Flame 프로토타입 닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Positioned(
              left: 74,
              right: 18,
              top: 14,
              child: Text(
                'Flame 실험 · 별받침대',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PedestalPrototypeGame extends FlameGame {
  final _PedestalWorld _worldScene = _PedestalWorld();

  @override
  Color backgroundColor() => const Color(0xFF0B1020);

  @override
  Future<void> onLoad() async {
    await add(_worldScene);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _worldScene.size = size;
  }
}

enum _PrototypePhase { garden, zooming, grouping, solved }

class _DustPiece {
  _DustPiece({required this.home, required this.position});

  final Vector2 home;
  Vector2 position;
  int? group;
  bool dragging = false;
}

class _Spark {
  _Spark({required this.position, required this.velocity, required this.life});

  Vector2 position;
  final Vector2 velocity;
  double life;
}

class _PedestalWorld extends PositionComponent
    with TapCallbacks, DragCallbacks {
  final math.Random _random = math.Random(7);
  final List<_DustPiece> _dust = [];
  final List<_Spark> _sparks = [];

  _PrototypePhase _phase = _PrototypePhase.garden;
  int? _draggingIndex;
  double _time = 0;
  double _zoom = 0;
  double _successPulse = 0;

  Rect get _pedestalRect => Rect.fromCenter(
        center: Offset(size.x * 0.53, size.y * 0.55),
        width: math.min(size.x * 0.30, 220),
        height: math.min(size.y * 0.24, 190),
      );

  List<Offset> get _groupCenters {
    final width = size.x;
    final y = size.y * 0.76;
    return List.generate(
      4,
      (index) => Offset(width * (0.2 + index * 0.2), y),
    );
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
    if (_dust.isEmpty && gameSize.x > 0 && gameSize.y > 0) {
      _createDust();
    }
  }

  void _createDust() {
    _dust.clear();
    for (var index = 0; index < 12; index++) {
      final column = index % 6;
      final row = index ~/ 6;
      final home = Vector2(
        size.x * 0.29 + column * math.min(size.x * 0.075, 54),
        size.y * 0.46 + row * 58,
      );
      _dust.add(_DustPiece(home: home.clone(), position: home.clone()));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    if (_phase == _PrototypePhase.zooming) {
      _zoom = (_zoom + dt * 1.25).clamp(0, 1);
      if (_zoom >= 1) {
        _phase = _PrototypePhase.grouping;
      }
    }

    if (_phase == _PrototypePhase.solved) {
      _successPulse = (_successPulse + dt * 2.4).clamp(0, 1);
    }

    for (final spark in _sparks) {
      spark.position += spark.velocity * dt;
      spark.velocity.y += 80 * dt;
      spark.life -= dt;
    }
    _sparks.removeWhere((spark) => spark.life <= 0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_phase != _PrototypePhase.garden) {
      return;
    }

    if (_pedestalRect.inflate(28).contains(event.localPosition.toOffset())) {
      _phase = _PrototypePhase.zooming;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_phase != _PrototypePhase.grouping) {
      return;
    }

    final point = event.localPosition;
    for (var index = _dust.length - 1; index >= 0; index--) {
      final piece = _dust[index];
      if (piece.group != null) {
        continue;
      }
      if (piece.position.distanceTo(point) <= 28) {
        _draggingIndex = index;
        piece.dragging = true;
        _burst(piece.position, count: 5);
        break;
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final index = _draggingIndex;
    if (index == null) {
      return;
    }
    _dust[index].position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final index = _draggingIndex;
    if (index == null) {
      return;
    }

    final piece = _dust[index];
    piece.dragging = false;
    _draggingIndex = null;

    final centers = _groupCenters;
    int? targetGroup;
    var bestDistance = double.infinity;
    for (var group = 0; group < centers.length; group++) {
      final distance = piece.position.distanceTo(Vector2(
        centers[group].dx,
        centers[group].dy,
      ));
      if (distance < 74 && distance < bestDistance) {
        targetGroup = group;
        bestDistance = distance;
      }
    }

    if (targetGroup == null || _countInGroup(targetGroup) >= 3) {
      piece.position = piece.home.clone();
      return;
    }

    piece.group = targetGroup;
    final slot = _countInGroup(targetGroup) - 1;
    final center = centers[targetGroup];
    const offsets = [Offset(-22, 8), Offset(0, -18), Offset(22, 8)];
    piece.position = Vector2(
      center.dx + offsets[slot].dx,
      center.dy + offsets[slot].dy,
    );
    _burst(piece.position, count: 14);

    if (_dust.every((dust) => dust.group != null)) {
      _phase = _PrototypePhase.solved;
      for (var index = 0; index < 90; index++) {
        _burst(
          Vector2(size.x * 0.5, size.y * 0.47),
          count: 1,
          strong: true,
        );
      }
    }
  }

  int _countInGroup(int group) {
    return _dust.where((piece) => piece.group == group).length;
  }

  void _burst(Vector2 origin, {required int count, bool strong = false}) {
    for (var index = 0; index < count; index++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = (strong ? 130 : 55) + _random.nextDouble() * 90;
      _sparks.add(
        _Spark(
          position: origin.clone(),
          velocity: Vector2(math.cos(angle), math.sin(angle)) * speed,
          life: 0.45 + _random.nextDouble() * 0.75,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawBackground(canvas);

    final zoomCurve = Curves.easeInOutCubic.transform(_zoom);
    canvas.save();
    if (zoomCurve > 0) {
      final focus = _pedestalRect.center;
      final scale = lerpDouble(1, 1.75, zoomCurve)!;
      canvas.translate(size.x * 0.5, size.y * 0.48);
      canvas.scale(scale);
      canvas.translate(-focus.dx, -focus.dy);
    }

    _drawGarden(canvas, zoomCurve);
    _drawPedestal(canvas);
    canvas.restore();

    if (_phase == _PrototypePhase.grouping ||
        _phase == _PrototypePhase.solved) {
      _drawGroupingLayer(canvas);
    }

    _drawSparks(canvas);
    _drawInstruction(canvas);
  }

  void _drawBackground(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF11162E), Color(0xFF173D45), Color(0xFF10261E)],
        ).createShader(rect),
    );

    final moon = Offset(size.x * 0.82, size.y * 0.17);
    canvas.drawCircle(
      moon,
      54 + math.sin(_time * 1.2) * 3,
      Paint()..color = const Color(0x22FFF1B8),
    );
    canvas.drawCircle(moon, 31, Paint()..color = const Color(0xFFFFE7A5));
  }

  void _drawGarden(Canvas canvas, double zoomCurve) {
    final groundY = size.y * 0.69;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.5, groundY),
        width: size.x * 1.18,
        height: size.y * 0.47,
      ),
      Paint()..color = const Color(0xFF214F3D),
    );

    for (var index = 0; index < 14; index++) {
      final x = size.x * (0.04 + index * 0.074);
      final sway = math.sin(_time * 1.8 + index) * 5;
      final top = groundY - 90 - (index % 3) * 16;
      canvas.drawLine(
        Offset(x, groundY + 20),
        Offset(x + sway, top),
        Paint()
          ..color = const Color(0xFF6BA56F)
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        Offset(x + sway, top),
        11,
        Paint()..color = const Color(0xFFE8A8D4),
      );
    }

    if (zoomCurve < 0.85) {
      final lumi = Offset(
        size.x * 0.22,
        size.y * 0.43 + math.sin(_time * 2.4) * 8,
      );
      canvas.drawCircle(lumi, 40, Paint()..color = const Color(0x44E8D6FF));
      canvas.drawCircle(lumi, 26, Paint()..color = const Color(0xFFDCCBFF));
      canvas.drawCircle(lumi + const Offset(-8, -3), 3, Paint()..color = const Color(0xFF433554));
      canvas.drawCircle(lumi + const Offset(8, -3), 3, Paint()..color = const Color(0xFF433554));
    }
  }

  void _drawPedestal(Canvas canvas) {
    final rect = _pedestalRect;
    final glowStrength = _phase == _PrototypePhase.garden
        ? 0.45 + math.sin(_time * 3) * 0.18
        : 0.75;

    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center + Offset(0, rect.height * 0.43),
        width: rect.width * 1.22,
        height: rect.height * 0.28,
      ),
      Paint()..color = const Color(0x66000000),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(34)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE1CA8C), Color(0xFF8C7044)],
        ).createShader(rect),
    );

    canvas.drawCircle(
      rect.center - Offset(0, rect.height * 0.12),
      rect.width * 0.21,
      Paint()..color = const Color(0xFF463A53),
    );
    canvas.drawCircle(
      rect.center - Offset(0, rect.height * 0.12),
      rect.width * 0.28,
      Paint()
        ..color = Color.fromRGBO(255, 222, 113, glowStrength)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );

    final scratch = Paint()
      ..color = const Color(0xFFFFD867)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      canvas.drawLine(
        Offset(rect.center.dx + 24, rect.center.dy - 34 + index * 15),
        Offset(rect.right + 52, rect.center.dy - 20 + index * 15),
        scratch,
      );
    }
  }

  void _drawGroupingLayer(Canvas canvas) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.x * 0.08,
        size.y * 0.35,
        size.x * 0.84,
        size.y * 0.51,
      ),
      const Radius.circular(30),
    );
    canvas.drawRRect(panel, Paint()..color = const Color(0xD91A1930));
    canvas.drawRRect(
      panel,
      Paint()
        ..color = const Color(0x66FFE59B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final centers = _groupCenters;
    for (var index = 0; index < centers.length; index++) {
      final center = centers[index];
      final count = _countInGroup(index);
      final complete = count == 3;
      canvas.drawCircle(
        center,
        52 + (complete ? math.sin(_time * 4 + index) * 4 : 0),
        Paint()
          ..color = complete
              ? const Color(0x445CFFB0)
              : const Color(0x223A3157),
      );
      canvas.drawCircle(
        center,
        47,
        Paint()
          ..color = complete
              ? const Color(0xFF8DE8B8)
              : const Color(0xFF6D6385)
          ..style = PaintingStyle.stroke
          ..strokeWidth = complete ? 5 : 3,
      );
      _paintText(
        canvas,
        '${index + 1}번 묶음 · $count/3',
        Offset(center.dx, center.dy + 65),
        fontSize: 13,
        color: Colors.white,
        align: TextAlign.center,
      );
    }

    for (final piece in _dust) {
      final pulse = piece.dragging ? 1.25 : 1 + math.sin(_time * 3 + piece.home.x) * 0.04;
      _drawStar(
        canvas,
        piece.position.toOffset(),
        17 * pulse,
        piece.group == null
            ? const Color(0xFFFFD968)
            : const Color(0xFFA7F3C4),
      );
    }
  }

  void _drawSparks(Canvas canvas) {
    for (final spark in _sparks) {
      final alpha = (spark.life.clamp(0, 1) * 255).round();
      canvas.drawCircle(
        spark.position.toOffset(),
        2.5 + spark.life * 3,
        Paint()..color = Color.fromARGB(alpha, 255, 224, 112),
      );
    }
  }

  void _drawInstruction(Canvas canvas) {
    String title;
    String subtitle;

    switch (_phase) {
      case _PrototypePhase.garden:
        title = '빛나는 별받침대를 눌러 조사하세요';
        subtitle = '화면 속 오브젝트가 계속 움직이고 반응합니다.';
      case _PrototypePhase.zooming:
        title = '받침대로 가까이 이동하는 중…';
        subtitle = '카메라가 게임 월드 안에서 확대됩니다.';
      case _PrototypePhase.grouping:
        final placed = _dust.where((piece) => piece.group != null).length;
        title = '별가루를 드래그해 3개씩 네 묶음으로 만드세요';
        subtitle = '배치 완료 $placed/12 · 가득 찬 묶음에는 더 넣을 수 없어요.';
      case _PrototypePhase.solved:
        title = '흔적 해석 성공!';
        subtitle = '별가루가 오른쪽으로 흘렀어요. 씨앗도 바람에 밀린 것 같아요.';
    }

    final top = size.y * 0.13;
    _paintText(
      canvas,
      title,
      Offset(size.x * 0.5, top),
      fontSize: 21 + _successPulse * 3,
      color: _phase == _PrototypePhase.solved
          ? const Color(0xFFFFE27A)
          : Colors.white,
      align: TextAlign.center,
      weight: FontWeight.w900,
    );
    _paintText(
      canvas,
      subtitle,
      Offset(size.x * 0.5, top + 34),
      fontSize: 13,
      color: const Color(0xFFDAD5E7),
      align: TextAlign.center,
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center, {
    required double fontSize,
    required Color color,
    required TextAlign align,
    FontWeight weight = FontWeight.w700,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 2,
    )..layout(maxWidth: size.x * 0.86);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final angle = -math.pi / 2 + index * math.pi / 5;
      final currentRadius = index.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
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
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }
}
