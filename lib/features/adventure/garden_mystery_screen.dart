import 'package:flutter/material.dart';

enum _MysteryScene {
  opening,
  garden,
  pedestal,
  trail,
  chest,
  deduction,
  solved,
}

enum _Evidence { scratch, footprints, fiber }

class GardenMysteryScreen extends StatefulWidget {
  const GardenMysteryScreen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  State<GardenMysteryScreen> createState() => _GardenMysteryScreenState();
}

class _GardenMysteryScreenState extends State<GardenMysteryScreen> {
  final Set<_Evidence> _evidence = {};
  _MysteryScene _scene = _MysteryScene.opening;
  bool _chestInspected = false;
  bool _stoneMoved = false;
  bool _hasKey = false;
  int? _scratchAnswer;
  int? _trailAnswer;
  int? _deductionAnswer;
  final Set<int> _factors = {};
  String? _feedback;

  String get _objective {
    switch (_scene) {
      case _MysteryScene.opening:
        return '사라진 별빛 씨앗 사건을 시작하세요.';
      case _MysteryScene.garden:
        if (!_evidence.contains(_Evidence.scratch)) {
          return '씨앗이 있던 별받침대를 자세히 살펴보세요.';
        }
        if (!_evidence.contains(_Evidence.footprints)) {
          return '오른쪽 길에 나타난 발자국을 따라가세요.';
        }
        return '발자국이 멈춘 분수대 상자를 조사하세요.';
      case _MysteryScene.pedestal:
        return '별가루 묶음을 직접 세어 긁힌 방향을 해석하세요.';
      case _MysteryScene.trail:
        return '발자국과 별가루가 함께 나타나는 첫 지점을 찾으세요.';
      case _MysteryScene.chest:
        if (!_chestInspected) return '상자의 잠금장치를 살펴보세요.';
        if (!_hasKey) return '상자 주변에서 움직일 수 있는 물건을 찾아보세요.';
        return '별열쇠를 사용하고 12의 약수 문양을 선택하세요.';
      case _MysteryScene.deduction:
        return '세 증거를 연결해 가장 자연스러운 가설을 고르세요.';
      case _MysteryScene.solved:
        return '씨앗을 지켜준 포포와 함께 정원을 회복했어요.';
    }
  }

  void _go(_MysteryScene scene) {
    setState(() {
      _scene = scene;
      _feedback = null;
    });
  }

  void _solveScratch() {
    if (_scratchAnswer != 4) {
      setState(() => _feedback = '12개를 3개씩 묶어 보세요. 한 묶음씩 손가락으로 짚어도 좋아요.');
      return;
    }
    setState(() {
      _evidence.add(_Evidence.scratch);
      _feedback = '오른쪽으로 난 긁힌 자국을 발견했어요. 정원 오른쪽에 발자국이 나타났어요!';
    });
  }

  void _solveTrail() {
    if (_trailAnswer != 12) {
      setState(() => _feedback = '4의 배수와 6의 배수를 차례로 비교해 보세요.');
      return;
    }
    setState(() {
      _evidence.add(_Evidence.footprints);
      _feedback = '두 흔적은 12번째 칸에서 만나요. 발자국이 분수대까지 이어졌어요!';
    });
  }

  void _inspectChest() {
    setState(() {
      _chestInspected = true;
      _feedback = '별 모양 열쇠구멍이에요. 상자 가까이에서 움직인 흔적이 있는 물건을 찾아보세요.';
    });
  }

  void _moveStone() {
    if (!_chestInspected) {
      setState(() => _feedback = '먼저 상자의 잠금장치를 살펴보는 게 좋겠어요.');
      return;
    }
    setState(() {
      _stoneMoved = true;
      _hasKey = true;
      _feedback = '돌 아래에서 낡은 별열쇠를 찾았어요!';
    });
  }

  void _solveChest() {
    if (!_hasKey) {
      setState(() => _feedback = '별 모양 열쇠가 필요해요.');
      return;
    }
    const correct = {1, 2, 3, 4, 6, 12};
    if (_factors.length != correct.length || !_factors.containsAll(correct)) {
      setState(() => _feedback = '12를 나누어떨어지게 하는 수만 선택해 보세요.');
      return;
    }
    setState(() {
      _evidence.add(_Evidence.fiber);
      _feedback = '상자가 열렸어요! 은빛 털과 바람에 꺾인 잎을 발견했어요.';
    });
  }

