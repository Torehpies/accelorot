import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class RestrictOperatorView extends StatelessWidget {
  const RestrictOperatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileView: _MobileRestrictOperatorView(),
      desktopView: _WebRestrictOperatorView(),
    );
  }
}

class _WebRestrictOperatorView extends StatelessWidget {
  const _WebRestrictOperatorView();

  Future<void> downloadApk() async {
    final Uri url = Uri.parse(
      "https://firebasestorage.googleapis.com/v0/b/accel-o-rot.firebasestorage.app/o/accel-o-rot-app.apk?alt=media&token=ac77cf37-81d0-433a-8668-eeaa9ef62107",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Accelorot_logo.svg',
                      width: 160,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Download the Accel-O-Rot App",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "To continue using Accel-O-Rot, please download and install our Android app.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: downloadApk,
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(220, 50),
                        backgroundColor: AppColors.green100,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Download APK",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextButton.icon(
                      onPressed: () async => await handleLogout(
                        context,
                        roleName: "Operator",
                        confirmColor: AppColors.error,
                      ),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(220, 40),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                      ),
                      label: const Text("Logout"),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/mockup.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileRestrictOperatorView extends StatelessWidget {
  const _MobileRestrictOperatorView();

  Future<void> downloadApk() async {
    final Uri url = Uri.parse(
      "https://firebasestorage.googleapis.com/v0/b/accel-o-rot.firebasestorage.app/o/accel-o-rot-app.apk?alt=media&token=56490298-4701-45b9-bd35-ba6a39748465",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1, // Changed to background1 to make the white container pop
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                "assets/images/mockup.png",
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Accelorot_logo.svg',
                        width: 120,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Download the Accel-O-Rot App",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green100,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "To continue using Accel-O-Rot, please download and install our Android app.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: downloadApk,
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.green100,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Download APK",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () async => await handleLogout(
                          context,
                          roleName: "Operator",
                          confirmColor: AppColors.error,
                        ),
                        style: TextButton.styleFrom(
                          fixedSize: const Size(double.infinity, 40),
                          foregroundColor: Colors.black,
                        ),
                        label: const Text("Logout"),
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
