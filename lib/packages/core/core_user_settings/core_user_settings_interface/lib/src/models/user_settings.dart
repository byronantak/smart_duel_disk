import 'package:auto_route/auto_route.dart';

class UserSettings {
  bool enablePlayMat;

  UserSettings({@required this.enablePlayMat});

  UserSettings.clone(UserSettings randomObject)
      : this(enablePlayMat: randomObject.enablePlayMat);
}
