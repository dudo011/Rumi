import 'package:flutter/material.dart';

import '../../../../core/storage/progress_store.dart';
import 'episode_one_v3_state.dart';

class EpisodeOneV3Screen extends StatefulWidget {
  const EpisodeOneV3Screen({
    super.key,
    this.controller,
    this.store = const ProgressStore(),
  });

  final EpisodeOneV3Controller? controller;
  final ProgressStore store;

  @override
  State<EpisodeOneV3Screen> createState() => _EpisodeOneV3ScreenState();
}

class _EpisodeOneV3ScreenState extends State<EpisodeOneV3Screen> {
  late final EpisodeOneV3Controller _controller;
  late final bool _ownsController;
  bool _loadingCheckpoint = true;
  bool _savingReward = false;
  bool _rewardSaved = false;
  String? _rewardError;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? EpisodeOneV3Controller();
    if (_ownsController) {
      _loadCheckpoint();
    } else {
      _loadingCheckpoint = false;
    }
  }

  Future<void> _loadCheckpoint() async {
    final checkpoint = await widget.store.loadEpisodeOneV3Checkpoint();
    if (!mounted) return;
    _controller.restoreCheckpoint(checkpoint);
    setState(() => _loadingCheckpoint = false);
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final before = _controller.value.stage;
    final success = _controller.submitCurrent();
    if (!success) return;

    final after = _controller.value.stage;
    if (after == EpisodeOneV3Stage.identifyFlowerpot &&
        before != EpisodeOneV3Stage.identifyFlowerpot) {
      await widget.store.saveEpisodeOneV3Checkpoint(1);
    } else if (after == EpisodeOneV3Stage.arrangeTwentyFour &&
        before != EpisodeOneV3Stage.arrangeTwentyFour) {
      await widget.store.saveEpisodeOneV3Checkpoint(2);
    } else if (after == EpisodeOneV3Stage.useTraceFilters &&
        before != EpisodeOneV3Stage.useTraceFilters) {
      await widget.store.saveEpisodeOneV3Checkpoint(3);
    }

    if (_controller.value.completed) {
      await widget.store.clearEpisodeOneV3Checkpoint();
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
        content: const Text('수집한 단서와 자동 저장된 대형 퍼즐 진행도 함께 초기화돼요.'),
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
    if (reset != true) return;
    await widget.store.clearEpisodeOneV3Checkpoint();
    _controller.reset();
    if (!mounted) return;
    setState(() {
      _rewardSaved = false;
      _rewardError = null;
    });
  }

  void _handleBackAttempt() {
    if (_controller.undoCurrentInput()) return;
    final message = _controller.value.completed
        ? '조사가 끝났어요. 결말 화면의 정원으로 돌아가기 버튼을 이용하세요.'
        : '단서 6개를 모두 찾기 전에는 메인 화면으로 나갈 수 없어요.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showClues(EpisodeOneV3Snapshot snapshot) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF172A31),
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final clues = snapshot.clues.toList()
          ..sort((first, second) => first.index.compareTo(second.index));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 620),
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
                  const SizedBox(height: 6),
                  Text(
                    '중앙 정원의 흔적 ${clues.length}/6',
                    style: const TextStyle(
                      color: Color(0xFFA8D9CC),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (clues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        '아직 기록한 단서가 없어요. 장면의 물건과 장치 반응을 조사해 보세요.',
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
                            key: Key('episode-one-v3-clue-${clue.name}'),
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
    if (_loadingCheckpoint) {
      return const Scaffold(
        backgroundColor: Color(0xFF08141C),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackAttempt();
      },
      child: Scaffold(
        key: const Key('episode-one-v3-screen'),
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
                const _GardenBackground(),
                ValueListenableBuilder<EpisodeOneV3Snapshot>(
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
                            onUndo: _controller.undoCurrentInput,
                            onClues: () => _showClues(snapshot),
                            onReset: _confirmReset,
                          ),
                          SizedBox(height: compact ? 8 : 12),
                          Expanded(
                            child: SingleChildScrollView(
                              key: const Key('episode-one-v3-scroll'),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 780,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _InvestigationScene(
                                        snapshot: snapshot,
                                        compact: compact,
                                      ),
                                      SizedBox(height: compact ? 10 : 14),
                                      _PuzzlePanel(
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
      ),
    );
  }
}

class _GardenBackground extends StatelessWidget {
  const _GardenBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101C2D), Color(0xFF174D45), Color(0xFF07131B)],
        ),
      ),
      child: CustomPaint(painter: _GardenParticlePainter()),
    );
  }
}

