// ignore_for_file: sort_child_properties_last

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

const _inventoryOverlay = 'inventory';
const _hintOverlay = 'hint';
const _statusOverlay = 'status';

enum EscapeLabScene { garden, closeUp, dragPuzzle }

enum EscapeLabItem { flower, starKey }

extension on EscapeLabItem {
  String get label => this == EscapeLabItem.flower ? '꽃잎' : '별열쇠';

  IconData get icon => this == EscapeLabItem.flower
      ? Icons.local_florist_rounded
      : Icons.key_rounded;
}

@immutable
class EscapeLabState {
  const EscapeLabState({
    required this.inventory,
    required this.selected,
    required this.message,
    required this.completed,
    required this.inputLocked,
    required this.lifecycle,
    this.audioError,
  });

  final Set<EscapeLabItem> inventory;
  final EscapeLabItem? selected;
  final String message;
  final Set<String> completed;
  final bool inputLocked;
  final String lifecycle;
  final String? audioError;
}

class EscapeFeasibilityScreen extends StatefulWidget {
  const EscapeFeasibilityScreen({super.key});

  @override
  State<EscapeFeasibilityScreen> createState() =>
      _EscapeFeasibilityScreenState();
}

class _EscapeFeasibilityScreenState extends State<EscapeFeasibilityScreen>
    with WidgetsBindingObserver {
  late final EscapeFeasibilityGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = EscapeFeasibilityGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _game.handleLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_game.disposeResources());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07131A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GameWidget<EscapeFeasibilityGame>(
                game: _game,
                initialActiveOverlays: const [_inventoryOverlay],
                overlayBuilderMap: {
                  _inventoryOverlay: (_, game) => _InventoryOverlay(game: game),
                  _hintOverlay: (_, game) => _HintOverlay(game: game),
                  _statusOverlay: (_, game) => _StatusOverlay(game: game),
                },
              ),
            ),
            Positioned(
              left: 8,
              top: 6,
              child: IconButton.filledTonal(
                key: const Key('escape-lab-back'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Positioned(
              left: 62,
              top: 16,
              child: Text(
                'Flame 방탈출 기술 검증실',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            Positioned(
              right: 54,
              top: 6,
              child: IconButton.filledTonal(
                key: const Key('escape-lab-status'),
                onPressed: _game.showStatus,
                icon: const Icon(Icons.fact_check_rounded),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: IconButton.filledTonal(
                key: const Key('escape-lab-hint'),
                onPressed: _game.showHint,
                icon: const Icon(Icons.lightbulb_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EscapeFeasibilityGame extends FlameGame {
  EscapeFeasibilityGame()
    : state = ValueNotifier<EscapeLabState>(
        const EscapeLabState(
          inventory: {EscapeLabItem.flower},
          selected: null,
          message: '등불을 누른 뒤 다른 장면을 조사하세요.',
          completed: {},
          inputLocked: false,
          lifecycle: '실행 중',
        ),
      );

  final ValueNotifier<EscapeLabState> state;
  final AudioPlayer _player = AudioPlayer();
  final Set<EscapeLabItem> inventory = {EscapeLabItem.flower};
  final Set<String> completed = {};

  EscapeLabScene scene = EscapeLabScene.garden;
  EscapeLabItem? selected;
  bool lampOn = false;
  bool visitedCloseUp = false;
  bool dragSolved = false;
  bool doorOpen = false;
  bool inputLocked = false;
  double mechanismProgress = 0;
  String message = '등불을 누른 뒤 다른 장면을 조사하세요.';
  String lifecycle = '실행 중';
  String? audioError;
  bool _disposed = false;

  @override
  Color backgroundColor() => const Color(0xFF07131A);

  @override
  Future<void> onLoad() async {
    await add(_EscapeLabWorld(this));
  }

  void selectItem(EscapeLabItem item) {
    selected = selected == item ? null : item;
    message = selected == null ? '아이템 선택을 해제했어요.' : '${item.label} 선택';
    _notify();
  }

  void addKey() {
    inventory.add(EscapeLabItem.starKey);
    selected = EscapeLabItem.starKey;
    completed.add('인벤토리 획득·선택·사용');
    message = '별열쇠를 얻었어요. 정원의 문에 사용하세요.';
    _notify();
  }

  void changeScene(EscapeLabScene next) {
    if (inputLocked) return;

    final previous = scene;
    scene = next;
    if (next == EscapeLabScene.closeUp) {
      visitedCloseUp = true;
      message = '확대 조사: 작업대 위 열쇠를 찾아보세요.';
    } else if (next == EscapeLabScene.dragPuzzle) {
      message = dragSolved ? '조각 맞춤 완료' : '별조각을 빛나는 홈으로 옮기세요.';
    } else {
      if (previous == EscapeLabScene.closeUp) {
        completed.add('확대 조사 후 복귀');
        if (visitedCloseUp && lampOn) {
          completed.add('장면 이동 후 상태 유지');
        }
      }
      message = doorOpen ? '검증 문이 열렸어요.' : '등불과 잠긴 문을 조사하세요.';
    }
    _notify();
  }

  void toggleLamp() {
    if (inputLocked) return;
    lampOn = !lampOn;
    message = lampOn ? '등불 상태를 기억했어요.' : '등불이 꺼졌어요.';
    _notify();
  }

  void useOnLock() {
    if (inputLocked || doorOpen) return;

    if (selected == EscapeLabItem.starKey && inventory.contains(selected)) {
      inputLocked = true;
      mechanismProgress = 0;
      selected = null;
      message = '장치 작동 중에는 입력을 잠급니다.';
    } else if (selected == EscapeLabItem.flower) {
      completed.add('잘못된 아이템 반응');
      message = '꽃잎은 별 모양 열쇠구멍과 맞지 않아요.';
    } else {
      message = '별 모양 아이템이 필요해요.';
    }
    _notify();
  }

  void updateMechanism(double dt) {
    if (!inputLocked || doorOpen) return;

    mechanismProgress = math.min(1, mechanismProgress + dt / 1.6).toDouble();
    if (mechanismProgress >= 1) {
      inputLocked = false;
      doorOpen = true;
      completed.add('연쇄 애니메이션 입력 잠금');
      message = '장치가 차례로 움직이고 문이 열렸어요.';
      _notify();
      unawaited(playChime());
    }
  }

  void finishDrag() {
    dragSolved = true;
    completed.add('드래그 스냅 판정');
    message = '조각이 홈에 맞아 스냅되었습니다.';
    _notify();
    unawaited(playChime());
  }

  void reportSmallLayout() {
    if (size.x <= 420 || size.y <= 700) {
      completed.add('작은 화면 반응형 배치');
      _notify();
    }
  }

  void showHint() {
    completed.add('Flutter 오버레이 입력 분리');
    overlays.add(_hintOverlay);
    _notify();
  }

  void showStatus() {
    completed.add('Flutter 오버레이 입력 분리');
    overlays.add(_statusOverlay);
    _notify();
  }

  void handleLifecycle(AppLifecycleState value) {
    lifecycle = value.name;
    if (value == AppLifecycleState.resumed) {
      resumeEngine();
      completed.add('앱 생명주기 처리');
    } else {
      pauseEngine();
      unawaited(_pauseAudio());
    }
    _notify();
  }

  Future<void> _pauseAudio() async {
    try {
      await _player.pause();
    } catch (_) {
      // 재생 전 pause 요청은 무시한다.
    }
  }

  Future<void> playChime() async {
    try {
      await _player.play(
        BytesSource(_wavBytes(), mimeType: 'audio/wav'),
        volume: 0.18,
      );
      completed.add('효과음 재생 요청');
    } catch (error) {
      audioError = error.toString();
    }
    _notify();
  }

  void setMessage(String value) {
    message = value;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    state.value = EscapeLabState(
      inventory: Set.unmodifiable(inventory),
      selected: selected,
      message: message,
      completed: Set.unmodifiable(completed),
      inputLocked: inputLocked,
      lifecycle: lifecycle,
      audioError: audioError,
    );
  }

  Future<void> disposeResources() async {
    if (_disposed) return;
    _disposed = true;
    await _player.dispose();
    state.dispose();
  }

  Uint8List _wavBytes() {
    const rate = 8000;
    const samples = 960;
    final bytes = ByteData(44 + samples * 2);

    void ascii(int offset, String text) {
      for (var index = 0; index < text.length; index++) {
        bytes.setUint8(offset + index, text.codeUnitAt(index));
      }
    }

    ascii(0, 'RIFF');
    bytes.setUint32(4, 36 + samples * 2, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, rate, Endian.little);
    bytes.setUint32(28, rate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    bytes.setUint32(40, samples * 2, Endian.little);

    for (var index = 0; index < samples; index++) {
      final envelope = 1 - index / samples;
      final sample =
          (math.sin(2 * math.pi * 880 * index / rate) * envelope * 8500)
              .round();
      bytes.setInt16(44 + index * 2, sample, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}

class _EscapeLabWorld extends PositionComponent
    with TapCallbacks, DragCallbacks {
  _EscapeLabWorld(this.lab);

  final EscapeFeasibilityGame lab;
  Vector2 piece = Vector2.zero();
  Vector2 home = Vector2.zero();
  Vector2 target = Vector2.zero();
  bool dragging = false;

  Rect get frame => Rect.fromLTWH(14, 72, size.x - 28, size.y - 170);
  Rect get leftButton =>
      Rect.fromLTWH(frame.left + 12, frame.bottom - 52, 120, 40);
  Rect get rightButton =>
      Rect.fromLTWH(frame.right - 132, frame.bottom - 52, 120, 40);
  Rect get lamp => Rect.fromCenter(
    center: Offset(size.x * .28, frame.center.dy),
    width: 110,
    height: 140,
  );
  Rect get door => Rect.fromCenter(
    center: Offset(size.x * .68, frame.center.dy),
    width: 140,
    height: 210,
  );
  Rect get keyRect => Rect.fromCenter(
    center: Offset(size.x * .56, frame.center.dy),
    width: 100,
    height: 80,
  );

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
    home = Vector2(size.x * .25, frame.center.dy);
    target = Vector2(size.x * .72, frame.center.dy);
    if (!dragging && !lab.dragSolved) piece = home.clone();
    if (lab.dragSolved) piece = target.clone();
    lab.reportSmallLayout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lab.updateMechanism(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (lab.inputLocked) return;

    final point = event.localPosition.toOffset();
    switch (lab.scene) {
      case EscapeLabScene.garden:
        if (lamp.inflate(16).contains(point)) {
          lab.toggleLamp();
          return;
        }
        if (door.inflate(16).contains(point)) {
          lab.useOnLock();
          return;
        }
        if (leftButton.contains(point)) {
          lab.changeScene(EscapeLabScene.dragPuzzle);
          return;
        }
        if (rightButton.contains(point)) {
          lab.changeScene(EscapeLabScene.closeUp);
          return;
        }
      case EscapeLabScene.closeUp:
        if (leftButton.contains(point)) {
          lab.changeScene(EscapeLabScene.garden);
          return;
        }
        if (!lab.inventory.contains(EscapeLabItem.starKey) &&
            keyRect.inflate(20).contains(point)) {
          lab.addKey();
          return;
        }
      case EscapeLabScene.dragPuzzle:
        if (rightButton.contains(point)) {
          lab.changeScene(EscapeLabScene.garden);
        }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (lab.scene == EscapeLabScene.dragPuzzle &&
        !lab.dragSolved &&
        piece.distanceTo(event.localPosition) < 50) {
      dragging = true;
      lab.setMessage('별조각을 옮기는 중이에요.');
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!dragging) return;
    piece += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!dragging) return;

    dragging = false;
    if (piece.distanceTo(target) < 76) {
      piece = target.clone();
      lab.finishDrag();
    } else {
      piece = home.clone();
      lab.setMessage('홈과 멀어 조각이 원래 자리로 돌아왔어요.');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = const Color(0xFF0A2226),
    );
    _box(
      canvas,
      Rect.fromLTWH(14, 52, size.x - 28, 56),
      const Color(0xFF18313B),
    );
    _text(canvas, lab.message, const Offset(28, 66), size.x - 56, 13);
    _box(canvas, frame, const Color(0xFF1A403B));

    switch (lab.scene) {
      case EscapeLabScene.garden:
        _garden(canvas);
      case EscapeLabScene.closeUp:
        _closeUp(canvas);
      case EscapeLabScene.dragPuzzle:
        _drag(canvas);
    }
  }

  void _garden(Canvas canvas) {
    _box(canvas, lamp, const Color(0xFF315A52));
    canvas.drawCircle(
      lamp.center,
      28,
      Paint()
        ..color = lab.lampOn
            ? const Color(0xFFFFE276)
            : const Color(0xFF718078),
    );
    _text(
      canvas,
      lab.lampOn ? '켜진 등불' : '꺼진 등불',
      Offset(lamp.left, lamp.bottom + 8),
      lamp.width,
      13,
      center: true,
    );

    _box(canvas, door, const Color(0xFF57406B));
    final shift = lab.mechanismProgress * 46;
    if (!lab.doorOpen) {
      canvas.drawRect(
        Rect.fromLTWH(
          door.left + 8 - shift,
          door.top + 8,
          door.width / 2 - 8,
          door.height - 16,
        ),
        Paint()..color = const Color(0xFF8568A0),
      );
      canvas.drawRect(
        Rect.fromLTWH(
          door.center.dx + shift,
          door.top + 8,
          door.width / 2 - 8,
          door.height - 16,
        ),
        Paint()..color = const Color(0xFF8568A0),
      );
    } else {
      _box(canvas, door.deflate(10), const Color(0xFFFFDE77));
    }
    canvas.drawCircle(
      Offset(door.center.dx, door.center.dy + 25),
      18,
      Paint()..color = const Color(0xFFFFD96A),
    );
    _text(
      canvas,
      lab.doorOpen ? '열린 문' : '별 자물쇠',
      Offset(door.left, door.top - 25),
      door.width,
      13,
      center: true,
    );

    _button(canvas, leftButton, '조각실');
    _button(canvas, rightButton, '확대 조사');
    if (lab.inputLocked) {
      _box(
        canvas,
        Rect.fromCenter(
          center: frame.center,
          width: math.min(330, size.x * .75).toDouble(),
          height: 64,
        ),
        const Color(0xEE111923),
      );
      _text(
        canvas,
        '장치 작동 중 ${(lab.mechanismProgress * 100).round()}%',
        Offset(frame.center.dx - 130, frame.center.dy - 10),
        260,
        14,
        center: true,
      );
    }
  }

  void _closeUp(Canvas canvas) {
    _text(
      canvas,
      '확대 조사: 오래된 작업대',
      Offset(frame.left + 20, frame.top + 26),
      frame.width - 40,
      20,
      center: true,
    );
    _box(
      canvas,
      Rect.fromLTWH(
        frame.left + 28,
        frame.center.dy - 45,
        frame.width - 56,
        100,
      ),
      const Color(0xFF6D503B),
    );
    if (!lab.inventory.contains(EscapeLabItem.starKey)) {
      canvas.drawCircle(
        keyRect.center,
        24,
        Paint()..color = const Color(0xFFFFD96A),
      );
      canvas.drawRect(
        Rect.fromLTWH(keyRect.center.dx + 15, keyRect.center.dy - 6, 42, 12),
        Paint()..color = const Color(0xFFFFD96A),
      );
      _text(
        canvas,
        '별열쇠',
        Offset(keyRect.left, keyRect.bottom + 8),
        keyRect.width,
        13,
        center: true,
      );
    } else {
      _text(
        canvas,
        '열쇠를 가방에 넣었어요.',
        Offset(frame.left + 40, frame.center.dy - 8),
        frame.width - 80,
        15,
        center: true,
      );
    }
    _button(canvas, leftButton, '정원으로');
  }

  void _drag(Canvas canvas) {
    _text(
      canvas,
      '드래그·스냅 검증',
      Offset(frame.left + 20, frame.top + 26),
      frame.width - 40,
      20,
      center: true,
    );
    canvas.drawCircle(
      target.toOffset(),
      52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = const Color(0xFF72DFC3),
    );
    canvas.drawCircle(
      piece.toOffset(),
      34,
      Paint()
        ..color = lab.dragSolved
            ? const Color(0xFFFFE276)
            : const Color(0xFFD49BFF),
    );
    _text(
      canvas,
      lab.dragSolved ? '맞춤 완료' : '별조각',
      Offset(piece.x - 55, piece.y + 45),
      110,
      13,
      center: true,
    );
    _button(canvas, rightButton, '정원으로');
  }

  void _box(Canvas canvas, Rect rect, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      Paint()..color = color,
    );
  }

  void _button(Canvas canvas, Rect rect, String label) {
    _box(canvas, rect, const Color(0xFF32665B));
    _text(
      canvas,
      label,
      Offset(rect.left + 8, rect.top + 11),
      rect.width - 16,
      13,
      center: true,
    );
  }

  void _text(
    Canvas canvas,
    String value,
    Offset offset,
    double width,
    double size, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }
}

class _InventoryOverlay extends StatelessWidget {
  const _InventoryOverlay({required this.game});

  final EscapeFeasibilityGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ValueListenableBuilder<EscapeLabState>(
          valueListenable: game.state,
          builder: (_, state, _) => Container(
            height: 80,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xF21A2730),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    '가방',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                for (final item in state.inventory)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('escape-lab-item-${item.name}'),
                      selected: state.selected == item,
                      onSelected: (_) => game.selectItem(item),
                      avatar: Icon(item.icon, size: 18),
                      label: Text(item.label),
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

class _HintOverlay extends StatelessWidget {
  const _HintOverlay({required this.game});

  final EscapeFeasibilityGame game;

  @override
  Widget build(BuildContext context) {
    return _Modal(
      title: '기술 검증 힌트',
      child: const Text(
        '확대 조사에서 별열쇠를 얻고 정원의 문에 사용하세요. '
        '조각실에서는 별조각을 빛나는 홈으로 끌어놓으세요.',
        textAlign: TextAlign.center,
      ),
      onClose: () => game.overlays.remove(_hintOverlay),
      closeKey: const Key('escape-lab-hint-close'),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.game});

  final EscapeFeasibilityGame game;

  @override
  Widget build(BuildContext context) {
    return _Modal(
      title: 'Flame 구현 가능성 검증 현황',
      child: ValueListenableBuilder<EscapeLabState>(
        valueListenable: game.state,
        builder: (_, state, _) => ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 390),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final item in state.completed)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_rounded),
                  title: Text(item),
                ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.phone_android_rounded),
                title: const Text('생명주기'),
                subtitle: Text(state.lifecycle),
              ),
              if (state.audioError != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.error_outline),
                  title: const Text('오디오 오류'),
                  subtitle: Text(state.audioError!),
                ),
            ],
          ),
        ),
      ),
      onClose: () => game.overlays.remove(_statusOverlay),
      closeKey: const Key('escape-lab-status-close'),
    );
  }
}

class _Modal extends StatelessWidget {
  const _Modal({
    required this.title,
    required this.child,
    required this.onClose,
    required this.closeKey,
  });

  final String title;
  final Widget child;
  final VoidCallback onClose;
  final Key closeKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    child,
                    const SizedBox(height: 14),
                    FilledButton(
                      key: closeKey,
                      onPressed: onClose,
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
