abstract class SettingsRepository {
  Future<void> clearAllData({void Function(double progress)? onProgress});
}
