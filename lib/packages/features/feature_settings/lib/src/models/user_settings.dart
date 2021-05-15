import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@Immutable()
class UserSettings extends Equatable {
  final bool isPlayMatEnabled;

  const UserSettings({@required this.isPlayMatEnabled});

  UserSettings copyWith({bool isPlayMatEnabled}) =>
      UserSettings(isPlayMatEnabled: isPlayMatEnabled ?? this.isPlayMatEnabled);

  @override
  List<Object> get props => [isPlayMatEnabled];
}
