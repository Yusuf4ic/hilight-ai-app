import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 14),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildGoalCard(),
          const SizedBox(height: 20),
          _buildSectionLabel('Account'),
          _buildMenuItem(Icons.person_outline, 'Edit Profile', () {}),
          _buildMenuItem(Icons.notifications_outlined, 'Notifications', () {}),
          _buildMenuItem(Icons.lock_outline, 'Privacy', () {}),
          const SizedBox(height: 16),
          _buildSectionLabel('Preferences'),
          _buildMenuItem(Icons.palette_outlined, 'Appearance', () {}),
          _buildMenuItem(Icons.language_outlined, 'Language', () {}),
          _buildMenuItem(Icons.sync_outlined, 'Sync & Backup', () {}),
          const SizedBox(height: 16),
          _buildSectionLabel('About'),
          _buildMenuItem(Icons.star_outline, 'Rate HiLight', () {}),
          _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
          _buildMenuItem(Icons.info_outline, 'App Version 1.0.0', () {}, showArrow: false),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.divider,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFB4B2A9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alex Johnson',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'alex@example.com',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.aiBadgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Pro Plan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.aiBadgeFg,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Yearly Reading Goal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Text(
                '8 / 36 books',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 8 / 36,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.aiAccent),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '22% completed — keep going!',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C2C2), width: 0.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, size: 18, color: Color(0xFFD94F4F)),
          SizedBox(width: 8),
          Text(
            'Log Out',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD94F4F),
            ),
          ),
        ],
      ),
    );
  }
}
