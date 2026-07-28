import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Widget buildScreen() {
    return MaterialApp(home: GardenExplorationScreen(onContinue: (_) {}));
  }

  Future<void> start(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('start-investigation')));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('별받침대는 문제지보다 조사 지점을 먼저 제공한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen());
    await start(tester);

    await tester.tap(find.byKey(const Key('pedestal-hotspot')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.byKey(const Key('pedestal-investigation-scene')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('inspect-empty-spot')), findsOneWidget);
    expect(find.byKey(const Key('inspect-scratch-mark')), findsOneWidget);
    expect(find.byKey(const Key('inspect-star-dust')), findsOneWidget);
    expect(find.byKey(const Key('star-dust-0')), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('세 지점을 조사하면 별가루 직접 묶기가 열린다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen());
    await start(tester);
    await tester.tap(find.byKey(const Key('pedestal-hotspot')));
    await tester.pump(const Duration(milliseconds: 600));

    for (final key in [
      'inspect-empty-spot',
      'inspect-scratch-mark',
      'inspect-star-dust',
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(find.byKey(const Key('star-dust-0')), findsOneWidget);
    expect(find.byKey(const Key('star-dust-11')), findsOneWidget);
    expect(find.textContaining('0/12'), findsOneWidget);
    expect(find.text('증거 0/3'), findsOneWidget);
  });

  testWidgets('상자와 돌은 발자국 증거 전에는 나타나지 않는다', (tester) async {
    await tester.pumpWidget(buildScreen());
    await start(tester);

    expect(find.byKey(const Key('chest-hotspot')), findsNothing);
    expect(find.byKey(const Key('move-stone')), findsNothing);
  });
}
