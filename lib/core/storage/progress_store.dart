import 'package:shared_preferences/shared_preferences.dart';

class PlayerProgress {
  const PlayerProgress({
    required this.nickname,
    required this.experience,
    required this.completedAdventures,
  });

  final String nickname;
  final int experience;
  final int completedAdventures;

  int get gardenLevel => (experience ~/ 100) + 1;
  int get levelExperience => experience % 100;
}

class ProgressStore {
  const ProgressStore();

  static const _nicknameKey = 'player_nickname';
  static const _experienceKey = 'player_experience';
  static const _completedAdventuresKey = 'completed_adventures';
  static const _episodeOneV3CheckpointKey = 'episode_one_v3_checkpoint';

  Future<PlayerProgress> load() async {
    final preferences = await SharedPreferences.getInstance();
    return PlayerProgress(
      nickname: preferences.getString(_nicknameKey) ?? '',
      experience: preferences.getInt(_experienceKey) ?? 0,
      completedAdventures: preferences.getInt(_completedAdventuresKey) ?? 0,
    );
  }

  Future<void> saveNickname(String nickname) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nicknameKey, nickname.trim());
  }

  Future<int> loadEpisodeOneV3Checkpoint() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_episodeOneV3CheckpointKey) ?? 0;
  }

  Future<void> saveEpisodeOneV3Checkpoint(int checkpoint) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _episodeOneV3CheckpointKey,
      checkpoint.clamp(0, 3),
    );
  }

  Future<void> clearEpisodeOneV3Checkpoint() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_episodeOneV3CheckpointKey);
  }

  Future<PlayerProgress> completeAdventure({
    required int earnedExperience,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final experience =
        (preferences.getInt(_experienceKey) ?? 0) + earnedExperience;
    final completed = (preferences.getInt(_completedAdventuresKey) ?? 0) + 1;
    await preferences.setInt(_experienceKey, experience);
    await preferences.setInt(_completedAdventuresKey, completed);
    return PlayerProgress(
      nickname: preferences.getString(_nicknameKey) ?? '',
      experience: experience,
      completedAdventures: completed,
    );
  }
}
