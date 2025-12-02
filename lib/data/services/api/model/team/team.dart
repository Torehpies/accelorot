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
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) =>
      _$TeamFromJson(json);
}
