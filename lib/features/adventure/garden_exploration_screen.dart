import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _Direction { up, down, left, right }

enum _Discovery { rumi, pedestal, footprints }

class GardenExplorationScreen extends StatefulWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  State<GardenExplorationScreen> createState() => _GardenExplorationScreenState();
}

class _GardenExplorationScreenState extends State<GardenExplorationScreen> {
  static const _step = 0.035;
  static const _interactionDistance = 0.17;
  static const _playerSize = 0.075;

  final FocusNode _focusNode = FocusNode();
  final Set<_Discovery> _discoveries = {};
  Offset _player = const Offset(0.5, 0.79);
  _Direction _facing = _Direction.up;
  String? _message;

  static const _targets = <_Discovery, Offset>{
    _Discovery.rumi: Offset(0.5, 0.64),
    _Discovery.pedestal: Offset(0.5, 0.39),
    _Discovery.footprints: Offset(0.73, 0.29),
  };

  static const _blockedAreas = <Rect>[
    Rect.fromLTWH(0.04, 0.08, 0.26, 0.22),
    Rect.fromLTWH(0.69, 0.06, 0.27, 0.22),
    Rect.fromLTWH(0.07, 0.52, 0.22, 0.18),
    Rect.fromLTWH(0.76, 0.52, 0.18, 0.2),
  ];

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      _move(_Direction.up);
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      _move(_Direction.down);
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _move(_Direction.left);
    } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      _move(_Direction.right);
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter) {
      _interact();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _move(_Direction direction) {
    final delta = switch (direction) {
      _Direction.up => const Offset(0, -_step),
      _Direction.down => const Offset(0, _step),
      _Direction.left => const Offset(-_step, 0),
      _Direction.right => const Offset(_step, 0),
    };
    final candidate = Offset(
      (_player.dx + delta.dx).clamp(0.055, 0.945),
      (_player.dy + delta.dy).clamp(0.075, 0.91),
    );
    final playerBounds = Rect.fromCenter(
      center: candidate,
      width: _playerSize,
      height: _playerSize,
    );
    if (_blockedAreas.any((area) => area.overlaps(playerBounds))) {
      setState(() {
        _facing = direction;
        _message = '꽃밭을 밟지 않도록 길을 따라가 볼까요?';
      });
      return;
    }
    setState(() {
      _facing = direction;
      _player = candidate;
      _message = null;
    });
  }

  _Discovery? get _nearbyDiscovery {
    _Discovery? closest;
    var closestDistance = _interactionDistance;
    for (final entry in _targets.entries) {
      final distance = (entry.value - _player).distance;
      if (distance <= closestDistance) {
        closest = entry.key;
        closestDistance = distance;
      }
    }
    return closest;
  }

  void _interact() {
    final target = _nearbyDiscovery;
    if (target == null) {
      setState(() => _message = '조사할 대상에 조금 더 가까이 가보세요.');
      return;
    }
    setState(() {
      _discoveries.add(target);
      _message = switch (target) {
        _Discovery.rumi => '꽃루미: 기다렸어, 탐험가! 별받침대까지 함께 가보자.',
        _Discovery.pedestal => '빈 별받침대에 오른쪽으로 길게 긁힌 자국이 있어. 씨앗이 밀려난 것 같아!',
        _Discovery.footprints => '작고 둥근 발자국이 연못 쪽으로 이어져 있어. 보리와 닮았지만 아직 단정할 수 없어.',
      };
    });
  }

  void _moveToward(Offset destination) {
    final delta = destination - _player;
    if (delta.distance < _step) return;
    if (delta.dx.abs() > delta.dy.abs()) {
      _move(delta.dx > 0 ? _Direction.right : _Direction.left);
    } else {
      _move(delta.dy > 0 ? _Direction.down : _Direction.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complete = _discoveries.length == _targets.length;
    return Scaffold(
      backgroundColor: const Color(0xFF241D36),
      body: SafeArea(
        child: Focus(
          autofocus: true,
          focusNode: _focusNode,
          onKeyEvent: _handleKey,
          child: Column(
            children: [
              _MissionBar(
                found: _discoveries.length,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTapUp: (details) {
                            final destination = Offset(
                              details.localPosition.dx / constraints.maxWidth,
                              details.localPosition.dy / constraints.maxHeight,
                            );
                            _moveToward(destination);
                            _focusNode.requestFocus();
                          },
                          child: CustomPaint(
                            painter: _GardenPainter(
                              discoveries: _discoveries,
                              complete: complete,
                            ),
                          ),
                        ),
                        _PositionedMapItem(
                          position: _targets[_Discovery.rumi]!,
                          child: _CharacterMarker(
                            emoji: '🌸',
                            label: '꽃루미',
                            active: _nearbyDiscovery == _Discovery.rumi,
                          ),
                        ),
                        _PositionedMapItem(
                          position: _targets[_Discovery.pedestal]!,
                          child: _ObjectMarker(
                            icon: Icons.auto_awesome_rounded,
                            label: _discoveries.contains(_Discovery.pedestal) ? '긁힌 자국' : '별받침대',
                            active: _nearbyDiscovery == _Discovery.pedestal,
                          ),
                        ),
                        _PositionedMapItem(
                          position: _targets[_Discovery.footprints]!,
                          child: _ObjectMarker(
                            icon: Icons.pets_rounded,
                            label: _discoveries.contains(_Discovery.footprints) ? '발자국 발견' : '수상한 흔적',
                            active: _nearbyDiscovery == _Discovery.footprints,
                          ),
                        ),
                        _PositionedMapItem(
                          position: _player,
                          size: 72,
                          child: _PlayerMarker(facing: _facing),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 18,
                          child: _DirectionPad(onMove: _move),
                        ),
                        Positioned(
                          right: 18,
                          bottom: 26,
                          child: _ActionButton(
                            enabled: _nearbyDiscovery != null,
                            onPressed: _interact,
                          ),
                        ),
                        if (_message != null)
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 145,
                            child: _MessageBubble(
                              message: _message!,
                              onClose: () => setState(() => _message = null),
                            ),
                          ),
                        if (complete)
                          Positioned(
                            top: 14,
                            left: 18,
                            right: 18,
                            child: _ContinueBanner(
                              onPressed: () => widget.onContinue(context),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionBar extends StatelessWidget {
  const _MissionBar({required this.found, required this.onClose});
  final int found;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF332746),
      padding: const EdgeInsets.fromLTRB(10, 10, 18, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: '모험 나가기',
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('별정원 중앙', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                Text('캐릭터를 움직여 수상한 흔적을 찾아요', style: TextStyle(color: Color(0xFFD7CBE2), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF554168), borderRadius: BorderRadius.circular(18)),
            child: Text('발견 $found/3', style: const TextStyle(color: Color(0xFFFFE59D), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _PositionedMapItem extends StatelessWidget {
  const _PositionedMapItem({required this.position, required this.child, this.size = 86});
  final Offset position;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(position.dx * 2 - 1, position.dy * 2 - 1),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

class _CharacterMarker extends StatelessWidget {
  const _CharacterMarker({required this.emoji, required this.label, required this.active});
  final String emoji;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (active) const _InteractionHint(),
        Text(emoji, style: const TextStyle(fontSize: 38)),
        _MapLabel(text: label),
      ],
    );
  }
}

class _ObjectMarker extends StatelessWidget {
  const _ObjectMarker({required this.icon, required this.label, required this.active});
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (active) const _InteractionHint(),
        Icon(icon, color: const Color(0xFFFFE38D), size: 34, shadows: const [Shadow(color: Colors.white, blurRadius: 12)]),
        const SizedBox(height: 3),
        _MapLabel(text: label),
      ],
    );
  }
}

class _InteractionHint extends StatelessWidget {
  const _InteractionHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFFFE89C), borderRadius: BorderRadius.circular(10)),
      child: const Text('!', style: TextStyle(color: Color(0xFF523F29), fontWeight: FontWeight.w900)),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xB72A2237), borderRadius: BorderRadius.circular(9)),
      child: Text(text, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _PlayerMarker extends StatelessWidget {
  const _PlayerMarker({required this.facing});
  final _Direction facing;

  @override
  Widget build(BuildContext context) {
    final arrow = switch (facing) {
      _Direction.up => Icons.keyboard_arrow_up_rounded,
      _Direction.down => Icons.keyboard_arrow_down_rounded,
      _Direction.left => Icons.keyboard_arrow_left_rounded,
      _Direction.right => Icons.keyboard_arrow_right_rounded,
    };
    return Semantics(
      label: '플레이어 캐릭터',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF6D6E7),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('🧒', style: TextStyle(fontSize: 35)),
            Align(alignment: Alignment.bottomCenter, child: Icon(arrow, color: const Color(0xFF6C4B7E), size: 18)),
          ],
        ),
      ),
    );
  }
}

class _DirectionPad extends StatelessWidget {
  const _DirectionPad({required this.onMove});
  final ValueChanged<_Direction> onMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 126,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x66342A42)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.topCenter, child: _PadButton(label: '위로 이동', icon: Icons.keyboard_arrow_up_rounded, onTap: () => onMove(_Direction.up))),
          Align(alignment: Alignment.bottomCenter, child: _PadButton(label: '아래로 이동', icon: Icons.keyboard_arrow_down_rounded, onTap: () => onMove(_Direction.down))),
          Align(alignment: Alignment.centerLeft, child: _PadButton(label: '왼쪽으로 이동', icon: Icons.keyboard_arrow_left_rounded, onTap: () => onMove(_Direction.left))),
          Align(alignment: Alignment.centerRight, child: _PadButton(label: '오른쪽으로 이동', icon: Icons.keyboard_arrow_right_rounded, onTap: () => onMove(_Direction.right))),
          Container(width: 34, height: 34, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xAA6E5A7C))),
        ],
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  const _PadButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 31),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '조사하기',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFFFFD86E) : const Color(0x995A5064),
          boxShadow: enabled ? const [BoxShadow(color: Color(0x88FFE38A), blurRadius: 20, spreadRadius: 3)] : null,
        ),
        child: IconButton(
          tooltip: '조사하기',
          onPressed: onPressed,
          icon: Icon(Icons.search_rounded, color: enabled ? const Color(0xFF4A382A) : Colors.white54, size: 38),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF9FFF9F0),
      elevation: 10,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 15, 8, 15),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFFFD9E8), child: Text('🌸')),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF4C4052), height: 1.4, fontWeight: FontWeight.w700))),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
          ],
        ),
      ),
    );
  }
}

