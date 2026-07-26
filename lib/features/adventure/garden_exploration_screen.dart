import 'package:flutter/material.dart';

enum _Clue { scratch, footprints, silverFiber }

class GardenExplorationScreen extends StatefulWidget {
  const GardenExplorationScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  State<GardenExplorationScreen> createState() =>
      _GardenExplorationScreenState();
}

class _GardenExplorationScreenState extends State<GardenExplorationScreen> {
  final Set<_Clue> _clues = {};
  final Set<String> _checkedObjects = {};
  bool _showGuide = true;
  bool _hasKey = false;
  bool _chestOpened = false;
  bool _puzzleSolved = false;

  static const _clueDetails =
      <_Clue, ({IconData icon, String title, String text})>{
        _Clue.scratch: (
          icon: Icons.blur_on_rounded,
          title: '오른쪽으로 난 긁힌 자국',
          text: '별빛 씨앗은 누가 들고 간 게 아니라 강한 힘에 밀려난 것 같아요.',
        ),
        _Clue.footprints: (
          icon: Icons.pets_rounded,
          title: '작고 둥근 발자국',
          text: '연못 쪽에서 온 발자국이 받침대를 지나 온실 방향으로 이어져요.',
        ),
        _Clue.silverFiber: (
          icon: Icons.air_rounded,
          title: '상자 속 은빛 털',
          text: '차갑고 반짝이는 털 사이에 바람에 꺾인 잎이 끼어 있어요.',
        ),
      };

  bool get _complete => _clues.length == _clueDetails.length;

