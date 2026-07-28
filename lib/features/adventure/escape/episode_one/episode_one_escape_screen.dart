import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/storage/progress_store.dart';
import 'episode_one_game.dart';
import 'episode_one_state.dart';
import 'widgets/episode_one_clockflower_overlay.dart';
import 'widgets/episode_one_finale_overlay.dart';
import 'widgets/episode_one_fountain_overlay.dart';
import 'widgets/episode_one_greenhouse_overlay.dart';
import 'widgets/episode_one_inventory_overlay.dart';

class EpisodeOneEscapeScreen extends StatefulWidget {
  const EpisodeOneEscapeScreen({
    super.key,
    this.controller,
    this.store = const ProgressStore(),
  });

  final EpisodeOneStateController? controller;
  final ProgressStore store;

  @override
  State<EpisodeOneEscapeScreen> createState() => _EpisodeOneEscapeScreenState();
}

class _EpisodeOneEscapeScreenState extends State<EpisodeOneEscapeScreen> {
  late final EpisodeOneStateController _controller;
  late final EpisodeOneEscapeGame _game;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? EpisodeOneStateController();
    _game = EpisodeOneEscapeGame(controller: _controller);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showClues(EpisodeOneSnapshot snapshot) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF24343E),
      showDragHandle: true,
      builder: (context) {
        final clues = snapshot.clues.toList()
          ..sort((first, second) => first.index.compareTo(second.index));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '별지기의 단서 수첩',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                if (clues.isEmpty)
                  const Text(
                    '아직 기록한 핵심 단서가 없어요.',
                    style: TextStyle(color: Color(0xFFD6E8E2)),
                  )
                else
                  for (final clue in clues)
                    ListTile(
                      key: Key('episode-one-clue-${clue.name}'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFD96A),
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
                        style: const TextStyle(color: Color(0xFFD6E8E2)),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _returnToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08141C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final safePadding = mediaQuery.padding;
          final compact =
              constraints.maxWidth < 480 || constraints.maxHeight < 720;

          final topBarHeight = compact ? 58.0 : 66.0;
          final inventoryReserve = compact ? 78.0 : 82.0;
          final overlayTop = safePadding.top + topBarHeight + 4;
          final overlayBottom = safePadding.bottom + inventoryReserve;
          final statusBottom = overlayBottom + (compact ? 2 : 6);

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GameWidget<EpisodeOneEscapeGame>(game: _game),
              ),
              Positioned(
                left: safePadding.left,
                right: safePadding.right,
                top: overlayTop,
                bottom: overlayBottom,
                child: EpisodeOneClockflowerOverlay(controller: _controller),
              ),
              Positioned(
                left: safePadding.left,
                right: safePadding.right,
                top: overlayTop,
                bottom: overlayBottom,
                child: EpisodeOneFountainOverlay(controller: _controller),
              ),
              Positioned(
                left: safePadding.left,
                right: safePadding.right,
                top: overlayTop,
                bottom: overlayBottom,
                child: EpisodeOneGreenhouseOverlay(controller: _controller),
              ),
              Positioned(
                left: safePadding.left + 8,
                right: safePadding.right + 8,
                top: safePadding.top + 4,
                child: ValueListenableBuilder<EpisodeOneSnapshot>(
                  valueListenable: _controller,
                  builder: (context, snapshot, _) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.square(
                          dimension: 44,
                          child: IconButton.filledTonal(
                            key: const Key('episode-one-foundation-back'),
                            tooltip: '모험 나가기',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  snapshot.displayLabel,
                                  key: const Key(
                                    'episode-one-current-scene',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 15 : 17,
                                    fontWeight: FontWeight.w900,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  snapshot.objective,
                                  key: const Key(
                                    'episode-one-current-objective',
                                  ),
                                  maxLines: compact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFD6E8E2),
                                    fontSize: compact ? 11 : 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox.square(
                              dimension: 44,
                              child: IconButton.filledTonal(
                                key: const Key('episode-one-clue-notebook'),
                                tooltip: '단서 수첩',
                                onPressed: snapshot.inputLocked
                                    ? null
                                    : () => _showClues(snapshot),
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
                            key: const Key('episode-one-foundation-reset'),
                            tooltip: 'Episode 1 진행 초기화',
                            onPressed: _controller.reset,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                left: safePadding.left + 12,
                right: safePadding.right + 12,
                bottom: statusBottom,
                child: ValueListenableBuilder<EpisodeOneSnapshot>(
                  valueListenable: _controller,
                  builder: (context, snapshot, _) {
                    return Container(
                      key: const Key('episode-one-foundation-status'),
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 11 : 14,
                        vertical: compact ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE6253440),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: snapshot.inputLocked
                              ? const Color(0x88FFE39A)
                              : const Color(0x5578DFC3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            snapshot.inputLocked
                                ? Icons.auto_awesome_rounded
                                : Icons.search_rounded,
                            size: 18,
                            color: const Color(0xFFFFE39A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              snapshot.message,
                              key: const Key('episode-one-feedback-message'),
                              maxLines: compact ? 1 : 2,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x334FD0B1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              snapshot.progressLabel,
                              key: const Key('episode-one-progress-label'),
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
                  },
                ),
              ),
              Positioned(
                left: safePadding.left,
                right: safePadding.right,
                bottom: safePadding.bottom,
                child: EpisodeOneInventoryOverlay(controller: _controller),
              ),
              Positioned.fill(
                child: EpisodeOneFinaleOverlay(
                  controller: _controller,
                  store: widget.store,
                  onReturnToGarden: _returnToHome,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
