import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';

abstract class UserSettingsStorageProvider {
  UserSettings getUserSettings();
  void setUserSettings(UserSettings userSettings);
}
