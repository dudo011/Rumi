import 'package:flutter/material.dart';

import '../../core/storage/progress_store.dart';
import 'math_question.dart';

enum _EpisodeStage { intro, investigation, map, puzzle, notebook, deduction, ending }

enum _Location { pond, forest, greenhouse }

class StarlightSeedEpisodeScreen extends StatefulWidget {
  const StarlightSeedEpisodeScreen({super.key, this.store = const ProgressStore()});

  final ProgressStore store;

  @override
  State<StarlightSeedEpisodeScreen> createState() => _StarlightSeedEpisodeScreenState();
}

class _StarlightSeedEpisodeScreenState extends State<StarlightSeedEpisodeScreen> {
  _EpisodeStage _stage = _EpisodeStage.intro;
  int _introPage = 0;
  final Set<int> _inspected = {};
  final Set<_Location> _completedLocations = {};
  _Location? _location;
  int _greenhousePuzzle = 0;
  int? _selectedAnswer;
  int _hintLevel = 0;
  bool _answered = false;
  int _deductionIndex = 0;
  bool _saving = false;
  int _gardenLevel = 1;

  static const _questions = <_Location, List<MathQuestion>>{
    _Location.pond: [
      MathQuestion(
        prompt: '별가루 24개를 남김없이 똑같이 나누어 담을 수 있는 바구니 수는?',
        options: ['5개', '6개', '7개', '9개'],
        correctIndex: 1,
        hints: ['24를 각 바구니 수로 나누어 보세요. 별가루가 남으면 안 돼요.', '6개의 바구니에는 별가루를 4개씩 담을 수 있어요.'],
        explanation: '24 ÷ 6 = 4이므로 6은 24의 약수예요. 반짝이는 별가루가 진짜 발자국을 비췄어요!',
      ),
    ],
    _Location.forest: [
      MathQuestion(
        prompt: '파란 꽃은 4분마다, 노란 꽃은 6분마다 열려요. 두 꽃이 다시 함께 열리는 것은 몇 분 뒤일까요?',
        options: ['8분', '10분', '12분', '24분'],
        correctIndex: 2,
        hints: ['4의 배수와 6의 배수를 차례로 찾아보세요.', '4의 배수는 4, 8, 12…이고 6의 배수는 6, 12…예요.'],
        explanation: '두 배수에서 처음 함께 나타나는 수는 12예요. 바로 그때 강한 은하 바람이 온실 쪽으로 불었어요!',
      ),
    ],
    _Location.greenhouse: [
      MathQuestion(
        prompt: '별 문양 18개와 달 문양 24개를 남김없이 똑같이 나누어 가장 많은 장식판을 만들면 몇 개일까요?',
        options: ['3개', '6개', '8개', '12개'],
        correctIndex: 1,
        hints: ['18과 24를 모두 남김없이 나눌 수 있는 가장 큰 수를 찾아보세요.', '6개로 나누면 장식판마다 별 3개와 달 4개가 들어가요.'],
        explanation: '18과 24의 최대공약수는 6이에요. 여섯 장식판이 빛나며 온실 문이 열렸어요!',
      ),
      MathQuestion(
        prompt: '24의 약수이면서 6의 배수이고, 10보다 크고 20보다 작은 화분 번호는?',
        options: ['6번', '8번', '12번', '18번'],
        correctIndex: 2,
        hints: ['조건을 하나씩 적용해 후보를 줄여보세요.', '24의 약수 중 6의 배수는 6과 12예요. 둘 중 10보다 큰 수는 무엇일까요?'],
        explanation: '모든 조건을 만족하는 것은 12예요. 화분 속에서 따뜻한 달빛 이끼와 별빛 씨앗을 찾았어요!',
      ),
    ],
  };

  MathQuestion get _question => _questions[_location]![_location == _Location.greenhouse ? _greenhousePuzzle : 0];

  void _nextIntro() {
    if (_introPage < 2) {
      setState(() => _introPage++);
    } else {
      setState(() => _stage = _EpisodeStage.investigation);
    }
  }

  void _inspect(int index) {
    setState(() => _inspected.add(index));
  }

