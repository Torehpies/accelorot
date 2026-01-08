import 'package:flutter_application_1/data/models/pending_member_user.dart';
import 'package:flutter_application_1/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_member.freezed.dart';
part 'pending_member.g.dart';

@freezed
abstract class PendingMember with _$PendingMember {
  const factory PendingMember({
    required PendingMemberUser? user,
    @TimestampConverter() required DateTime requestedAt,
  }) = _PendingMember;

  factory PendingMember.fromJson(Map<String, dynamic> json) =>
      _$PendingMemberFromJson(json);
}
