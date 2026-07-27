import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/garden_exploration_screen.dart';

void main() {
  Future<void> waitForUi(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> start(WidgetTester tester) async {
    await waitForUi(tester);
    expect(find.text('별빛 씨앗이 사라졌어요!'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-investigation')));
    await waitForUi(tester);
  }

  Future<void> solvePedestal(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('pedestal-hotspot')));
    await waitForUi(tester);
    expect(find.byKey(const Key('pedestal-investigation-scene')), findsOneWidget);

    for (final key in [
      'inspect-empty-spot',
      'inspect-scratch-mark',
      'inspect-star-dust',
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump(const Duration(milliseconds: 350));
    }

    for (var index = 0; index < 12; index++) {
      await tester.tap(find.byKey(Key('star-dust-$index')));
      await tester.pump(const Duration(milliseconds: 80));
    }
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.textContaining('네 묶음 완성'), findsOneWidget);
    expect(find.byKey(const Key('return-from-pedestal')), findsOneWidget);
    await tester.tap(find.byKey(const Key('return-from-pedestal')));
    await waitForUi(tester);
  }

  Future<void> reachSolved(WidgetTester tester) async {
    await solvePedestal(tester);

    await tester.tap(find.byKey(const Key('trail-hotspot')));
    await waitForUi(tester);
    expect(find.text('오른쪽 길 확대 조사'), findsOneWidget);
    await tester.tap(find.byKey(const Key('trail-option-12')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('trail-check-answer')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('return-from-trail')));
    await waitForUi(tester);

    await tester.tap(find.byKey(const Key('chest-hotspot')));
    await waitForUi(tester);
    expect(find.text('분수대 상자 확대 조사'), findsOneWidget);
    await tester.tap(find.byKey(const Key('inspect-lock')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('move-stone')));
    await tester.pump();

    for (final value in [1, 2, 3, 4, 6, 12]) {
      await tester.tap(find.byKey(Key('factor-$value')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('check-puzzle-answer')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('open-deduction')));
    await waitForUi(tester);

    expect(find.text('추리 보드'), findsOneWidget);
    await tester.tap(find.byKey(const Key('deduction-option-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('check-deduction')));
    await waitForUi(tester);
  }

  testWidgets('별받침대는 관찰 후 별가루를 직접 묶어 해결한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );
    await start(tester);

    await tester.tap(find.byKey(const Key('pedestal-hotspot')));
    await waitForUi(tester);

    expect(find.text('별받침대 근접 조사'), findsOneWidget);
    expect(find.byKey(const Key('inspect-empty-spot')), findsOneWidget);
    expect(find.byKey(const Key('star-dust-0')), findsNothing);

    await tester.tap(find.byKey(const Key('inspect-empty-spot')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('inspect-scratch-mark')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('inspect-star-dust')));
    await tester.pump();

    expect(find.byKey(const Key('star-dust-0')), findsOneWidget);
    expect(find.textContaining('0/12'), findsOneWidget);
  });

  testWidgets('조사 대상이 증거에 따라 단계적으로 열린다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );
    await start(tester);

    expect(find.byKey(const Key('pedestal-hotspot')), findsOneWidget);
    expect(find.byKey(const Key('trail-hotspot')), findsNothing);
    expect(find.byKey(const Key('chest-hotspot')), findsNothing);

    await solvePedestal(tester);

    expect(find.byKey(const Key('trail-hotspot')), findsOneWidget);
    expect(find.byKey(const Key('chest-hotspot')), findsNothing);
  });

  testWidgets('세 조사 장면과 추리 보드를 거쳐 사건을 해결한다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var continued = false;
    await tester.pumpWidget(
      MaterialApp(
        home: GardenExplorationScreen(onContinue: (_) => continued = true),
      ),
    );
    await start(tester);
    await reachSolved(tester);

    expect(find.text('사건 해결!'), findsOneWidget);
    expect(find.byKey(const Key('continue-adventure')), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('continue-adventure')),
    );
    button.onPressed!.call();
    await tester.pump();
    expect(continued, isTrue);
  });

  testWidgets('작은 화면에서도 시작 화면과 목표 영역이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: GardenExplorationScreen(onContinue: (_) {})),
    );
    await start(tester);

    expect(find.text('사라진 별빛 씨앗'), findsOneWidget);
    expect(find.byKey(const Key('current-objective')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
