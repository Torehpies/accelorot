import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef VoidAsyncValue = AsyncValue<void>;

extension AsyncValueUI on VoidAsyncValue {
  void showSnackBarOnError(BuildContext context) => whenOrNull(
    error: (error, _) {
      AppSnackbar.error(context, error.toString());
    },
  );
  void showSnackBarOnSuccess(
    BuildContext context, [
    String message = 'Success',
  ]) => whenData((_) => AppSnackbar.success(context, message));
}
