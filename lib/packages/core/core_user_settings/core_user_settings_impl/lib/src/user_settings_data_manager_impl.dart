import 'package:injectable/injectable.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/src/user_settings_storage_provider.dart';

@LazySingleton(as: UserSettingsDataManager)
class UserSettingsDataManagerImpl implements UserSettingsDataManager {
  final UserSettingsStorageProvider _userSettingsStorageProvider;

  UserSettingsDataManagerImpl(this._userSettingsStorageProvider);

  @override
  bool isPlaymatEnabled() {
    return _userSettingsStorageProvider.isPlaymatEnabled();
  }

  @override
  void savePlaymatEnabled({bool value}) {
    _userSettingsStorageProvider.savePlaymatEnabled(value: value);
  }
}
