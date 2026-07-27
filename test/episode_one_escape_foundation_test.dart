import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_escape_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_state.dart';

void main() {
  test('Episode 1 장면 이동 기록과 초기화 상태를 유지한다', () {
    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    expect(controller.value.currentScene, EpisodeOneScene.centralGarden);
    expect(controller.value.visitedScenes, {EpisodeOneScene.centralGarden});

    controller.navigateTo(EpisodeOneScene.pond);
    controller.returnToGarden();
    controller.navigateTo(EpisodeOneScene.fountain);

    expect(controller.value.currentScene, EpisodeOneScene.fountain);
    expect(
      controller.value.visitedScenes,
      containsAll({
        EpisodeOneScene.centralGarden,
        EpisodeOneScene.pond,
        EpisodeOneScene.fountain,
      }),
    );
    expect(controller.value.history.length, 4);

    controller.reset();

    expect(controller.value.currentScene, EpisodeOneScene.centralGarden);
    expect(controller.value.visitedScenes, {EpisodeOneScene.centralGarden});
    expect(controller.value.history, [EpisodeOneScene.centralGarden]);
  });

  testWidgets('Episode 1 기반 화면이 장면 상태 변경을 UI에 반영한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeOneEscapeScreen(controller: controller),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('중앙 정원'), findsOneWidget);
    expect(find.byKey(const Key('episode-one-foundation-status')), findsOneWidget);
    expect(find.textContaining('방문 1/5'), findsOneWidget);

    controller.navigateTo(EpisodeOneScene.clockflowerGrove);
    await tester.pump();

    expect(find.text('시계꽃 숲'), findsOneWidget);
    expect(find.textContaining('방문 2/5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('작은 화면에서도 Episode 1 기반 UI가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: EpisodeOneEscapeScreen()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('episode-one-current-objective')), findsOneWidget);
    expect(find.byKey(const Key('episode-one-foundation-status')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
