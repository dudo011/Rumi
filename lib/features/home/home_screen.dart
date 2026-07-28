import 'package:flutter/material.dart';

import '../../core/storage/progress_store.dart';
import '../adventure/escape/episode_one_v3/episode_one_v3_screen.dart';

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
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeOneV3Screen(store: widget.store),
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
                              style: const TextStyle(
                                color: Color(0xFF786E82),
                                fontWeight: FontWeight.w600,
                              ),
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
              Text(
                '${progress.nickname} 별지기님',
                style: const TextStyle(
                  color: Color(0xFF392C50),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                '오늘도 꽃루미가 기다리고 있어요.',
                style: TextStyle(color: Color(0xFF7A7084)),
              ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2DF), Color(0xFFFFECF4)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '꽃숲 · 성장 ${progress.gardenLevel}단계',
            style: const TextStyle(
              color: Color(0xFF405C45),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              flowers,
              (index) => Icon(
                Icons.local_florist_rounded,
                size: 38 + (index % 3) * 4,
                color: index.isEven
                    ? const Color(0xFFE875A4)
                    : const Color(0xFF8B6BB3),
              ),
            ),
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
          Text(
            '다음 성장까지 ${100 - progress.levelExperience} XP',
            style: const TextStyle(
              color: Color(0xFF5F7161),
              fontWeight: FontWeight.w600,
            ),
          ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7158AE), Color(0xFFD37DA5)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사라진 별빛 씨앗',
                        style: TextStyle(
                          color: Color(0xFF9A4D72),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '중앙 정원의 흔적',
                        style: TextStyle(
                          color: Color(0xFF3F3156),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '흩어진 흔적을 복원하고 약수 규칙을 장치에 적용해, 겹쳐진 발자국 중 사건과 맞는 경로를 찾아보세요.',
              style: TextStyle(color: Color(0xFF6F6478), height: 1.5),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(icon: Icons.calculate_rounded, label: '약수'),
                _Tag(icon: Icons.schedule_rounded, label: '20~25분'),
                _Tag(icon: Icons.extension_rounded, label: '연쇄 퍼즐 4개'),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.travel_explore_rounded),
              label: const Text('사건 조사하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7255A0)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF655475),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
