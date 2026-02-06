import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mobile_settings_view.dart';
import '../../core/widgets/web_base_container.dart';

class WebSettingsView extends ConsumerWidget {
  const WebSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const WebScaffoldContainer(
      child: WebContentContainer(
        innerPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: SettingsContent(),
      ),
    );
  }
}
