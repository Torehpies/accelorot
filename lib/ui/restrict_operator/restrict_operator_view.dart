import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class RestrictOperatorView extends StatelessWidget {
  const RestrictOperatorView({super.key});

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
                        fixedSize: Size(220, 50),
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
                        fixedSize: Size(220, 40),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                      ),
                      label: Text("Logout"),
                      icon: Icon(Icons.logout),
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