  Future<void> _findClue(_Clue clue) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (_clues.contains(clue)) {
      _openNotebook(focus: clue);
      return;
    }
    setState(() {
      _clues.add(clue);
      _showGuide = false;
    });
    final detail = _clueDetails[clue]!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _ClueFoundDialog(number: _clues.length, detail: detail),
    );
  }

  void _inspectDecoy({
    required String id,
    required String title,
    required String message,
  }) {
    setState(() {
      _checkedObjects.add(id);
      _showGuide = false;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('$title · $message'),
          action: SnackBarAction(label: '알겠어', onPressed: () {}),
        ),
      );
  }

  Future<void> _findKey() async {
    if (_hasKey) {
      _showMessage('작은 돌', '이미 낡은 별열쇠를 찾았어요. 분수대 상자를 살펴보세요.');
      return;
    }
    setState(() {
      _hasKey = true;
      _checkedObjects.add('stone');
      _showGuide = false;
    });
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ItemFoundDialog(),
    );
  }

  Future<void> _inspectChest() async {
    if (_puzzleSolved) {
      _openNotebook(focus: _Clue.silverFiber);
      return;
    }
    if (!_hasKey) {
      _showMessage('잠긴 분수대 상자', '별 모양 열쇠구멍이 있어요. 정원 어딘가에서 열쇠를 찾아야 해요.');
      return;
    }
    if (!_chestOpened) {
      setState(() {
        _chestOpened = true;
        _showGuide = false;
      });
    }
    final solved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _FactorPuzzleDialog(),
    );
    if (solved != true || !mounted) {
      return;
    }
    setState(() => _puzzleSolved = true);
    await _findClue(_Clue.silverFiber);
  }

  void _showMessage(String title, String message) {
    _inspectDecoy(id: title, title: title, message: message);
  }

  void _openNotebook({_Clue? focus}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ClueNotebook(clues: _clues, details: _clueDetails, focus: focus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161329),
      body: SafeArea(
        child: Column(
          children: [
            _MissionBar(
              found: _clues.length,
              hasKey: _hasKey,
              onClose: () => Navigator.of(context).pop(),
              onNotebook: _openNotebook,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const RepaintBoundary(
                    child: CustomPaint(painter: _GardenScenePainter()),
                  ),
                  const Positioned(left: 18, top: 16, child: _SceneLabel()),
                  _Hotspot(
                    key: const Key('scratch-hotspot'),
                    alignment: const Alignment(-0.12, -0.15),
                    semanticLabel: '빈 별받침대 조사',
                    discovered: _clues.contains(_Clue.scratch),
                    icon: Icons.auto_awesome_rounded,
                    color: const Color(0xFFFFDB72),
                    onTap: () => _findClue(_Clue.scratch),
                  ),
                  _Hotspot(
                    key: const Key('footprints-hotspot'),
                    alignment: const Alignment(0.55, 0.23),
                    semanticLabel: '작은 발자국 조사',
                    discovered: _clues.contains(_Clue.footprints),
                    icon: Icons.pets_rounded,
                    color: const Color(0xFFEAB4DB),
                    onTap: () => _findClue(_Clue.footprints),
                  ),
                  _Hotspot(
                    key: const Key('chest-hotspot'),
                    alignment: const Alignment(-0.72, 0.36),
                    semanticLabel: '분수대의 잠긴 상자 조사',
                    discovered: _puzzleSolved,
                    checked: _chestOpened,
                    icon: _chestOpened
                        ? Icons.lock_open_rounded
                        : Icons.inventory_2_rounded,
                    color: const Color(0xFF9AD9D2),
                    onTap: _inspectChest,
                  ),
                  _Hotspot(
                    key: const Key('key-hotspot'),
                    alignment: const Alignment(0.76, -0.55),
                    semanticLabel: '작은 돌 아래 조사',
                    checked: _hasKey,
                    icon: _hasKey ? Icons.key_rounded : Icons.landscape_rounded,
                    color: const Color(0xFFC9E8F2),
                    onTap: _findKey,
                  ),
                  _Hotspot(
                    alignment: const Alignment(-0.55, -0.48),
                    semanticLabel: '쓰러진 물뿌리개 조사',
                    checked: _checkedObjects.contains('can'),
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF8CD5E3),
                    onTap: () => _inspectDecoy(
                      id: 'can',
                      title: '쓰러진 물뿌리개',
                      message: '물은 아직 따뜻해요. 씨앗이 사라진 것과는 관계없어 보여요.',
                    ),
                  ),
                  _Hotspot(
                    alignment: const Alignment(0.55, 0.7),
                    semanticLabel: '반짝이는 꽃밭 조사',
                    checked: _checkedObjects.contains('flowers'),
                    icon: Icons.local_florist_rounded,
                    color: const Color(0xFFFFA8C8),
                    onTap: () => _inspectDecoy(
                      id: 'flowers',
                      title: '반짝이는 꽃밭',
                      message: '꽃잎이 사르르 흔들렸어요. 하지만 씨앗의 흔적은 없어요.',
                    ),
                  ),
                  if (_showGuide)
                    const Positioned(
                      left: 18,
                      right: 18,
                      bottom: 22,
                      child: _GuideCard(),
                    ),
                  if (_complete)
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 22,
                      child: _ContinueCard(
                        onNotebook: _openNotebook,
                        onContinue: () => widget.onContinue(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionBar extends StatelessWidget {
  const _MissionBar({
    required this.found,
    required this.hasKey,
    required this.onClose,
    required this.onNotebook,
  });

  final int found;
  final bool hasKey;
  final VoidCallback onClose;
  final VoidCallback onNotebook;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xEE231D38),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: '모험 나가기',
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사라진 별빛 씨앗',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '수상한 곳을 직접 눌러 단서를 찾아요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFFCFC4DA), fontSize: 11),
                ),
              ],
            ),
          ),
          if (hasKey)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Tooltip(
                message: '낡은 별열쇠',
                child: Icon(Icons.key_rounded, color: Color(0xFFFFD978)),
              ),
            ),
          TextButton.icon(
            onPressed: onNotebook,
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text('단서 $found/3'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFE69A),
              backgroundColor: const Color(0xFF453957),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneLabel extends StatelessWidget {
  const _SceneLabel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xBB211A32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, color: Color(0xFFFFD778), size: 17),
            SizedBox(width: 5),
            Text(
              '별정원 중앙 · 사건 현장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hotspot extends StatefulWidget {
  const _Hotspot({
    required this.alignment,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.onTap,
    this.discovered = false,
    this.checked = false,
    super.key,
  });

  final Alignment alignment;
  final String semanticLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool discovered;
  final bool checked;

  @override
  State<_Hotspot> createState() => _HotspotState();
}

class _HotspotState extends State<_Hotspot> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final resolved = widget.discovered || widget.checked;
    return Align(
      alignment: widget.alignment,
      child: Semantics(
        button: true,
        label: widget.semanticLabel,
        child: Tooltip(
          message: widget.semanticLabel,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedScale(
              scale: _hovering ? 1.12 : 1,
              duration: const Duration(milliseconds: 180),
              child: InkResponse(
                onTap: widget.onTap,
                radius: 45,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resolved
                        ? const Color(0xEE392E49)
                        : const Color(0x88342A42),
                    border: Border.all(
                      color: resolved
                          ? const Color(0xFFFFE68F)
                          : const Color(0x88FFFFFF),
                      width: resolved ? 3 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(
                          alpha: resolved ? 0.7 : 0.35,
                        ),
                        blurRadius: resolved ? 24 : 14,
                        spreadRadius: resolved ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(widget.icon, color: widget.color, size: 31),
                      if (widget.discovered)
                        const Align(
                          alignment: Alignment(0.9, -0.9),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xFFFFE68F),
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Color(0xFF493B2B),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xF22B233B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x55FFE99A)),
        boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 22)],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFFD7E6),
            child: Text('🌸', style: TextStyle(fontSize: 22)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '꽃루미: 반짝이는 곳만 정답은 아닐 거야. 돌과 상자도 눌러 보고, 수상한 흔적 3개를 찾아보자!',
              style: TextStyle(
                color: Colors.white,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemFoundDialog extends StatelessWidget {
  const _ItemFoundDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🔑 낡은 별열쇠 발견!'),
      content: const Text('작은 돌 아래에서 별 모양 열쇠를 찾았어요. 분수대 상자에 맞을 것 같아요.'),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('열쇠 챙기기'),
        ),
      ],
    );
  }
}

