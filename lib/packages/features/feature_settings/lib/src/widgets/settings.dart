
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_duel_disk/packages/features/feature_settings/lib/src/constants/setting-keys.dart';
import 'package:smart_duel_disk/src/localization/strings.al.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingsScreen> {
  bool _enablePlayMat;

  Future<void> loadSettingsFromSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enablePlayMat = prefs.getBool(settingEnabledPlayMatKey) ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _enablePlayMat = false;
    loadSettingsFromSharedPrefs();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> onSwitchChanged(bool value) async {
    setState(() {
      _enablePlayMat = value;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(settingEnabledPlayMatKey, _enablePlayMat);
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(Strings.settingsEnablePlaymat.get()),
                Switch(value: _enablePlayMat, onChanged: onSwitchChanged),
              ]
            ),
          ),
        ],
      );
  }
}


