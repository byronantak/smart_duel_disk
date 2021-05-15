import 'package:auto_route/auto_route.dart';

abstract class UserSettingsDataManager {
  bool isPlayMatEnabled();
  void savePlayMatEnabled({@required bool value});
}