class _GardenParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = const Color(0x66FFF0B0);
    final leafPaint = Paint()..color = const Color(0x332FE0AE);
    for (var index = 0; index < 30; index++) {
      final x = size.width * ((index * 37 % 97) / 100);
      final y = size.height * (0.03 + ((index * 23 % 72) / 100));
      canvas.drawCircle(Offset(x, y), 1 + index % 3, starPaint);
    }
    for (var index = 0; index < 12; index++) {
      final x = size.width * ((index * 53 % 91) / 100);
      final y = size.height * (0.25 + ((index * 17 % 65) / 100));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 8 + (index % 3) * 3,
          height: 4 + (index % 2) * 2,
        ),
        leafPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.snapshot,
    required this.compact,
    required this.onUndo,
    required this.onClues,
    required this.onReset,
  });

  final EpisodeOneV3Snapshot snapshot;
  final bool compact;
  final VoidCallback onUndo;
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
            key: const Key('episode-one-v3-undo'),
            tooltip: '현재 선택 하나 되돌리기',
            onPressed: snapshot.canUndoCurrentInput ? onUndo : null,
            icon: const Icon(Icons.undo_rounded),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            children: [
              Text(
                snapshot.stage.sceneLabel,
                key: const Key('episode-one-v3-scene-label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 15.5 : 18,
                  fontWeight: FontWeight.w900,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                snapshot.stage.objective,
                key: const Key('episode-one-v3-objective'),
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
                key: const Key('episode-one-v3-notebook'),
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
            key: const Key('episode-one-v3-reset'),
            tooltip: 'Episode 1 초기화',
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    );
  }
}

class _InvestigationScene extends StatelessWidget {
  const _InvestigationScene({required this.snapshot, required this.compact});

