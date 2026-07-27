import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'episode_one_game.dart';
import 'episode_one_state.dart';

class EpisodeOneEscapeScreen extends StatefulWidget {
  const EpisodeOneEscapeScreen({super.key, this.controller});

  final EpisodeOneStateController? controller;

  @override
  State<EpisodeOneEscapeScreen> createState() =>
      _EpisodeOneEscapeScreenState();
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
                tooltip: '돌아가기',
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
                        snapshot.currentScene.label,
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
                tooltip: '장면 방문 기록 초기화',
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
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD9253440),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x5578DFC3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_tree_rounded,
                          size: 18,
                          color: Color(0xFFFFE39A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '장면 이동 기반 · 방문 ${snapshot.visitedScenes.length}/5',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Text(
                          '퍼즐은 다음 단계',
                          style: TextStyle(
                            color: Color(0xFFB9CCC7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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
