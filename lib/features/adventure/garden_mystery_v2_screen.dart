import 'package:flutter/material.dart';

enum _MysteryScene { opening, garden, pedestal, trail, chest, deduction, solved }
enum _Evidence { scratch, footprints, fiber }
enum _PedestalClue { emptySpot, scratch, dust }

class GardenMysteryV2Screen extends StatefulWidget {
  const GardenMysteryV2Screen({required this.onContinue, super.key});

  final ValueChanged<BuildContext> onContinue;

  @override
  State<GardenMysteryV2Screen> createState() => _GardenMysteryV2ScreenState();
}

class _GardenMysteryV2ScreenState extends State<GardenMysteryV2Screen> {
  final Set<_Evidence> _evidence = {};
  final Set<_PedestalClue> _pedestalClues = {};
  final Set<int> _groupedDust = {};
  final Set<int> _factors = {};
  _MysteryScene _scene = _MysteryScene.opening;
  int? _trailAnswer;
  int? _deductionAnswer;
  bool _chestInspected = false;
  bool _stoneMoved = false;
  bool _hasKey = false;
  bool _dustFlowing = false;
  String? _feedback;

  bool get _pedestalReady => _pedestalClues.length == 3;
  bool get _pedestalSolved => _evidence.contains(_Evidence.scratch);

  String get _objective {
    switch (_scene) {
      case _MysteryScene.opening:
        return '사라진 별빛 씨앗 사건을 시작하세요.';
      case _MysteryScene.garden:
        if (!_pedestalSolved) return '씨앗이 있던 별받침대를 자세히 살펴보세요.';
        if (!_evidence.contains(_Evidence.footprints)) return '오른쪽 길에 나타난 발자국을 따라가세요.';
        return '발자국이 멈춘 분수대 상자를 조사하세요.';
      case _MysteryScene.pedestal:
        if (!_pedestalReady) return '받침대의 수상한 지점 세 곳을 직접 조사하세요.';
        if (!_pedestalSolved) return '별가루를 눌러 3개씩 묶어 보세요.';
        return '금빛 흔적이 가리키는 오른쪽 길을 따라가세요.';
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

  void _inspectPedestal(_PedestalClue clue) {
    if (_pedestalClues.contains(clue)) return;
    setState(() {
      _pedestalClues.add(clue);
      _feedback = switch (clue) {
        _PedestalClue.emptySpot => '씨앗을 위로 들어 올린 흔적은 없어요. 받침대 표면을 스치며 이동한 것 같아요.',
        _PedestalClue.scratch => '긁힌 자국이 모두 오른쪽을 향해 있어요. 강한 힘이 한 방향으로 밀었어요.',
        _PedestalClue.dust => '별가루 12개가 흩어져 있어요. 세 개씩 묶으면 이동 흔적의 규칙을 알 수 있을 것 같아요.',
      };
    });
  }

  Future<void> _tapDust(int index) async {
    if (!_pedestalReady || _pedestalSolved || _groupedDust.contains(index)) return;
    setState(() {
      _groupedDust.add(index);
      final groups = _groupedDust.length ~/ 3;
      final remainder = _groupedDust.length % 3;
      _feedback = remainder == 0
          ? '$groups번째 묶음 완성! ${4 - groups}묶음 남았어요.'
          : '별가루 ${_groupedDust.length}개를 모았어요. 지금 묶음에 ${3 - remainder}개 더 필요해요.';
    });
    if (_groupedDust.length != 12) return;
    setState(() {
      _evidence.add(_Evidence.scratch);
      _dustFlowing = true;
      _feedback = '네 묶음이 완성되자 별가루가 오른쪽으로 흘러가요! 씨앗도 같은 방향으로 밀려난 것 같아요.';
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _dustFlowing = false);
  }

  void _solveTrail() {
    if (_trailAnswer != 12) {
      setState(() => _feedback = '4칸마다 나타나는 발자국과 6칸마다 나타나는 별가루를 함께 살펴보세요.');
      return;
    }
    setState(() {
      _evidence.add(_Evidence.footprints);
      _feedback = '두 흔적이 12번째 칸에서 만나며 분수대까지 이어졌어요!';
    });
  }

  void _inspectChest() => setState(() {
        _chestInspected = true;
        _feedback = '별 모양 열쇠구멍이에요. 근처에서 최근 움직인 물건을 찾아보세요.';
      });

  void _moveStone() {
    if (!_chestInspected) {
      setState(() => _feedback = '먼저 상자의 잠금장치를 살펴보세요.');
      return;
    }
    setState(() {
      _stoneMoved = true;
      _hasKey = true;
      _feedback = '돌이 옆으로 밀리며 낡은 별열쇠가 나타났어요!';
    });
  }

  void _solveChest() {
    const correct = {1, 2, 3, 4, 6, 12};
    if (!_hasKey) {
      setState(() => _feedback = '별 모양 열쇠가 필요해요.');
      return;
    }
    if (_factors.length != correct.length || !_factors.containsAll(correct)) {
      setState(() => _feedback = '12를 나누어떨어지게 하는 수만 선택해 보세요.');
      return;
    }
    setState(() {
      _evidence.add(_Evidence.fiber);
      _feedback = '상자 뚜껑이 열렸어요! 은빛 털과 바람에 꺾인 잎을 발견했어요.';
    });
  }

  void _solveDeduction() {
    if (_deductionAnswer != 1) {
      setState(() => _feedback = '긁힌 방향, 꺾인 잎, 상자 속 은빛 털을 함께 생각해 보세요.');
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
            _MissionHeader(objective: _objective, evidenceCount: _evidence.length, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)), child: child),
                ),
                child: KeyedSubtree(key: ValueKey(_scene), child: _buildScene()),
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
          onTrail: _pedestalSolved ? () => _go(_MysteryScene.trail) : null,
          onChest: _evidence.contains(_Evidence.footprints) ? () => _go(_MysteryScene.chest) : null,
        );
      case _MysteryScene.pedestal:
        return _InteractivePedestalScene(
          inspected: _pedestalClues,
          groupedDust: _groupedDust,
          solved: _pedestalSolved,
          flowing: _dustFlowing,
          feedback: _feedback,
          onInspect: _inspectPedestal,
          onDust: _tapDust,
          onReturn: () => _go(_MysteryScene.garden),
        );
      case _MysteryScene.trail:
        return _TrailScene(
          selected: _trailAnswer,
          solved: _evidence.contains(_Evidence.footprints),
          feedback: _feedback,
          onSelect: (value) => setState(() { _trailAnswer = value; _feedback = null; }),
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
          onToggleFactor: (value) => setState(() { _factors.contains(value) ? _factors.remove(value) : _factors.add(value); _feedback = null; }),
          onCheck: _solveChest,
          onReturn: () => _go(_MysteryScene.garden),
          onDeduce: () => _go(_MysteryScene.deduction),
        );
      case _MysteryScene.deduction:
        return _DeductionScene(
          selected: _deductionAnswer,
          feedback: _feedback,
          onSelect: (value) => setState(() { _deductionAnswer = value; _feedback = null; }),
          onCheck: _solveDeduction,
        );
      case _MysteryScene.solved:
        return _SolvedScene(onContinue: () => widget.onContinue(context));
    }
  }
}

