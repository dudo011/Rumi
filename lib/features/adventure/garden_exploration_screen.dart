import 'package:flutter/material.dart';

enum _Clue { scratch, footprints, silverFiber }
enum _InvestigationStage { observe, followTrail, openChest, deduce, solved }

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
  _InvestigationStage _stage = _InvestigationStage.observe;
  bool _hasKey = false;
  bool _chestOpened = false;
  bool _chestTried = false;
  bool _puzzleSolved = false;
  bool _openingShown = false;

  static const _clueDetails =
      <_Clue, ({IconData icon, String title, String text})>{
        _Clue.scratch: (
          icon: Icons.blur_on_rounded,
          title: '오른쪽으로 난 긁힌 자국',
          text: '씨앗은 누가 집어 간 것이 아니라 오른쪽으로 강하게 밀려난 것 같아요.',
        ),
        _Clue.footprints: (
          icon: Icons.pets_rounded,
          title: '분수대로 이어진 작은 발자국',
          text: '작고 둥근 발자국이 오른쪽 길을 따라 분수대 앞에서 멈췄어요.',
        ),
        _Clue.silverFiber: (
          icon: Icons.air_rounded,
          title: '상자 속 은빛 털과 꺾인 잎',
          text: '은빛 털 사이에 바람에 꺾인 잎이 끼어 있어요. 누군가 씨앗을 보호한 흔적 같아요.',
        ),
      };

  String get _objective {
    switch (_stage) {
      case _InvestigationStage.observe:
        return '빈 별받침대 주변에서 무슨 일이 있었는지 살펴보세요.';
      case _InvestigationStage.followTrail:
        return '오른쪽 길에 새로 드러난 흔적을 따라가 보세요.';
      case _InvestigationStage.openChest:
        if (!_chestTried) {
          return '발자국이 멈춘 분수대 주변을 조사하세요.';
        }
        if (!_hasKey) {
          return '잠긴 상자 근처에서 움직인 물건을 찾아보세요.';
        }
        return '별열쇠로 분수대 상자의 암호를 풀어보세요.';
      case _InvestigationStage.deduce:
        return '세 가지 증거를 연결해 정원에서 일어난 일을 추리하세요.';
      case _InvestigationStage.solved:
        return '사건 해결! 별빛 씨앗을 다시 심을 준비가 되었어요.';
    }
  }

  String get _hypothesis {
    if (_stage == _InvestigationStage.solved) {
      return '강한 바람에 밀린 씨앗을 포포가 지켜주었다';
    }
    if (_clues.contains(_Clue.silverFiber)) {
      return '누군가 씨앗을 발견해 안전한 곳에 숨긴 것 같다';
    }
    if (_clues.contains(_Clue.footprints)) {
      return '작은 동물이 분수대까지 씨앗을 따라간 것 같다';
    }
    if (_clues.contains(_Clue.scratch)) {
      return '씨앗이 오른쪽으로 밀려난 것 같다';
    }
    return '아직 모르겠다';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openingShown) return;
    _openingShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showOpeningStory();
    });
  }

  Future<void> _showOpeningStory() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🌟 별빛 씨앗이 사라졌어요!'),
        content: const Text(
          '꽃루미: 조금 전까지 받침대 위에 있던 씨앗이 없어졌어.\n\n'
          '누가 가져간 걸까, 아니면 바람에 밀려난 걸까? 정원에 남은 흔적을 보고 무슨 일이 있었는지 밝혀줘!',
        ),
        actions: [
          FilledButton(
            key: const Key('start-investigation'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('정원 조사 시작'),
          ),
        ],
      ),
    );
  }

  Future<void> _inspectScratch() async {
    if (_clues.contains(_Clue.scratch)) {
      _openNotebook(focus: _Clue.scratch);
      return;
    }
    final solved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SingleChoicePuzzleDialog(
        puzzleKey: 'scratch',
        title: '긁힌 별가루 해석',
        story: '받침대 오른쪽에 별가루 12개가 3개씩 모여 있어요. 묶음 수를 알아내면 힘이 향한 방향을 확인할 수 있어요.',
        question: '별가루 12개를 3개씩 묶으면 몇 묶음일까요?',
        options: ['3묶음', '4묶음', '6묶음'],
        correctIndex: 1,
        hint: '12 ÷ 3을 생각해 보세요.',
      ),
    );
    if (solved != true || !mounted) return;
    await _findClue(_Clue.scratch);
    if (!mounted) return;
    setState(() => _stage = _InvestigationStage.followTrail);
    _showMessage('새로운 흔적', '긁힌 자국이 향한 오른쪽 길에 희미한 발자국이 나타났어요.');
  }

  Future<void> _inspectFootprints() async {
    if (_stage.index < _InvestigationStage.followTrail.index) {
      _showMessage('희미한 흙자국', '아직 방향을 알 수 없어요. 씨앗이 있던 받침대부터 살펴보세요.');
      return;
    }
    if (_clues.contains(_Clue.footprints)) {
      _openNotebook(focus: _Clue.footprints);
      return;
    }
    final solved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SingleChoicePuzzleDialog(
        puzzleKey: 'footprints',
        title: '발자국 길 찾기',
        story: '발자국은 4칸마다, 별가루는 6칸마다 다시 나타나요. 두 표시가 함께 나타나는 지점을 찾으면 이동 방향을 알 수 있어요.',
        question: '4와 6의 공배수 중 가장 작은 수는 무엇일까요?',
        options: ['8', '10', '12'],
        correctIndex: 2,
        hint: '4의 배수와 6의 배수를 차례로 적어 보세요.',
      ),
    );
    if (solved != true || !mounted) return;
    await _findClue(_Clue.footprints);
    if (!mounted) return;
    setState(() => _stage = _InvestigationStage.openChest);
    _showMessage('발자국의 끝', '작은 발자국이 분수대 앞에서 멈췄어요. 근처를 자세히 살펴보세요.');
  }

  Future<void> _findClue(_Clue clue) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (_clues.contains(clue)) {
      _openNotebook(focus: clue);
      return;
    }
    setState(() => _clues.add(clue));
    final detail = _clueDetails[clue]!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _ClueFoundDialog(number: _clues.length, detail: detail),
    );
  }

  Future<void> _findKey() async {
    if (_stage != _InvestigationStage.openChest || !_chestTried) {
      _showMessage('작은 돌', '겉보기에는 평범한 돌이에요. 지금은 다른 흔적을 먼저 살펴보는 게 좋겠어요.');
      return;
    }
    if (_hasKey) {
      _showMessage('작은 돌', '이미 낡은 별열쇠를 찾았어요. 분수대 상자에 사용해 보세요.');
      return;
    }
    setState(() {
      _hasKey = true;
      _checkedObjects.add('stone');
    });
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ItemFoundDialog(),
    );
  }

  Future<void> _inspectChest() async {
    if (_stage.index < _InvestigationStage.openChest.index) {
      _showMessage('분수대 상자', '지금은 상자보다 씨앗이 사라진 방향을 먼저 알아내야 해요.');
      return;
    }
    if (_puzzleSolved) {
      _openNotebook(focus: _Clue.silverFiber);
      return;
    }
    if (!_hasKey) {
      setState(() => _chestTried = true);
      _showMessage('잠긴 분수대 상자', '별 모양 열쇠구멍이 있어요. 상자 가까이에서 최근에 움직인 물건을 찾아보세요.');
      return;
    }
    if (!_chestOpened) setState(() => _chestOpened = true);
    final solved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _FactorPuzzleDialog(),
    );
    if (solved != true || !mounted) return;
    setState(() => _puzzleSolved = true);
    await _findClue(_Clue.silverFiber);
    if (!mounted) return;
    setState(() => _stage = _InvestigationStage.deduce);
    await _showDeduction();
  }

  Future<void> _showDeduction() async {
    final solved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DeductionDialog(),
    );
    if (solved != true || !mounted) return;
    setState(() => _stage = _InvestigationStage.solved);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🌸 사건 해결!'),
        content: const Text(
          '포포: 훔친 게 아니야! 바람에 밀려온 씨앗이 연못에 빠질까 봐 상자에 넣어 두었어.\n\n'
          '꽃루미: 포포가 별빛 씨앗을 지켜준 거였구나! 별지기님이 흔적을 잘 연결해 준 덕분이야.',
        ),
        actions: [
          FilledButton(
            key: const Key('close-resolution'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('씨앗을 다시 심기'),
          ),
        ],
      ),
    );
  }

  void _inspectWorld({
    required String id,
    required String title,
    required String message,
  }) {
    setState(() => _checkedObjects.add(id));
    _showMessage(title, message);
  }

  void _showMessage(String title, String message) {
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
    final solved = _stage == _InvestigationStage.solved;
    return Scaffold(
      backgroundColor: const Color(0xFF161329),
      body: SafeArea(
        child: Column(
          children: [
            _MissionBar(
              objective: _objective,
              hypothesis: _hypothesis,
              found: _clues.length,
              hasKey: _hasKey,
              onClose: () => Navigator.of(context).pop(),
              onNotebook: _openNotebook,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _GardenScenePainter(
                        solved: solved,
                        showTrail: _stage.index >=
                            _InvestigationStage.followTrail.index,
                      ),
                    ),
                  ),
                  const Positioned(left: 18, top: 16, child: _SceneLabel()),
                  _SceneObject(
                    key: const Key('scratch-hotspot'),
                    alignment: const Alignment(-0.12, -0.15),
                    semanticLabel: '빈 별받침대 조사',
                    icon: Icons.auto_awesome_rounded,
                    color: const Color(0xFFFFDB72),
                    emphasized: _stage == _InvestigationStage.observe,
                    discovered: _clues.contains(_Clue.scratch),
                    onTap: _inspectScratch,
                  ),
                  if (_stage.index >= _InvestigationStage.followTrail.index)
                    _SceneObject(
                      key: const Key('footprints-hotspot'),
                      alignment: const Alignment(0.52, 0.22),
                      semanticLabel: '오른쪽 길의 작은 발자국 조사',
                      icon: Icons.pets_rounded,
                      color: const Color(0xFFEAB4DB),
                      emphasized: _stage == _InvestigationStage.followTrail,
                      discovered: _clues.contains(_Clue.footprints),
                      onTap: _inspectFootprints,
                    ),
                  if (_stage.index >= _InvestigationStage.openChest.index)
                    _SceneObject(
                      key: const Key('chest-hotspot'),
                      alignment: const Alignment(-0.72, 0.36),
                      semanticLabel: '분수대의 잠긴 상자 조사',
                      icon: _chestOpened
                          ? Icons.lock_open_rounded
                          : Icons.inventory_2_rounded,
                      color: const Color(0xFF9AD9D2),
                      emphasized: _stage == _InvestigationStage.openChest &&
                          !_chestTried,
                      discovered: _puzzleSolved,
                      onTap: _inspectChest,
                    ),
                  _SceneObject(
                    key: const Key('key-hotspot'),
                    alignment: const Alignment(0.76, -0.55),
                    semanticLabel: '작은 돌 아래 조사',
                    icon: _hasKey
                        ? Icons.key_rounded
                        : Icons.landscape_rounded,
                    color: const Color(0xFFC9E8F2),
                    emphasized: _stage == _InvestigationStage.openChest &&
                        _chestTried &&
                        !_hasKey,
                    discovered: _hasKey,
                    onTap: _findKey,
                  ),
                  _SceneObject(
                    alignment: const Alignment(-0.55, -0.48),
                    semanticLabel: '쓰러진 물뿌리개 조사',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF8CD5E3),
                    discovered: _checkedObjects.contains('can'),
                    onTap: () => _inspectWorld(
                      id: 'can',
                      title: '쓰러진 물뿌리개',
                      message: '물은 아직 따뜻해요. 누군가 조금 전까지 정원에 있었던 것 같아요.',
                    ),
                  ),
                  _SceneObject(
                    alignment: const Alignment(0.55, 0.7),
                    semanticLabel: '한쪽으로 누운 꽃밭 조사',
                    icon: Icons.local_florist_rounded,
                    color: const Color(0xFFFFA8C8),
                    discovered: _checkedObjects.contains('flowers'),
                    onTap: () => _inspectWorld(
                      id: 'flowers',
                      title: '한쪽으로 누운 꽃밭',
                      message: '꽃들이 모두 오른쪽으로 누워 있어요. 오늘 바람이 꽤 강했던 것 같아요.',
                    ),
                  ),
                  _SceneObject(
                    alignment: const Alignment(-0.3, 0.63),
                    semanticLabel: '연못의 떠다니는 잎 조사',
                    icon: Icons.water_rounded,
                    color: const Color(0xFF79D5E6),
                    discovered: _checkedObjects.contains('pond'),
                    onTap: () => _inspectWorld(
                      id: 'pond',
                      title: '연못의 떠다니는 잎',
                      message: '꺾인 잎들이 오른쪽 물가에 모여 있어요. 바람의 방향과 같아요.',
                    ),
                  ),
                  if (_stage == _InvestigationStage.deduce)
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 22,
                      child: FilledButton.icon(
                        key: const Key('open-deduction'),
                        onPressed: _showDeduction,
                        icon: const Icon(Icons.psychology_alt_rounded),
                        label: const Text('증거를 연결해 추리하기'),
                      ),
                    ),
                  if (solved)
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
    required this.objective,
    required this.hypothesis,
    required this.found,
    required this.hasKey,
    required this.onClose,
    required this.onNotebook,
  });

  final String objective;
  final String hypothesis;
  final int found;
  final bool hasKey;
  final VoidCallback onClose;
  final VoidCallback onNotebook;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xEE231D38),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '모험 나가기',
                onPressed: onClose,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  '사라진 별빛 씨앗',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
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
                label: Text('증거 $found/3'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFE69A),
                  backgroundColor: const Color(0xFF453957),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF342B49),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 목표 · $objective',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '현재 생각 · $hypothesis',
                  style: const TextStyle(
                    color: Color(0xFFFFD978),
                    fontSize: 11,
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
            Icon(Icons.location_on_rounded,
                color: Color(0xFFFFD778), size: 17),
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

class _SceneObject extends StatefulWidget {
  const _SceneObject({
    required this.alignment,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.onTap,
    this.emphasized = false,
    this.discovered = false,
    super.key,
  });

  final Alignment alignment;
  final String semanticLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool emphasized;
  final bool discovered;

  @override
  State<_SceneObject> createState() => _SceneObjectState();
}

class _SceneObjectState extends State<_SceneObject>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _SceneObject oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emphasized != widget.emphasized) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.emphasized) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Semantics(
        button: true,
        label: widget.semanticLabel,
        child: Tooltip(
          message: widget.semanticLabel,
          child: InkResponse(
            onTap: widget.onTap,
            radius: 42,
            child: ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.emphasized
                      ? const Color(0x663A3048)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: widget.emphasized
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.55),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.color,
                      size: widget.emphasized ? 34 : 30,
                    ),
                    if (widget.discovered)
                      const Align(
                        alignment: Alignment(0.9, -0.9),
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Color(0xFFFFE68F),
                          child: Icon(
                            Icons.check_rounded,
                            size: 13,
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
    );
  }
}

