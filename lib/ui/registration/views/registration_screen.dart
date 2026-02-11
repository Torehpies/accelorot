import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'registration_handlers.dart';
import 'package:flutter_application_1/ui/registration/widgets/registration_left_panel.dart';

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: RepaintBoundary(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isDesktop = screenWidth >= kDesktopBreakpoint;
              final isTablet = screenWidth >= kTabletBreakpoint;
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;

              if (isDesktop) {
                return Row(
                  children: [
                    const Expanded(flex: 3, child: RegistrationLeftPanel()),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topCenter,
                            child: const SizedBox(
                              width: 480,
                              child: RegistrationFormContent(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 24.0 : 20.0,
                  isTablet ? 6.0 : 4.0,
                  isTablet ? 24.0 : 20.0,
                  (isTablet ? 20.0 : 16.0) + bottomInset,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: isTablet ? 600 : kMaxFormWidth,
                      child: isTablet
                          ? Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: RegistrationFormContent(),
                              ),
                            )
                          : const RegistrationFormContent(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
