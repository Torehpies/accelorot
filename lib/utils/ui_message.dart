import 'package:freezed_annotation/freezed_annotation.dart';
part 'ui_message.freezed.dart';

@freezed
abstract class UiMessage with _$UiMessage {
  const factory UiMessage.success(String text) = SuccessMessage;
  const factory UiMessage.error(String text) = ErrorMessage;
}
