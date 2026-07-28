import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_escape_screen.dart';
import 'package:rumi/features/adventure/escape/episode_one/episode_one_state.dart';

void main() {
  testWidgets('설치형 앱 안전영역 안에 상단 HUD와 인벤토리를 배치한다', (tester) async {
    const screenSize = Size(360, 640);
    const safePadding = EdgeInsets.fromLTRB(0, 28, 0, 24);

    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = EpisodeOneStateController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: screenSize,
            padding: safePadding,
            viewPadding: safePadding,
          ),
          child: EpisodeOneEscapeScreen(controller: controller),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final backButton = find.byKey(const Key('episode-one-foundation-back'));
    final inventory = find.byKey(const Key('episode-one-inventory'));

    expect(backButton, findsOneWidget);
    expect(inventory, findsOneWidget);
    expect(tester.getTopLeft(backButton).dy, greaterThanOrEqualTo(28));
    expect(tester.getBottomRight(inventory).dy, lessThanOrEqualTo(616));
    expect(find.byKey(const Key('episode-one-current-objective')), findsOneWidget);
    expect(find.byKey(const Key('episode-one-foundation-status')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
