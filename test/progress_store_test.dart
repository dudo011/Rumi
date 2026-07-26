import 'package:flutter_test/flutter_test.dart';
import 'package:rumi/core/storage/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('닉네임과 모험 진행 상황을 기기에 저장한다', () async {
    const store = ProgressStore();

    await store.saveNickname('별하');
    final updated = await store.completeAdventure(earnedExperience: 70);
    final loaded = await store.load();

    expect(updated.nickname, '별하');
    expect(loaded.experience, 70);
    expect(loaded.completedAdventures, 1);
    expect(loaded.gardenLevel, 1);
    expect(loaded.levelExperience, 70);
  });

  test('경험치가 100을 넘으면 꽃숲 성장 단계가 오른다', () async {
    SharedPreferences.setMockInitialValues({
      'player_nickname': '별하',
      'player_experience': 80,
      'completed_adventures': 1,
    });
    const store = ProgressStore();

    final updated = await store.completeAdventure(earnedExperience: 50);

    expect(updated.experience, 130);
    expect(updated.gardenLevel, 2);
    expect(updated.levelExperience, 30);
    expect(updated.completedAdventures, 2);
  });
}
