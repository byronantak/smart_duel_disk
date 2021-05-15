import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smart_duel_disk/packages/core/core_general/lib/core_general.dart';
import 'package:smart_duel_disk/packages/core/core_logger/core_logger_interface/lib/src/logger.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'models/user_settings.dart';

@Injectable()
class SettingsViewModel extends BaseViewModel {
  final UserSettingsDataManager _userSettingsDataManager;

  SettingsViewModel(
      Logger logger, UserSettingsDataManager userSettingsDataManager)
      : _userSettingsDataManager = userSettingsDataManager,
        super(logger) {
    _refreshSettings.add(UserSettings(
        isPlayMatEnabled: _userSettingsDataManager.isPlayMatEnabled()));
  }

  final _refreshSettings = BehaviorSubject<UserSettings>();

  Stream<UserSettings> get refreshSettings => _refreshSettings.stream;

  void savePlayMatEnabled({bool value}) {
    _userSettingsDataManager.savePlayMatEnabled(value: value);
    final settings = _refreshSettings.value.copyWith(isPlayMatEnabled: value);
    _refreshSettings.add(settings);
  }
}
