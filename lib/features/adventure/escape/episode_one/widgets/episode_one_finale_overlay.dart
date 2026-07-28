import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/storage/progress_store.dart';
import '../episode_one_state.dart';

enum _FinaleStage { deduction, blooming, saveError, ending }

class EpisodeOneFinaleOverlay extends StatefulWidget {
  const EpisodeOneFinaleOverlay({
    required this.controller,
    required this.store,
    required this.onReturnToGarden,
    super.key,
  });

  final EpisodeOneStateController controller;
  final ProgressStore store;
  final VoidCallback onReturnToGarden;

  @override
  State<EpisodeOneFinaleOverlay> createState() =>
      _EpisodeOneFinaleOverlayState();
}

class _EpisodeOneFinaleOverlayState extends State<EpisodeOneFinaleOverlay> {
  static const _hypotheses = [
    '포포가 바람이 불기 전에 씨앗을 몰래 가져갔다.',
    '은하 바람이 씨앗을 떨어뜨렸고, 포포가 뒤따라가 따뜻한 온실에서 보호했다.',
    '꽃루미가 씨앗을 옮겼고 바람이 모든 흔적을 만들었다.',
  ];

  _FinaleStage _stage = _FinaleStage.deduction;
  int? _selectedHypothesis;
  bool _checked = false;
  bool _saving = false;
  bool _animationFinished = false;
  bool _canSkip = false;
  PlayerProgress? _progress;
  String? _saveError;
  Timer? _skipTimer;

  bool get _correct => _selectedHypothesis == 1;

  @override
  void dispose() {
    _skipTimer?.cancel();
    super.dispose();
  }

  void _selectHypothesis(int index) {
    if (_checked || _saving) return;
    setState(() => _selectedHypothesis = index);
  }

  void _handleDeductionAction() {
    if (_selectedHypothesis == null || _saving) return;

    if (!_checked) {
      setState(() => _checked = true);
      return;
    }

    if (!_correct) {
      setState(() {
        _selectedHypothesis = null;
        _checked = false;
      });
      return;
    }

    _startFinale();
  }

