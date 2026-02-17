import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueUI on AsyncValue<void> {
  // isLoading shorthand (AsyncLoading is a subclass of AsycValue)
  bool get isLoading => this is AsyncLoading<void>;

  // show a snackbar on error only
  void showSnackBarOnError(BuildContext context) => whenOrNull(
    error: (error, _) {
      AppSnackbar.error(context, error.toString());
    },
  );
}