class _MissionHeader extends StatelessWidget {
  const _MissionHeader({required this.objective, required this.evidenceCount, required this.onBack});
  final String objective;
  final int evidenceCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF241D38),
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 10),
        child: Column(children: [
          Row(children: [
            IconButton(tooltip: '모험 나가기', onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
            const Expanded(child: Text('사라진 별빛 씨앗', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
            Chip(avatar: const Icon(Icons.search_rounded, size: 17), label: Text('증거 $evidenceCount/3'), backgroundColor: const Color(0xFFFFE29B)),
          ]),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(color: const Color(0xFF382D51), borderRadius: BorderRadius.circular(14)),
            child: Text('현재 목표 · $objective', key: const Key('current-objective'), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ]),
      );
}

class _OpeningScene extends StatelessWidget {
  const _OpeningScene({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => _GradientScene(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.auto_awesome_rounded, size: 88, color: Color(0xFFFFDB72)),
          const SizedBox(height: 18),
          const Text('별빛 씨앗이 사라졌어요!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _StoryCard(text: '꽃루미: 조금 전까지 받침대 위에 있던 씨앗이 없어졌어.\n\n정원의 물건을 직접 만져 보고 무슨 일이 있었는지 밝혀줘!'),
          const SizedBox(height: 20),
          FilledButton.icon(key: const Key('start-investigation'), onPressed: onStart, icon: const Icon(Icons.travel_explore_rounded), label: const Text('정원 조사 시작')),
        ]),
      );
}

class _GardenScene extends StatelessWidget {
  const _GardenScene({required this.evidence, required this.onPedestal, required this.onTrail, required this.onChest});
  final Set<_Evidence> evidence;
  final VoidCallback onPedestal;
  final VoidCallback? onTrail;
  final VoidCallback? onChest;

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _GardenPainter(evidence: evidence)),
        const Positioned(left: 18, top: 18, child: _SceneCaption(text: '별정원 중앙 · 사건 현장')),
        Align(alignment: const Alignment(-0.1, -0.25), child: _SceneButton(key: const Key('pedestal-hotspot'), label: '빈 별받침대 확대', icon: Icons.auto_awesome_rounded, emphasized: !evidence.contains(_Evidence.scratch), onPressed: onPedestal)),
        if (onTrail != null) Align(alignment: const Alignment(0.56, 0.22), child: _SceneButton(key: const Key('trail-hotspot'), label: '발자국 길 확대', icon: Icons.pets_rounded, emphasized: !evidence.contains(_Evidence.footprints), onPressed: onTrail!)),
        if (onChest != null) Align(alignment: const Alignment(-0.68, 0.42), child: _SceneButton(key: const Key('chest-hotspot'), label: '분수대 상자 확대', icon: Icons.inventory_2_rounded, emphasized: !evidence.contains(_Evidence.fiber), onPressed: onChest!)),
      ]);
}