  void _openLocation(_Location location) {
    final greenhouseLocked = location == _Location.greenhouse &&
        !(_completedLocations.contains(_Location.pond) && _completedLocations.contains(_Location.forest));
    if (greenhouseLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연못과 시계꽃 숲의 단서를 먼저 찾아보세요.')),
      );
      return;
    }
    setState(() {
      _location = location;
      _stage = _EpisodeStage.puzzle;
      _greenhousePuzzle = 0;
      _resetAnswer();
    });
  }

  void _resetAnswer() {
    _selectedAnswer = null;
    _hintLevel = 0;
    _answered = false;
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) return;
    setState(() => _answered = true);
  }

  void _continueAfterAnswer() {
    if (_selectedAnswer != _question.correctIndex) {
      setState(() {
        _answered = false;
        _selectedAnswer = null;
        if (_hintLevel < _question.hints.length) _hintLevel++;
      });
      return;
    }
    if (_location == _Location.greenhouse && _greenhousePuzzle == 0) {
      setState(() {
        _greenhousePuzzle = 1;
        _resetAnswer();
      });
      return;
    }
    setState(() {
      _completedLocations.add(_location!);
      if (_location == _Location.greenhouse) {
        _stage = _EpisodeStage.notebook;
      } else {
        _stage = _EpisodeStage.map;
      }
      _location = null;
      _resetAnswer();
    });
  }

  Future<void> _finishEpisode() async {
    if (_saving) return;
    setState(() => _saving = true);
    final progress = await widget.store.completeAdventure(earnedExperience: 110);
    if (!mounted) return;
    setState(() {
      _gardenLevel = progress.gardenLevel;
      _saving = false;
      _stage = _EpisodeStage.ending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF463755),
        elevation: 0,
        title: const Text('사라진 별빛 씨앗', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStage(),
        ),
      ),
    );
  }

  Widget _buildStage() {
    return switch (_stage) {
      _EpisodeStage.intro => _buildIntro(),
      _EpisodeStage.investigation => _buildInvestigation(),
      _EpisodeStage.map => _buildMap(),
      _EpisodeStage.puzzle => _buildPuzzle(),
      _EpisodeStage.notebook => _buildNotebook(),
      _EpisodeStage.deduction => _buildDeduction(),
      _EpisodeStage.ending => _buildEnding(),
    };
  }

  Widget _page({required Widget child}) {
    return SingleChildScrollView(
      key: ValueKey('${_stage.name}-$_introPage-${_location?.name}-$_greenhousePuzzle-$_deductionIndex'),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: child)),
    );
  }

  Widget _buildIntro() {
    const titles = ['오늘은 특별한 날', '거센 은하 바람', '씨앗이 사라졌어!'];
    const messages = [
      '오늘 밤 별빛 씨앗에서 커다란 별빛 꽃이 피어날 거야. 그 빛은 길을 잃은 작은 정령들을 집으로 안내해 줘.',
      '잠시 자리를 비운 사이, 별정원에 차갑고 강한 바람이 지나갔어. 무슨 소리가 들린 것 같기도 해.',
      '별받침대가 비어 있어! 오늘 밤이 오기 전에 씨앗을 찾아야 해. 서두르기 전에 주변부터 천천히 살펴보자.',
    ];
    final icons = [Icons.local_florist_rounded, Icons.air_rounded, Icons.search_rounded];
    return _page(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _HeroOrb(icon: icons[_introPage], danger: _introPage == 2),
          const SizedBox(height: 30),
          Text(titles[_introPage], textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3F3153), fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _DialogueCard(speaker: '꽃루미', message: messages[_introPage]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextIntro,
              child: Text(_introPage == 2 ? '주변 조사하기' : '계속'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigation() {
    const items = [
      (Icons.blur_on_rounded, '빈 별받침대', '씨앗이 오른쪽으로 밀린 듯한 긴 긁힌 자국이 있어.'),
      (Icons.pets_rounded, '작은 발자국', '보리와 비슷한 발자국이지만, 지나갔다는 것만으로 훔쳤다고 할 수는 없어.'),
      (Icons.air_rounded, '은빛 털과 잎', '울타리에 은빛 털과 바람에 꺾인 잎이 함께 걸려 있어.'),
    ];
    return _page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(eyebrow: '사건 현장', title: '반짝이는 곳을 눌러 조사해요', subtitle: '흔적을 모두 확인해도 아직 범인을 정하지 마세요.'),
          const SizedBox(height: 20),
          for (var index = 0; index < items.length; index++) ...[
            _InvestigationTile(
              icon: items[index].$1,
              title: items[index].$2,
              detail: items[index].$3,
              inspected: _inspected.contains(index),
              onTap: () => _inspect(index),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _inspected.length == 3 ? () => setState(() => _stage = _EpisodeStage.map) : null,
            icon: const Icon(Icons.map_rounded),
            label: Text(_inspected.length == 3 ? '탐험 지도 펼치기' : '흔적 ${_inspected.length}/3'),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final greenhouseUnlocked = _completedLocations.contains(_Location.pond) && _completedLocations.contains(_Location.forest);
    return _page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(
            eyebrow: '별정원 탐험 지도',
            title: '어디부터 살펴볼까요?',
            subtitle: '찾은 단서 ${_completedLocations.length}/3 · 연못과 숲은 원하는 순서로 탐험할 수 있어요.',
          ),
          const SizedBox(height: 22),
          _LocationCard(
            icon: Icons.water_rounded,
            color: const Color(0xFF4E9DB3),
            title: '반짝이는 연못',
            subtitle: '뒤섞인 발자국의 방향을 찾아요',
            completed: _completedLocations.contains(_Location.pond),
            onTap: () => _openLocation(_Location.pond),
          ),
          const SizedBox(height: 14),
          _LocationCard(
            icon: Icons.access_time_filled_rounded,
            color: const Color(0xFFD08653),
            title: '시계꽃 숲',
            subtitle: '은하 바람이 분 시간을 알아내요',
            completed: _completedLocations.contains(_Location.forest),
            onTap: () => _openLocation(_Location.forest),
          ),
          const SizedBox(height: 14),
          _LocationCard(
            icon: greenhouseUnlocked ? Icons.cottage_rounded : Icons.lock_rounded,
            color: const Color(0xFF8260A7),
            title: '달빛 온실',
            subtitle: greenhouseUnlocked ? '두 단서가 모두 이곳을 가리켜요' : '연못과 숲의 단서가 필요해요',
            completed: _completedLocations.contains(_Location.greenhouse),
            locked: !greenhouseUnlocked,
            onTap: () => _openLocation(_Location.greenhouse),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzle() {
    final location = _location!;
    final details = switch (location) {
      _Location.pond => ('반짝이는 연못', '포롱', '별가루를 똑같이 나누면 진짜 발자국이 다시 빛날 거야!'),
      _Location.forest => ('시계꽃 숲', '바람정령 소소', '두 시계꽃이 함께 열린 순간에 아주 강한 바람이 불었어.'),
      _Location.greenhouse => _greenhousePuzzle == 0
          ? ('달빛 온실', '꽃루미', '별과 달 문양을 똑같이 나누면 잠긴 문을 열 수 있을 것 같아.')
          : ('온실 안쪽', '꽃루미', '희미한 빛이 네 개의 화분 사이를 오가고 있어. 조건에 맞는 화분을 찾자!'),
    };
    final isCorrect = _selectedAnswer == _question.correctIndex;
    return _page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(eyebrow: details.$1, title: details.$2, subtitle: details.$3),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26)),
            child: Text(_question.prompt, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3C304B), fontSize: 21, height: 1.4, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < _question.options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerTile(
                label: _question.options[index],
                selected: _selectedAnswer == index,
                correct: _answered && index == _question.correctIndex,
                wrong: _answered && _selectedAnswer == index && index != _question.correctIndex,
                onTap: _answered ? null : () => setState(() => _selectedAnswer = index),
              ),
            ),
          if (_hintLevel > 0) _HintCard(text: _question.hints[_hintLevel - 1]),
          if (_answered) ...[
            const SizedBox(height: 8),
            _FeedbackCard(
              correct: isCorrect,
              text: isCorrect ? _question.explanation : '괜찮아요. 관련 단서를 다시 보고 한 번 더 생각해 봐요.',
            ),
          ],
          const SizedBox(height: 18),
          if (!_answered)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _hintLevel < _question.hints.length ? () => setState(() => _hintLevel++) : null,
                    icon: const Icon(Icons.lightbulb_outline_rounded),
                    label: Text(_hintLevel == 0 ? '힌트 보기' : '힌트 한 번 더'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: _selectedAnswer == null ? null : _checkAnswer, child: const Text('단서 확인'))),
              ],
            )
          else
            FilledButton(
              onPressed: _continueAfterAnswer,
              child: Text(isCorrect ? (_location == _Location.greenhouse && _greenhousePuzzle == 0 ? '온실 안으로' : '단서 챙기기') : '단서 보고 다시 풀기'),
            ),
        ],
      ),
    );
  }

  Widget _buildNotebook() {
    return _page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(eyebrow: '단서 수첩 · 3/3', title: '사건의 순서가 보이기 시작해요', subtitle: '세 단서를 시간 순서대로 연결해 진짜 이야기를 확인해요.'),
          const SizedBox(height: 22),
          const _ClueCard(number: '1', icon: Icons.air_rounded, title: '차가운 은하 바람', text: '강한 바람이 씨앗을 받침대에서 온실 방향으로 밀었어요.'),
          const _Connector(),
          const _ClueCard(number: '2', icon: Icons.pets_rounded, title: '작고 둥근 발자국', text: '보리와 비슷한 발자국이 떨어진 씨앗을 따라 온실로 향했어요.'),
          const _Connector(),
          const _ClueCard(number: '3', icon: Icons.local_florist_rounded, title: '따뜻한 별무늬 화분', text: '보리는 차가워진 씨앗을 달빛 이끼 위에 보호해 두었어요.'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => setState(() => _stage = _EpisodeStage.deduction),
            icon: const Icon(Icons.psychology_alt_rounded),
            label: const Text('사건 해결하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeduction() {
    const prompts = [
      '별빛 씨앗이 받침대에서 사라진 첫 번째 원인은?',
      '보리는 왜 별빛 씨앗을 온실로 옮겼을까요?',
      '별빛 씨앗이 발견된 곳은 어디일까요?',
    ];
    const options = [
      ['보리가 몰래 가져갔다', '강한 은하 바람에 떨어졌다', '꽃루미가 옮겼다'],
      ['혼자 꽃을 키우려고', '꽃루미를 놀라게 하려고', '추위로부터 보호하려고'],
      ['반짝이는 연못 아래', '달빛 온실의 12번 화분', '시계꽃 숲 나무 위'],
    ];
    const correct = [1, 2, 1];
    final isCorrect = _selectedAnswer == correct[_deductionIndex];
    return _page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(eyebrow: '최종 추리 ${_deductionIndex + 1}/3', title: prompts[_deductionIndex], subtitle: '느낌보다 우리가 찾은 단서를 떠올려 보세요.'),
          const SizedBox(height: 22),
          for (var index = 0; index < options[_deductionIndex].length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnswerTile(
                label: options[_deductionIndex][index],
                selected: _selectedAnswer == index,
                correct: _answered && index == correct[_deductionIndex],
                wrong: _answered && _selectedAnswer == index && index != correct[_deductionIndex],
                onTap: _answered ? null : () => setState(() => _selectedAnswer = index),
              ),
            ),
          if (_answered) ...[
            const SizedBox(height: 4),
            _FeedbackCard(
              correct: isCorrect,
              text: isCorrect ? '단서를 정확하게 연결했어요!' : '그렇게 생각할 수도 있어요. 수첩의 단서를 다시 떠올려 볼까요?',
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _selectedAnswer == null
                ? null
                : !_answered
                    ? () => setState(() => _answered = true)
                    : () {
                        if (!isCorrect) {
                          setState(() {
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        } else if (_deductionIndex < 2) {
                          setState(() {
                            _deductionIndex++;
                            _resetAnswer();
                          });
                        } else {
                          _finishEpisode();
                        }
                      },
            child: Text(_saving ? '기록하는 중...' : !_answered ? '단서와 비교하기' : isCorrect ? (_deductionIndex == 2 ? '진실 확인하기' : '다음 추리') : '단서 보고 다시 생각하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnding() {
    return _page(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const _HeroOrb(icon: Icons.local_florist_rounded),
          const SizedBox(height: 26),
          const Text('사건 해결!', style: TextStyle(color: Color(0xFF3D304D), fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('별빛 꽃이 다시 정원을 환하게 밝혔어요', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF76687D), fontSize: 17)),
          const SizedBox(height: 24),
          const _DialogueCard(
            speaker: '보리',
            message: '씨앗이 바람에 떨어져 너무 차가워 보였어. 먼저 알려주지 못해서 미안해. 다음에는 꼭 이야기할게!',
          ),
          const SizedBox(height: 14),
          const _DialogueCard(
            speaker: '꽃루미',
            message: '네가 단서를 끝까지 살펴본 덕분에 보리를 오해하지 않고 진짜 이야기를 찾았어!',
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFF1C9), Color(0xFFFFE3F0)]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                const Text('새로운 꽃을 발견했어요', style: TextStyle(color: Color(0xFF7B5B32), fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('✨ 별빛 꽃 ✨', style: TextStyle(color: Color(0xFF5D416D), fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text('단서 3/3 · 수학 활동 4개 · +110 XP · 꽃숲 $_gardenLevel단계', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF755F69))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('별정원으로 돌아가기'))),
        ],
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb({required this.icon, this.danger = false});
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: danger ? const [Color(0xFFFFDFE5), Color(0xFFEBDCF5)] : const [Color(0xFFFFF3BC), Color(0xFFE7D4FF)]),
        boxShadow: const [BoxShadow(color: Color(0x33896AB2), blurRadius: 35, spreadRadius: 7)],
      ),
      child: Icon(icon, size: 78, color: danger ? const Color(0xFFA45B70) : const Color(0xFF7958A5)),
    );
  }
}

class _DialogueCard extends StatelessWidget {
  const _DialogueCard({required this.speaker, required this.message});
  final String speaker;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(speaker, style: const TextStyle(color: Color(0xFF986080), fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(0xFF55495E), fontSize: 16, height: 1.55)),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title, required this.subtitle});
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: const TextStyle(color: Color(0xFF956080), fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Color(0xFF3F3150), fontSize: 27, height: 1.25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Color(0xFF786C80), height: 1.45)),
      ],
    );
  }
}