class _ContinueBanner extends StatelessWidget {
  const _ContinueBanner({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDF4D0),
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFA9782E)),
            const SizedBox(width: 10),
            const Expanded(child: Text('중앙 정원의 흔적을 모두 찾았어요!', style: TextStyle(color: Color(0xFF5C4934), fontWeight: FontWeight.w900))),
            FilledButton(onPressed: onPressed, child: const Text('연못으로')),
          ],
        ),
      ),
    );
  }
}

class _GardenPainter extends CustomPainter {
  const _GardenPainter({required this.discoveries, required this.complete});
  final Set<_Discovery> discoveries;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const background = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF315D51), Color(0xFF49795B), Color(0xFF2F5C48)],
    );
    canvas.drawRect(rect, Paint()..shader = background.createShader(rect));

    final path = Path()
      ..moveTo(size.width * 0.43, size.height)
      ..cubicTo(size.width * 0.42, size.height * 0.72, size.width * 0.57, size.height * 0.58, size.width * 0.5, size.height * 0.38)
      ..cubicTo(size.width * 0.46, size.height * 0.25, size.width * 0.58, size.height * 0.17, size.width * 0.56, 0)
      ..lineTo(size.width * 0.73, 0)
      ..cubicTo(size.width * 0.72, size.height * 0.2, size.width * 0.62, size.height * 0.28, size.width * 0.63, size.height * 0.4)
      ..cubicTo(size.width * 0.68, size.height * 0.62, size.width * 0.57, size.height * 0.76, size.width * 0.6, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFC9AE7B));
    canvas.drawPath(path, Paint()..color = const Color(0x55FFF0C9)..style = PaintingStyle.stroke..strokeWidth = 5);

    _drawPond(canvas, size);
    _drawFlowerBed(canvas, size, const Rect.fromLTWH(0.07, 0.52, 0.22, 0.18), const Color(0xFFE792BB));
    _drawFlowerBed(canvas, size, const Rect.fromLTWH(0.76, 0.52, 0.18, 0.2), const Color(0xFFB99AE8));
    _drawTrees(canvas, size);

    for (var index = 0; index < 20; index++) {
      final x = ((index * 47) % 93) / 100 * size.width;
      final y = ((index * 31 + 17) % 87) / 100 * size.height;
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.7 : 1.1, Paint()..color = const Color(0x99FFF0AD));
    }

    if (discoveries.contains(_Discovery.footprints)) {
      final paint = Paint()..color = const Color(0xFFFFE29A);
      for (var i = 0; i < 6; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * (0.69 - i * 0.025), size.height * (0.32 + i * 0.035)),
            width: 8,
            height: 12,
          ),
          paint,
        );
      }
    }

    if (complete) {
      canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 22, Paint()..color = const Color(0x88FFE596));
      canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 8, Paint()..color = const Color(0xFFFFF4B0));
    }
  }

  void _drawPond(Canvas canvas, Size size) {
    final pond = Rect.fromLTWH(size.width * 0.04, size.height * 0.08, size.width * 0.26, size.height * 0.22);
    canvas.drawOval(pond, Paint()..color = const Color(0xFF67B8C5));
    canvas.drawOval(pond.deflate(8), Paint()..color = const Color(0xFF8BD2D5));
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(pond.left + 35 + i * 28, pond.top + 42 + (i % 2) * 25), 9, Paint()..color = const Color(0xFF6C9C71));
    }
  }

  void _drawFlowerBed(Canvas canvas, Size size, Rect normalized, Color flowerColor) {
    final rect = Rect.fromLTWH(normalized.left * size.width, normalized.top * size.height, normalized.width * size.width, normalized.height * size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(30)), Paint()..color = const Color(0xFF285743));
    for (var index = 0; index < 11; index++) {
      final x = rect.left + 14 + (index * 31 % rect.width).toDouble();
      final y = rect.top + 15 + (index * 23 % rect.height).toDouble();
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = flowerColor);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = const Color(0xFFFFEB8C));
    }
  }

  void _drawTrees(Canvas canvas, Size size) {
    const positions = [Offset(0.76, 0.12), Offset(0.87, 0.17), Offset(0.17, 0.37), Offset(0.9, 0.4), Offset(0.12, 0.82), Offset(0.87, 0.84)];
    for (final position in positions) {
      final center = Offset(position.dx * size.width, position.dy * size.height);
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, 18), width: 10, height: 36), Paint()..color = const Color(0xFF745033));
      canvas.drawCircle(center, 29, Paint()..color = const Color(0xFF234D3E));
      canvas.drawCircle(center - const Offset(10, 8), 18, Paint()..color = const Color(0xFF3F7652));
    }
  }

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) {
    return oldDelegate.discoveries.length != discoveries.length || oldDelegate.complete != complete;
  }
}
