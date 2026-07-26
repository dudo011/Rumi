import 'package:flutter/material.dart';

import '../../core/storage/progress_store.dart';
import 'math_question.dart';
import 'question_bank.dart';

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({
    super.key,
    this.store = const ProgressStore(),
    this.questions = divisorMultipleQuestions,
  });

  final ProgressStore store;
  final List<MathQuestion> questions;

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  late final List<MathQuestion> _sessionQuestions;
  int _questionIndex = 0;
  int _correctCount = 0;
  int _hintLevel = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _saving = false;

  MathQuestion get _question => _sessionQuestions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _sessionQuestions = widget.questions.take(5).toList(growable: false);
    assert(_sessionQuestions.isNotEmpty, 'At least one question is required.');
  }

  void _selectAnswer(int index) {
    if (_answered) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _checkAnswer() {
    final selectedIndex = _selectedIndex;
    if (selectedIndex == null || _answered) {
      return;
    }
    setState(() {
      _answered = true;
      if (selectedIndex == _question.correctIndex) {
        _correctCount++;
      }
    });
  }

  void _showHint() {
    if (_answered || _hintLevel >= _question.hints.length) {
      return;
    }
    setState(() => _hintLevel++);
  }

  Future<void> _nextQuestion() async {
    if (_questionIndex < _sessionQuestions.length - 1) {
      setState(() {
        _questionIndex++;
        _hintLevel = 0;
        _selectedIndex = null;
        _answered = false;
      });
      return;
    }
    setState(() => _saving = true);
    final earnedExperience = 20 + (_correctCount * 10);
    final progress = await widget.store.completeAdventure(
      earnedExperience: earnedExperience,
    );
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => AdventureResultScreen(
          correctCount: _correctCount,
          totalCount: _sessionQuestions.length,
          earnedExperience: earnedExperience,
          gardenLevel: progress.gardenLevel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = _selectedIndex == _question.correctIndex;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF49385F),
        elevation: 0,
        title: const Text('오늘의 모험', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_questionIndex + 1) / _sessionQuestions.length,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF8064B5),
                          backgroundColor: const Color(0xFFE5DCEC),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text('${_questionIndex + 1}/${_sessionQuestions.length}', style: const TextStyle(color: Color(0xFF685D72), fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                    child: Column(
                      children: [
                        const Icon(Icons.local_florist_rounded, color: Color(0xFFD4729A), size: 42),
                        const SizedBox(height: 16),
                        Text(_question.prompt, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF382C4D), fontSize: 24, height: 1.4, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (var index = 0; index < _question.options.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AnswerOption(
                        label: _question.options[index],
                        index: index,
                        selectedIndex: _selectedIndex,
                        correctIndex: _question.correctIndex,
                        answered: _answered,
                        onTap: () => _selectAnswer(index),
                      ),
                    ),
                  if (_hintLevel > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFFFF4CE), borderRadius: BorderRadius.circular(18)),
                      child: Text('💡 ${_question.hints[_hintLevel - 1]}', style: const TextStyle(color: Color(0xFF68572D), fontSize: 15, height: 1.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  if (_answered) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isCorrect ? const Color(0xFFE5F5E6) : const Color(0xFFFFE9EF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isCorrect ? '멋져요! 용기 있게 풀어냈어요.' : '괜찮아요! 도전한 마음이 정원을 키워요.', style: TextStyle(color: isCorrect ? const Color(0xFF397245) : const Color(0xFF9A4960), fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 7),
                          Text(_question.explanation, style: const TextStyle(color: Color(0xFF645B69), height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (!_answered)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _hintLevel < _question.hints.length ? _showHint : null,
                            icon: const Icon(Icons.lightbulb_outline_rounded),
                            label: Text(_hintLevel == 0 ? '힌트 보기' : '힌트 한 번 더'),
                          ),
                        ),
                      if (!_answered) const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving
                              ? null
                              : _answered
                                  ? _nextQuestion
                                  : _selectedIndex == null
                                      ? null
                                      : _checkAnswer,
                          child: Text(_saving ? '저장 중...' : _answered ? (_questionIndex == _sessionQuestions.length - 1 ? '모험 완료' : '다음 문제') : '정답 확인'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({required this.label, required this.index, required this.selectedIndex, required this.correctIndex, required this.answered, required this.onTap});

  final String label;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    final correct = answered && index == correctIndex;
    final incorrect = answered && selected && !correct;
    final color = correct ? const Color(0xFF5B9D67) : incorrect ? const Color(0xFFD76D89) : selected ? const Color(0xFF8064B5) : const Color(0xFFDCD3E3);
    return Material(
      color: correct ? const Color(0xFFE8F7E9) : incorrect ? const Color(0xFFFFE9EF) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: answered ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: color, width: selected || correct ? 2 : 1.2)),
          child: Row(
            children: [
              CircleAvatar(radius: 15, backgroundColor: color, foregroundColor: Colors.white, child: Text('${index + 1}')),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF44384F), fontSize: 17, fontWeight: FontWeight.w700))),
              if (correct) const Icon(Icons.check_circle_rounded, color: Color(0xFF4D945B)),
            ],
          ),
        ),
      ),
    );
  }
}

class AdventureResultScreen extends StatelessWidget {
  const AdventureResultScreen({required this.correctCount, required this.totalCount, required this.earnedExperience, required this.gardenLevel, super.key});

  final int correctCount;
  final int totalCount;
  final int earnedExperience;
  final int gardenLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB94D), size: 96),
                  const SizedBox(height: 24),
                  const Text('오늘의 모험 완료!', style: TextStyle(color: Color(0xFF3E3155), fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text('끝까지 해낸 용기가 정말 반짝여요.', style: TextStyle(color: Color(0xFF756A7E), fontSize: 17)),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultValue(label: '정답', value: '$correctCount/$totalCount'),
                        _ResultValue(label: '경험치', value: '+$earnedExperience XP'),
                        _ResultValue(label: '꽃숲', value: '$gardenLevel단계'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('별정원으로 돌아가기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultValue extends StatelessWidget {
  const _ResultValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: const TextStyle(color: Color(0xFF6F54A7), fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(label, style: const TextStyle(color: Color(0xFF817788)))]);
  }
}
