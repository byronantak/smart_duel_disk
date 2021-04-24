import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smart_duel_disk/packages/core/core_general/lib/core_general.dart';
import 'package:smart_duel_disk/packages/core/core_logger/core_logger_interface/lib/src/logger.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';

@Injectable()
class SettingsViewModel extends BaseViewModel {
  final UserSettingsDataManager userSettingsDataManager;

  SettingsViewModel(Logger logger, {this.userSettingsDataManager})
      : super(logger) {
    _refreshSettings.add(userSettingsDataManager.getUserSettings());
  }

  final _refreshSettings = BehaviorSubject<UserSettings>();

  Stream<UserSettings> get refreshSettings => _refreshSettings.stream;

  void saveSettings(UserSettings userSettings) {
    userSettingsDataManager.saveUserSettings(userSettings);
    _refreshSettings.add(userSettings);
  }

  void setEnablePlayMat({bool value}) {
    final settings = UserSettings.clone(_refreshSettings.value);
    settings.enablePlayMat = value;
    userSettingsDataManager.saveUserSettings(settings);
    _refreshSettings.add(settings);
  }
}
