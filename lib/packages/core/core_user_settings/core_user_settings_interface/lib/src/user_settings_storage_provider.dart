import 'package:auto_route/auto_route.dart';

abstract class UserSettingsStorageProvider {
  bool isPlayMatEnabled();
  void savePlayMatEnabled({@required bool value});
}
