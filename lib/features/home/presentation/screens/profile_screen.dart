import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';

// ─── Entry point (для теста) ───────────────────────────────────────────────
void main() => runApp(const HiLightApp());

class HiLightApp extends StatelessWidget {
  const HiLightApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HiLight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF534AB7)),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

// ─── Цвета ────────────────────────────────────────────────────────────────
class AppColors {
  static const background   = Color(0xFFFFFFFF);
  static const surface      = Color(0xFFF9F9F7);
  static const cardBorder   = Color(0xFFE8E6E0);
  static const divider      = Color(0xFFE8E6E0);
  static const textPrimary  = Color(0xFF1A1A1A);
  static const textSecondary= Color(0xFF888886);
  static const textHint     = Color(0xFFAAAAAA);
  static const aiAccent     = Color(0xFF534AB7);
  static const aiBadgeBg    = Color(0xFFEEEDFE);
  static const aiBadgeFg    = Color(0xFF3C3489);
  static const success      = Color(0xFF1D9E75);
  static const danger       = Color(0xFFD94F4F);
  static const dangerBg     = Color(0xFFFDEDED);
  static const dangerBorder = Color(0xFFF5C2C2);
  static const avatarBg     = Color(0xFFB4B2A9);
  static const starOn       = Color(0xFFEF9F27);
}

// ─── Модель состояния профиля ─────────────────────────────────────────────
class ProfileData {
  String name;
  String email;
  String bio;
  int booksRead;
  int booksTarget;

  ProfileData({
    this.name        = 'Alex Johnson',
    this.email       = 'alex@example.com',
    this.bio         = 'Avid reader. 36 books a year or bust.',
    this.booksRead   = 8,
    this.booksTarget = 36,
  });

  double get progress => (booksRead / booksTarget).clamp(0.0, 1.0);
  int    get progressPct => (progress * 100).round();

