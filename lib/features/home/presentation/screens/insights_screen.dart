import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static const _insights = [
    _Insight(
      'Weekly Summary',
      'You highlighted 14 quotes this week — your best streak yet. '
          'Most focused on creativity and deep work.',
      Icons.auto_awesome,
      AppColors.aiAccent,
      AppColors.aiBadgeBg,
    ),
    _Insight(
      'Top Theme',
      'Creativity & Constraints appears in 6 of your recent highlights. '
          'Consider writing a note connecting these ideas.',
      Icons.lightbulb_outline,
      AppColors.quoteAccent,
      AppColors.quoteBadgeBg,
    ),
    _Insight(
      'Reading Pace',
      'You are averaging 3 books per month. '
          'At this pace you will hit your 36-book yearly goal.',
      Icons.bar_chart,
      AppColors.voiceAccent,
      Color(0xFFEEEDFA),
    ),
    _Insight(
      'Forgotten Gem',
      'You highlighted this 30 days ago — worth revisiting:\n'
          '"Subtract the obvious, add the meaningful."',
      Icons.history,
      AppColors.aiAccent,
      AppColors.aiBadgeBg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          _buildStatsRow(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _insights.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _InsightTile(insight: _insights[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        'Insights',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatChip(label: 'This week', value: '14', icon: Icons.bookmark),
          const SizedBox(width: 10),
          _StatChip(label: 'Books read', value: '8', icon: Icons.menu_book),
          const SizedBox(width: 10),
          _StatChip(label: 'Streak', value: '5d', icon: Icons.local_fire_department),
        ],
      ),
    );
  }
}

class _Insight {
  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const _Insight(this.title, this.body, this.icon, this.accentColor, this.bgColor);
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: insight.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(insight.icon, size: 18, color: insight.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insight.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: insight.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
