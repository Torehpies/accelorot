// lib/ui/landing_page/widgets/impact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';

class ImpactSection extends StatelessWidget {
  final List<ImpactStatModel> stats;
  const ImpactSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl * 2,
        vertical: AppSpacing.xxxl * 3,
      ),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context);
        },
      ),
    );
  }

  // ===================== MOBILE =====================
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'MAKING A SUSTAINABLE IMPACT',
            textAlign: TextAlign.center,
            style: WebTextStyles.h2.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: WebColors.textTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
            textAlign: TextAlign.center,
            style: WebTextStyles.sectionSubtitle.copyWith(
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          _buildImpactItem(Icons.delete_outline, 'Reduces landfill waste', isMobile: true),
          const SizedBox(height: AppSpacing.sm),
          _buildImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', isMobile: true),
          const SizedBox(height: AppSpacing.sm),
          _buildImpactItem(Icons.eco_outlined, 'Empowers communities', isMobile: true),

          const SizedBox(height: AppSpacing.xl),

          AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return _buildStatsContainer(index, stats[index], isMobile: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===================== DESKTOP =====================
  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      height: 540,
      child: Row(
        children: [
          // LEFT CONTENT – CENTER VERTICALLY
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Making a Sustainable Impact',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: 500,
                    child: Text(
                      'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
                      style: WebTextStyles.sectionSubtitle.copyWith(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildImpactItem(Icons.delete_outline, 'Reduces landfill waste'),
                  const SizedBox(height: AppSpacing.md),
                  _buildImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost'),
                  const SizedBox(height: AppSpacing.md),
                  _buildImpactItem(Icons.eco_outlined, 'Empowers communities'),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.xxl),

          // RIGHT CONTENT (STATS)
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-32, 0),
                      child: SizedBox(
                        width: 420,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildStatsContainer(0, stats[0])),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: _buildStatsContainer(1, stats[1])),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(child: _buildStatsContainer(2, stats[2])),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: _buildStatsContainer(3, stats[3])),
                              ],
                            ),
                          ],
                        ),
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
  }

  // ===================== STAT CARD =====================
  Widget _buildStatsContainer(int index, ImpactStatModel stat, {bool isMobile = false}) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isGreen ? const Color.fromARGB(255, 74, 211, 126) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isGreen ? Colors.transparent : const Color(0xFFE0E0E0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stat.value,
              style: TextStyle(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.w800,
                color: isGreen ? Colors.white : WebColors.textTitle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 10 : 13,
                fontWeight: FontWeight.w500,
                color: isGreen ? Colors.white : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== IMPACT ITEM =====================
  Widget _buildImpactItem(IconData icon, String text, {bool isMobile = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF28A85A).withAlpha(26), // <- updated to remove deprecation
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF28A85A)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF444444),
          ),
        ),
      ],
    );
  }
}
