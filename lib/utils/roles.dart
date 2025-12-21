import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum(valueField: 'value')
enum GlobalRole {
  superadmin('SuperAdmin'),
  user('User');

  final String value;
  const GlobalRole(this.value);
}

@JsonEnum(valueField: 'value')
enum TeamRole {
  admin('Admin'),
  operator('Operator');

  final String value;
  const TeamRole(this.value);
}
