import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSpacing {
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
            ),
          ),
          // Dark overlay for text contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          // Content with responsive padding
          SafeArea(
            child: Column(
              children: [
                // 🔙 Back to Home Link (top-left) - WHITE TEXT
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                          padding: EdgeInsets.zero,
                          tooltip: 'Back to Home',
                          splashRadius: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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
                                      'receive real-time insights, and manage your organic waste efficiently.\n\n'
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
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                                                backgroundColor: Color(0xFF22C55E),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF22C55E),
                                            foregroundColor: Colors.white,
                                            elevation: 2,
                                            shadowColor: Colors.black.withValues(alpha: 0.25),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.download, size: 18),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  'Download Accel-O-Rot\nv1.0.0.apk',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxxl),
                                  ],
                                ),
                              ),
                              _PhonePreview(),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Desktop: Phone preview on LEFT
                                Expanded(
                                  flex: 1,
                                  child: Center(child: _PhonePreview()),
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
                                        'receive real-time insights, and manage your organic waste efficiently.\n\n'
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
                                          child: ElevatedButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                                                  backgroundColor: Color(0xFF22C55E),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF22C55E),
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              shadowColor: Colors.black.withValues(alpha: 0.25),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.download, size: 18),
                                                SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    'Download Accel-O-Rot\nv1.0.0.apk',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                        content = SingleChildScrollView(
                          child: content,
                        );
                      }

                      return content;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Phone preview and helper widgets
class _PhonePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 650,
      padding: const EdgeInsets.all(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('9:41', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.wifi, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Operators',
                            value: '15',
                            percentage: '13%',
                            icon: Icons.person_outline,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Total Machines',
                            value: '12',
                            percentage: '8%',
                            icon: Icons.settings_outlined,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analytics',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Text(
                                    'Activity',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Reports',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Activity Overview',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Per Day',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 90,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                _ChartBar(height: 0, label: 'Thu'),
                                _ChartBar(height: 0, label: 'Fri'),
                                _ChartBar(height: 0, label: 'Sat'),
                                _ChartBar(height: 70, label: 'Sun'),
                                _ChartBar(height: 0, label: 'Mon'),
                                _ChartBar(height: 0, label: 'Tue'),
                                _ChartBar(height: 0, label: 'Wed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                              const Text(
                                'Recent Activities',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Icon(Icons.refresh, size: 16, color: Colors.grey.shade600),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.air,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Aerator',
                            subtitle: 'machine01',
                            category: 'Aerator',
                            status: 'COMPLETE',
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.settings_input_component,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Drum Controller',
                            subtitle: 'machine01',
                            category: 'Drum',
                            status: 'COMPLETE',
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.settings_input_component,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Drum Controller',
                            subtitle: 'machine01',
                            category: 'Drum',
                            status: 'COMPLETE',
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.air,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Aerator',
                            subtitle: 'machine01',
                            category: 'Drum',
                            status: 'COMPLETE',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$percentage compared this month',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double height;
  final String label;

  const _ChartBar({
    required this.height,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 18,
          height: height,
          decoration: BoxDecoration(
            color: height > 0 ? const Color(0xFF22C55E) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String category;
  final String status;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}