import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/src/models/user_settings.dart';

abstract class UserSettingsDataManager {
  UserSettings getUserSettings();
  void saveUserSettings(UserSettings userSettings);
}
