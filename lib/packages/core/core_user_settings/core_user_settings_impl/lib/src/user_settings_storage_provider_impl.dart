import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_duel_disk/packages/core/core_storage/core_storage_impl/lib/src/providers/shared_preferences/shared_preferences_interface/shared_preferences_provider.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/src/user_settings_storage_provider.dart';

const enablePlayMatKey = 'enablePlayMat';

@LazySingleton(as: UserSettingsStorageProvider)
class UserSettingsStorageProviderImpl implements UserSettingsStorageProvider {
  final SharedPreferencesProvider _sharedPreferencesProvider;

  UserSettingsStorageProviderImpl(this._sharedPreferencesProvider);

  @override
  bool isPlayMatEnabled() {
    return _sharedPreferencesProvider.getBool(enablePlayMatKey);
  }

  @override
  void savePlayMatEnabled({@required bool value}) {
    _sharedPreferencesProvider.setBool(enablePlayMatKey, value: value);
  }
}
