import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mobile_settings_view.dart';

class WebSettingsView extends ConsumerWidget {
  const WebSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MobileSettingsView();
  }
}