class _FactorPuzzleDialog extends StatefulWidget {
  const _FactorPuzzleDialog();

  @override
  State<_FactorPuzzleDialog> createState() => _FactorPuzzleDialogState();
}

class _FactorPuzzleDialogState extends State<_FactorPuzzleDialog> {
  static const _options = [1, 2, 3, 4, 5, 6];
  static const _answers = {1, 2, 3, 4, 6};
  final Set<int> _selected = {};
  String? _feedback;

  void _checkAnswer() {
    if (_selected.length == _answers.length && _selected.containsAll(_answers)) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _feedback = '아직 맞지 않아요. 12를 남김없이 나눌 수 있는 수만 골라보세요.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 48, color: Color(0xFF76558C)),
              const SizedBox(height: 12),
              const Text(
                '별빛 암호판',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                '12의 약수를 모두 선택하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in _options)
                    FilterChip(
                      key: Key('factor-$option'),
                      label: Text('$option'),
                      selected: _selected.contains(option),
                      onSelected: (selected) {
                        setState(() {
                          _feedback = null;
                          selected ? _selected.add(option) : _selected.remove(option);
                        });
                      },
                    ),
                ],
              ),
              if (_feedback != null) ...[
                const SizedBox(height: 14),
                Text(
                  _feedback!,
                  key: const Key('puzzle-feedback'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF9A4D72), fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('check-puzzle-answer'),
                onPressed: _selected.isEmpty ? null : _checkAnswer,
                child: const Text('암호 확인하기'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('정원을 더 살펴보기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClueFoundDialog extends StatelessWidget {
  const _ClueFoundDialog({required this.number, required this.detail});

  final int number;
  final ({IconData icon, String title, String text}) detail;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('✨ 새로운 단서 발견!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFFFE2EC),
            child: Icon(detail.icon, size: 36, color: const Color(0xFF76558C)),
          ),
          const SizedBox(height: 16),
          Text(
            detail.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(detail.text, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.menu_book_rounded),
          label: Text('수첩에 저장 · $number/3'),
        ),
      ],
    );
  }
}

class _ClueNotebook extends StatelessWidget {
  const _ClueNotebook({required this.clues, required this.details, this.focus});

