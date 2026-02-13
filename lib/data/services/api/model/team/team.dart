import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';
part 'team.g.dart';

@freezed
abstract class Team with _$Team {
  const factory Team({
    String? teamId,
    required String teamName,
    required String address,
    String? createdBy,
    @Default(0) int activeOperators,
    @Default(0) int archivedOperators,
    @Default(0) int formerOperators,
    @Default(0) int pendingOperators,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}
