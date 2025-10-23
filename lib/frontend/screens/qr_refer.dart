import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReferralOverlay extends StatefulWidget {
final String referralCode;
final VoidCallback onSkip;

const ReferralOverlay({
super.key,
required this.referralCode,
required this.onSkip,
});

@override
State<ReferralOverlay> createState() => _ReferralOverlayState();
}

class _ReferralOverlayState extends State<ReferralOverlay>
with SingleTickerProviderStateMixin {
late TabController _tabController;

@override
void initState() {
super.initState();
_tabController = TabController(length: 2, vsync: this);
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final themeGreen = const Color(0xFF2E5733);

return Center(
  child: Container(
    width: 350,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          labelColor: themeGreen,
          unselectedLabelColor: Colors.black54,
          indicatorColor: themeGreen,
          tabs: const [
            Tab(text: "QR Code"),
            Tab(text: "Referral Code"),
          ],
        ),
        const SizedBox(height: 20),

        // Tab content
        SizedBox(
          height: 260,
          child: TabBarView(
            controller: _tabController,
            children: [
              // QR tab
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: widget.referralCode,
                    version: QrVersions.auto,
                    size: 180,
                    foregroundColor: themeGreen,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Scan the QR Code",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),

              // Referral code tab
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Referral Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 160,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black38),
                    ),
                    child: SelectableText(
                      widget.referralCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Skip button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onSkip,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  ),
);


}
}