import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
	const factory User({
		required String email,
		required String firstName,
		required String lastName,
		required String role,
		@Default('') String teamId,
		@Default(false) bool isArchived,
		@Default('') String pendingTeamSelection,
		@Default(true) bool isActive,
		required bool emailVerified,
		required String uid,
		required Timestamp createdAt,
	}) = _User;

	factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
