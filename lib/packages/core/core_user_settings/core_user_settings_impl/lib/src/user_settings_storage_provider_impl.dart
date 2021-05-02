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
  bool isPlaymatEnabled() {
    return _sharedPreferencesProvider.getBool(_enablePlayMatKey);
  }

  @override
  void savePlaymatEnabled({bool value}) {
    _sharedPreferencesProvider.setBool(_enablePlayMatKey, value: value);
  }
}
