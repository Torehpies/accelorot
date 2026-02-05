import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/header_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double xl = 24.0;
  static const double lg = 20.0;
  static const double xxxl = 48.0;
}

class DownloadApp extends StatelessWidget {
  const DownloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              cacheHeight: 1000,
              cacheWidth: 1000,
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          // Content with responsive padding
          SafeArea(
            child: Column(
              children: [
                // App Header
                _AppHeader(
                  onBreadcrumbTap: (section) {
                    context.go('/');
                  },
                  activeSection: 'download',
                  isScrolled: true,
                ),
                // Main content area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 900;
                      final maxWidth = isMobile ? double.infinity : 1200.0;
                      final horizontalPadding = isMobile ? AppSpacing.lg : AppSpacing.xxxl;
                      Widget content = isMobile
                          ? Column(
                              children: [
                                // Mobile: Text content first
                                Container(
                                  constraints: BoxConstraints(maxWidth: maxWidth),
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'dm-sans',
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(text: 'Download the\n'),
                                            TextSpan(
                                              text: 'Accel-O-Rot App',
                                              style: TextStyle(
                                                color: Color(0xFF22C55E),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Text(
                                        'Get our AI-powered mobile app to monitor your composting system, '
                                        'receive real-time insights, and manage your organic waste efficiently.\n'
                                        'Available for Android.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.6,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxxl),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 280),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          height: 56,
                                          child: PrimaryButton(
                                            text: 'Download APK v1.0.0',
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                                                  backgroundColor: Color(0xFF22C55E),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxxl),
                                    ],
                                  ),
                                ),
                                // NEW: Carousel Phone Preview
                                const PhoneCarouselPreview(),
                              ],
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Desktop: Phone preview on LEFT
                                  const Expanded(
                                    flex: 1,
                                    child: Center(child: PhoneCarouselPreview()),
                                  ),
                                  const SizedBox(width: AppSpacing.xxxl),
                                  // Desktop: Text content on RIGHT
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        RichText(
                                          textAlign: TextAlign.start,
                                          text: const TextSpan(
                                            style: TextStyle(
                                              fontFamily: 'dm-sans',
                                              fontSize: 44,
                                              fontWeight: FontWeight.w800,
                                              height: 1.2,
                                              color: Colors.white,
                                            ),
                                            children: [
                                              TextSpan(text: 'Download the\n'),
                                              TextSpan(
                                                text: 'Accel-O-Rot App',
                                                style: TextStyle(
                                                  color: Color(0xFF22C55E),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.lg),
                                        Text(
                                          'Get our AI-powered mobile app to monitor your composting system, '
                                          'receive real-time insights, and manage your organic waste efficiently.\n'
                                          'Available for Android.',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.6,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xxxl),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 280),
                                          child: SizedBox(
                                            width: 260,
                                            height: 56,
                                            child: PrimaryButton(
                                              text: 'Download APK v1.0.0',
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                                                    backgroundColor: Color(0xFF22C55E),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                      // Apply scrolling only on mobile
                      if (isMobile) {
                        content = SingleChildScrollView(child: content);
                      }
                      return content;
                    },
                  ),
                ),
              ],
            ),
          ),
          // Image courtesy credit - bottom right
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Image courtesy of A1 Organics',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== NEW CAROUSEL PHONE PREVIEW ====================
class PhoneCarouselPreview extends StatefulWidget {
  const PhoneCarouselPreview({super.key});

  @override
  State<PhoneCarouselPreview> createState() => _PhoneCarouselPreviewState();
}

class _PhoneCarouselPreviewState extends State<PhoneCarouselPreview> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phone Frame with Carousel
        Container(
          width: 280,
          height: 570,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                blurRadius: 50,
                offset: const Offset(0, 20),
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Column(
            children: [
              // Status Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('9:41', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 14),
                      SizedBox(width: 3),
                      Icon(Icons.wifi, size: 14),
                      SizedBox(width: 3),
                      Icon(Icons.battery_full, size: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // PageView for Carousel — MACHINES REMOVED, DASHBOARD ADDED
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: const [
                    DashboardPage(),   // ← Restored
                    SettingsPage(),
                    StatsPage(),
                    ActivityPage(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Page Indicator Dots — now 4 dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Color(0xFF22C55E)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Page Title
        Text(
          _getPageTitle(_currentPage),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Settings';
      case 2:
        return 'Statistics';
      case 3:
        return 'Activity';
      default:
        return '';
    }
  }
}

// ==================== PAGE 1: DASHBOARD — Fixed Overflow & Hex Colors ====================
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            // Batch Tracker Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Batch Tracker',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  // Filter chips — compact
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.precision_manufacturing, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text('All Machines', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text('All Batches', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Decomposition Progress', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  // ✅ FIXED OVERFLOW: Use Flexible + constrained width + clip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40, // fixed width for % label
                        child: Text(
                          '0%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Icon(Icons.lightbulb_outline, size: 40, color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Select a machine to get started',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Select a Machine First',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Drum Controller Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Drum Controller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(fontSize: 10, color: Color(0xFFD97706), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('No Active Batch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Start a composting batch to use drum rotation',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PAGE 2: SETTINGS ====================
// (Keep exactly as in your file — no changes needed)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ACCOUNT', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingsCard(
              items: [
                _SettingsItem(
                  icon: Icons.person,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Profile Information',
                  subtitle: 'msaver225@gmail.com',
                  hasArrow: true,
                ),
                _SettingsItem(
                  icon: Icons.lock,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Change Password',
                  hasArrow: true,
                ),
                _SettingsItem(
                  icon: Icons.email,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Email Updates',
                  subtitle: 'Receive updates and newsletters',
                  hasToggle: true,
                  toggleValue: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('NOTIFICATIONS', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingsCard(
              items: [
                _SettingsItem(
                  icon: Icons.notifications,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Push Notifications',
                  subtitle: 'Receive app notifications',
                  hasToggle: true,
                  toggleValue: true,
                ),
                _SettingsItem(
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Email Reports',
                  subtitle: 'Get weekly reports via email',
                  hasToggle: true,
                  toggleValue: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('ALERT PREFERENCES', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingsCard(
              items: [
                _SettingsItem(
                  icon: Icons.thermostat,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Temperature Alerts',
                  hasToggle: true,
                  toggleValue: true,
                ),
                _SettingsItem(
                  icon: Icons.water_drop,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Moisture Alerts',
                  hasToggle: true,
                  toggleValue: true,
                ),
                _SettingsItem(
                  icon: Icons.air,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Oxygen Alerts',
                  hasToggle: true,
                  toggleValue: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
              if (index < items.length - 1)
                Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool hasArrow;
  final bool hasToggle;
  final bool toggleValue;
  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.hasArrow = false,
    this.hasToggle = false,
    this.toggleValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (hasArrow) Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          if (hasToggle)
            Switch(
              value: toggleValue,
              onChanged: (val) {},
              activeThumbColor: const Color(0xFF22C55E),
              activeTrackColor: const Color(0xFFA7F3D0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}

// ==================== PAGE 3: STATISTICS ====================
// (Keep as-is)
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.precision_manufacturing, size: 16, color: Color(0xFF22C55E)),
                        const SizedBox(width: 6),
                        const Text('Machine01', style: TextStyle(fontSize: 11)),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 16, color: Color(0xFF22C55E)),
                        const SizedBox(width: 6),
                        const Text('Official Batch 1', style: TextStyle(fontSize: 11)),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Temperature Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9A62).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Temperature', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('0.0 °C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFFF9A62))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Internal compost pile temperature', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  const SizedBox(height: 12),
                  const Text('Ideal Range: 55°C - 70°C', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: CustomPaint(
                      painter: _LineChartPainter(),
                      child: Container(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Trending up by 5.2% this week', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('More Information:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  _InfoBullet('Indicates microbial activity level'),
                  _InfoBullet('Peak heat shows thermophilic phase'),
                  _InfoBullet('Ensures pathogen elimination'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Moisture Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Moisture', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('0.0 %', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Compost moisture content', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  const SizedBox(height: 12),
                  const Text('Ideal Range: 40% - 60%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;
  const _InfoBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 10)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 9, color: Colors.grey))),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF9A62)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
    // Draw dots
    final dotPaint = Paint()
      ..color = const Color(0xFFFF9A62)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== PAGE 4: ACTIVITY ====================
// (Keep as-is)
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select A Batch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF22C55E))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('All Batches', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // View All Activity Button
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.access_time, color: Color(0xFF22C55E), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('View All Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Substrate Section
            _ActivitySection(
              title: 'Substrate',
              items: [
                _ActivityCategoryItem(icon: Icons.eco, label: 'Green', color: const Color(0xFF22C55E)),
                _ActivityCategoryItem(icon: Icons.spa, label: 'Brown', color: const Color(0xFF92400E)),
                _ActivityCategoryItem(icon: Icons.recycling, label: 'Compost', color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            // Alerts Section
            _ActivitySection(
              title: 'Alerts',
              items: [
                _ActivityCategoryItem(icon: Icons.thermostat, label: 'Temperature', color: const Color(0xFFFF9A62)),
                _ActivityCategoryItem(icon: Icons.water_drop, label: 'Moisture', color: const Color(0xFF3B82F6)),
                _ActivityCategoryItem(icon: Icons.air, label: 'Air Quality', color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final List<_ActivityCategoryItem> items;
  const _ActivitySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    title == 'Substrate' ? Icons.eco : Icons.notifications,
                    size: 16,
                    color: const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 6),
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const Text('View All >', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items,
          ),
        ],
      ),
    );
  }
}

class _ActivityCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActivityCategoryItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==================== HEADER & HELPER WIDGETS ====================
// (Keep exactly as in your second file)
class _AppHeader extends StatefulWidget {
  final Function(String) onBreadcrumbTap;
  final String activeSection;
  final bool isScrolled;
  const _AppHeader({
    required this.onBreadcrumbTap,
    required this.activeSection,
    required this.isScrolled,
  });

  @override
  State<_AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<_AppHeader> {
  bool _isLogoHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isVerySmall = screenWidth < 320;
    final horizontalPadding = isVerySmall
        ? AppSpacing.sm
        : (isMobile ? AppSpacing.md : (isTablet ? AppSpacing.lg : AppSpacing.xxxl));
    final headerHeight = isMobile ? 64.0 : 88.0;
    final logoSize = isVerySmall ? 32.0 : (isMobile ? 40.0 : 50.0);
    final appNameFontSize = isVerySmall ? 16.0 : (isMobile ? 20.0 : 24.0);
    final showAppName = screenWidth > 280;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isScrolled ? Colors.white : const Color(0xFFE0F2FE),
        border: widget.isScrolled
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB), // ✅ Fixed valid 8-digit hex
                  width: 1,
                ),
              )
            : null,
        boxShadow: widget.isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isLogoHovered = true),
                onExit: (_) => setState(() => _isLogoHovered = false),
                child: GestureDetector(
                  onTap: () => widget.onBreadcrumbTap('home'),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isLogoHovered ? 1.05 : 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Image.asset(
                            'assets/images/Accelorot Logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return SvgPicture.asset(
                                'assets/images/Accelorot_logo.svg',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        if (showAppName) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: WebTextStyles.h2.copyWith(
                                color: _isLogoHovered ? WebColors.success : WebColors.buttonsPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: appNameFontSize,
                              ),
                              child: const Text(
                                'Accel-O-Rot',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isMobile) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: WebColors.textPrimary,
                      size: isVerySmall ? 24 : 28,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Open menu',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    width: isVerySmall ? 90 : 110,
                    height: 32,
                    child: PrimaryButton(
                      text: isVerySmall ? 'Start' : 'Get Started',
                      onPressed: () {
                        context.go('/');
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BreadcrumbItem(
                        label: 'Home',
                        id: 'home',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Features',
                        id: 'features',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'How It Works',
                        id: 'how-it-works',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Impact',
                        id: 'impact',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Downloads',
                        id: 'download',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'FAQs',
                        id: 'faq',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    height: isTablet ? 38 : 42,
                    child: HeaderButton(
                      text: 'Login',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 140,
                    height: isTablet ? 38 : 42,
                    child: PrimaryButton(
                      text: 'Get Started',
                      onPressed: () {
                        context.go('/');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbItem extends StatefulWidget {
  final String label;
  final String id;
  final String active;
  final Function(String) onTap;
  final double fontSize;
  const _BreadcrumbItem({
    required this.label,
    required this.id,
    required this.active,
    required this.onTap,
    this.fontSize = 16,
  });

  @override
  State<_BreadcrumbItem> createState() => _BreadcrumbItemState();
}

class _BreadcrumbItemState extends State<_BreadcrumbItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.active == widget.id;
    final double paddingVertical = widget.fontSize < 16 ? 6 : 8;
    final double paddingHorizontal = widget.fontSize < 16 ? 4 : 6;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.id),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: paddingVertical,
            horizontal: paddingHorizontal,
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? WebColors.success
                  : _isHovered
                      ? WebColors.success
                      : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  final double size;
  const _Chevron({this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size < 20 ? 6 : 10,
      ),
      child: Icon(
        Icons.chevron_right,
        size: size,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }
}