class _InvestigationTile extends StatelessWidget {
  const _InvestigationTile({required this.icon, required this.title, required this.detail, required this.inspected, required this.onTap});
  final IconData icon;
  final String title;
  final String detail;
  final bool inspected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: inspected ? const Color(0xFFEAF5EA) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: inspected ? const Color(0xFFCDE8CF) : const Color(0xFFF0E8F7), child: Icon(inspected ? Icons.check_rounded : icon, color: const Color(0xFF72518F))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF493A55), fontWeight: FontWeight.w900)), if (inspected) ...[const SizedBox(height: 5), Text(detail, style: const TextStyle(color: Color(0xFF6D6372), height: 1.4))]])),
              if (!inspected) const Icon(Icons.touch_app_rounded, color: Color(0xFFB190C6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.completed, required this.onTap, this.locked = false});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool completed;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: completed ? const Color(0xFFEAF5EA) : locked ? const Color(0xFFEDE9EF) : Colors.white,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: completed ? null : onTap,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(width: 58, height: 58, decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(18)), child: Icon(completed ? Icons.check_circle_rounded : icon, color: completed ? const Color(0xFF529160) : color, size: 31)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF493A55), fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(completed ? '단서를 찾았어요' : subtitle, style: const TextStyle(color: Color(0xFF776B7D)))])),
              Icon(completed ? Icons.done_rounded : Icons.chevron_right_rounded, color: const Color(0xFF957BA5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.label, required this.selected, required this.correct, required this.wrong, required this.onTap});
  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFFE4F4E6) : wrong ? const Color(0xFFFFE8EE) : selected ? const Color(0xFFECE2F7) : Colors.white;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(children: [Icon(correct ? Icons.check_circle_rounded : wrong ? Icons.refresh_rounded : selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: correct ? const Color(0xFF4B8A58) : wrong ? const Color(0xFFA65069) : const Color(0xFF80609D)), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF4B3F53), fontWeight: FontWeight.w800)))]),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF2C8), borderRadius: BorderRadius.circular(18)), child: Text('💡 $text', style: const TextStyle(color: Color(0xFF705D34), height: 1.45, fontWeight: FontWeight.w600)));
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.correct, required this.text});
  final bool correct;
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: correct ? const Color(0xFFE4F4E6) : const Color(0xFFFFEAF0), borderRadius: BorderRadius.circular(18)), child: Text(text, style: TextStyle(color: correct ? const Color(0xFF3F7449) : const Color(0xFF8D4C61), height: 1.45, fontWeight: FontWeight.w700)));
}

class _ClueCard extends StatelessWidget {
  const _ClueCard({required this.number, required this.icon, required this.title, required this.text});
  final String number;
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(backgroundColor: const Color(0xFFECE1F5), child: Icon(icon, color: const Color(0xFF765593))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$number · $title', style: const TextStyle(color: Color(0xFF493B54), fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(text, style: const TextStyle(color: Color(0xFF716676), height: 1.4))]))]));
}

class _Connector extends StatelessWidget {
  const _Connector();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Icon(Icons.south_rounded, color: Color(0xFFAD90BD))));
}