class _InteractivePedestalScene extends StatelessWidget {
  const _InteractivePedestalScene({required this.inspected, required this.groupedDust, required this.solved, required this.flowing, required this.feedback, required this.onInspect, required this.onDust, required this.onReturn});
  final Set<_PedestalClue> inspected;
  final Set<int> groupedDust;
  final bool solved;
  final bool flowing;
  final String? feedback;
  final ValueChanged<_PedestalClue> onInspect;
  final ValueChanged<int> onDust;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final ready = inspected.length == 3;
    return Container(
      key: const Key('pedestal-investigation-scene'),
      decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -0.2), radius: 1.1, colors: [Color(0xFF574579), Color(0xFF1E3142), Color(0xFF111923)])),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _PedestalPainter(flowing: flowing, solved: solved))),
          const Positioned(left: 18, top: 16, child: _SceneCaption(text: '별받침대 근접 조사')),
          Positioned(
            left: constraints.maxWidth * .5 - 58,
            top: constraints.maxHeight * .22,
            child: _PulseTarget(
              key: const Key('inspect-empty-spot'),
              inspected: inspected.contains(_PedestalClue.emptySpot),
              icon: Icons.radio_button_unchecked_rounded,
              label: '빈 자리',
              onTap: () => onInspect(_PedestalClue.emptySpot),
            ),
          ),
          Positioned(
            right: constraints.maxWidth * .1,
            top: constraints.maxHeight * .42,
            child: _PulseTarget(
              key: const Key('inspect-scratch-mark'),
              inspected: inspected.contains(_PedestalClue.scratch),
              icon: Icons.east_rounded,
              label: '긁힌 자국',
              onTap: () => onInspect(_PedestalClue.scratch),
            ),
          ),
          Positioned(
            left: constraints.maxWidth * .12,
            top: constraints.maxHeight * .48,
            child: _PulseTarget(
              key: const Key('inspect-star-dust'),
              inspected: inspected.contains(_PedestalClue.dust),
              icon: Icons.auto_awesome_rounded,
              label: '흩어진 별가루',
              onTap: () => onInspect(_PedestalClue.dust),
            ),
          ),
          if (ready)
            Positioned(
              left: 18,
              right: 18,
              bottom: 82,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xEFFFFFFF), borderRadius: BorderRadius.circular(22)),
                child: Column(children: [
                  Text(solved ? '네 묶음 완성! 별가루가 오른쪽 길을 밝혔어요.' : '별가루를 눌러 3개씩 묶어 보세요 · ${groupedDust.length}/12', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF443653))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(12, (index) {
                      final selected = groupedDust.contains(index);
                      final group = index ~/ 3;
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 260),
                        scale: selected ? 1.12 : 1,
                        child: InkWell(
                          key: Key('star-dust-$index'),
                          onTap: solved ? null : () => onDust(index),
                          borderRadius: BorderRadius.circular(30),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? [const Color(0xFFFFE082), const Color(0xFFFFC7E2), const Color(0xFFC8E6FF), const Color(0xFFD8F5C8)][group] : const Color(0xFFEEE8F2),
                              boxShadow: selected ? const [BoxShadow(color: Color(0x88FFD75A), blurRadius: 12)] : null,
                            ),
                            child: Icon(Icons.star_rounded, color: selected ? const Color(0xFF8A5A00) : const Color(0xFF8B8292)),
                          ),
                        ),
                      );
                    }),
                  ),
                ]),
              ),
            ),
          if (feedback != null) Positioned(left: 18, right: 18, bottom: ready ? 18 : 88, child: _Feedback(text: feedback)),
          if (solved) Positioned(right: 18, bottom: 18, child: FilledButton.icon(key: const Key('return-from-pedestal'), onPressed: onReturn, icon: const Icon(Icons.arrow_back_rounded), label: const Text('정원으로 돌아가 발자국 찾기'))),
        ]);
      }),
    );
  }
}

