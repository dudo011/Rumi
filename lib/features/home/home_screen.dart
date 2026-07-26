import 'package:flutter/material.dart';

import '../../core/storage/progress_store.dart';
import '../adventure/adventure_screen.dart';
import '../adventure/question_bank.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.store = const ProgressStore()});

  final ProgressStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlayerProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await widget.store.load();
    if (mounted) {
      setState(() => _progress = progress);
    }
  }

  Future<void> _startAdventure() async {
    final completedAdventures = _progress?.completedAdventures ?? 0;
    final startIndex = (completedAdventures * 5) % divisorMultipleQuestions.length;
    final questions = List.generate(
      5,
      (index) => divisorMultipleQuestions[
        (startIndex + index) % divisorMultipleQuestions.length
      ],
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AdventureScreen(
          store: widget.store,
          questions: questions,
        ),
      ),
    );
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1FB),
      body: SafeArea(
        child: progress == null
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Header(progress: progress),
                            const SizedBox(height: 24),
                            _GardenCard(progress: progress),
                            const SizedBox(height: 20),
                            _AdventureCard(onPressed: _startAdventure),
                            const SizedBox(height: 18),
                            Text(
                              '완료한 모험 ${progress.completedAdventures}회 · 모은 경험치 ${progress.experience} XP',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF786E82), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});
  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFFFFD8E8),
          child: Icon(Icons.local_florist_rounded, color: Color(0xFF72509B)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${progress.nickname} 별지기님', style: const TextStyle(color: Color(0xFF392C50), fontSize: 22, fontWeight: FontWeight.w900)),
              const Text('오늘도 꽃루미가 기다리고 있어요.', style: TextStyle(color: Color(0xFF7A7084))),
            ],
          ),
        ),
      ],
    );
  }
}

class _GardenCard extends StatelessWidget {
  const _GardenCard({required this.progress});
  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    final flowers = (progress.gardenLevel + 2).clamp(3, 9).toInt();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE0F2DF), Color(0xFFFFECF4)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('꽃숲 · 성장 ${progress.gardenLevel}단계', style: const TextStyle(color: Color(0xFF405C45), fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(flowers, (index) => Icon(Icons.local_florist_rounded, size: 38 + (index % 3) * 4, color: index.isEven ? const Color(0xFFE875A4) : const Color(0xFF8B6BB3))),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress.levelExperience / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF76A879),
            backgroundColor: Colors.white.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 8),
          Text('다음 성장까지 ${100 - progress.levelExperience} XP', style: const TextStyle(color: Color(0xFF5F7161), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AdventureCard extends StatelessWidget {
  const _AdventureCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8A68C1), size: 48),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘의 모험', style: TextStyle(color: Color(0xFF3F3156), fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('약수와 배수 · 5문제', style: TextStyle(color: Color(0xFF7B7184))),
                ],
              ),
            ),
            FilledButton(onPressed: onPressed, child: const Text('시작')),
          ],
        ),
      ),
    );
  }
}
