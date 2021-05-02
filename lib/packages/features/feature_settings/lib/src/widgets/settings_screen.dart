import 'package:smart_duel_disk/packages/core/core_user_settings/core_user_settings_interface/lib/core_user_settings_interface.dart';
import 'package:smart_duel_disk/packages/ui_components/lib/ui_components.dart';
import 'package:smart_duel_disk/src/localization/strings.al.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_duel_disk/packages/features/feature_settings/lib/src/settings_viewmodel.dart';
import 'package:smart_duel_disk/packages/ui_components/lib/src/widgets/state/general_loading_state.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsViewModel>(context);

    return StreamBuilder<UserSettings>(
        stream: vm.refreshSettings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const GeneralLoadingState();
          }

          return SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.screenMargin),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(Strings.settingsEnablePlaymat.get()),
                          Switch(
                              value: snapshot.data.enablePlayMat,
                              onChanged: (bool value) {
                                vm.setEnablePlayMat(value: value);
                              })
                        ])
                  ])));
        });
  }
}
