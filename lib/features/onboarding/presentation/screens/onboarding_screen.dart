import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Onboarding Screen — Warm beige theme with animated bokeh orbs
// ═══════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Orb animation controllers ──
  late final AnimationController _orbController;
  late final AnimationController _fadeController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;

  // Warm beige palette
  static const _bgColor = Color.fromARGB(255, 228, 209, 178);
  static const _textColor = Color(0xFF2C2C2A);
  static const _subtitleColor = Color(0xFF5F5E5A);
  static const _hintColor = Color(0xFF888780);

  // ── Page data ──
  static const _pages = [
    _OnboardingPage(
      title: 'Welcome to\nHiLight',
      subtitle: 'Your AI-powered reading companion',
      description:
          'Transform how you read, learn, and organize knowledge with the help of artificial intelligence.',
      orbs: [
        _OrbData(0.20, 0.18, 190, Color(0xFFF5A623), Color(0xFFFFD88A)),
        _OrbData(0.72, 0.30, 150, Color(0xFF5DCAA5), Color(0xFFB2F0DB)),
        _OrbData(0.45, 0.58, 110, Color(0xFF7F77DD), Color(0xFFCBC6F5)),
      ],
    ),
    _OnboardingPage(
      title: 'Meet Lumi\nYour AI Tutor',
      subtitle: 'Scan • Listen • Summarize • Learn',
      description:
          'OCR scanning, voice notes, AI summaries, quiz generation — all powered by Lumi, your personal study assistant.',
      orbs: [
        _OrbData(0.28, 0.22, 170, Color(0xFF7F77DD), Color(0xFFD4CFFF)),
        _OrbData(0.68, 0.42, 140, Color(0xFFE74C8B), Color(0xFFFFB8D4)),
        _OrbData(0.15, 0.60, 120, Color(0xFF3498DB), Color(0xFFACDAFF)),
      ],
    ),
    _OnboardingPage(
      title: 'Start Your\nJourney',
      subtitle: 'Knowledge at your fingertips',
      description:
          'Highlight what matters, let AI organize the rest. Your learning journey begins now.',
      orbs: [
        _OrbData(0.32, 0.25, 180, Color(0xFF5DCAA5), Color(0xFFA8F0D5)),
        _OrbData(0.75, 0.18, 130, Color(0xFFF5A623), Color(0xFFFFE0A0)),
        _OrbData(0.50, 0.52, 160, Color(0xFFFF6B6B), Color(0xFFFFBFBF)),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _fadeController.reset();
    _fadeController.forward();
    _textController.reset();
    _textController.forward();
  }

  void _onGetStarted() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ── Animated background orbs ──
          ..._buildOrbs(_pages[_currentPage].orbs),

          // ── Page content ──
          SafeArea(
            child: Column(
              children: [
                // ── Skip button ──
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 20),
                    child: _currentPage < _pages.length - 1
                        ? TextButton(
                            onPressed: _onGetStarted,
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: _hintColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                ),

                // ── PageView ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _buildPage(_pages[i]),
                  ),
                ),

                // ── Bottom controls ──
                _buildBottomControls(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Orbs ──

  List<Widget> _buildOrbs(List<_OrbData> orbs) {
    return orbs.map((orb) {
      return AnimatedBuilder(
        animation: _orbController,
        builder: (_, __) {
          final t = _orbController.value;
          final dx = sin(t * 2 * pi + orb.xFrac * 10) * 30;
          final dy = cos(t * 2 * pi * 0.7 + orb.yFrac * 8) * 25;

          return Positioned(
            left: MediaQuery.of(context).size.width * orb.xFrac + dx - orb.radius,
            top: MediaQuery.of(context).size.height * orb.yFrac + dy - orb.radius,
            child: Container(
              width: orb.radius * 2,
              height: orb.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    orb.color1.withValues(alpha: 0.35),
                    orb.color2.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  // ── Page content ──

  Widget _buildPage(_OnboardingPage page) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // ── Logo icon ──
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) {
                final scale = 1.0 + _pulseController.value * 0.05;
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 34,
                  color: _textColor,
                ),
              ),
            ),
            const SizedBox(height: 44),

            // ── Title with typing reveal ──
            AnimatedBuilder(
              animation: _textController,
              builder: (_, __) {
                final chars =
                    (page.title.length * _textController.value).round();
                final visibleText = page.title.substring(0, chars);
                return Text(
                  visibleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // ── Subtitle ──
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _fadeController,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeController,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                ),
                child: Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _subtitleColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Description ──
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _fadeController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                ),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _hintColor,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  // ── Bottom controls ──

  Widget _buildBottomControls() {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Page dots ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? _textColor
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // ── CTA Button ──
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) {
              if (!isLast) return child!;
              final glow = 4.0 + _pulseController.value * 8;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5DCAA5).withValues(alpha: 0.25),
                      blurRadius: glow,
                      spreadRadius: glow * 0.2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLast ? _onGetStarted : () => _goToPage(_currentPage + 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLast ? _textColor : Colors.white,
                  foregroundColor: isLast ? Colors.white : _textColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isLast
                        ? BorderSide.none
                        : BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                child: Text(
                  isLast ? 'Get Started' : 'Continue',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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

// ═══════════════════════════════════════════════════════════════════════════
//  Data classes
// ═══════════════════════════════════════════════════════════════════════════

class _OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final List<_OrbData> orbs;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.orbs,
  });
}

class _OrbData {
  final double xFrac;
  final double yFrac;
  final double radius;
  final Color color1;
  final Color color2;

  const _OrbData(this.xFrac, this.yFrac, this.radius, this.color1, this.color2);
}
