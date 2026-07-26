import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/features/adventure/starlight_seed_episode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> tapVisible(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'player_nickname': '별하'});
  });

  testWidgets('사건을 조사하고 세 장소의 단서를 모아 진실을 밝힌다', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: StarlightSeedEpisodeScreen()),
    );

    expect(find.text('오늘은 특별한 날'), findsOneWidget);
    await tapVisible(tester, '계속');
    await tapVisible(tester, '계속');
    await tapVisible(tester, '주변 조사하기');

    await tapVisible(tester, '빈 별받침대');
    await tapVisible(tester, '작은 발자국');
    await tapVisible(tester, '은빛 털과 잎');
    await tapVisible(tester, '탐험 지도 펼치기');

    await tapVisible(tester, '반짝이는 연못');
    await tapVisible(tester, '6개');
    await tapVisible(tester, '단서 확인');
    await tapVisible(tester, '단서 챙기기');
    expect(find.text('찾은 단서 1/3 · 연못과 숲은 원하는 순서로 탐험할 수 있어요.'), findsOneWidget);

    await tapVisible(tester, '시계꽃 숲');
    await tapVisible(tester, '12분');
    await tapVisible(tester, '단서 확인');
    await tapVisible(tester, '단서 챙기기');

    await tapVisible(tester, '달빛 온실');
    await tapVisible(tester, '6개');
    await tapVisible(tester, '단서 확인');
    await tapVisible(tester, '온실 안으로');
    await tapVisible(tester, '12번');
    await tapVisible(tester, '단서 확인');
    await tapVisible(tester, '단서 챙기기');

    expect(find.text('단서 수첩 · 3/3'), findsOneWidget);
    await tapVisible(tester, '사건 해결하기');

    await tapVisible(tester, '강한 은하 바람에 떨어졌다');
    await tapVisible(tester, '단서와 비교하기');
    await tapVisible(tester, '다음 추리');
    await tapVisible(tester, '추위로부터 보호하려고');
    await tapVisible(tester, '단서와 비교하기');
    await tapVisible(tester, '다음 추리');
    await tapVisible(tester, '달빛 온실의 12번 화분');
    await tapVisible(tester, '단서와 비교하기');
    await tapVisible(tester, '진실 확인하기');

    expect(find.text('사건 해결!'), findsOneWidget);
    expect(find.textContaining('+110 XP'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('player_experience'), 110);
    expect(preferences.getInt('completed_adventures'), 1);
  });

  testWidgets('온실은 연못과 숲의 단서를 찾기 전에는 잠겨 있다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StarlightSeedEpisodeScreen()),
    );

    await tapVisible(tester, '계속');
    await tapVisible(tester, '계속');
    await tapVisible(tester, '주변 조사하기');
    await tapVisible(tester, '빈 별받침대');
    await tapVisible(tester, '작은 발자국');
    await tapVisible(tester, '은빛 털과 잎');
    await tapVisible(tester, '탐험 지도 펼치기');
    await tapVisible(tester, '달빛 온실');

    expect(find.text('연못과 시계꽃 숲의 단서를 먼저 찾아보세요.'), findsOneWidget);
  });
}