class _TrailScene extends StatelessWidget {
  const _TrailScene({required this.selected, required this.solved, required this.feedback, required this.onSelect, required this.onCheck, required this.onReturn});
  final int? selected;
  final bool solved;
  final String? feedback;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) => _CloseUpShell(title: '오른쪽 길 확대 조사', subtitle: '발자국은 4칸마다, 별가루는 6칸마다 나타나요.', icon: Icons.pets_rounded, child: Column(children: [
        const _TrailTracks(),
        const SizedBox(height: 18),
        const Text('두 표시가 처음 함께 나타나는 칸은 어디일까요?', style: _questionStyle),
        const SizedBox(height: 12),
        _ChoiceRow(values: const [8, 10, 12], selected: selected, keyPrefix: 'trail', onSelect: onSelect),
        const SizedBox(height: 12),
        _Feedback(text: feedback),
        const SizedBox(height: 12),
        if (!solved) FilledButton(key: const Key('trail-check-answer'), onPressed: selected == null ? null : onCheck, child: const Text('흔적 연결하기')) else FilledButton.icon(key: const Key('return-from-trail'), onPressed: onReturn, icon: const Icon(Icons.arrow_back_rounded), label: const Text('분수대가 보이는 정원으로 돌아가기')),
      ]));
}

class _ChestScene extends StatelessWidget {
  const _ChestScene({required this.inspected, required this.stoneMoved, required this.hasKey, required this.solved, required this.factors, required this.feedback, required this.onInspect, required this.onMoveStone, required this.onToggleFactor, required this.onCheck, required this.onReturn, required this.onDeduce});
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
  Widget build(BuildContext context) => _CloseUpShell(title: '분수대 상자 확대 조사', subtitle: solved ? '상자 안에 은빛 털과 꺾인 잎이 있어요.' : '상자와 주변 물건을 직접 살펴보세요.', icon: solved ? Icons.lock_open_rounded : Icons.inventory_2_rounded, child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ObjectTile(key: const Key('inspect-lock'), icon: inspected ? Icons.lock_outline_rounded : Icons.lock_rounded, label: inspected ? '별 모양 열쇠구멍' : '상자 잠금장치', onTap: onInspect),
          const SizedBox(width: 18),
          AnimatedSlide(duration: const Duration(milliseconds: 500), offset: stoneMoved ? const Offset(.22, 0) : Offset.zero, child: _ObjectTile(key: const Key('move-stone'), icon: stoneMoved ? Icons.key_rounded : Icons.landscape_rounded, label: stoneMoved ? '별열쇠 발견' : '긁힌 작은 돌', onTap: onMoveStone)),
        ]),
        const SizedBox(height: 18),
        if (hasKey && !solved) ...[
          const Text('열쇠를 꽂았어요. 12의 약수 문양을 모두 선택하세요.', style: _questionStyle),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [1, 2, 3, 4, 5, 6, 8, 12].map((value) => FilterChip(key: Key('factor-$value'), label: Text('$value'), selected: factors.contains(value), onSelected: (_) => onToggleFactor(value))).toList()),
          const SizedBox(height: 12),
          FilledButton(key: const Key('check-puzzle-answer'), onPressed: onCheck, child: const Text('상자 열기')),
        ],
        _Feedback(text: feedback),
        const SizedBox(height: 12),
        if (solved) FilledButton.icon(key: const Key('open-deduction'), onPressed: onDeduce, icon: const Icon(Icons.psychology_alt_rounded), label: const Text('세 증거를 연결해 추리하기')) else TextButton.icon(onPressed: onReturn, icon: const Icon(Icons.arrow_back_rounded), label: const Text('정원 전체 보기')),
      ]));
}

class _DeductionScene extends StatelessWidget {
  const _DeductionScene({required this.selected, required this.feedback, required this.onSelect, required this.onCheck});
  final int? selected;
  final String? feedback;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  static const options = ['포포가 별빛 씨앗을 훔쳤다.', '강한 바람에 밀린 씨앗을 포포가 주워 상자에 지켜두었다.', '쓰러진 물뿌리개가 씨앗을 분수대로 밀었다.'];

