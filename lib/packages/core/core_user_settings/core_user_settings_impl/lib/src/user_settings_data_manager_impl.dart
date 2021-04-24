import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/src/user_settings_storage_provider.dart';

class UserSettingsDataManagerImpl implements UserSettingsDataManager {
  final UserSettingsStorageProvider _userSettingsStorageProvider;

  UserSettingsDataManagerImpl(this._userSettingsStorageProvider);

  @override
  UserSettings getUserSettings() {
    return _userSettingsStorageProvider.getUserSettings();
  }

  @override
  void saveUserSettings(UserSettings userSettings) {
    _userSettingsStorageProvider.setUserSettings(userSettings);
  }
}