  final Set<_Clue> clues;
  final Map<_Clue, ({IconData icon, String title, String text})> details;
  final _Clue? focus;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.9,
      minChildSize: 0.45,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F0E4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '별지기의 단서 수첩',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    tooltip: '단서 수첩 닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text('발견한 단서 ${clues.length}/3'),
              const SizedBox(height: 20),
              for (final entry in details.entries)
                _NotebookEntry(
                  detail: entry.value,
                  unlocked: clues.contains(entry.key),
                  highlighted: focus == entry.key,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotebookEntry extends StatelessWidget {
  const _NotebookEntry({
    required this.detail,
    required this.unlocked,
    required this.highlighted,
  });

  final ({IconData icon, String title, String text}) detail;
  final bool unlocked;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFE9E1D7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? const Color(0xFFE79BBE) : const Color(0xFFD8CEC2),
          width: highlighted ? 3 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: unlocked ? const Color(0xFFFFE2EC) : const Color(0xFFD5CDC4),
            child: Icon(
              unlocked ? detail.icon : Icons.lock_outline_rounded,
              color: const Color(0xFF76558C),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlocked ? detail.title : '아직 찾지 못한 단서',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(unlocked ? detail.text : '사건 현장을 조금 더 자세히 살펴보세요.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.onNotebook, required this.onContinue});

  final VoidCallback onNotebook;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF0B5), Color(0xFFFFD2E5)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 25)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('단서 3개를 모두 찾았어요!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('수첩의 단서를 따라 다음 장소로 추적해 볼까요?'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onNotebook, child: const Text('수첩 보기'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton(onPressed: onContinue, child: const Text('연못으로 추적'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _GardenScenePainter extends CustomPainter {
  const _GardenScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1836), Color(0xFF243B3C), Color(0xFF162E28)],
        ).createShader(rect),
    );

    final moon = Offset(size.width * 0.17, size.height * 0.18);
    canvas.drawCircle(moon, 42, Paint()..color = const Color(0x33FFF4C2));
    canvas.drawCircle(moon, 25, Paint()..color = const Color(0xFFFFE9A5));

    final path = Path()
      ..moveTo(size.width * 0.34, size.height)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.68, size.width * 0.47, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.22, size.width * 0.55, 0)
      ..lineTo(size.width * 0.76, 0)
      ..quadraticBezierTo(size.width * 0.63, size.height * 0.25, size.width * 0.66, size.height * 0.46)
      ..quadraticBezierTo(size.width * 0.73, size.height * 0.72, size.width * 0.67, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF9F8967));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.62),
        width: size.width * 0.3,
        height: size.height * 0.17,
      ),
      Paint()..color = const Color(0xFF4B9BA8),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.61),
        width: size.width * 0.24,
        height: size.height * 0.11,
      ),
      Paint()..color = const Color(0xFF72C3C4),
    );

    for (var index = 0; index < 34; index++) {
      final x = ((index * 47 + 13) % 97) / 100 * size.width;
      final y = ((index * 31 + 7) % 91) / 100 * size.height;
      final color = index.isEven ? const Color(0xFFFFE99C) : const Color(0xFFE8B6DC);
      canvas.drawCircle(Offset(x, y), index % 3 == 0 ? 2.2 : 1.3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
