import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class EpisodeOneFlameScreen extends StatefulWidget {
  const EpisodeOneFlameScreen({super.key});

  @override
  State<EpisodeOneFlameScreen> createState() => _EpisodeOneFlameScreenState();
}

class _EpisodeOneFlameScreenState extends State<EpisodeOneFlameScreen> {
  late final _EpisodeOneGame _game;

  @override
  void initState() {
    super.initState();
    _game = _EpisodeOneGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09131A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget<_EpisodeOneGame>(game: _game)),
            Positioned(
              left: 12,
              top: 10,
              child: IconButton.filledTonal(
                tooltip: 'Flame 1단계 닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Positioned(
              left: 70,
              top: 16,
              child: Text(
                'Flame 1단계 · 사라진 별빛 씨앗',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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

class _EpisodeOneGame extends FlameGame {
  final _EpisodeOneWorld _world = _EpisodeOneWorld();

  @override
  Color backgroundColor() => const Color(0xFF09131A);

  @override
  Future<void> onLoad() async {
    await add(_world);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _world.size = size;
  }
}

enum _EpisodeScene { intro, garden, pedestal, trail, chest, deduction, solved }

enum _PedestalClue { emptySpot, scratch, dust }

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

class _EpisodeOneWorld extends PositionComponent with TapCallbacks, DragCallbacks {
  final math.Random _random = math.Random(17);
  final List<_Spark> _sparks = [];
  final List<_DustPiece> _dust = [];
  final Set<_PedestalClue> _pedestalClues = {};
  final Set<int> _factors = {};

  _EpisodeScene _scene = _EpisodeScene.intro;
  double _time = 0;
  double _transition = 0;
  int? _draggingDust;
  bool _trailSolved = false;
  bool _lockInspected = false;
  bool _stoneMoved = false;
  bool _hasKey = false;
  bool _keyDragging = false;
  Vector2 _keyPosition = Vector2.zero();
  int? _deductionChoice;
  String _message = '별빛 씨앗이 사라졌어요. 정원을 조사해 주세요.';

  Rect get _primaryButton => Rect.fromCenter(
        center: Offset(size.x * 0.5, size.y * 0.84),
        width: math.min(size.x * 0.62, 420),
        height: 58,
      );

  Rect get _pedestalRect => Rect.fromCenter(
        center: Offset(size.x * 0.52, size.y * 0.53),
        width: math.min(size.x * 0.27, 210),
        height: math.min(size.y * 0.25, 190),
      );

  List<Offset> get _groupCenters {
    return List.generate(
      4,
      (index) => Offset(size.x * (0.2 + index * 0.2), size.y * 0.76),
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
      _keyPosition = Vector2(size.x * 0.33, size.y * 0.65);
    }
  }

  void _createDust() {
    _dust.clear();
    for (var index = 0; index < 12; index++) {
      final column = index % 6;
      final row = index ~/ 6;
      final home = Vector2(
        size.x * 0.3 + column * math.min(size.x * 0.07, 52),
        size.y * 0.46 + row * 56,
      );
      _dust.add(_DustPiece(home: home.clone(), position: home.clone()));
    }
  }

  void _changeScene(_EpisodeScene next, String message) {
    _scene = next;
    _message = message;
    _transition = 1;
    _burst(Vector2(size.x * 0.5, size.y * 0.5), count: 28);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _transition = math.max(0, _transition - dt * 2.8).toDouble();

    for (final spark in _sparks) {
      spark.position += spark.velocity * dt;
      spark.velocity.y += 65 * dt;
      spark.life -= dt;
    }
    _sparks.removeWhere((spark) => spark.life <= 0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final point = event.localPosition.toOffset();

    switch (_scene) {
      case _EpisodeScene.intro:
        if (_primaryButton.contains(point)) {
          _changeScene(_EpisodeScene.garden, '빛나는 오브젝트를 눌러 흔적을 찾아보세요.');
        }
      case _EpisodeScene.garden:
        if (_pedestalRect.inflate(35).contains(point)) {
          _changeScene(_EpisodeScene.pedestal, '빈 자리, 긁힌 자국, 별가루를 모두 조사하세요.');
        }
      case _EpisodeScene.pedestal:
        _handlePedestalTap(point);
      case _EpisodeScene.trail:
        _handleTrailTap(point);
      case _EpisodeScene.chest:
        _handleChestTap(point);
      case _EpisodeScene.deduction:
        _handleDeductionTap(point);
      case _EpisodeScene.solved:
        if (_primaryButton.contains(point)) {
          _resetEpisode();
        }
    }
  }

  void _handlePedestalTap(Offset point) {
    if (_dust.every((item) => item.group != null) && _primaryButton.contains(point)) {
      _changeScene(_EpisodeScene.trail, '4칸마다 발자국, 6칸마다 별가루가 나타납니다.');
      return;
    }

    final targets = <_PedestalClue, Offset>{
      _PedestalClue.emptySpot: Offset(size.x * 0.5, size.y * 0.34),
      _PedestalClue.scratch: Offset(size.x * 0.69, size.y * 0.49),
      _PedestalClue.dust: Offset(size.x * 0.27, size.y * 0.52),
    };

    for (final entry in targets.entries) {
      if ((point - entry.value).distance < 58) {
        _pedestalClues.add(entry.key);
        _message = switch (entry.key) {
          _PedestalClue.emptySpot => '씨앗이 위로 들린 것이 아니라 옆으로 밀린 흔적이에요.',
          _PedestalClue.scratch => '긁힌 방향이 정원 오른쪽을 가리켜요.',
          _PedestalClue.dust => '별가루가 12개예요. 3개씩 묶어 방향을 확인해 보세요.',
        };
        _burst(Vector2(entry.value.dx, entry.value.dy), count: 15);
        return;
      }
    }
  }

  void _handleTrailTap(Offset point) {
    final startX = size.x * 0.15;
    final spacing = size.x * 0.7 / 11;
    for (var index = 1; index <= 12; index++) {
      final target = Offset(startX + (index - 1) * spacing, size.y * 0.56);
      if ((point - target).distance < 28) {
        if (index == 12) {
          _trailSolved = true;
          _message = '12번째 칸에서 두 흔적이 만났어요. 발자국이 분수대로 이어집니다!';
          _burst(Vector2(target.dx, target.dy), count: 40);
        } else {
          _message = '$index번째 칸은 두 흔적이 함께 나타나는 곳이 아니에요.';
        }
        return;
      }
    }
    if (_trailSolved && _primaryButton.contains(point)) {
      _changeScene(_EpisodeScene.chest, '상자와 주변 물건을 직접 조사하세요.');
    }
  }

  void _handleChestTap(Offset point) {
    final lockRect = Rect.fromCenter(
      center: Offset(size.x * 0.62, size.y * 0.47),
      width: 120,
      height: 120,
    );
    final stoneRect = Rect.fromCenter(
      center: Offset(size.x * 0.28, size.y * 0.66),
      width: 150,
      height: 100,
    );

    if (lockRect.contains(point)) {
      _lockInspected = true;
      _message = _hasKey ? '별 모양 열쇠를 자물쇠로 끌어다 놓으세요.' : '별 모양 열쇠가 필요해요. 최근에 움직인 물건을 찾아보세요.';
      return;
    }
    if (stoneRect.contains(point) && !_stoneMoved) {
      _stoneMoved = true;
      _hasKey = true;
      _keyPosition = Vector2(size.x * 0.33, size.y * 0.65);
      _message = '돌 아래에서 별열쇠를 찾았어요!';
      _burst(_keyPosition, count: 35);
      return;
    }

    final lockCenter = Vector2(size.x * 0.62, size.y * 0.47);
    if (_hasKey && _keyPosition.distanceTo(lockCenter) < 12) {
      final values = [1, 2, 3, 4, 5, 6, 8, 12];
      for (var index = 0; index < values.length; index++) {
        final factorPoint = Offset(
          size.x * (0.18 + (index % 4) * 0.21),
          size.y * (0.72 + (index ~/ 4) * 0.08),
        );
        if ((point - factorPoint).distance < 32) {
          _toggleFactor(values[index]);
          return;
        }
      }
    }

    if (_hasKey && !_keyDragging && _keyPosition.distanceTo(Vector2(point.dx, point.dy)) < 42) {
      _keyDragging = true;
    }

    if (_factorsSolved && _primaryButton.contains(point)) {
      _changeScene(_EpisodeScene.deduction, '세 증거를 연결해 가장 자연스러운 가설을 선택하세요.');
    }
  }

  void _handleDeductionTap(Offset point) {
    final cardWidth = math.min(size.x * 0.78, 620);
    final left = (size.x - cardWidth) / 2;
    for (var index = 0; index < 3; index++) {
      final rect = Rect.fromLTWH(left, size.y * (0.38 + index * 0.13), cardWidth, 68);
      if (rect.contains(point)) {
        _deductionChoice = index;
        _message = index == 1
            ? '증거가 모두 연결됩니다. 이 가설로 사건을 설명할 수 있어요.'
            : '일부 증거가 설명되지 않아요. 다시 연결해 보세요.';
        return;
      }
    }
    if (_deductionChoice == 1 && _primaryButton.contains(point)) {
      _changeScene(_EpisodeScene.solved, '포포는 씨앗을 훔친 것이 아니라 바람에서 지켜주고 있었어요.');
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final point = event.localPosition;

    if (_scene == _EpisodeScene.pedestal && _pedestalClues.length == 3) {
      for (var index = _dust.length - 1; index >= 0; index--) {
        final piece = _dust[index];
        if (piece.group == null && piece.position.distanceTo(point) <= 30) {
          _draggingDust = index;
          piece.dragging = true;
          _burst(piece.position, count: 6);
          return;
        }
      }
    }

    if (_scene == _EpisodeScene.chest && _hasKey && _factors.isEmpty && _keyPosition.distanceTo(point) < 45) {
      _keyDragging = true;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final dustIndex = _draggingDust;
    if (dustIndex != null) {
      _dust[dustIndex].position += event.localDelta;
      return;
    }
    if (_keyDragging) {
      _keyPosition += event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final dustIndex = _draggingDust;
    if (dustIndex != null) {
      _finishDustDrag(dustIndex);
      return;
    }

    if (_keyDragging) {
      _keyDragging = false;
      final lockCenter = Vector2(size.x * 0.62, size.y * 0.47);
      if (_keyPosition.distanceTo(lockCenter) < 90) {
        _keyPosition = lockCenter;
        _message = '열쇠가 맞았어요. 12의 약수 문양을 모두 켜세요.';
        _burst(lockCenter, count: 45);
      } else {
        _keyPosition = Vector2(size.x * 0.33, size.y * 0.65);
      }
    }
  }

  void _finishDustDrag(int index) {
    final piece = _dust[index];
    piece.dragging = false;
    _draggingDust = null;

    final centers = _groupCenters;
    int? targetGroup;
    var bestDistance = double.infinity;
    for (var group = 0; group < centers.length; group++) {
      final distance = piece.position.distanceTo(Vector2(centers[group].dx, centers[group].dy));
      if (distance < 80 && distance < bestDistance && _countInGroup(group) < 3) {
        targetGroup = group;
        bestDistance = distance;
      }
    }

    if (targetGroup == null) {
      piece.position = piece.home.clone();
      return;
    }

    piece.group = targetGroup;
    final slot = _countInGroup(targetGroup) - 1;
    final center = centers[targetGroup];
    const offsets = [Offset(-23, 9), Offset(0, -20), Offset(23, 9)];
    piece.position = Vector2(center.dx + offsets[slot].dx, center.dy + offsets[slot].dy);
    _burst(piece.position, count: 16);

    if (_dust.every((item) => item.group != null)) {
      _message = '네 묶음 완성! 별가루가 오른쪽 길을 밝혔어요.';
      _burst(Vector2(size.x * 0.52, size.y * 0.48), count: 90);
    }
  }

  int _countInGroup(int group) => _dust.where((piece) => piece.group == group).length;

  bool get _factorsSolved {
    const answer = {1, 2, 3, 4, 6, 12};
    return _factors.length == answer.length && _factors.containsAll(answer);
  }

  void _toggleFactor(int value) {
    if (_factors.contains(value)) {
      _factors.remove(value);
    } else {
      _factors.add(value);
    }
    const answer = {1, 2, 3, 4, 6, 12};
    if (_factors.length == answer.length && _factors.containsAll(answer)) {
      _message = '잠금장치가 열렸어요. 상자 안에서 은빛 털과 꺾인 잎을 발견했습니다.';
      _burst(Vector2(size.x * 0.62, size.y * 0.43), count: 75);
    }
  }

  void _resetEpisode() {
    _scene = _EpisodeScene.intro;
    _pedestalClues.clear();
    _trailSolved = false;
    _lockInspected = false;
    _stoneMoved = false;
    _hasKey = false;
    _keyDragging = false;
    _factors.clear();
    _deductionChoice = null;
    _message = '별빛 씨앗이 사라졌어요. 정원을 조사해 주세요.';
    _createDust();
  }

  void _burst(Vector2 origin, {required int count}) {
    for (var index = 0; index < count; index++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 50 + _random.nextDouble() * 150;
      _sparks.add(
        _Spark(
          position: origin.clone(),
          velocity: Vector2(math.cos(angle), math.sin(angle)) * speed,
          life: 0.45 + _random.nextDouble() * 0.9,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawBackdrop(canvas);

    switch (_scene) {
      case _EpisodeScene.intro:
        _drawIntro(canvas);
      case _EpisodeScene.garden:
        _drawGardenScene(canvas);
      case _EpisodeScene.pedestal:
        _drawPedestalScene(canvas);
      case _EpisodeScene.trail:
        _drawTrailScene(canvas);
      case _EpisodeScene.chest:
        _drawChestScene(canvas);
      case _EpisodeScene.deduction:
        _drawDeductionScene(canvas);
      case _EpisodeScene.solved:
        _drawSolvedScene(canvas);
    }

    _drawSparks(canvas);
    _drawMessage(canvas);
    if (_transition > 0) {
      canvas.drawRect(
        Offset.zero & Size(size.x, size.y),
        Paint()..color = Colors.white.withValues(alpha: _transition * 0.14),
      );
    }
  }

  void _drawBackdrop(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF11172D), Color(0xFF163E45), Color(0xFF10261F)],
        ).createShader(rect),
    );
    final moon = Offset(size.x * 0.83, size.y * 0.17);
    canvas.drawCircle(moon, 48 + math.sin(_time * 1.4) * 3, Paint()..color = const Color(0x22FFF0AA));
    canvas.drawCircle(moon, 27, Paint()..color = const Color(0xFFFFE5A0));
  }

  void _drawIntro(Canvas canvas) {
    _drawGarden(canvas, dimmed: true);
    final card = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.48),
      width: math.min(size.x * 0.78, 650),
      height: math.min(size.y * 0.48, 380),
    );
    _drawRoundedPanel(canvas, card, const Color(0xDD251D38));
    _drawText(canvas, '사라진 별빛 씨앗', Offset(card.left + 28, card.top + 34), 30, Colors.white, FontWeight.w900);
    _drawText(canvas, '별받침대가 비어 있고 정원에는 수상한 흔적이 남아 있어요.\n직접 조사해서 씨앗이 사라진 이유를 밝혀보세요.', Offset(card.left + 28, card.top + 92), 17, const Color(0xFFE8DFF3), FontWeight.w600, maxWidth: card.width - 56);
    _drawButton(canvas, _primaryButton, '정원 조사 시작');
  }

  void _drawGardenScene(Canvas canvas) {
    _drawGarden(canvas);
    _drawText(canvas, '정원 전체 조사', Offset(24, 76), 24, Colors.white, FontWeight.w900);
    final glow = 0.55 + math.sin(_time * 3) * 0.25;
    canvas.drawRRect(
      RRect.fromRectAndRadius(_pedestalRect.inflate(18), const Radius.circular(40)),
      Paint()
        ..color = Color.fromRGBO(255, 218, 100, glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    _drawText(canvas, '빛나는 별받침대를 눌러 조사', Offset(size.x * 0.5 - 130, size.y * 0.73), 16, const Color(0xFFFFE596), FontWeight.w900);
  }

  void _drawPedestalScene(Canvas canvas) {
    _drawPedestal(canvas, large: true);
    final targets = <_PedestalClue, Offset>{
      _PedestalClue.emptySpot: Offset(size.x * 0.5, size.y * 0.34),
      _PedestalClue.scratch: Offset(size.x * 0.69, size.y * 0.49),
      _PedestalClue.dust: Offset(size.x * 0.27, size.y * 0.52),
    };
    for (final entry in targets.entries) {
      final inspected = _pedestalClues.contains(entry.key);
      canvas.drawCircle(
        entry.value,
        31 + math.sin(_time * 3.2) * 3,
        Paint()
          ..color = inspected ? const Color(0xAA8EE6BC) : const Color(0x66FFE680)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
      _drawText(canvas, inspected ? '✓' : '?', entry.value - const Offset(8, 17), 24, Colors.white, FontWeight.w900);
    }

    if (_pedestalClues.length == 3) {
      final centers = _groupCenters;
      for (var index = 0; index < centers.length; index++) {
        canvas.drawCircle(
          centers[index],
          48,
          Paint()
            ..color = const Color(0x334DD7B8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
        _drawText(canvas, '${_countInGroup(index)}/3', centers[index] - const Offset(14, 12), 15, const Color(0xFFBDF8E8), FontWeight.w900);
      }
      for (final piece in _dust) {
        canvas.drawCircle(piece.position.toOffset(), piece.dragging ? 18 : 15, Paint()..color = const Color(0xFFFFD86C));
        canvas.drawCircle(piece.position.toOffset(), piece.dragging ? 25 : 21, Paint()..color = const Color(0x33FFE989));
      }
      if (_dust.every((item) => item.group != null)) {
        _drawButton(canvas, _primaryButton, '오른쪽 길의 발자국 추적');
      }
    }
  }

  void _drawTrailScene(Canvas canvas) {
    _drawGarden(canvas);
    _drawText(canvas, '발자국과 별가루가 만나는 지점을 찾으세요', Offset(24, 82), 22, Colors.white, FontWeight.w900);
    final startX = size.x * 0.15;
    final spacing = size.x * 0.7 / 11;
    for (var index = 1; index <= 12; index++) {
      final point = Offset(startX + (index - 1) * spacing, size.y * 0.56);
      final footprint = index % 4 == 0;
      final dust = index % 6 == 0;
      canvas.drawCircle(point, 22, Paint()..color = const Color(0x55304F67));
      if (footprint) {
        canvas.drawCircle(point - const Offset(5, 2), 6, Paint()..color = const Color(0xFFE8B5D9));
        canvas.drawCircle(point + const Offset(7, 5), 5, Paint()..color = const Color(0xFFE8B5D9));
      }
      if (dust) {
        canvas.drawCircle(point, 7, Paint()..color = const Color(0xFFFFD96A));
      }
      _drawText(canvas, '$index', point + const Offset(-7, 28), 13, const Color(0xFFD9E9E7), FontWeight.w700);
    }
    if (_trailSolved) {
      _drawButton(canvas, _primaryButton, '분수대 상자 조사');
    }
  }

  void _drawChestScene(Canvas canvas) {
    _drawGarden(canvas);
    final chest = Rect.fromCenter(center: Offset(size.x * 0.62, size.y * 0.48), width: 250, height: 170);
    _drawRoundedPanel(canvas, chest, const Color(0xFF684E34));
    canvas.drawRect(Rect.fromCenter(center: chest.center, width: 52, height: 68), Paint()..color = const Color(0xFF2B2130));
    _drawText(canvas, _lockInspected ? '별 열쇠구멍' : '잠긴 상자', Offset(chest.left + 62, chest.top - 34), 18, Colors.white, FontWeight.w900);

    final stoneCenter = Offset(size.x * 0.28 + (_stoneMoved ? 70 : 0), size.y * 0.66);
    canvas.drawOval(Rect.fromCenter(center: stoneCenter, width: 150, height: 86), Paint()..color = const Color(0xFF637276));
    _drawText(canvas, _stoneMoved ? '돌을 옮겼어요' : '긁힌 돌', stoneCenter - const Offset(48, 58), 16, Colors.white, FontWeight.w800);

    if (_hasKey) {
      canvas.drawCircle(_keyPosition.toOffset(), 24, Paint()..color = const Color(0xFFFFD96A));
      canvas.drawRect(Rect.fromCenter(center: _keyPosition.toOffset() + const Offset(25, 0), width: 42, height: 10), Paint()..color = const Color(0xFFFFD96A));
    }

    final lockCenter = Vector2(size.x * 0.62, size.y * 0.47);
    if (_hasKey && _keyPosition.distanceTo(lockCenter) < 12) {
      final values = [1, 2, 3, 4, 5, 6, 8, 12];
      for (var index = 0; index < values.length; index++) {
        final point = Offset(size.x * (0.18 + (index % 4) * 0.21), size.y * (0.72 + (index ~/ 4) * 0.08));
        final selected = _factors.contains(values[index]);
        canvas.drawCircle(point, 27, Paint()..color = selected ? const Color(0xFF8FE0BE) : const Color(0xFF425866));
        _drawText(canvas, '${values[index]}', point - const Offset(8, 12), 16, Colors.white, FontWeight.w900);
      }
      if (_factorsSolved) {
        _drawButton(canvas, _primaryButton, '세 증거 연결해 추리');
      }
    }
  }

  void _drawDeductionScene(Canvas canvas) {
    final board = Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.5), width: math.min(size.x * 0.86, 720), height: math.min(size.y * 0.7, 560));
    _drawRoundedPanel(canvas, board, const Color(0xEE251E35));
    _drawText(canvas, '추리 보드', Offset(board.left + 28, board.top + 24), 27, Colors.white, FontWeight.w900);
    _drawText(canvas, '증거: 오른쪽 긁힌 자국 · 분수대 발자국 · 은빛 털과 꺾인 잎', Offset(board.left + 28, board.top + 70), 15, const Color(0xFFDCCDEA), FontWeight.w700, maxWidth: board.width - 56);
    const options = [
      '포포가 별빛 씨앗을 훔쳤다.',
      '강한 바람에 밀린 씨앗을 포포가 주워 상자에 지켜두었다.',
      '쓰러진 물뿌리개가 씨앗을 분수대로 밀었다.',
    ];
    final cardWidth = math.min(size.x * 0.78, 620);
    final left = (size.x - cardWidth) / 2;
    for (var index = 0; index < options.length; index++) {
      final rect = Rect.fromLTWH(left, size.y * (0.38 + index * 0.13), cardWidth, 68);
      _drawRoundedPanel(canvas, rect, _deductionChoice == index ? const Color(0xFF8B6DA8) : const Color(0xFF3A3048));
      _drawText(canvas, options[index], Offset(rect.left + 18, rect.top + 17), 15, Colors.white, FontWeight.w700, maxWidth: rect.width - 36);
    }
    if (_deductionChoice == 1) {
      _drawButton(canvas, _primaryButton, '이 가설로 사건 해결');
    }
  }

  void _drawSolvedScene(Canvas canvas) {
    _drawGarden(canvas, bright: true);
    for (var index = 0; index < 18; index++) {
      final x = size.x * (0.05 + index * 0.053);
      final y = size.y * (0.65 + math.sin(_time * 2 + index) * 0.03);
      canvas.drawCircle(Offset(x, y), 13, Paint()..color = const Color(0xFFF4A9D4));
    }
    final lumi = Offset(size.x * 0.38, size.y * 0.43 + math.sin(_time * 2.2) * 8);
    final popo = Offset(size.x * 0.62, size.y * 0.43 + math.sin(_time * 2.2 + 1) * 8);
    canvas.drawCircle(lumi, 42, Paint()..color = const Color(0xFFDCCBFF));
    canvas.drawCircle(popo, 42, Paint()..color = const Color(0xFFE8D6B1));
    _drawText(canvas, '사건 해결!', Offset(size.x * 0.5 - 92, size.y * 0.22), 34, Colors.white, FontWeight.w900);
    _drawText(canvas, '포포는 바람에 밀려온 씨앗이 연못에 빠지지 않도록 상자에 보관했어요.\n별빛 씨앗을 되찾자 정원에 다시 꽃이 피었습니다.', Offset(size.x * 0.5 - math.min(size.x * 0.36, 310), size.y * 0.57), 17, const Color(0xFFF4F1F7), FontWeight.w700, maxWidth: math.min(size.x * 0.72, 620));
    _drawButton(canvas, _primaryButton, '1단계 다시 플레이');
  }

  void _drawGarden(Canvas canvas, {bool dimmed = false, bool bright = false}) {
    final groundY = size.y * 0.7;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x * 0.5, groundY), width: size.x * 1.2, height: size.y * 0.48),
      Paint()..color = bright ? const Color(0xFF3F8B58) : const Color(0xFF22533E),
    );
    for (var index = 0; index < 16; index++) {
      final x = size.x * (0.03 + index * 0.063);
      final sway = math.sin(_time * 1.8 + index) * 5;
      final top = groundY - 80 - (index % 4) * 15;
      canvas.drawLine(Offset(x, groundY + 20), Offset(x + sway, top), Paint()..color = const Color(0xFF76B67B)..strokeWidth = 7..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(x + sway, top), 10, Paint()..color = const Color(0xFFE8A8D4));
    }
    _drawPedestal(canvas);
    if (dimmed) {
      canvas.drawRect(Offset.zero & Size(size.x, size.y), Paint()..color = const Color(0x66000000));
    }
  }

  void _drawPedestal(Canvas canvas, {bool large = false}) {
    final rect = large
        ? Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.48), width: math.min(size.x * 0.38, 330), height: math.min(size.y * 0.34, 280))
        : _pedestalRect;
    canvas.drawOval(Rect.fromCenter(center: rect.center + Offset(0, rect.height * 0.43), width: rect.width * 1.2, height: rect.height * 0.27), Paint()..color = const Color(0x66000000));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(34)), Paint()..shader = const LinearGradient(colors: [Color(0xFFE0C98C), Color(0xFF8E7148)]).createShader(rect));
    canvas.drawCircle(rect.center - Offset(0, rect.height * 0.12), rect.width * 0.2, Paint()..color = const Color(0xFF463A53));
    final glow = 0.55 + math.sin(_time * 3) * 0.2;
    canvas.drawCircle(rect.center - Offset(0, rect.height * 0.12), rect.width * 0.27, Paint()..color = Color.fromRGBO(255, 221, 110, glow)..style = PaintingStyle.stroke..strokeWidth = 7);
    for (var index = 0; index < 4; index++) {
      canvas.drawLine(Offset(rect.center.dx + 20, rect.center.dy - 34 + index * 14), Offset(rect.right + 42, rect.center.dy - 22 + index * 14), Paint()..color = const Color(0xFFFFD867)..strokeWidth = 4..strokeCap = StrokeCap.round);
    }
  }

  void _drawRoundedPanel(Canvas canvas, Rect rect, Color color) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(24)), Paint()..color = color);
  }

  void _drawButton(Canvas canvas, Rect rect, String label) {
    _drawRoundedPanel(canvas, rect, const Color(0xFFFFD96A));
    final painter = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Color(0xFF302440), fontSize: 18, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 24);
    painter.paint(canvas, Offset(rect.center.dx - painter.width / 2, rect.center.dy - painter.height / 2));
  }

  void _drawMessage(Canvas canvas) {
    final rect = Rect.fromLTWH(18, size.y - 92, size.x - 36, 56);
    _drawRoundedPanel(canvas, rect, const Color(0xDD171421));
    _drawText(canvas, _message, Offset(rect.left + 16, rect.top + 15), 14, const Color(0xFFF3ECF6), FontWeight.w700, maxWidth: rect.width - 32);
  }

  void _drawSparks(Canvas canvas) {
    for (final spark in _sparks) {
      canvas.drawCircle(spark.position.toOffset(), 3 + spark.life * 3, Paint()..color = Color.fromRGBO(255, 220, 105, spark.life.clamp(0, 1).toDouble()));
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double sizeValue, Color color, FontWeight weight, {double? maxWidth}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: sizeValue, fontWeight: weight, height: 1.35)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? size.x);
    painter.paint(canvas, offset);
  }
}
