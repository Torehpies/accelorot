import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_application_1/data/models/app_user.dart';

part 'add_operator_state.freezed.dart';

@freezed
abstract class AddOperatorState with _$AddOperatorState {
  const factory AddOperatorState({
    required bool isLoading,
    String? error,
    AppUser? operator,
  }) = _AddOperatorState;
}
