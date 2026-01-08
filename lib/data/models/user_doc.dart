import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_doc.freezed.dart';
part 'user_doc.g.dart';

@freezed
abstract class UserDoc with _$UserDoc {
  const factory UserDoc({
    required String status,
    required String globalRole,
    String? teamRole,
  }) = _UserDoc;

  factory UserDoc.fromJson(Map<String, dynamic> json) =>
      _$UserDocFromJson(json);
}