  @override
  Widget build(BuildContext context) => _GradientScene(child: Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('추리 보드', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        const _EvidenceBoard(),
        const SizedBox(height: 16),
        for (var index = 0; index < options.length; index++) Padding(padding: const EdgeInsets.only(bottom: 9), child: ChoiceChip(key: Key('deduction-option-$index'), label: SizedBox(width: double.infinity, child: Text(options[index])), selected: selected == index, onSelected: (_) => onSelect(index))),
        _Feedback(text: feedback),
        const SizedBox(height: 12),
        FilledButton(key: const Key('check-deduction'), onPressed: selected == null ? null : onCheck, child: const Text('이 가설로 사건 설명하기')),
      ]))));
}

class _SolvedScene extends StatelessWidget {
  const _SolvedScene({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => _GradientScene(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Stack(alignment: Alignment.center, children: [Icon(Icons.wb_sunny_rounded, size: 150, color: Color(0x44FFE67F)), CircleAvatar(radius: 52, backgroundColor: Color(0xFFEEE6FF), child: Icon(Icons.pets_rounded, size: 58, color: Color(0xFF755C91)))]),
        const SizedBox(height: 20),
        const Text('사건 해결!', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        _StoryCard(text: '포포: 훔친 게 아니야! 바람에 밀려온 씨앗이 연못에 빠질까 봐 상자에 넣어 두었어.\n\n꽃루미: 별지기님이 직접 흔적을 조사해 준 덕분이야!'),
        const SizedBox(height: 18),
        FilledButton.icon(key: const Key('continue-adventure'), onPressed: onContinue, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('씨앗을 다시 심고 다음 모험 보기')),
      ]));
}

class _GradientScene extends StatelessWidget {
  const _GradientScene({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF30264F), Color(0xFF213C42)])), child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: child))));
}

class _CloseUpShell extends StatelessWidget {
  const _CloseUpShell({required this.title, required this.subtitle, required this.icon, required this.child});
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => _GradientScene(child: Card(elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [CircleAvatar(radius: 35, backgroundColor: const Color(0xFFFFE6A3), child: Icon(icon, size: 38, color: const Color(0xFF76558C))), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF74677B))), const SizedBox(height: 20), child]))));
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Text(text, style: const TextStyle(color: Color(0xFF473A54), height: 1.55, fontSize: 16)));
}

class _SceneCaption extends StatelessWidget {
  const _SceneCaption({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: const Color(0xCC211A32), borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))));
}

class _SceneButton extends StatelessWidget {
  const _SceneButton({required this.label, required this.icon, required this.emphasized, required this.onPressed, super.key});
  final String label;
  final IconData icon;
  final bool emphasized;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => AnimatedScale(duration: const Duration(milliseconds: 600), scale: emphasized ? 1.05 : 1, child: FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)));
}

class _PulseTarget extends StatelessWidget {
  const _PulseTarget({required this.inspected, required this.icon, required this.label, required this.onTap, super.key});
  final bool inspected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: AnimatedContainer(duration: const Duration(milliseconds: 350), width: 116, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: inspected ? const Color(0xE8D9F6D4) : const Color(0xE8FFF4C9), borderRadius: BorderRadius.circular(24), border: Border.all(color: inspected ? const Color(0xFF65A45F) : const Color(0xFFFFCF55), width: 3), boxShadow: [BoxShadow(color: inspected ? const Color(0x5565A45F) : const Color(0x88FFD75A), blurRadius: inspected ? 8 : 20)]), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(inspected ? Icons.check_circle_rounded : icon, size: 34, color: const Color(0xFF654873)), const SizedBox(height: 5), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900))])));
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.values, required this.selected, required this.keyPrefix, required this.onSelect});
  final List<int> values;
  final int? selected;
  final String keyPrefix;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: values.map((value) => ChoiceChip(key: Key('$keyPrefix-option-$value'), label: Text('$value'), selected: selected == value, onSelected: (_) => onSelect(value))).toList());
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.text});
  final String? text;
  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Container(key: const Key('scene-feedback'), margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF4ECF7), borderRadius: BorderRadius.circular(14)), child: Text(text!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF65486E), fontWeight: FontWeight.w700)));
  }
}