  void _startFinale() {
    if (_stage != _FinaleStage.deduction || _saving) return;

    setState(() {
      _stage = _FinaleStage.blooming;
      _saving = true;
      _animationFinished = false;
      _canSkip = false;
      _saveError = null;
    });

    _skipTimer?.cancel();
    _skipTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _stage == _FinaleStage.blooming) {
        setState(() => _canSkip = true);
      }
    });

    _recordCompletion();
  }

  Future<void> _recordCompletion() async {
    try {
      final progress = await widget.store.completeAdventure(
        earnedExperience: 110,
      );
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _saving = false;
      });
      _finishBloomingWhenReady();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = '완료 기록을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.';
      });
      _finishBloomingWhenReady();
    }
  }

  void _markAnimationFinished() {
    if (_animationFinished) return;
    setState(() => _animationFinished = true);
    _finishBloomingWhenReady();
  }

  void _finishBloomingWhenReady() {
    if (!mounted || !_animationFinished || _saving) return;
    setState(() {
      _stage = _saveError == null
          ? _FinaleStage.ending
          : _FinaleStage.saveError;
    });
  }

  void _retrySaving() {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    _recordCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EpisodeOneSnapshot>(
      valueListenable: widget.controller,
      builder: (context, snapshot, _) {
        if (!snapshot.seedFound) return const SizedBox.shrink();

        return Material(
          key: const Key('episode-one-finale-overlay'),
          color: const Color(0xFF101B27),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: switch (_stage) {
                _FinaleStage.deduction => _buildDeduction(snapshot),
                _FinaleStage.blooming => _buildBlooming(),
                _FinaleStage.saveError => _buildSaveError(),
                _FinaleStage.ending => _buildEnding(),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeduction(EpisodeOneSnapshot snapshot) {
    return _FinalePage(
      key: const Key('episode-one-final-deduction'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Heading(
            eyebrow: '최종 추리 · 핵심 증거 3/3',
            title: '별빛 씨앗은 왜 사라졌을까요?',
            subtitle: '한 가지 흔적만 보고 누군가를 의심하지 말고, 사건의 순서를 모두 연결해 보세요.',
          ),
          const SizedBox(height: 18),
          _EvidenceCard(
            key: const Key('episode-one-finale-evidence-1'),
            number: '1',
            icon: Icons.air_rounded,
            title: '옆으로 이어진 긁힘과 별가루',
            text: '씨앗이 위로 들린 자국은 없고, 강한 바람 방향으로 길게 밀려났어요.',
            confirmed: snapshot.pedestalSolved,
          ),
          const SizedBox(height: 10),
          _EvidenceCard(
            key: const Key('episode-one-finale-evidence-2'),
            number: '2',
            icon: Icons.pets_rounded,
            title: '바람 뒤의 젖은 발자국과 은빛 털',
            text: '포포의 흔적은 바람 자국 위에 남았고 씨앗을 따라 온실로 이어졌어요.',
            confirmed: snapshot.pondSolved && snapshot.fountainSolved,
          ),
          const SizedBox(height: 10),
          _EvidenceCard(
            key: const Key('episode-one-finale-evidence-3'),
            number: '3',
            icon: Icons.local_florist_rounded,
            title: '따뜻한 이끼와 감싼 씨앗',
            text: '씨앗은 잎에 감싸져 있었고 포포가 따뜻한 이끼 곁을 지키고 있었어요.',
            confirmed: snapshot.seedFound,
          ),
          const SizedBox(height: 22),
          const Text(
            '세 증거를 가장 잘 설명하는 이야기를 선택하세요.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < _hypotheses.length; index++) ...[
            _HypothesisTile(
              key: Key('episode-one-hypothesis-$index'),
              index: index,
              label: _hypotheses[index],
              selected: _selectedHypothesis == index,
              checked: _checked,
              correct: index == 1,
              onTap: () => _selectHypothesis(index),
            ),
            if (index != _hypotheses.length - 1) const SizedBox(height: 10),
          ],
          if (_checked) ...[
            const SizedBox(height: 14),
            _FeedbackCard(correct: _correct, text: _feedbackForSelection()),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('episode-one-deduction-action'),
            onPressed: _selectedHypothesis == null
                ? null
                : _handleDeductionAction,
            icon: Icon(
              _checked && _correct
                  ? Icons.local_florist_rounded
                  : Icons.fact_check_rounded,
            ),
            label: Text(
              !_checked
                  ? '증거와 비교하기'
                  : _correct
                  ? '씨앗을 받침대로 돌려보내기'
                  : '단서 보고 다시 생각하기',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  String _feedbackForSelection() {
    if (_correct) {
      return '세 증거가 모두 연결돼요. 바람이 씨앗을 떨어뜨렸고, 포포는 차가워진 씨앗을 온실로 옮겨 보호했어요.';
    }
    if (_selectedHypothesis == 0) {
      return '젖은 발자국은 바람 자국 위에 남아 있어요. 포포는 바람이 분 뒤에 씨앗을 따라갔어요.';
    }
    return '둥근 발자국과 은빛 털은 포포의 이동을 보여줘요. 꽃루미가 옮겼다는 증거는 없어요.';
  }

  Widget _buildBlooming() {
    return TweenAnimationBuilder<double>(
      key: const Key('episode-one-finale-blooming'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 3200),
      onEnd: _markAnimationFinished,
      builder: (context, value, _) {
        final flowerProgress = ((value - 0.45) / 0.55)
            .clamp(0.0, 1.0)
            .toDouble();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(
                  const Color(0xFF1B2940),
                  const Color(0xFF65528A),
                  value,
                )!,
                Color.lerp(
                  const Color(0xFF17372F),
                  const Color(0xFF52866B),
                  value,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -120 * (1 - value)),
                      child: Transform.scale(
                        scale: 0.65 + value * 0.35,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFF4B8),
                                Color.lerp(
                                  const Color(0xFFFFC7DD),
                                  const Color(0xFFB9F0D5),
                                  flowerProgress,
                                )!,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFE39A,
                                ).withValues(alpha: 0.35 + value * 0.5),
                                blurRadius: 30 + value * 30,
                                spreadRadius: 4 + value * 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            flowerProgress > 0.45
                                ? Icons.local_florist_rounded
                                : Icons.grain_rounded,
                            size: 82 + flowerProgress * 22,
                            color: const Color(0xFF75528F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      flowerProgress > 0.65
                          ? '별빛 꽃이 피었어요!'
                          : value > 0.35
                          ? '받침대의 세 고리가 빛나고 있어요.'
                          : '별빛 씨앗이 중앙 정원으로 돌아가요.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _saving ? '모험 완료 기록을 안전하게 저장하고 있어요.' : '완료 기록을 저장했어요.',
                      style: const TextStyle(
                        color: Color(0xFFD9ECE5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (_canSkip)
                Positioned(
                  right: 16,
                  top: 12,
                  child: TextButton.icon(
                    key: const Key('episode-one-skip-finale-animation'),
                    onPressed: _markAnimationFinished,
                    icon: const Icon(Icons.fast_forward_rounded),
                    label: const Text('연출 건너뛰기'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveError() {
    return _FinalePage(
      key: const Key('episode-one-finale-save-error'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFFFD7A3),
            size: 70,
          ),
          const SizedBox(height: 18),
          const Text(
            '별빛 꽃은 안전해요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _saveError ?? '완료 기록을 저장하지 못했어요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDCE9E5),
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('episode-one-retry-save'),
              onPressed: _saving ? null : _retrySaving,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_saving ? '저장 중...' : '완료 기록 다시 저장'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnding() {
    final progress = _progress;
    return _FinalePage(
      key: const Key('episode-one-finale-ending'),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFFFF4B8), Color(0xFFFFCBE2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x99FFE39A),
                  blurRadius: 42,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: Color(0xFF75528F),
              size: 82,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Episode 1 사건 해결!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '별빛 꽃이 다시 중앙 정원을 환하게 밝혔어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFDCE9E5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          const _DialogueCard(
            speaker: '포포',
            icon: Icons.pets_rounded,
            message: '차가운 바람에 씨앗이 떨어졌어. 얼어붙을까 봐 달빛 이끼로 옮겼는데 먼저 알려주지 못해서 미안해.',
          ),
          const SizedBox(height: 10),
          const _DialogueCard(
            speaker: '꽃루미',
            icon: Icons.local_florist_rounded,
            message: '별지기가 누구도 함부로 의심하지 않고 세 증거를 끝까지 연결해서 포포의 진짜 마음을 알아냈어!',
          ),
          const SizedBox(height: 18),
          Container(
            key: const Key('episode-one-finale-reward'),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0BE), Color(0xFFFFDCEB)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  '새로운 꽃을 발견했어요',
                  style: TextStyle(
                    color: Color(0xFF795833),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '✨ 별빛 꽃 ✨',
                  style: TextStyle(
                    color: Color(0xFF5D416D),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '핵심 증거 3개 · P0~P5 해결 · +110 XP${progress == null ? '' : ' · 꽃숲 ${progress.gardenLevel}단계'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF755F69),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '완료한 모험 ${progress.completedAdventures}회 · 누적 ${progress.experience} XP',
                    key: const Key('episode-one-finale-progress-record'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF795F6C),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0x553A4D59),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x5578DFC3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFFFE39A),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '별빛 꽃이 피는 순간, 꽃숲 깊은 곳에서 아무도 건드리지 않은 작은 별종이 한 번 울렸어요. 누가 새로운 도움을 요청하는 걸까요?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('episode-one-return-home'),
              onPressed: widget.onReturnToGarden,
              icon: const Icon(Icons.park_rounded),
              label: const Text(
                '별정원으로 돌아가기',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalePage extends StatelessWidget {
  const _FinalePage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF31274B), Color(0xFF16372F), Color(0xFF0E1B25)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 34),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFFFFD96A),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            height: 1.25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFFDCE9E5),
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
    required this.confirmed,
    super.key,
  });

  final String number;
  final IconData icon;
  final String title;
  final String text;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: confirmed ? const Color(0x554A8A78) : const Color(0x443C4651),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: confirmed ? const Color(0xFF9BE7D0) : const Color(0x556E817E),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: confirmed
                ? const Color(0xFFFFE39A)
                : const Color(0xFF65726F),
            foregroundColor: const Color(0xFF302440),
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFFFFD96A), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFFDCE9E5),
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (confirmed)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF9BE7D0)),
        ],
      ),
    );
  }
}

class _HypothesisTile extends StatelessWidget {
  const _HypothesisTile({
    required this.index,
    required this.label,
    required this.selected,
    required this.checked,
    required this.correct,
    required this.onTap,
    super.key,
  });

  final int index;
  final String label;
  final bool selected;
  final bool checked;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showCorrect = checked && correct;
    final showWrong = checked && selected && !correct;

    return Semantics(
      button: true,
      selected: selected,
      label: '가설 ${index + 1}, $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: checked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: showCorrect
                ? const Color(0x6653C8A9)
                : showWrong
                ? const Color(0x666A4557)
                : selected
                ? const Color(0x665C4D7D)
                : const Color(0x443B4D59),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: showCorrect
                  ? const Color(0xFF9BE7D0)
                  : showWrong
                  ? const Color(0xFFFFB5C9)
                  : selected
                  ? const Color(0xFFFFE39A)
                  : const Color(0x5578DFC3),
              width: selected || showCorrect ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: selected
                    ? const Color(0xFFFFE39A)
                    : const Color(0xFF53636B),
                foregroundColor: const Color(0xFF302440),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (showCorrect)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF9BE7D0))
              else if (showWrong)
                const Icon(Icons.help_rounded, color: Color(0xFFFFC2D2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.correct, required this.text});

  final bool correct;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(
        correct
            ? 'episode-one-deduction-correct'
            : 'episode-one-deduction-wrong',
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? const Color(0x6653C8A9) : const Color(0x665A4557),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: correct ? const Color(0xFF9BE7D0) : const Color(0xFFFFC2D2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.lightbulb_rounded : Icons.menu_book_rounded,
            color: correct ? const Color(0xFFFFE39A) : const Color(0xFFFFC2D2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                height: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogueCard extends StatelessWidget {
  const _DialogueCard({
    required this.speaker,
    required this.icon,
    required this.message,
  });

  final String speaker;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x553A4D59),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x5578DFC3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFE39A),
            foregroundColor: const Color(0xFF5A456A),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker,
                  style: const TextStyle(
                    color: Color(0xFFFFE39A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
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