  String get goalNote {
    if (progressPct >= 100) return '🎉 Goal completed!';
    if (progressPct >= 50)  return '$progressPct% completed — great job!';
    return '$progressPct% completed — keep going!';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ProfileScreen
// ═══════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profile = ProfileData();

  void _updateProfile(ProfileData updated) =>
      setState(() {
        _profile.name        = updated.name;
        _profile.email       = updated.email;
        _profile.bio         = updated.bio;
      });

  void _updateGoal(int read, int target) =>
      setState(() {
        _profile.booksRead   = read;
        _profile.booksTarget = target;
      });

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _LogoutDialog(),
    );
    if (ok == true && mounted) {
      setState(() {
        _profile.name  = 'Signed out';
        _profile.email = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 14),
            _Header(profile: _profile),
            const SizedBox(height: 24),
            _GoalCard(
              profile: _profile,
              onTap: () async {
                final result = await Navigator.push<Map<String, int>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GoalEditorScreen(
                      read:   _profile.booksRead,
                      target: _profile.booksTarget,
                    ),
                  ),
                );
                if (result != null) _updateGoal(result['read']!, result['target']!);
              },
            ),
            const SizedBox(height: 20),
            _SectionLabel(S.account),
            _MenuItem(Icons.person_outline,        S.editProfile,   () async {
              final updated = await Navigator.push<ProfileData>(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
              );
              if (updated != null) _updateProfile(updated);
            }),
            _MenuItem(Icons.notifications_outlined,S.notifications,  () => _push(const NotificationsScreen())),
            _MenuItem(Icons.lock_outline,          S.privacy,        () => _push(const PrivacyScreen())),
            const SizedBox(height: 16),
            _SectionLabel(S.preferences),
            _MenuItem(Icons.palette_outlined,      S.appearance,     () => _push(const AppearanceScreen())),
            _MenuItem(Icons.language_outlined,     S.language,       () => _push(const LanguageScreen())),
            _MenuItem(Icons.sync_outlined,         S.syncBackup,  () => _push(const SyncScreen())),
            const SizedBox(height: 16),
            _SectionLabel(S.about),
            _MenuItem(Icons.star_outline,          S.rateHilight,   () => _push(const RateScreen())),
            _MenuItem(Icons.help_outline,          S.helpSupport, () => _push(const HelpScreen())),
            _MenuItem(Icons.info_outline,          S.appVersion, () => _push(const VersionScreen()), showArrow: false),
            const SizedBox(height: 24),
            _LogoutButton(onTap: _confirmLogout),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

// ─── Header ───────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.avatarBg,
              child: const Icon(Icons.person, size: 32, color: AppColors.textSecondary),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(profile.email,
                style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.aiBadgeBg, borderRadius: BorderRadius.circular(8)),
              child: Text(S.proPlan,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.aiBadgeFg)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Goal Card ────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.profile, required this.onTap});
  final ProfileData profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(S.yearlyReadingGoal,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Spacer(),
                Text('${profile.booksRead} / ${profile.booksTarget} books',
                    style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: profile.progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.aiAccent),
              ),
            ),
            const SizedBox(height: 8),
            Text(profile.goalNote,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.textHint, letterSpacing: 0.8)),
      );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.icon, this.label, this.onTap, {this.showArrow = true});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
            if (showArrow)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dangerBorder, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18, color: AppColors.danger),
            SizedBox(width: 8),
             Text(S.logOut,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger)),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Dialog ────────────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       title: Text(S.logOutQuestion),
       content: Text(S.logOutMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
           child: Text(S.cancel, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
           child: Text(S.logOut, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Edit Profile Screen
// ═══════════════════════════════════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});
  final ProfileData profile;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _bio;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _name  = TextEditingController(text: widget.profile.name);
    _email = TextEditingController(text: widget.profile.email);
    _bio   = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _bio.dispose();
    super.dispose();
  }

  void _save() {
    final updated = ProfileData(
      name:        _name.text.trim().isEmpty  ? 'Alex Johnson' : _name.text.trim(),
      email:       _email.text.trim().isEmpty ? 'alex@example.com' : _email.text.trim(),
      bio:         _bio.text.trim(),
      booksRead:   widget.profile.booksRead,
      booksTarget: widget.profile.booksTarget,
    );
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context, updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.editProfile),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Field(S.fullName, _name),
            const SizedBox(height: 16),
            _Field(S.email, _email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _Field(S.bio, _bio, maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aiAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: Text(S.saveChanges, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
            if (_saved) ...[
              const SizedBox(height: 12),
              Text(S.saved, style: const TextStyle(color: AppColors.success, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.controller, {this.maxLines = 1, this.keyboardType});
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.aiAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Goal Editor Screen
// ═══════════════════════════════════════════════════════════════════════════
class GoalEditorScreen extends StatefulWidget {
  const GoalEditorScreen({super.key, required this.read, required this.target});
  final int read;
  final int target;
  @override
  State<GoalEditorScreen> createState() => _GoalEditorScreenState();
}

class _GoalEditorScreenState extends State<GoalEditorScreen> {
  late int _read;
  late int _target;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _read   = widget.read;
    _target = widget.target;
  }

  double get _progress => (_read / _target).clamp(0.0, 1.0);
  int    get _pct      => (_progress * 100).round();
  String get _note {
    if (_pct >= 100) return '🎉 Goal completed!';
    if (_pct >= 50)  return '$_pct% completed — great job!';
    return '$_pct% completed — keep going!';
  }

  void _save() {
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context, {'read': _read, 'target': _target});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(S.yearlyReadingGoal),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _NumberField(S.booksReadSoFar, _read, (v) => setState(() => _read = v)),
            const SizedBox(height: 16),
            _NumberField(S.targetBooks, _target, (v) => setState(() => _target = v)),
            const SizedBox(height: 20),
            Text('$_pct%',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.aiAccent)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: _progress, minHeight: 10,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.aiAccent),
              ),
            ),
            const SizedBox(height: 8),
            Text(_note, style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aiAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: Text(S.saveGoal, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
            if (_saved) ...[
              const SizedBox(height: 12),
              Text(S.goalUpdated, style: const TextStyle(color: AppColors.success, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField(this.label, this.value, this.onChanged);
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          onChanged: (s) { final v = int.tryParse(s); if (v != null && v > 0) onChanged(v); },
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.cardBorder, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.aiAccent)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Notifications Screen
// ═══════════════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Map<String, bool> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = {
      S.pushNotifications:    true,
      S.readingReminders:     true,
      S.weeklyProgress:       false,
      S.newRecommendations:   true,
      S.friendActivity:       false,
      S.promotions:           false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.notifications),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: ListView(
        children: _prefs.entries.map((e) => _ToggleRow(
          label: e.key,
          value: e.value,
          onChanged: (v) => setState(() => _prefs[e.key] = v),
        )).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Privacy Screen
// ═══════════════════════════════════════════════════════════════════════════
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late Map<String, bool> _prefs;
  late Map<String, String> _descs;

  @override
  void initState() {
    super.initState();
    _prefs = {
      S.publicProfile:        true,
      S.showReadingActivity:  false,
      S.readingStatsVisible:  true,
      S.dataPersonalization:  true,
    };
    _descs = {
      S.publicProfile:        S.publicProfileDesc,
      S.showReadingActivity:  S.showReadingActivityDesc,
      S.readingStatsVisible:  S.readingStatsVisibleDesc,
      S.dataPersonalization:  S.dataPersonalizationDesc,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.privacy),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _prefs.entries.map((e) => _ToggleRow(
          label: e.key,
          subtitle: _descs[e.key],
          value: e.value,
          onChanged: (v) => setState(() => _prefs[e.key] = v),
        )).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Appearance Screen
// ═══════════════════════════════════════════════════════════════════════════
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});
  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _theme    = 'light';
  double _textSize = 3;

  static const _themes = [
    {'key': 'light', 'label': 'Light',  'icon': Icons.wb_sunny_outlined},
    {'key': 'dark',  'label': 'Dark',   'icon': Icons.dark_mode_outlined},
    {'key': 'auto',  'label': 'System', 'icon': Icons.devices_outlined},
  ];

  static const _sizes = [12.0, 13.0, 14.0, 16.0, 18.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.appearance),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(S.theme),
            const SizedBox(height: 8),
            Row(
              children: _themes.map((t) {
                final selected = _theme == t['key'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _theme = t['key'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected ? AppColors.aiAccent : AppColors.cardBorder,
                          width: selected ? 2 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(t['icon'] as IconData, color: selected ? AppColors.aiAccent : AppColors.textSecondary),
                          const SizedBox(height: 6),
                          Text(t['label'] as String,
                              style: TextStyle(fontSize: 12,
                                  color: selected ? AppColors.aiAccent : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _SectionLabel(S.textSize),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Expanded(
                  child: Slider(
                    value: _textSize,
                    min: 1, max: 5, divisions: 4,
                    activeColor: AppColors.aiAccent,
                    onChanged: (v) => setState(() => _textSize = v),
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                S.sampleText,
                style: TextStyle(fontSize: _sizes[_textSize.round() - 1], color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Language Screen
// ═══════════════════════════════════════════════════════════════════════════
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});
  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  static const _langs = [
    {'code': 'en', 'flag': '🇺🇸', 'label': 'English'},
    {'code': 'uz', 'flag': '🇺🇿', 'label': "O'zbek tili"},
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.language),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _langs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          final lang = _langs[i];
          final sel  = currentLocale.languageCode == lang['code'];
          return GestureDetector(
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(Locale(lang['code']!));
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(
                  color: sel ? AppColors.aiAccent : AppColors.cardBorder,
                  width: sel ? 1.5 : 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(lang['label']!, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  const Spacer(),
                  if (sel) const Icon(Icons.check, color: AppColors.aiAccent, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Sync Screen
// ═══════════════════════════════════════════════════════════════════════════
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _syncing = false;
  bool _synced  = false;
  late Map<String, bool> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = {
      S.autoSyncWifi:         true,
      S.syncReadingProgress:  true,
      S.syncHighlightsNotes:  true,
    };
  }

  Future<void> _doSync() async {
    setState(() { _syncing = true; _synced = false; });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _syncing = false; _synced = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.syncBackup),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SyncSource(icon: Icons.drive_folder_upload_outlined, name: 'Google Drive',
                sub: S.lastSynced, statusLabel: S.synced, statusColor: AppColors.success),
            const SizedBox(height: 8),
            _SyncSource(icon: Icons.cloud_outlined, name: 'iCloud',
                sub: S.notConnected, statusLabel: S.connect, statusColor: AppColors.textHint),
            const SizedBox(height: 16),
            ..._prefs.entries.map((e) => _ToggleRow(
              label: e.key, value: e.value,
              onChanged: (v) => setState(() => _prefs[e.key] = v),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aiAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _syncing ? null : _doSync,
                child: _syncing
                    ? const SizedBox(height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(S.syncNow, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
            if (_synced) ...[
              const SizedBox(height: 12),
              Center(child: Text(S.syncedSuccessfully,
                  style: const TextStyle(color: AppColors.success, fontSize: 13))),
            ],
          ],
        ),
      ),
    );
  }
}

class _SyncSource extends StatelessWidget {
  const _SyncSource({required this.icon, required this.name, required this.sub,
      required this.statusLabel, required this.statusColor});
  final IconData icon;
  final String name, sub, statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            Text(sub,  style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ])),
          Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: statusColor)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Rate Screen
// ═══════════════════════════════════════════════════════════════════════════
class RateScreen extends StatefulWidget {
  const RateScreen({super.key});
  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _stars = 0;
  bool _submitted = false;
  final _reviewCtrl = TextEditingController();
  List<String> get _labels => ['', S.rateAwful, S.rateNotGreat, S.rateOkay, S.rateGood, S.rateExcellent];

  @override
  void dispose() { _reviewCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.rateHilight),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _submitted ? _Thanks() : Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Icon(
                  i < _stars ? Icons.star : Icons.star_border,
                  size: 40,
                  color: i < _stars ? AppColors.starOn : AppColors.cardBorder,
                ),
              )),
            ),
            const SizedBox(height: 12),
            Text(_stars > 0 ? _labels[_stars] : S.tapStarToRate,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            if (_stars > 0) ...[
              const SizedBox(height: 20),
              _Field(S.leaveReview, _reviewCtrl, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.aiAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => setState(() => _submitted = true),
                  child: Text(S.submitReview, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Thanks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 64, color: Color(0xFFD85A30)),
          const SizedBox(height: 16),
          Text(S.thankYou, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(S.feedbackHelps,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Help Screen
// ═══════════════════════════════════════════════════════════════════════════
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late List<Map<String, String>> _faqs;

  final Set<int> _open = {};

  @override
  void initState() {
    super.initState();
    _faqs = [
      {'q': S.faq1q, 'a': S.faq1a},
      {'q': S.faq2q, 'a': S.faq2a},
      {'q': S.faq3q, 'a': S.faq3a},
      {'q': S.faq4q, 'a': S.faq4a},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.helpSupport),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._faqs.asMap().entries.map((e) {
            final isOpen = _open.contains(e.key);
            return GestureDetector(
              onTap: () => setState(() => isOpen ? _open.remove(e.key) : _open.add(e.key)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(e.value['q']!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                        Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: AppColors.textHint),
                      ],
                    ),
                    if (isOpen) ...[
                      const SizedBox(height: 8),
                      Text(e.value['a']!,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                    ],
                  ],
                ),
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.mail_outline, size: 22, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(S.contactSupport, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const Text('support@hilight.app', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Version Screen
// ═══════════════════════════════════════════════════════════════════════════
class VersionScreen extends StatelessWidget {
  const VersionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.appVersion),
          backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📚', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('1.0.0', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.aiAccent)),
              const SizedBox(height: 4),
              Text(S.readingCompanion,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Text('Build 2026.05.24\n© 2026 HiLight Inc.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Shared widget — Toggle Row
// ═══════════════════════════════════════════════════════════════════════════
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged, this.subtitle});
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.aiAccent,
          ),
        ],
      ),
    );
  }
}