  final EpisodeOneV3Snapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final icon = switch (snapshot.macroPuzzleIndex) {
      1 => Icons.auto_awesome_rounded,
      2 => Icons.local_florist_rounded,
      3 => Icons.inventory_2_rounded,
      _ => Icons.water_drop_rounded,
    };
    final description = switch (snapshot.macroPuzzleIndex) {
      1 =>
        '받침대의 장치는 별가루가 남는지에 따라 다른 별자리 문양을 밝힙니다. 벽화와 회전판은 서로 다른 정보의 일부만 보여줍니다.',
      2 =>
        '긁힘은 화분 테두리, 흙과 바닥에 나뉘어 있습니다. 복원한 수와 바람 방향을 함께 사용해야 숨은 화분을 열 수 있습니다.',
      3 => '씨앗 배열은 잠금핀과 문양 암호로 변환됩니다. 이전 장소에서 얻은 읽는 방향이 문을 여는 순서를 결정합니다.',
      _ => '씨앗 이동선, 젖은 발자국과 장화 자국이 겹쳐 있습니다. 도구, 시작점, 간격과 방향을 모두 확인해야 합니다.',
    };

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xD91A2B35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x5578DFC3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: compact ? 22 : 25,
                backgroundColor: const Color(0x334FD0B1),
                child: Icon(icon, color: const Color(0xFFFFE39A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.stage.title,
                      key: Key('episode-one-v3-stage-${snapshot.stage.name}'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 18 : 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFFD6E8E2),
                        fontSize: compact ? 12 : 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (snapshot.inventory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: snapshot.inventory
                  .map(
                    (item) => Chip(
                      avatar: const Icon(
                        Icons.category_rounded,
                        size: 16,
                        color: Color(0xFFFFD96A),
                      ),
                      label: Text(item.label),
                      backgroundColor: const Color(0x33243C45),
                      side: const BorderSide(color: Color(0x4459CDB1)),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PuzzlePanel extends StatelessWidget {
  const _PuzzlePanel({
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

  final EpisodeOneV3Controller controller;
  final EpisodeOneV3Snapshot snapshot;
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
      key: const Key('episode-one-v3-puzzle-panel'),
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xF2F7F3EC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x88F6DFA6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StageContent(
            controller: controller,
            snapshot: snapshot,
            compact: compact,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('episode-one-v3-hint'),
                  onPressed: controller.requestHint,
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: Text(
                    snapshot.hintLevel == 0
                        ? '꽃루미에게 힌트'
                        : '다음 힌트 ${snapshot.hintLevel}/3',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  key: const Key('episode-one-v3-submit'),
                  onPressed: onSubmit,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('장치 확인하기'),
                ),
              ),
            ],
          ),
          if (snapshot.supportSuggested) ...[
            const SizedBox(height: 9),
            const Text(
              '여러 번 시도한 활동이에요. 힌트를 사용해도 경험치와 보상은 줄지 않아요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF725A3D),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StageContent extends StatelessWidget {
  const _StageContent({
    required this.controller,
    required this.snapshot,
    required this.compact,
  });

  final EpisodeOneV3Controller controller;
  final EpisodeOneV3Snapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return switch (snapshot.stage) {
      EpisodeOneV3Stage.identifyFragment => _textGrid(const [
        _TextOption(
          'crescent',
          '반달 별조각',
          '오른쪽 가장자리에 길게 긁힌 자국이 있다.',
          Icons.nightlight_round,
        ),
        _TextOption(
          'pottery',
          '화분 조각',
          '흙이 묻어 있고 홈보다 두껍다.',
          Icons.local_florist_rounded,
        ),
        _TextOption(
          'button',
          '은빛 단추',
          '둥글고 작은 구멍이 두 개 있다.',
          Icons.radio_button_checked,
        ),
        _TextOption(
          'glass',
          '유리 파편',
          '빛을 반사하지만 삼각형에 가깝다.',
          Icons.change_history_rounded,
        ),
      ]),
      EpisodeOneV3Stage.testTwelveGroups => _experimentButtons(
        const [2, 3, 4, 5],
        total: 12,
        unit: '개씩',
      ),
      EpisodeOneV3Stage.revealTwelveDivisors => _numberGrid(const [
        1,
        2,
        3,
        4,
        5,
        6,
        8,
        12,
      ]),
      EpisodeOneV3Stage.pairTwelveFactors => _simpleTextChoices(const [
        '1×12',
        '2×6',
        '3×4',
        '1×11',
        '2×5',
        '4×4',
      ]),
      EpisodeOneV3Stage.orderTwelveDivisors => _orderedNumberStage(const [
        1,
        2,
        3,
        4,
        5,
        6,
        8,
        12,
      ]),
      EpisodeOneV3Stage.identifyFlowerpot => _textGrid(const [
        _TextOption('pot1', '1번 화분', '잎 문양 3개', Icons.local_florist),
        _TextOption('pot2', '2번 화분', '잎 문양 4개', Icons.local_florist),
        _TextOption('pot3', '3번 화분', '잎 문양 5개', Icons.local_florist),
        _TextOption('pot4', '4번 화분', '잎 문양 8개', Icons.local_florist),
        _TextOption('pot5', '5번 화분', '잎 문양 7개', Icons.local_florist),
        _TextOption('pot6', '6번 화분', '잎 문양 6개', Icons.local_florist),
      ]),
      EpisodeOneV3Stage.assembleScratches => _textGrid(const [
        _TextOption('rim7', '화분 테두리', '짧은 긁힘 7개', Icons.circle_outlined),
        _TextOption('soil5', '흙 위', '눌린 긁힘 5개', Icons.grass_rounded),
        _TextOption('tile6', '바닥 타일', '빛에 비치는 긁힘 6개', Icons.grid_4x4_rounded),
        _TextOption(
          'wind4',
          '바람종',
          '금속 긁힘 4개, 방향이 다름',
          Icons.notifications_none_rounded,
        ),
      ]),
      EpisodeOneV3Stage.arrangeEighteen => _numberGrid(const [
        1,
        2,
        3,
        4,
        6,
        9,
        12,
        18,
      ]),
      EpisodeOneV3Stage.removeDuplicateEighteen => _simpleTextChoices(const [
        '18×1',
        '9×2',
        '6×3',
        '1×17',
        '4×4',
        '5×3',
      ]),
      EpisodeOneV3Stage.findMissingEighteen => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RecordStrip(text: '1 — 18    2 — 9    3 — □'),
          const SizedBox(height: 10),
          _numberGrid(const [4, 5, 6, 7]),
        ],
      ),
      EpisodeOneV3Stage.rejectNonDivisorEighteen => _numberGrid(const [
        2,
        3,
        4,
        6,
        9,
      ]),
      EpisodeOneV3Stage.arrangeTwentyFour => _simpleTextChoices(const [
        '1×24',
        '2×12',
        '3×8',
        '4×6',
        '5×5',
        '6×5',
      ]),
      EpisodeOneV3Stage.mapTwentyFourPins => _numberGrid(const [
        1,
        2,
        3,
        4,
        5,
        6,
        8,
        10,
        12,
        24,
      ]),
      EpisodeOneV3Stage.orderStorageGlyphs => _orderedGlyphStage(),
      EpisodeOneV3Stage.rejectFalseRecord => _falseRecordStage(),
      EpisodeOneV3Stage.useTraceFilters => _filterStage(),
      EpisodeOneV3Stage.chooseTrackStart => _trackStartStage(),
      EpisodeOneV3Stage.testTrackIntervals => _experimentButtons(
        const [4, 5, 6],
        total: 24,
        unit: '칸',
      ),
      EpisodeOneV3Stage.connectFootprints => _trackNodeStage(),
      EpisodeOneV3Stage.orderEvidence => _evidenceStage(),
      EpisodeOneV3Stage.chooseConclusion => _conclusionStage(),
      EpisodeOneV3Stage.completed => const SizedBox.shrink(),
    };
  }

  Widget _numberGrid(List<int> numbers) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: numbers.map((number) {
        final selected = snapshot.selectedNumbers.contains(number);
        return FilterChip(
          key: Key('episode-one-v3-number-$number'),
          selected: selected,
          onSelected: (_) => controller.toggleNumber(number),
          label: Text('$number'),
          avatar: Icon(
            selected ? Icons.auto_awesome : Icons.circle_outlined,
            size: 17,
          ),
        );
      }).toList(),
    );
  }

  Widget _simpleTextChoices(List<String> choices) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: choices.map((choice) {
        final selected = snapshot.selectedTexts.contains(choice);
        return FilterChip(
          key: Key('episode-one-v3-text-${choice.replaceAll('×', 'x')}'),
          selected: selected,
          onSelected: (_) => controller.toggleText(choice),
          label: Text(choice),
          avatar: Icon(
            selected ? Icons.link_rounded : Icons.link_off_rounded,
            size: 17,
          ),
        );
      }).toList(),
    );
  }

  Widget _textGrid(List<_TextOption> options) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: compact ? 132 : 126,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = snapshot.selectedTexts.contains(option.code);
        return InkWell(
          key: Key('episode-one-v3-option-${option.code}'),
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.toggleText(option.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFFFE8A8)
                  : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? const Color(0xFF8D6B1E)
                    : const Color(0xFFD8D2C4),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option.icon,
                  color: const Color(0xFF5B4C78),
                  size: compact ? 25 : 29,
                ),
                const SizedBox(height: 6),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF3D3350),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  option.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6D6475),
                    fontSize: 10.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _experimentButtons(
    List<int> values, {
    required int total,
    required String unit,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((valueToTest) {
        final tested = snapshot.testedValues.contains(valueToTest);
        final remainder = total % valueToTest;
        return OutlinedButton.icon(
          key: Key('episode-one-v3-test-$valueToTest'),
          onPressed: () => controller.testValue(valueToTest),
          icon: Icon(tested ? Icons.science_rounded : Icons.science_outlined),
          label: Text(
            tested
                ? '$valueToTest$unit · ${remainder == 0 ? '남지 않음' : '$remainder 남음'}'
                : '$valueToTest$unit 시험',
          ),
        );
      }).toList(),
    );
  }

  Widget _orderedNumberStage(List<int> candidates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SequenceDisplay(
          values: snapshot.orderedNumbers.map((value) => '$value').toList(),
          emptyText: '아직 놓은 별자리 조각이 없어요.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: candidates
              .map(
                (number) => ActionChip(
                  key: Key('episode-one-v3-order-number-$number'),
                  avatar: const Icon(Icons.auto_awesome_rounded, size: 17),
                  label: Text('$number'),
                  onPressed: () => controller.selectOrderedNumber(number),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _orderedGlyphStage() {
    const glyphs = [
      ('leaf', '잎', Icons.eco_rounded),
      ('drop', '물방울', Icons.water_drop_rounded),
      ('star', '별', Icons.star_rounded),
      ('moon', '달', Icons.nightlight_round),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SequenceDisplay(
          values: snapshot.orderedTexts
              .map((code) => _glyphLabel(code))
              .toList(),
          emptyText: '문양의 입력 순서를 찾아야 해요.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: glyphs
              .map(
                (glyph) => ActionChip(
                  key: Key('episode-one-v3-glyph-${glyph.$1}'),
                  avatar: Icon(glyph.$3, size: 18),
                  label: Text(glyph.$2),
                  onPressed: () => controller.selectOrderedText(glyph.$1),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _glyphLabel(String code) => switch (code) {
    'star' => '별',
    'moon' => '달',
    'leaf' => '잎',
    _ => '물방울',
  };

  Widget _falseRecordStage() {
    const records = [
      _TextOption(
        'A',
        '기록 A',
        '3개씩 놓으면 24개가 남지 않는다.',
        Icons.description_rounded,
      ),
      _TextOption('B', '기록 B', '3과 8을 곱하면 24가 된다.', Icons.description_rounded),
      _TextOption(
        'C',
        '기록 C',
        '5는 24보다 작으므로 잠금핀에 사용할 수 있다.',
        Icons.warning_amber_rounded,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _textGrid(records),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const Key('episode-one-v3-five-board'),
          onPressed: () => controller.testValue(5),
          icon: Icon(
            snapshot.testedValues.contains(5)
                ? Icons.check_circle_rounded
                : Icons.grid_view_rounded,
          ),
          label: Text(
            snapshot.testedValues.contains(5)
                ? '5칸 시험판: 씨앗 4개가 남음'
                : '선택한 기록을 5칸 시험판으로 검증',
          ),
        ),
      ],
    );
  }

  Widget _filterStage() {
    const tools = [
      _TextOption('dew', '물방울 렌즈', '젖은 흔적만 밝힌다.', Icons.water_drop_rounded),
      _TextOption(
        'stencil',
        '잎사귀 흔적틀',
        '발자국의 크기와 밑창을 비교한다.',
        Icons.filter_alt_rounded,
      ),
      _TextOption(
        'starlight',
        '별가루 조명',
        '오래된 씨앗 이동선을 드러낸다.',
        Icons.flashlight_on_rounded,
      ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tools.map((tool) {
        final selected = snapshot.activeFilters.contains(tool.code);
        return SizedBox(
          width: compact ? double.infinity : 230,
          child: FilterChip(
            key: Key('episode-one-v3-filter-${tool.code}'),
            selected: selected,
            onSelected: (_) => controller.toggleFilter(tool.code),
            avatar: Icon(tool.icon, size: 18),
            label: Text('${tool.label} · ${tool.detail}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _trackStartStage() {
    const starts = [
      (1, '빈 받침대 아래', '씨앗 이동선은 있지만 둥근 발자국은 없다.'),
      (2, '씨앗이 떨어진 지점', '이 지점 뒤에서 젖은 둥근 발자국이 시작한다.'),
      (3, '정원사 보관소 앞', '큰 장화 밑창 문양만 이어진다.'),
    ];
    return Column(
      children: starts
          .map(
            (start) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: _SingleChoiceCard(
                key: Key('episode-one-v3-start-${start.$1}'),
                selected: snapshot.selectedNumbers.contains(start.$1),
                title: start.$2,
                subtitle: start.$3,
                onTap: () => controller.toggleNumber(start.$1),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _trackNodeStage() {
    const nodes = [0, 4, 5, 6, 10, 12, 16, 18, 20, 24];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SequenceDisplay(
          values: snapshot.trackPath.map((value) => '$value번 돌').toList(),
          emptyText: '시작점부터 발자국을 하나씩 연결하세요.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: nodes.map((node) {
            final connected = snapshot.trackPath.contains(node);
            final wet = const {0, 6, 12, 18, 24}.contains(node);
            return ActionChip(
              key: Key('episode-one-v3-track-node-$node'),
              avatar: Icon(
                connected
                    ? Icons.pets_rounded
                    : wet
                    ? Icons.water_drop_rounded
                    : Icons.circle_outlined,
                size: 18,
              ),
              label: Text('$node번 ${wet ? '젖은 돌' : '마른 돌'}'),
              onPressed: () => controller.selectTrackNode(node),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _evidenceStage() {
    const cards = [
      ('seed', '씨앗이 오른쪽으로 밀려 바닥에 떨어졌다.'),
      ('wind', '강한 바람이 불어 바람종이 꺾였다.'),
      ('pond', '젖은 발자국이 연못 방향으로 이어졌다.'),
      ('piece', '받침대 오른쪽 조각이 떨어졌다.'),
      ('tracks', '씨앗 뒤에서 둥근 발자국이 시작됐다.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SequenceDisplay(
          values: snapshot.evidenceOrder
              .map((code) => cards.firstWhere((card) => card.$1 == code).$2)
              .toList(),
          emptyText: '원인이 되는 장면부터 카드를 놓으세요.',
        ),
        const SizedBox(height: 10),
        ...cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: OutlinedButton.icon(
              key: Key('episode-one-v3-evidence-${card.$1}'),
              onPressed: snapshot.evidenceOrder.contains(card.$1)
                  ? null
                  : () => controller.selectEvidenceCard(card.$1),
              icon: const Icon(Icons.view_timeline_rounded),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(card.$2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _conclusionStage() {
    const choices = [
      ('A', '작은 생물이 처음부터 씨앗을 훔쳤다.'),
      ('B', '씨앗이 먼저 떨어졌고 작은 생물이 그 뒤를 따라갔다.'),
      ('C', '바람이 씨앗을 하늘로 날려 보냈다.'),
    ];
    return Column(
      children: choices
          .map(
            (choice) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: _SingleChoiceCard(
                key: Key('episode-one-v3-conclusion-${choice.$1}'),
                selected: snapshot.selectedTexts.contains(choice.$1),
                title: '${choice.$1}. ${choice.$2}',
                onTap: () => controller.toggleText(choice.$1),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SingleChoiceCard extends StatelessWidget {
  const _SingleChoiceCard({
    super.key,
    required this.selected,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE8A8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF8D6B1E) : const Color(0xFFD8D2C4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: const Color(0xFF725A3D),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF3D3350),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF6D6475),
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextOption {
  const _TextOption(this.code, this.label, this.detail, this.icon);

  final String code;
  final String label;
  final String detail;
  final IconData icon;
}

class _RecordStrip extends StatelessWidget {
  const _RecordStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2CF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4B96F)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF54452E),
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SequenceDisplay extends StatelessWidget {
  const _SequenceDisplay({required this.values, required this.emptyText});

  final List<String> values;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: values.isEmpty
          ? Text(
              emptyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF746982),
                fontWeight: FontWeight.w700,
              ),
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (var index = 0; index < values.length; index++) ...[
                  Chip(label: Text(values[index])),
                  if (index < values.length - 1)
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: Color(0xFF806B9B),
                    ),
                ],
              ],
            ),
    );
  }
}

class _MessageBar extends StatelessWidget {
  const _MessageBar({required this.snapshot, required this.compact});

  final EpisodeOneV3Snapshot snapshot;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('episode-one-v3-message-bar'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 11 : 14,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xEC223540),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x5578DFC3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFFFFE39A), size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              snapshot.message,
              key: const Key('episode-one-v3-message'),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                snapshot.macroProgressLabel,
                style: const TextStyle(
                  color: Color(0xFFD8F5EC),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                snapshot.learningProgressLabel,
                key: const Key('episode-one-v3-learning-progress'),
                style: const TextStyle(
                  color: Color(0xFFFFE39A),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
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

  final EpisodeOneV3Controller controller;
  final EpisodeOneV3Snapshot snapshot;
  final bool savingReward;
  final bool rewardSaved;
  final String? rewardError;
  final Future<void> Function() onRetryReward;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('episode-one-v3-completion'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0C8), Color(0xFFE5F5EA)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 52,
            color: Color(0xFF80602B),
          ),
          const SizedBox(height: 10),
          const Text(
            'Episode 1 완료',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF3E3546),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '씨앗은 먼저 바람에 떨어졌고 작은 생물이 그 뒤를 따라 연못으로 이동했어요. 아직 범인이라고 단정할 수는 없어요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF62586A), height: 1.45),
          ),
          const SizedBox(height: 14),
          const _RewardLine(icon: Icons.stars_rounded, text: '경험치 +60'),
          const _RewardLine(icon: Icons.menu_book_rounded, text: '핵심 단서 6개 기록'),
          const _RewardLine(
            icon: Icons.lock_outline_rounded,
            text: 'Episode 2 · 연못의 잠긴 수문 예고',
          ),
          if (savingReward) ...[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ] else if (rewardError != null) ...[
            const SizedBox(height: 10),
            Text(
              rewardError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9B3F3F),
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(onPressed: onRetryReward, child: const Text('보상 다시 저장')),
          ] else if (rewardSaved) ...[
            const SizedBox(height: 8),
            const Text(
              '보상이 정원 기록에 저장됐어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3F7255),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (!snapshot.challengeCompleted && !snapshot.challengeOpen)
            OutlinedButton.icon(
              key: const Key('episode-one-v3-open-challenge'),
              onPressed: controller.openChallenge,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('정원사의 별도장 도전'),
            ),
          if (snapshot.challengeOpen) ...[
            const SizedBox(height: 8),
            const Text(
              '30의 약수를 모두 선택하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              alignment: WrapAlignment.center,
              children: const [1, 2, 3, 4, 5, 6, 10, 12, 15, 30]
                  .map(
                    (number) => _ChallengeNumber(
                      number: number,
                      controller: controller,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('episode-one-v3-submit-challenge'),
              onPressed: () => controller.submitChallenge(),
              child: const Text('별도장 확인'),
            ),
          ],
          if (snapshot.challengeCompleted) ...[
            const SizedBox(height: 8),
            const Text(
              '정원사의 별도장을 완성했어요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF765A23),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('episode-one-v3-return-home'),
            onPressed: onReturnHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('정원으로 돌아가기'),
          ),
        ],
      ),
    );
  }
}

class _ChallengeNumber extends StatelessWidget {
  const _ChallengeNumber({required this.number, required this.controller});

  final int number;
  final EpisodeOneV3Controller controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EpisodeOneV3Snapshot>(
      valueListenable: controller,
      builder: (context, snapshot, _) {
        return FilterChip(
          key: Key('episode-one-v3-challenge-$number'),
          selected: snapshot.selectedNumbers.contains(number),
          onSelected: (_) => controller.toggleNumber(number),
          label: Text('$number'),
        );
      },
    );
  }
}

class _RewardLine extends StatelessWidget {
  const _RewardLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF77602C), size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF53495B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
