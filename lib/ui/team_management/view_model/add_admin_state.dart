import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_application_1/data/models/app_user.dart';

part 'add_admin_state.freezed.dart';

@freezed
abstract class AddAdminState with _$AddAdminState {
  const factory AddAdminState({
    required bool isLoading,
    String? error,
    AppUser? admin,
  }) = _AddAdminState;
}
