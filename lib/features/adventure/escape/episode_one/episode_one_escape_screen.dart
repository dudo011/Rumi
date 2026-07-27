import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'episode_one_game.dart';
import 'episode_one_state.dart';

class EpisodeOneEscapeScreen extends StatefulWidget {
  const EpisodeOneEscapeScreen({super.key, this.controller});

  final EpisodeOneStateController? controller;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08141C),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GameWidget<EpisodeOneEscapeGame>(game: _game),
            ),
            Positioned(
              left: 8,
              top: 6,
              child: IconButton.filledTonal(
                key: const Key('episode-one-foundation-back'),
                tooltip: '모험 나가기',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Positioned(
              left: 58,
              right: 58,
              top: 8,
              child: ValueListenableBuilder<EpisodeOneSnapshot>(
                valueListenable: _controller,
                builder: (context, snapshot, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.displayLabel,
                        key: const Key('episode-one-current-scene'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        snapshot.objective,
                        key: const Key('episode-one-current-objective'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD6E8E2),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: IconButton.filledTonal(
                key: const Key('episode-one-foundation-reset'),
                tooltip: 'Episode 1 진행 초기화',
                onPressed: _controller.reset,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: ValueListenableBuilder<EpisodeOneSnapshot>(
                valueListenable: _controller,
                builder: (context, snapshot, _) {
                  return Container(
                    key: const Key('episode-one-foundation-status'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