class _ObjectTile extends StatelessWidget {
  const _ObjectTile({required this.icon, required this.label, required this.onTap, super.key});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(width: 130, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF3EDF7), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFD9CBE3))), child: Column(children: [Icon(icon, size: 48, color: const Color(0xFF76558C)), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))])));
}

class _TrailTracks extends StatelessWidget {
  const _TrailTracks();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF1EBDD), borderRadius: BorderRadius.circular(20)), child: const Column(children: [_MarkerTrack(label: '발자국', interval: 4, icon: Icons.pets_rounded), SizedBox(height: 12), _MarkerTrack(label: '별가루', interval: 6, icon: Icons.auto_awesome_rounded)]));
}

class _MarkerTrack extends StatelessWidget {
  const _MarkerTrack({required this.label, required this.interval, required this.icon});
  final String label;
  final int interval;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(children: [SizedBox(width: 52, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(12, (index) => Icon((index + 1) % interval == 0 ? icon : Icons.circle, size: (index + 1) % interval == 0 ? 19 : 5, color: (index + 1) % interval == 0 ? const Color(0xFF76558C) : const Color(0xFFBDB2A5)))))]);
}

class _EvidenceBoard extends StatelessWidget {
  const _EvidenceBoard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF4ECF7), borderRadius: BorderRadius.circular(18)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('확인한 증거', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('• 오른쪽으로 난 긁힌 자국'), Text('• 분수대로 이어진 작은 발자국'), Text('• 상자 속 은빛 털과 바람에 꺾인 잎')]));
}

class _GardenPainter extends CustomPainter {
  const _GardenPainter({required this.evidence});
  final Set<_Evidence> evidence;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF31264E), Color(0xFF24584B), Color(0xFF183C32)]).createShader(rect));
    final path = Path()..moveTo(size.width * .5, size.height * .46)..quadraticBezierTo(size.width * .72, size.height * .55, size.width * .78, size.height * .8);
    canvas.drawPath(path, Paint()..color = const Color(0x558FE0C0)..strokeWidth = 26..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(size.width * .18, size.height * .7), size.shortestSide * .13, Paint()..color = const Color(0xAA55B7C9));
    canvas.drawCircle(Offset(size.width * .48, size.height * .39), 34, Paint()..color = const Color(0xFFBBA36A));
    if (evidence.contains(_Evidence.scratch)) {
      final paint = Paint()..color = const Color(0xFFFFD66F)..strokeWidth = 4..strokeCap = StrokeCap.round;
      for (var i = 0; i < 4; i++) canvas.drawLine(Offset(size.width * .5 + i * 5, size.height * .39), Offset(size.width * .6 + i * 5, size.height * .43), paint);
    }
    if (evidence.contains(_Evidence.footprints)) {
      for (var i = 0; i < 5; i++) canvas.drawCircle(Offset(size.width * (.58 + i * .045), size.height * (.5 + i * .045)), 7, Paint()..color = const Color(0xFFEAB4DB));
    }
  }
  @override
  bool shouldRepaint(covariant _GardenPainter oldDelegate) => oldDelegate.evidence.length != evidence.length;
}

class _PedestalPainter extends CustomPainter {
  const _PedestalPainter({required this.flowing, required this.solved});
  final bool flowing;
  final bool solved;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .4);
    canvas.drawOval(Rect.fromCenter(center: center + const Offset(0, 58), width: size.width * .52, height: 80), Paint()..color = const Color(0xFF6E5C47));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size.width * .36, height: 150), const Radius.circular(32)), Paint()..shader = const LinearGradient(colors: [Color(0xFFD7C18C), Color(0xFF8C7650)]).createShader(Rect.fromCenter(center: center, width: size.width * .36, height: 150)));
    canvas.drawCircle(center, 34, Paint()..color = const Color(0xFF4D405A));
    final scratchPaint = Paint()..color = const Color(0xFFFFD55D)..strokeWidth = solved ? 7 : 3..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) canvas.drawLine(center + Offset(42, -18 + i * 12), center + Offset(size.width * (flowing ? .4 : .24), -10 + i * 12), scratchPaint);
    if (flowing) {
      for (var i = 0; i < 14; i++) canvas.drawCircle(Offset(center.dx + 40 + i * 18, center.dy - 42 + (i % 3) * 18), 5 + (i % 2) * 2, Paint()..color = const Color(0xFFFFE170));
    }
  }
  @override
  bool shouldRepaint(covariant _PedestalPainter oldDelegate) => oldDelegate.flowing != flowing || oldDelegate.solved != solved;
}

const _questionStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF45364F));