  void _solveDeduction() {
    if (_deductionAnswer != 1) {
      setState(() => _feedback = '긁힌 방향, 바람에 꺾인 잎, 상자 속 은빛 털을 함께 생각해 보세요.');
      return;
    }
    _go(_MysteryScene.solved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171326),
      body: SafeArea(
        child: Column(
          children: [
            _MissionHeader(
              objective: _objective,
              evidenceCount: _evidence.length,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.97, end: 1.0).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_scene),
                  child: _buildScene(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene() {
    switch (_scene) {
      case _MysteryScene.opening:
        return _OpeningScene(onStart: () => _go(_MysteryScene.garden));
      case _MysteryScene.garden:
        return _GardenScene(
          evidence: _evidence,
          onPedestal: () => _go(_MysteryScene.pedestal),
          onTrail: _evidence.contains(_Evidence.scratch)
              ? () => _go(_MysteryScene.trail)
              : null,
          onChest: _evidence.contains(_Evidence.footprints)
              ? () => _go(_MysteryScene.chest)
              : null,
        );
      case _MysteryScene.pedestal:
        return _PedestalScene(
          selected: _scratchAnswer,
          solved: _evidence.contains(_Evidence.scratch),
          feedback: _feedback,
          onSelect: (value) => setState(() {
            _scratchAnswer = value;
            _feedback = null;
          }),
          onCheck: _solveScratch,
          onReturn: () => _go(_MysteryScene.garden),
        );
      case _MysteryScene.trail:
        return _TrailScene(
          selected: _trailAnswer,
          solved: _evidence.contains(_Evidence.footprints),
          feedback: _feedback,
          onSelect: (value) => setState(() {
            _trailAnswer = value;
            _feedback = null;
          }),
          onCheck: _solveTrail,
          onReturn: () => _go(_MysteryScene.garden),
        );
      case _MysteryScene.chest:
        return _ChestScene(
          inspected: _chestInspected,
          stoneMoved: _stoneMoved,
          hasKey: _hasKey,
          solved: _evidence.contains(_Evidence.fiber),
          factors: _factors,
          feedback: _feedback,
          onInspect: _inspectChest,
          onMoveStone: _moveStone,
          onToggleFactor: (value) => setState(() {
            _factors.contains(value)
                ? _factors.remove(value)
                : _factors.add(value);
            _feedback = null;
          }),
          onCheck: _solveChest,
          onReturn: () => _go(_MysteryScene.garden),
          onDeduce: () => _go(_MysteryScene.deduction),
        );
      case _MysteryScene.deduction:
        return _DeductionScene(
          selected: _deductionAnswer,
          feedback: _feedback,
          onSelect: (value) => setState(() {
            _deductionAnswer = value;
            _feedback = null;
          }),
          onCheck: _solveDeduction,
        );
      case _MysteryScene.solved:
        return _SolvedScene(onContinue: () => widget.onContinue(context));
    }
  }
}

class _MissionHeader extends StatelessWidget {
  const _MissionHeader({
    required this.objective,
    required this.evidenceCount,
    required this.onBack,
  });

  final String objective;
  final int evidenceCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF241D38),
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '모험 나가기',
                onPressed: onBack,
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
              Chip(
                avatar: const Icon(Icons.search_rounded, size: 17),
                label: Text('증거 $evidenceCount/3'),
                backgroundColor: const Color(0xFFFFE29B),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF382D51),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '현재 목표 · $objective',
              key: const Key('current-objective'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningScene extends StatelessWidget {
  const _OpeningScene({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF30264F), Color(0xFF213C42)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 88,
                  color: Color(0xFFFFDB72),
                ),
                const SizedBox(height: 18),
                const Text(
                  '별빛 씨앗이 사라졌어요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '꽃루미: 조금 전까지 받침대 위에 있던 씨앗이 없어졌어.\n\n누가 가져간 걸까, 아니면 바람에 밀려난 걸까? 정원의 변화를 직접 살펴보고 무슨 일이 있었는지 밝혀줘!',
                    style: TextStyle(
                      color: Color(0xFF473A54),
                      height: 1.55,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const Key('start-investigation'),
                  onPressed: onStart,
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: const Text('정원 조사 시작'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GardenScene extends StatelessWidget {
  const _GardenScene({
    required this.evidence,
    required this.onPedestal,
    required this.onTrail,
    required this.onChest,
  });

  final Set<_Evidence> evidence;
  final VoidCallback onPedestal;
  final VoidCallback? onTrail;
  final VoidCallback? onChest;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _GardenPainter(evidence: evidence)),
        const Positioned(
          left: 18,
          top: 18,
          child: _SceneCaption(text: '별정원 중앙 · 사건 현장'),
        ),
        Align(
          alignment: const Alignment(-0.1, -0.25),
          child: _SceneButton(
            key: const Key('pedestal-hotspot'),
            label: '빈 별받침대 확대',
            icon: Icons.auto_awesome_rounded,
            emphasized: !evidence.contains(_Evidence.scratch),
            onPressed: onPedestal,
          ),
        ),
        if (onTrail != null)
          Align(
            alignment: const Alignment(0.56, 0.22),
            child: _SceneButton(
              key: const Key('trail-hotspot'),
              label: '발자국 길 확대',
              icon: Icons.pets_rounded,
              emphasized: !evidence.contains(_Evidence.footprints),
              onPressed: onTrail!,
            ),
          ),
        if (onChest != null)
          Align(
            alignment: const Alignment(-0.68, 0.42),
            child: _SceneButton(
              key: const Key('chest-hotspot'),
              label: '분수대 상자 확대',
              icon: Icons.inventory_2_rounded,
              emphasized: !evidence.contains(_Evidence.fiber),
              onPressed: onChest!,
            ),
          ),
      ],
    );
  }
}

class _PedestalScene extends StatelessWidget {
  const _PedestalScene({
    required this.selected,
    required this.solved,
    required this.feedback,
    required this.onSelect,
    required this.onCheck,
    required this.onReturn,
  });

  final int? selected;
  final bool solved;
  final String? feedback;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return _CloseUpShell(
      title: '별받침대 확대 조사',
      subtitle: '긁힌 별가루가 오른쪽으로 길게 이어져 있어요.',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: [
          const _StarGroups(),
          const SizedBox(height: 18),
          const Text('별가루 12개를 3개씩 묶으면 몇 묶음일까요?', style: _questionStyle),
          const SizedBox(height: 12),
          _ChoiceRow(
            values: const [3, 4, 6],
            selected: selected,
            keyPrefix: 'scratch',
            onSelect: onSelect,
          ),
          const SizedBox(height: 12),
          _Feedback(text: feedback),
          const SizedBox(height: 12),
          if (!solved)
            FilledButton(
              key: const Key('scratch-check-answer'),
              onPressed: selected == null ? null : onCheck,
              child: const Text('별가루 해석하기'),
            )
          else
            FilledButton.icon(
              key: const Key('return-from-pedestal'),
              onPressed: onReturn,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('정원으로 돌아가 발자국 찾기'),
            ),
        ],
      ),
    );
  }
}

class _TrailScene extends StatelessWidget {
  const _TrailScene({
    required this.selected,
    required this.solved,
    required this.feedback,
    required this.onSelect,
    required this.onCheck,
    required this.onReturn,
  });

  final int? selected;
  final bool solved;
  final String? feedback;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return _CloseUpShell(
      title: '오른쪽 길 확대 조사',
      subtitle: '발자국은 4칸마다, 별가루는 6칸마다 나타나요.',
      icon: Icons.pets_rounded,
      child: Column(
        children: [
          const _TrailTracks(),
          const SizedBox(height: 18),
          const Text('두 표시가 처음 함께 나타나는 칸은 어디일까요?', style: _questionStyle),
          const SizedBox(height: 12),
          _ChoiceRow(
            values: const [8, 10, 12],
            selected: selected,
            keyPrefix: 'trail',
            onSelect: onSelect,
          ),
          const SizedBox(height: 12),
          _Feedback(text: feedback),
          const SizedBox(height: 12),
          if (!solved)
            FilledButton(
              key: const Key('trail-check-answer'),
              onPressed: selected == null ? null : onCheck,
              child: const Text('흔적 연결하기'),
            )
          else
            FilledButton.icon(
              key: const Key('return-from-trail'),
              onPressed: onReturn,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('분수대가 보이는 정원으로 돌아가기'),
            ),
        ],
      ),
    );
  }
}

class _ChestScene extends StatelessWidget {
  const _ChestScene({
    required this.inspected,
    required this.stoneMoved,
    required this.hasKey,
    required this.solved,
    required this.factors,
    required this.feedback,
    required this.onInspect,
    required this.onMoveStone,
    required this.onToggleFactor,
    required this.onCheck,
    required this.onReturn,
    required this.onDeduce,
  });

  final bool inspected;
  final bool stoneMoved;
  final bool hasKey;
  final bool solved;
  final Set<int> factors;
  final String? feedback;
  final VoidCallback onInspect;
  final VoidCallback onMoveStone;
  final ValueChanged<int> onToggleFactor;
  final VoidCallback onCheck;
  final VoidCallback onReturn;
  final VoidCallback onDeduce;

  @override
  Widget build(BuildContext context) {
    return _CloseUpShell(
      title: '분수대 상자 확대 조사',
      subtitle: solved ? '상자 안에 은빛 털과 꺾인 잎이 있어요.' : '상자와 주변 물건을 직접 살펴보세요.',
      icon: solved ? Icons.lock_open_rounded : Icons.inventory_2_rounded,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ObjectTile(
                key: const Key('inspect-lock'),
                icon: inspected
                    ? Icons.lock_outline_rounded
                    : Icons.lock_rounded,
                label: inspected ? '별 모양 열쇠구멍' : '상자 잠금장치',
                onTap: onInspect,
              ),
              const SizedBox(width: 18),
              Transform.translate(
                offset: stoneMoved ? const Offset(24, 0) : Offset.zero,
                child: _ObjectTile(
                  key: const Key('move-stone'),
                  icon: stoneMoved
                      ? Icons.key_rounded
                      : Icons.landscape_rounded,
                  label: stoneMoved ? '별열쇠 발견' : '긁힌 작은 돌',
                  onTap: onMoveStone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasKey && !solved) ...[
            const Text('열쇠를 꽂았어요. 12의 약수 문양을 모두 선택하세요.', style: _questionStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [1, 2, 3, 4, 5, 6, 8, 12]
                  .map(
                    (value) => FilterChip(
                      key: Key('factor-$value'),
                      label: Text('$value'),
                      selected: factors.contains(value),
                      onSelected: (_) => onToggleFactor(value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('check-puzzle-answer'),
              onPressed: onCheck,
              child: const Text('상자 열기'),
            ),
          ],
          _Feedback(text: feedback),
          const SizedBox(height: 12),
          if (solved)
            FilledButton.icon(
              key: const Key('open-deduction'),
              onPressed: onDeduce,
              icon: const Icon(Icons.psychology_alt_rounded),
              label: const Text('세 증거를 연결해 추리하기'),
            )
          else
            TextButton.icon(
              onPressed: onReturn,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('정원 전체 보기'),
            ),
        ],
      ),
    );
  }
}

class _DeductionScene extends StatelessWidget {
  const _DeductionScene({
    required this.selected,
    required this.feedback,
    required this.onSelect,
    required this.onCheck,
  });

  final int? selected;
  final String? feedback;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;

  static const options = [
    '포포가 별빛 씨앗을 훔쳤다.',
    '강한 바람에 밀린 씨앗을 포포가 주워 상자에 지켜두었다.',
    '쓰러진 물뿌리개가 씨앗을 분수대로 밀었다.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E2547), Color(0xFF253D46)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '추리 보드',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _EvidenceBoard(),
                    const SizedBox(height: 16),
                    for (var index = 0; index < options.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: ChoiceChip(
                          key: Key('deduction-option-$index'),
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(options[index]),
                          ),
                          selected: selected == index,
                          onSelected: (_) => onSelect(index),
                        ),
                      ),
                    _Feedback(text: feedback),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const Key('check-deduction'),
                      onPressed: selected == null ? null : onCheck,
                      child: const Text('이 가설로 사건 설명하기'),
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

class _SolvedScene extends StatelessWidget {
  const _SolvedScene({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF55427A), Color(0xFF3C8065), Color(0xFF204A39)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      size: 150,
                      color: Color(0x44FFE67F),
                    ),
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Color(0xFFEEE6FF),
                      child: Icon(
                        Icons.pets_rounded,
                        size: 58,
                        color: Color(0xFF755C91),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '사건 해결!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF0B5), Color(0xFFFFD2E5)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '포포: 훔친 게 아니야! 바람에 밀려온 씨앗이 연못에 빠질까 봐 상자에 넣어 두었어.\n\n꽃루미: 포포가 씨앗을 지켜준 거였구나. 별지기님이 흔적을 잘 연결해 준 덕분이야!',
                    style: TextStyle(
                      color: Color(0xFF4A3042),
                      height: 1.55,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('continue-adventure'),
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('씨앗을 다시 심고 다음 모험 보기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseUpShell extends StatelessWidget {
  const _CloseUpShell({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF30264B), Color(0xFF1E4B4A)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFFFE6A3),
                      child: Icon(
                        icon,
                        size: 38,
                        color: const Color(0xFF654D78),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6F6478),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    child,
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

class _SceneButton extends StatelessWidget {
  const _SceneButton({
    required this.label,
    required this.icon,
    required this.emphasized,
    required this.onPressed,
    super.key,
  });
  final String label;
  final IconData icon;
  final bool emphasized;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: emphasized ? const Color(0xAA493A63) : const Color(0x66352C49),
        shape: const CircleBorder(),
        elevation: emphasized ? 10 : 2,
        child: InkResponse(
          onTap: onPressed,
          radius: 40,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              icon,
              color: const Color(0xFFFFDD7D),
              size: emphasized ? 37 : 31,
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneCaption extends StatelessWidget {
  const _SceneCaption({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC211A32),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.keyPrefix,
    required this.onSelect,
  });
  final List<int> values;
  final int? selected;
  final String keyPrefix;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: values
          .map(
            (value) => ChoiceChip(
              key: Key('$keyPrefix-option-$value'),
              label: Text('$value'),
              selected: selected == value,
              onSelected: (_) => onSelect(value),
            ),
          )
          .toList(),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Container(
      key: const Key('scene-feedback'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF65486E),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ObjectTile extends StatelessWidget {
  const _ObjectTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD9CBE3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: const Color(0xFF76558C)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarGroups extends StatelessWidget {
  const _StarGroups();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: List.generate(
        4,
        (group) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4C9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Color(0xFFFFC53D)),
              Icon(Icons.star_rounded, color: Color(0xFFFFC53D)),
              Icon(Icons.star_rounded, color: Color(0xFFFFC53D)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailTracks extends StatelessWidget {
  const _TrailTracks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EBDD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _MarkerTrack(label: '발자국', interval: 4, icon: Icons.pets_rounded),
          const SizedBox(height: 12),
          _MarkerTrack(
            label: '별가루',
            interval: 6,
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}

class _MarkerTrack extends StatelessWidget {
  const _MarkerTrack({
    required this.label,
    required this.interval,
    required this.icon,
  });
  final String label;
  final int interval;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              12,
              (index) => Icon(
                (index + 1) % interval == 0 ? icon : Icons.circle,
                size: (index + 1) % interval == 0 ? 19 : 5,
                color: (index + 1) % interval == 0
                    ? const Color(0xFF76558C)
                    : const Color(0xFFBDB2A5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EvidenceBoard extends StatelessWidget {
  const _EvidenceBoard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECF7),
        borderRadius: BorderRadius.circular(18),
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

class _GardenPainter extends CustomPainter {
  const _GardenPainter({required this.evidence});
  final Set<_Evidence> evidence;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF31264E), Color(0xFF24584B), Color(0xFF183C32)],
        ).createShader(rect),
    );
    final pathPaint = Paint()
      ..color = const Color(0x558FE0C0)
      ..strokeWidth = 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.46)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.55,
        size.width * 0.78,
        size.height * 0.8,
      );
    canvas.drawPath(path, pathPaint);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.7),
      size.shortestSide * 0.13,
      Paint()..color = const Color(0xAA55B7C9),
    );
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.39),
      34,
      Paint()..color = const Color(0xFFBBA36A),
    );
    if (evidence.contains(_Evidence.scratch)) {
      final cluePaint = Paint()
        ..color = const Color(0xFFFFD66F)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 4; i++) {
        canvas.drawLine(
          Offset(size.width * 0.5 + i * 5, size.height * 0.39),
          Offset(size.width * 0.6 + i * 5, size.height * 0.43),
          cluePaint,
        );
      }
    }
    if (evidence.contains(_Evidence.footprints)) {
      final printPaint = Paint()..color = const Color(0xFFEAB4DB);
      for (var i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(
            size.width * (0.58 + i * 0.045),
            size.height * (0.5 + i * 0.045),
          ),
          7,
          printPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) =>
      oldDelegate.evidence.length != evidence.length;
}

const _questionStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: Color(0xFF45364F),
);
