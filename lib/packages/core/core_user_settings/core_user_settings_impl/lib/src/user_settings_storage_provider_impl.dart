import 'package:injectable/injectable.dart';
import 'package:smart_duel_disk/packages/core/core_storage/core_storage_impl/lib/src/providers/shared_preferences/shared_preferences_interface/shared_preferences_provider.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/src/user_settings_storage_provider.dart';

@LazySingleton(as: UserSettingsStorageProvider)
class UserSettingsStorageProviderImpl implements UserSettingsStorageProvider {
  final SharedPreferencesProvider _sharedPreferencesProvider;
  final _enablePlayMatKey = 'enabledPlayMat';

  UserSettingsStorageProviderImpl(this._sharedPreferencesProvider);

  @override
  UserSettings getUserSettings() {
    return UserSettings(
        enablePlayMat: _sharedPreferencesProvider.getBool(_enablePlayMatKey));
  }

  @override
  void setUserSettings(UserSettings userSettings) {
    _sharedPreferencesProvider.setBool(_enablePlayMatKey,
        value: userSettings.enablePlayMat);
  }
}
