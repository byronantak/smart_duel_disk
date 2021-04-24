import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'package:smart_duel_disk/packages/features/feature_settings/lib/src/settings_viewmodel.dart';
import 'package:smart_duel_disk/src/di/di.dart';

import '../../feature_settings.dart';


class SettingsScreenProvider extends StatelessWidget {
  const SettingsScreenProvider();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserSettingsDataManager>(
          create: (_) => di.get<UserSettingsDataManager>(),
        ),
        Provider<SettingsViewModel>(
          create: (_) => di.get<SettingsViewModel>(),
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      child: SettingsScreen()
    );
  }
}
