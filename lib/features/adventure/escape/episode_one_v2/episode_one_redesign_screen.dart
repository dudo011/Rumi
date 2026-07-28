import 'package:flutter/material.dart';

import '../../../../core/storage/progress_store.dart';
import 'episode_one_redesign_state.dart';

class EpisodeOneRedesignScreen extends StatefulWidget {
  const EpisodeOneRedesignScreen({
    super.key,
    this.controller,
    this.store = const ProgressStore(),
  });

  final EpisodeOneRedesignController? controller;
  final ProgressStore store;

  @override
  State<EpisodeOneRedesignScreen> createState() =>
      _EpisodeOneRedesignScreenState();
}

class _EpisodeOneRedesignScreenState extends State<EpisodeOneRedesignScreen> {
  late final EpisodeOneRedesignController _controller;
  late final bool _ownsController;
  bool _savingReward = false;
  bool _rewardSaved = false;
  String? _rewardError;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? EpisodeOneRedesignController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final wasCompleted = _controller.value.completed;
    final success = _controller.submitCurrent();
    if (success && !wasCompleted && _controller.value.completed) {
      await _saveReward();
    }
  }

  Future<void> _saveReward() async {
    if (_savingReward || _rewardSaved) return;
    setState(() {
      _savingReward = true;
      _rewardError = null;
    });
    try {
      await widget.store.completeAdventure(earnedExperience: 60);
      if (!mounted) return;
      setState(() {
        _savingReward = false;
        _rewardSaved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savingReward = false;
        _rewardError = '보상 저장에 실패했어요. 다시 저장할 수 있어요.';
      });
    }
  }

  Future<void> _confirmReset() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Episode 1을 처음부터 시작할까요?'),
        content: const Text('현재 조사 기록과 학습 활동 진행이 모두 초기화돼요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속하기'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    if (reset == true) {
      _controller.reset();
      setState(() {
        _rewardSaved = false;
        _rewardError = null;
      });
    }
  }

  void _showClues(EpisodeOneRedesignSnapshot snapshot) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF182933),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final clues = snapshot.clues.toList()
          ..sort((first, second) => first.index.compareTo(second.index));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '별지기의 단서 수첩',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '중앙 정원의 흔적 ${clues.length}/6',
                    style: const TextStyle(
                      color: Color(0xFFA8D9CC),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (clues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        '아직 기록한 단서가 없어요. 장면 속 물건을 조사해 보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFD6E8E2)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: clues.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: Color(0x334FD0B1)),
                        itemBuilder: (context, index) {
                          final clue = clues[index];
                          return ListTile(
                            key: Key('episode-one-v2-clue-${clue.name}'),
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0x33FFD96A),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFFFFD96A),
                              ),
                            ),
                            title: Text(
                              clue.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(
                              clue.description,
                              style: const TextStyle(
                                color: Color(0xFFD6E8E2),
                                height: 1.35,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('episode-one-v2-screen'),
      backgroundColor: const Color(0xFF08141C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final media = MediaQuery.of(context);
          final safe = media.padding;
          final compact =
              constraints.maxWidth < 480 || constraints.maxHeight < 720;
          return Stack(
            fit: StackFit.expand,
            children: [
              const _FullScreenBackground(),
              ValueListenableBuilder<EpisodeOneRedesignSnapshot>(
                valueListenable: _controller,
                builder: (context, snapshot, _) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      safe.left + (compact ? 10 : 16),
                      safe.top + 6,
                      safe.right + (compact ? 10 : 16),
                      safe.bottom + 8,
                    ),
                    child: Column(
                      children: [
                        _TopBar(
                          snapshot: snapshot,
                          compact: compact,
                          onBack: () => Navigator.of(context).maybePop(),
                          onClues: () => _showClues(snapshot),
                          onReset: _confirmReset,
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        Expanded(
                          child: SingleChildScrollView(
                            key: const Key('episode-one-v2-scroll'),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 760,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _ScenePanel(
                                      snapshot: snapshot,
                                      compact: compact,
                                    ),
                                    SizedBox(height: compact ? 10 : 14),
                                    _ActivityPanel(
                                      controller: _controller,
                                      snapshot: snapshot,
                                      compact: compact,
                                      onSubmit: _handleSubmit,
                                      savingReward: _savingReward,
                                      rewardSaved: _rewardSaved,
                                      rewardError: _rewardError,
                                      onRetryReward: _saveReward,
                                      onReturnHome: () => Navigator.of(
                                        context,
                                      ).popUntil((route) => route.isFirst),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        _MessageBar(snapshot: snapshot, compact: compact),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FullScreenBackground extends StatelessWidget {
  const _FullScreenBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111D2C), Color(0xFF174D45), Color(0xFF08141C)],
        ),
      ),
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x66FFF0B0);
    for (var index = 0; index < 26; index++) {
      final x = size.width * ((index * 37 % 97) / 100);
      final y = size.height * (0.03 + ((index * 23 % 60) / 100));
      canvas.drawCircle(Offset(x, y), 1 + index % 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.snapshot,
    required this.compact,
    required this.onBack,
    required this.onClues,
    required this.onReset,
  });

  final EpisodeOneRedesignSnapshot snapshot;
  final bool compact;
  final VoidCallback onBack;
  final VoidCallback onClues;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 44,
          child: IconButton.filledTonal(
            key: const Key('episode-one-v2-back'),
            tooltip: '모험 나가기',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            children: [
              Text(
                snapshot.sceneLabel,
                key: const Key('episode-one-v2-scene-label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w900,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                snapshot.objective,
                key: const Key('episode-one-v2-objective'),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFD6E8E2),
                  fontSize: compact ? 10.5 : 12,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox.square(
              dimension: 44,
              child: IconButton.filledTonal(
                key: const Key('episode-one-v2-notebook'),
                tooltip: '단서 수첩',
                onPressed: onClues,
                icon: const Icon(Icons.menu_book_rounded),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: const Color(0xFFFFD96A),
                foregroundColor: const Color(0xFF302440),
                child: Text(
                  '${snapshot.clues.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        SizedBox.square(
          dimension: 44,
          child: IconButton.filledTonal(
            key: const Key('episode-one-v2-reset'),
            tooltip: 'Episode 1 초기화',
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    );
  }
}

class _ScenePanel extends StatelessWidget {
  const _ScenePanel({required this.snapshot, required this.compact});

  final EpisodeOneRedesignSnapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final icon = switch (snapshot.completed ? null : snapshot.activity) {
      EpisodeOneRedesignActivity.fitFallenPiece => Icons.auto_awesome_rounded,
      EpisodeOneRedesignActivity.testTwelveGroups ||
      EpisodeOneRedesignActivity.findTwelveDivisors ||
      EpisodeOneRedesignActivity.pairTwelveFactors ||
      EpisodeOneRedesignActivity.orderTwelveDivisors => Icons.balance_rounded,
      EpisodeOneRedesignActivity.arrangeEighteen ||
      EpisodeOneRedesignActivity.removeDuplicatePairs ||
      EpisodeOneRedesignActivity.findMissingDivisor ||
      EpisodeOneRedesignActivity.removeNonDivisor =>
        Icons.local_florist_rounded,
      EpisodeOneRedesignActivity.arrangeTwentyFour ||
      EpisodeOneRedesignActivity.findTwentyFourDivisors ||
      EpisodeOneRedesignActivity.rejectFalseRecord => Icons.handyman_rounded,
      EpisodeOneRedesignActivity.chooseFootprintPath ||
      EpisodeOneRedesignActivity.orderEvidence ||
      null => Icons.water_rounded,
    };
    return Container(
      key: const Key('episode-one-v2-scene-panel'),
      height: compact ? 142 : 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xCC285B56), Color(0xCC24304C)],
        ),
        border: Border.all(color: const Color(0x5578DFC3)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 18)],
      ),
      child: Stack(
        children: [
          Positioned(
            left: compact ? 18 : 28,
            top: compact ? 18 : 25,
            child: Icon(
              icon,
              size: compact ? 58 : 82,
              color: const Color(0xFFFFE39A),
            ),
          ),
          Positioned(
            left: compact ? 90 : 132,
            right: 18,
            top: compact ? 20 : 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.completed ? '다음 흔적 발견' : snapshot.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 18 : 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _sceneDescription(snapshot),
                  maxLines: compact ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFFD9EEE7),
                    fontSize: compact ? 11 : 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Row(
              children: List.generate(6, (index) {
                final found = index < snapshot.clues.length;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    decoration: BoxDecoration(
                      color: found
                          ? const Color(0xFFFFD96A)
                          : const Color(0x335FE3C0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _sceneDescription(EpisodeOneRedesignSnapshot snapshot) {
    if (snapshot.completed) {
      return '발자국은 씨앗이 떨어진 뒤에 시작됐어요. 연못가의 은빛 털과 물 아래 수문이 다음 Episode를 가리켜요.';
    }
    return switch (snapshot.activity) {
      EpisodeOneRedesignActivity.fitFallenPiece =>
        '빈 별받침대 아래에서 반달 모양 조각이 흔들려요. 같은 모양의 오른쪽 홈이 희미하게 빛나고 있어요.',
      EpisodeOneRedesignActivity.testTwelveGroups ||
      EpisodeOneRedesignActivity.findTwelveDivisors ||
      EpisodeOneRedesignActivity.pairTwelveFactors ||
      EpisodeOneRedesignActivity.orderTwelveDivisors =>
        '받침대 안에서 12개의 별가루와 여러 묶음판이 나타났어요. 남김없이 맞는 규칙이 방향판을 움직여요.',
      EpisodeOneRedesignActivity.arrangeEighteen ||
      EpisodeOneRedesignActivity.removeDuplicatePairs ||
      EpisodeOneRedesignActivity.findMissingDivisor ||
      EpisodeOneRedesignActivity.removeNonDivisor =>
        '쓰러진 화단 옆으로 18개의 긁힌 별가루가 이어져요. 기록을 복구하면 흔적이 향한 방향을 알 수 있어요.',
      EpisodeOneRedesignActivity.arrangeTwentyFour ||
      EpisodeOneRedesignActivity.findTwentyFourDivisors ||
      EpisodeOneRedesignActivity.rejectFalseRecord =>
        '화분 아래에서 별꽃 씨앗 24개와 잠긴 도구 보관소가 발견됐어요. 씨앗 배열이 잠금핀과 연결돼요.',
      EpisodeOneRedesignActivity.chooseFootprintPath ||
      EpisodeOneRedesignActivity.orderEvidence =>
        '24칸의 별돌 위에 여러 흔적이 겹쳐 있어요. 약수 규칙과 앞서 찾은 방향 단서를 함께 사용해야 해요.',
    };
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({
    required this.controller,
    required this.snapshot,
    required this.compact,
    required this.onSubmit,
    required this.savingReward,
    required this.rewardSaved,
    required this.rewardError,
    required this.onRetryReward,
    required this.onReturnHome,
  });

  final EpisodeOneRedesignController controller;
  final EpisodeOneRedesignSnapshot snapshot;
  final bool compact;
  final Future<void> Function() onSubmit;
  final bool savingReward;
  final bool rewardSaved;
  final String? rewardError;
  final Future<void> Function() onRetryReward;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    if (snapshot.completed) {
      return _CompletionPanel(
        controller: controller,
        snapshot: snapshot,
        savingReward: savingReward,
        rewardSaved: rewardSaved,
        rewardError: rewardError,
        onRetryReward: onRetryReward,
        onReturnHome: onReturnHome,
      );
    }

    return Container(
      key: Key('episode-one-v2-activity-${snapshot.activityIndex + 1}'),
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xF2F7F3FA),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DFF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  snapshot.progressLabel,
                  style: const TextStyle(
                    color: Color(0xFF624B7A),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              if (snapshot.supportSuggested)
                const Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 16,
                      color: Color(0xFFD66D9A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '보강 힌트 준비됨',
                      style: TextStyle(
                        color: Color(0xFF8A4C69),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.title,
            style: TextStyle(
              color: const Color(0xFF352747),
              fontSize: compact ? 19 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            snapshot.objective,
            style: TextStyle(
              color: const Color(0xFF675B70),
              fontSize: compact ? 12 : 13,
              height: 1.4,
            ),
          ),
          SizedBox(height: compact ? 14 : 18),
          _buildActivityContent(),
          SizedBox(height: compact ? 14 : 18),
          Row(
            children: [
              TextButton.icon(
                key: const Key('episode-one-v2-hint'),
                onPressed: controller.requestHint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(snapshot.hintLevel == 0 ? '힌트' : '다음 힌트'),
              ),
              const Spacer(),
              FilledButton.icon(
                key: const Key('episode-one-v2-submit'),
                onPressed: onSubmit,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(_submitLabel(snapshot.activity)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent() {
    return switch (snapshot.activity) {
      EpisodeOneRedesignActivity.fitFallenPiece => _ObjectAction(
        icon: Icons.auto_awesome_rounded,
        label: '떨어진 별조각 조사',
        description: '반달 모양 조각을 들어 받침대 오른쪽 홈과 맞춰 보세요.',
        onTap: controller.fitFallenPiece,
      ),
      EpisodeOneRedesignActivity.testTwelveGroups => _GroupExperiment(
        snapshot: snapshot,
        onTap: controller.testGroupSize,
      ),
      EpisodeOneRedesignActivity.findTwelveDivisors => _NumberChoices(
        numbers: const [1, 2, 3, 4, 5, 6, 12],
        selected: snapshot.selectedNumbers,
        onTap: controller.toggleNumber,
      ),
      EpisodeOneRedesignActivity.pairTwelveFactors => _TextChoices(
        choices: const ['1×12', '2×6', '2×5', '3×4', '4×4'],
        selected: snapshot.selectedTexts,
        onTap: controller.toggleText,
      ),
      EpisodeOneRedesignActivity.orderTwelveDivisors => _OrderedNumberActivity(
        selectedOrder: snapshot.orderedNumbers,
        onTap: controller.selectOrderedNumber,
      ),
      EpisodeOneRedesignActivity.arrangeEighteen => _NumberChoices(
        numbers: const [1, 2, 3, 4, 5, 6, 9, 18],
        selected: snapshot.selectedNumbers,
        onTap: controller.toggleNumber,
      ),
      EpisodeOneRedesignActivity.removeDuplicatePairs => _TextChoices(
        choices: const ['1×18', '2×9', '3×6', '6×3', '9×2', '18×1'],
        selected: snapshot.selectedTexts,
        onTap: controller.toggleText,
      ),
      EpisodeOneRedesignActivity.findMissingDivisor => _NumberChoices(
        numbers: const [4, 5, 6, 7],
        selected: snapshot.selectedNumbers,
        onTap: controller.toggleNumber,
      ),
      EpisodeOneRedesignActivity.removeNonDivisor => _NumberChoices(
        numbers: const [2, 3, 4, 6, 9],
        selected: snapshot.selectedNumbers,
        onTap: controller.toggleNumber,
      ),
      EpisodeOneRedesignActivity.arrangeTwentyFour => _TextChoices(
        choices: const ['1×24', '2×12', '3×8', '4×6', '5×5'],
        selected: snapshot.selectedTexts,
        onTap: controller.toggleText,
      ),
      EpisodeOneRedesignActivity.findTwentyFourDivisors => _NumberChoices(
        numbers: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 24],
        selected: snapshot.selectedNumbers,
        onTap: controller.toggleNumber,
      ),
      EpisodeOneRedesignActivity.rejectFalseRecord => _RecordChoices(
        selected: snapshot.selectedTexts,
        onTap: controller.toggleText,
      ),
      EpisodeOneRedesignActivity.chooseFootprintPath => _PathChoices(
        selected: snapshot.selectedNumbers,
        onTap: controller.toggleNumber,
      ),
      EpisodeOneRedesignActivity.orderEvidence => _TimelineActivity(
        snapshot: snapshot,
        onCardTap: controller.selectTimelineCard,
        onConclusionTap: controller.toggleText,
      ),
    };
  }

  String _submitLabel(EpisodeOneRedesignActivity activity) =>
      switch (activity) {
        EpisodeOneRedesignActivity.fitFallenPiece => '조각 맞추기',
        EpisodeOneRedesignActivity.testTwelveGroups => '실험 기록하기',
        EpisodeOneRedesignActivity.orderTwelveDivisors => '방향판 작동',
        EpisodeOneRedesignActivity.orderEvidence => '중간 결론 확정',
        _ => '장치 확인',
      };
}

class _ObjectAction extends StatelessWidget {
  const _ObjectAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('episode-one-v2-fallen-piece'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6D8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFD96A), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 42, color: const Color(0xFF936A22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF5D441B),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF745F38),
                      height: 1.35,
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

class _GroupExperiment extends StatelessWidget {
  const _GroupExperiment({required this.snapshot, required this.onTap});

  final EpisodeOneRedesignSnapshot snapshot;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [2, 3, 4, 5].map((size) {
        final tested = snapshot.testedGroupSizes.contains(size);
        final remainder = 12 % size;
        return ActionChip(
          key: Key('episode-one-v2-group-$size'),
          avatar: Icon(
            tested
                ? remainder == 0
                      ? Icons.check_circle_rounded
                      : Icons.info_rounded
                : Icons.science_rounded,
            size: 18,
          ),
          label: Text(
            tested
                ? remainder == 0
                      ? '$size개씩 · 남음 없음'
                      : '$size개씩 · $remainder개 남음'
                : '$size개씩 묶어 보기',
          ),
          onPressed: () => onTap(size),
        );
      }).toList(),
    );
  }
}

class _NumberChoices extends StatelessWidget {
  const _NumberChoices({
    required this.numbers,
    required this.selected,
    required this.onTap,
  });

  final List<int> numbers;
  final Set<int> selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: numbers.map((number) {
        return FilterChip(
          key: Key('episode-one-v2-number-$number'),
          selected: selected.contains(number),
          showCheckmark: true,
          label: Text('$number'),
          onSelected: (_) => onTap(number),
        );
      }).toList(),
    );
  }
}

class _TextChoices extends StatelessWidget {
  const _TextChoices({
    required this.choices,
    required this.selected,
    required this.onTap,
  });

  final List<String> choices;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: choices.map((choice) {
        return FilterChip(
          key: Key('episode-one-v2-text-${choice.replaceAll('×', 'x')}'),
          selected: selected.contains(choice),
          label: Text(choice),
          onSelected: (_) => onTap(choice),
        );
      }).toList(),
    );
  }
}

class _OrderedNumberActivity extends StatelessWidget {
  const _OrderedNumberActivity({
    required this.selectedOrder,
    required this.onTap,
  });

  final List<int> selectedOrder;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const choices = [6, 1, 12, 3, 2, 4];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3EF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            selectedOrder.isEmpty
                ? '아직 놓은 숫자가 없어요.'
                : selectedOrder.join('  →  '),
            key: const Key('episode-one-v2-ordered-numbers'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF315D52),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: choices.map((number) {
            final used = selectedOrder.contains(number);
            return ActionChip(
              key: Key('episode-one-v2-order-$number'),
              label: Text('$number'),
              onPressed: used ? null : () => onTap(number),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RecordChoices extends StatelessWidget {
  const _RecordChoices({required this.selected, required this.onTap});

  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const records = {
      'A': '3은 24를 나누어떨어지게 하므로 24의 약수다.',
      'B': '8과 3을 곱하면 24가 되므로 두 수는 24의 약수다.',
      'C': '5는 24보다 작으므로 24의 약수다.',
    };
    return Column(
      children: records.entries.map((entry) {
        final isSelected = selected.contains(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            key: Key('episode-one-v2-record-${entry.key}'),
            onTap: () => onTap(entry.key),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE8DDF5)
                    : const Color(0xFFF2EEF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF79559D)
                      : const Color(0xFFD5C9DE),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                '${entry.key}. ${entry.value}',
                style: const TextStyle(
                  color: Color(0xFF4D4058),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PathChoices extends StatelessWidget {
  const _PathChoices({required this.selected, required this.onTap});

  final Set<int> selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const descriptions = {
      4: '4칸마다 찍힌 발자국 · 24칸을 정확히 통과',
      5: '5칸마다 찍힌 발자국 · 마지막에 4칸이 남음',
      6: '6칸마다 찍힌 발자국 · 24칸 통과 · 오른쪽 흔적과 일치',
    };
    return Column(
      children: descriptions.entries.map((entry) {
        final active = selected.contains(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            key: Key('episode-one-v2-path-${entry.key}'),
            onTap: () => onTap(entry.key),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFDDF2EB)
                    : const Color(0xFFF0F5F3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? const Color(0xFF3A9B80)
                      : const Color(0xFFCADDD7),
                  width: active ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF315D52),
                    foregroundColor: Colors.white,
                    child: Text('${entry.key}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Color(0xFF3B524B),
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimelineActivity extends StatelessWidget {
  const _TimelineActivity({
    required this.snapshot,
    required this.onCardTap,
    required this.onConclusionTap,
  });

  final EpisodeOneRedesignSnapshot snapshot;
  final ValueChanged<int> onCardTap;
  final ValueChanged<String> onConclusionTap;

  static const cards = {
    1: '강한 바람이 불었다.',
    2: '받침대 조각이 떨어졌다.',
    3: '씨앗이 오른쪽으로 미끄러졌다.',
    4: '씨앗이 떨어진 자리에서 발자국이 시작됐다.',
    5: '발자국이 연못 방향으로 이어졌다.',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3EF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            snapshot.timelineOrder.isEmpty
                ? '증거 카드를 가장 먼저 일어난 일부터 놓으세요.'
                : snapshot.timelineOrder
                      .map((number) => '$number. ${cards[number]}')
                      .join('\n'),
            key: const Key('episode-one-v2-timeline-order'),
            style: const TextStyle(
              color: Color(0xFF315D52),
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [3, 1, 5, 2, 4].map((number) {
            return ActionChip(
              key: Key('episode-one-v2-timeline-$number'),
              label: Text('$number. ${cards[number]}'),
              onPressed: snapshot.timelineOrder.contains(number)
                  ? null
                  : () => onCardTap(number),
            );
          }).toList(),
        ),
        if (snapshot.timelineOrder.length == 5) ...[
          const SizedBox(height: 16),
          const Text(
            '지금까지의 증거로 확실히 말할 수 있는 것은?',
            style: TextStyle(
              color: Color(0xFF493956),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _ConclusionChoice(
            code: 'A',
            text: '포포가 처음부터 씨앗을 훔쳤다.',
            selected: snapshot.selectedTexts.contains('A'),
            onTap: onConclusionTap,
          ),
          _ConclusionChoice(
            code: 'B',
            text: '씨앗이 먼저 떨어졌고 작은 생물이 그 뒤를 따라갔다.',
            selected: snapshot.selectedTexts.contains('B'),
            onTap: onConclusionTap,
          ),
          _ConclusionChoice(
            code: 'C',
            text: '바람이 씨앗을 하늘로 날려 보냈다.',
            selected: snapshot.selectedTexts.contains('C'),
            onTap: onConclusionTap,
          ),
        ],
      ],
    );
  }
}

class _ConclusionChoice extends StatelessWidget {
  const _ConclusionChoice({
    required this.code,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String text;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      key: Key('episode-one-v2-conclusion-$code'),
      value: code,
      groupValue: selected ? code : null,
      onChanged: (_) => onTap(code),
      title: Text('$code. $text'),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({
    required this.controller,
    required this.snapshot,
    required this.savingReward,
    required this.rewardSaved,
    required this.rewardError,
    required this.onRetryReward,
    required this.onReturnHome,
  });

  final EpisodeOneRedesignController controller;
  final EpisodeOneRedesignSnapshot snapshot;
  final bool savingReward;
  final bool rewardSaved;
  final String? rewardError;
  final Future<void> Function() onRetryReward;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('episode-one-v2-completion'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4CE), Color(0xFFF2E9FF)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 50,
            color: Color(0xFF8D659F),
          ),
          const SizedBox(height: 10),
          const Text(
            'Episode 1 완료',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4A3659),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '씨앗은 먼저 오른쪽으로 떨어졌고, 작은 생물은 그 뒤를 따라 연못으로 이동했어요. 아직 누구도 범인으로 단정할 수 없어요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF65566D), height: 1.45),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFD69632)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    savingReward
                        ? 'Episode 보상 +60 XP를 저장하고 있어요.'
                        : rewardSaved
                        ? '+60 XP와 Episode 완료 기록을 저장했어요.'
                        : rewardError ?? 'Episode 보상 +60 XP',
                    style: const TextStyle(
                      color: Color(0xFF624B30),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (rewardError != null)
                  TextButton(
                    onPressed: onRetryReward,
                    child: const Text('다시 저장'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (!snapshot.challengeOpen && !snapshot.challengeCompleted)
            OutlinedButton.icon(
              key: const Key('episode-one-v2-open-challenge'),
              onPressed: controller.openChallenge,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('선택 도전: 30의 약수 찾기'),
            ),
          if (snapshot.challengeOpen) ...[
            const Text(
              '30의 약수를 모두 선택하세요.',
              style: TextStyle(
                color: Color(0xFF493956),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _NumberChoices(
              numbers: const [1, 2, 3, 4, 5, 6, 10, 12, 15, 30],
              selected: snapshot.selectedNumbers,
              onTap: controller.toggleNumber,
            ),
            const SizedBox(height: 10),
            FilledButton(
              key: const Key('episode-one-v2-submit-challenge'),
              onPressed: controller.submitChallenge,
              child: const Text('별도장 완성'),
            ),
          ],
          if (snapshot.challengeCompleted)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFD69632),
              ),
              title: Text(
                '정원사의 별도장 획득',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('30의 약수까지 스스로 찾아냈어요.'),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('episode-one-v2-return-home'),
            onPressed: onReturnHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('별정원으로 돌아가기'),
          ),
        ],
      ),
    );
  }
}

class _MessageBar extends StatelessWidget {
  const _MessageBar({required this.snapshot, required this.compact});

  final EpisodeOneRedesignSnapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('episode-one-v2-message-bar'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 11 : 14,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xE6253440),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x5578DFC3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFFFFE39A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              snapshot.message,
              key: const Key('episode-one-v2-message'),
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 11 : 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x334FD0B1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              snapshot.progressLabel,
              key: const Key('episode-one-v2-progress'),
              style: const TextStyle(
                color: Color(0xFFD8F5EC),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