class _ItemFoundDialog extends StatelessWidget {
  const _ItemFoundDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🔑 낡은 별열쇠 발견!'),
      content: const Text('최근에 움직인 작은 돌 아래에서 별 모양 열쇠를 찾았어요. 분수대 상자에 맞을 것 같아요.'),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('열쇠 챙기기'),
        ),
      ],
    );
  }
}

class _SingleChoicePuzzleDialog extends StatefulWidget {
  const _SingleChoicePuzzleDialog({
    required this.puzzleKey,
    required this.title,
    required this.story,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
  });

  final String puzzleKey;
  final String title;
  final String story;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String hint;

  @override
  State<_SingleChoicePuzzleDialog> createState() =>
      _SingleChoicePuzzleDialogState();
}

class _SingleChoicePuzzleDialogState
    extends State<_SingleChoicePuzzleDialog> {
  int? _selectedIndex;
  String? _feedback;

  void _checkAnswer() {
    if (_selectedIndex == widget.correctIndex) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _feedback = '다시 생각해 볼까요? ${widget.hint}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.story),
            const SizedBox(height: 16),
            Text(
              widget.question,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < widget.options.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChoiceChip(
                  key: Key('${widget.puzzleKey}-option-$index'),
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(widget.options[index]),
                  ),
                  selected: _selectedIndex == index,
                  onSelected: (_) => setState(() {
                    _selectedIndex = index;
                    _feedback = null;
                  }),
                ),
              ),
            if (_feedback != null)
              Text(
                _feedback!,
                key: Key('${widget.puzzleKey}-feedback'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9A4D72),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('정원을 더 살펴보기'),
        ),
        FilledButton(
          key: Key('${widget.puzzleKey}-check-answer'),
          onPressed: _selectedIndex == null ? null : _checkAnswer,
          child: const Text('흔적 해석하기'),
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
    if (_selected.length == _answers.length &&
        _selected.containsAll(_answers)) {
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
              const Icon(Icons.auto_awesome_rounded,
                  size: 48, color: Color(0xFF76558C)),
              const SizedBox(height: 12),
              const Text(
                '별빛 암호판',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                '상자의 별빛 자물쇠에는 12가 새겨져 있어요. 12의 약수를 모두 선택하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                          selected
                              ? _selected.add(option)
                              : _selected.remove(option);
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
                  style: const TextStyle(
                    color: Color(0xFF9A4D72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('check-puzzle-answer'),
                onPressed: _selected.isEmpty ? null : _checkAnswer,
                child: const Text('상자 암호 풀기'),
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

class _DeductionDialog extends StatefulWidget {
  const _DeductionDialog();

  @override
  State<_DeductionDialog> createState() => _DeductionDialogState();
}

class _DeductionDialogState extends State<_DeductionDialog> {
  int? _selectedIndex;
  String? _feedback;

  static const _options = [
    '포포가 별빛 씨앗을 훔쳤다.',
    '강한 바람에 씨앗이 밀렸고, 포포가 주워 상자에 지켜두었다.',
    '쓰러진 물뿌리개가 씨앗을 분수대로 밀었다.',
  ];

  void _check() {
    if (_selectedIndex == 1) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _feedback = '긁힌 자국의 방향, 바람에 꺾인 잎, 상자 안의 은빛 털을 함께 생각해 보세요.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🕵️ 정원에서 무슨 일이 있었을까요?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _EvidenceSummary(),
            const SizedBox(height: 12),
            for (var index = 0; index < _options.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChoiceChip(
                  key: Key('deduction-option-$index'),
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(_options[index]),
                  ),
                  selected: _selectedIndex == index,
                  onSelected: (_) => setState(() {
                    _selectedIndex = index;
                    _feedback = null;
                  }),
                ),
              ),
            if (_feedback != null)
              Text(
                _feedback!,
                key: const Key('deduction-feedback'),
                style: const TextStyle(
                  color: Color(0xFF9A4D72),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          key: const Key('check-deduction'),
          onPressed: _selectedIndex == null ? null : _check,
          child: const Text('이 가설로 설명하기'),
        ),
      ],
    );
  }
}

class _EvidenceSummary extends StatelessWidget {
  const _EvidenceSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECF7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('확인한 증거', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('• 오른쪽으로 난 긁힌 자국'),
          Text('• 분수대로 이어진 작은 발자국'),
          Text('• 상자 속 은빛 털과 바람에 꺾인 잎'),
        ],
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
      title: const Text('✨ 새로운 증거 발견!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFFFE2EC),
            child: Icon(detail.icon,
                size: 36, color: const Color(0xFF76558C)),
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
                      '별지기의 증거 수첩',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    tooltip: '단서 수첩 닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text('발견한 증거 ${clues.length}/3'),
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
          color: highlighted
              ? const Color(0xFFE79BBE)
              : const Color(0xFFD8CEC2),
          width: highlighted ? 3 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                unlocked ? const Color(0xFFFFE2EC) : const Color(0xFFD5CDC4),
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
                  unlocked ? detail.title : '아직 확인하지 못한 증거',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked
                      ? detail.text
                      : '현재 목표와 장면의 변화를 보고 다음 조사 장소를 생각해 보세요.',
                ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0B5), Color(0xFFFFD2E5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), blurRadius: 25),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '별빛 씨앗의 비밀을 밝혀냈어요!',
            style: TextStyle(
              color: Color(0xFF4A3042),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '포포는 씨앗을 훔친 것이 아니라 강한 바람으로부터 지켜주었어요.',
            style: TextStyle(color: Color(0xFF6B4F60)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onNotebook,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5E416B),
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    side: const BorderSide(
                      color: Color(0xFF76558C),
                      width: 1.5,
                    ),
                  ),
                  child: const Text('증거 수첩'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF76558C),
                  ),
                  child: const Text('다음 모험 보기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GardenScenePainter extends CustomPainter {
  const _GardenScenePainter({required this.solved, required this.showTrail});

  final bool solved;
  final bool showTrail;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: solved
              ? const [
                  Color(0xFF37265A),
                  Color(0xFF356557),
                  Color(0xFF1F4B3B),
                ]
              : const [
                  Color(0xFF1B1836),
                  Color(0xFF243B3C),
                  Color(0xFF162E28),
                ],
        ).createShader(rect),
    );

    final moon = Offset(size.width * 0.17, size.height * 0.18);
    canvas.drawCircle(
      moon,
      solved ? 50 : 42,
      Paint()..color = const Color(0x33FFF4C2),
    );
    canvas.drawCircle(moon, 25, Paint()..color = const Color(0xFFFFE9A5));

    final path = Path()
      ..moveTo(size.width * 0.34, size.height)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.68,
          size.width * 0.47, size.height * 0.42)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.22,
          size.width * 0.55, 0)
      ..lineTo(size.width * 0.76, 0)
      ..quadraticBezierTo(size.width * 0.63, size.height * 0.25,
          size.width * 0.66, size.height * 0.46)
      ..quadraticBezierTo(size.width * 0.73, size.height * 0.72,
          size.width * 0.67, size.height)
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

    if (showTrail) {
      final trailPaint = Paint()
        ..color = const Color(0x88EAB4DB)
        ..style = PaintingStyle.fill;
      for (var index = 0; index < 5; index++) {
        final x = size.width * (0.56 - index * 0.055);
        final y = size.height * (0.55 - index * 0.035);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 9,
            height: 13,
          ),
          trailPaint,
        );
      }
    }

    for (var index = 0; index < (solved ? 52 : 34); index++) {
      final x = ((index * 47 + 13) % 97) / 100 * size.width;
      final y = ((index * 31 + 7) % 91) / 100 * size.height;
      final color = index.isEven
          ? const Color(0xFFFFE99C)
          : const Color(0xFFE8B6DC);
      canvas.drawCircle(
        Offset(x, y),
        index % 3 == 0 ? 2.2 : 1.3,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GardenScenePainter oldDelegate) {
    return oldDelegate.solved != solved || oldDelegate.showTrail != showTrail;
  }
}
