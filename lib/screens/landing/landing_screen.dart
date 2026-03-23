import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk = Color(0xFF0A0F1E);
const kPrimary = Color(0xFF1D4ED8);
const kAccent = Color(0xFF38BDF8);
const kViolet = Color(0xFF7C3AED);
const kTeal = Color(0xFF0D9488);
const kAmber = Color(0xFFF59E0B);
const kRose = Color(0xFFF43F5E);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);

// ─────────────────────────────────────────────
//  MODELS (unchanged)
// ─────────────────────────────────────────────

class _Orb {
  final double x, y, size, phase, speed;
  final Color color;
  const _Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.phase,
    required this.speed,
  });
}

const _orbs = [
  _Orb(
    x: 0.08,
    y: 0.10,
    size: 180,
    color: Color(0xFF1D4ED8),
    phase: 0.0,
    speed: 0.6,
  ),
  _Orb(
    x: 0.75,
    y: 0.06,
    size: 140,
    color: Color(0xFF7C3AED),
    phase: 1.2,
    speed: 0.8,
  ),
  _Orb(
    x: 0.85,
    y: 0.40,
    size: 100,
    color: Color(0xFF0D9488),
    phase: 2.4,
    speed: 0.5,
  ),
  _Orb(
    x: 0.05,
    y: 0.55,
    size: 120,
    color: Color(0xFF38BDF8),
    phase: 0.7,
    speed: 0.7,
  ),
  _Orb(
    x: 0.60,
    y: 0.75,
    size: 90,
    color: Color(0xFFF43F5E),
    phase: 1.9,
    speed: 0.9,
  ),
  _Orb(
    x: 0.20,
    y: 0.85,
    size: 110,
    color: Color(0xFFF59E0B),
    phase: 3.1,
    speed: 0.6,
  ),
];

class _Feature {
  final String emoji, title, desc;
  final Color accent, bg;
  const _Feature({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.accent,
    required this.bg,
  });
}

const _features = [
  _Feature(
    emoji: '💼',
    title: 'Jobs & Internships',
    desc:
        'Paid & unpaid internships + full-time roles from 180+ companies across India.',
    accent: kPrimary,
    bg: Color(0xFFEFF6FF),
  ),
  _Feature(
    emoji: '🏢',
    title: 'Explore Companies',
    desc:
        'View company profiles, live locations, hiring requirements & culture insights.',
    accent: kTeal,
    bg: Color(0xFFEFFCF9),
  ),
  _Feature(
    emoji: '⚡',
    title: 'Hackathons',
    desc:
        'Compete in top hackathons across India — win prizes, PPOs & recognition.',
    accent: kAmber,
    bg: Color(0xFFFFFBEB),
  ),
  _Feature(
    emoji: '📚',
    title: 'Specialisation Courses',
    desc:
        'Industry-led courses to skill up for your dream job or internship fast.',
    accent: kViolet,
    bg: Color(0xFFF5F3FF),
  ),
  _Feature(
    emoji: '🚀',
    title: 'School Tech Programmes',
    desc:
        'Python, AI, Robotics & more — online/offline summer classes for grades 5-12.',
    accent: kRose,
    bg: Color(0xFFFFF1F2),
  ),
  _Feature(
    emoji: '🗺️',
    title: 'Company Map',
    desc:
        'Discover tech companies near you with live location and hiring status.',
    accent: kTeal,
    bg: Color(0xFFEFFCF9),
  ),
];

class _Particle {
  final String emoji;
  final double x, y, size, phase, amplitude;
  const _Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.amplitude,
  });
}

const _particles = [
  _Particle(emoji: '💻', x: 0.05, y: 0.18, size: 22, phase: 0.0, amplitude: 14),
  _Particle(emoji: '🤖', x: 0.88, y: 0.14, size: 24, phase: 1.1, amplitude: 18),
  _Particle(emoji: '🎮', x: 0.12, y: 0.45, size: 20, phase: 2.2, amplitude: 12),
  _Particle(emoji: '⭐', x: 0.82, y: 0.38, size: 18, phase: 0.5, amplitude: 16),
  _Particle(emoji: '🔬', x: 0.07, y: 0.70, size: 22, phase: 1.8, amplitude: 14),
  _Particle(emoji: '🏆', x: 0.90, y: 0.65, size: 20, phase: 3.0, amplitude: 10),
  _Particle(emoji: '🌟', x: 0.50, y: 0.08, size: 16, phase: 0.8, amplitude: 20),
  _Particle(emoji: '🎯', x: 0.35, y: 0.92, size: 18, phase: 2.6, amplitude: 12),
];

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbCtrl,
      _particleCtrl,
      _pulseCtrl,
      _heroCtrl,
      _btnCtrl,
      _cardsCtrl,
      _statsCtrl,
      _footerCtrl;

  late Animation<double> _heroFade,
      _badgeFade,
      _pulse,
      _btnScale,
      _statsFade,
      _statsSlide,
      _footerFade;
  late Animation<Offset> _heroSlide;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _badgeFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _cardFades = List.generate(
      _features.length,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(
            i * 0.12,
            min(i * 0.12 + 0.4, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );
    _cardSlides = List.generate(
      _features.length,
      (i) =>
          Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _cardsCtrl,
              curve: Interval(
                i * 0.12,
                min(i * 0.12 + 0.4, 1.0),
                curve: Curves.easeOut,
              ),
            ),
          ),
    );

    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _statsFade = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);
    _statsSlide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut));

    _footerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _footerFade = CurvedAnimation(parent: _footerCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _heroCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _cardsCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _statsCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _footerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    _heroCtrl.dispose();
    _btnCtrl.dispose();
    _cardsCtrl.dispose();
    _statsCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kInk,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeroSection(size),
              _buildFeaturesSection(size),
              _buildStatsSection(size),
              _buildFooter(size),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HERO SECTION
  // ─────────────────────────────────────────────

  Widget _buildHeroSection(Size size) {
    final sw = size.width;
    final sh = size.height;

    return SizedBox(
      height: sh * 0.92,
      child: Stack(
        children: [
          ..._orbs.map((orb) => _buildOrb(orb, size)),
          ..._particles.map((p) => _buildParticle(p, size)),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kInk.withOpacity(0.30),
                    kInk.withOpacity(0.55),
                    kInk.withOpacity(0.85),
                    kInk,
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          Positioned(top: 0, left: 0, right: 0, child: _buildNavBar(sw)),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
              child: FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: sh * 0.07),

                      FadeTransition(
                        opacity: _badgeFade,
                        child: _buildBadge(sw),
                      ),
                      SizedBox(height: sh * 0.035),

                      _buildHeadline(sw),
                      SizedBox(height: sh * 0.025),

                      Text(
                        'From internships to AI courses —\nNextStep powers every stage of your journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          height: 1.65,
                          color: Colors.white.withOpacity(0.62),
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: sh * 0.045),

                      _buildCTAButton(sw),
                      SizedBox(height: sh * 0.04),

                      _buildSocialProof(sw),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: sh * 0.018,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _heroFade,
              child: Column(
                children: [
                  Text(
                    'Scroll to explore',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.30),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: sh * 0.007),
                  _buildScrollArrow(sw),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(_Orb orb, Size size) {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (_, __) {
        final dy = sin(_orbCtrl.value * 2 * pi + orb.phase) * 28 * orb.speed;
        final dx = cos(_orbCtrl.value * 2 * pi * 0.4 + orb.phase) * 14;
        return Positioned(
          left: size.width * orb.x + dx - orb.size / 2,
          top: size.height * 0.92 * orb.y + dy - orb.size / 2,
          child: Container(
            width: orb.size,
            height: orb.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: orb.color.withOpacity(0.18),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(_Particle p, Size size) {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        final dy = sin(_particleCtrl.value * 2 * pi + p.phase) * p.amplitude;
        return Positioned(
          left: size.width * p.x,
          top: size.height * 0.92 * p.y + dy,
          child: Opacity(
            opacity: 0.50,
            child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
          ),
        );
      },
    );
  }

  // ── Nav bar ────────────────────────────────

  Widget _buildNavBar(double sw) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.05,
          vertical: sw * 0.035,
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.095,
              height: sw * 0.095,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text('⚡', style: TextStyle(fontSize: sw * 0.045)),
              ),
            ),
            SizedBox(width: sw * 0.025),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NextStep',
                  style: TextStyle(
                    fontSize: sw * 0.040,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'by TechPath',
                  style: TextStyle(
                    fontSize: sw * 0.025,
                    color: kAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.035,
                  vertical: sw * 0.020,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badge ──────────────────────────────────

  Widget _buildBadge(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.035,
        vertical: sw * 0.018,
      ),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kAccent.withOpacity(0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: sw * 0.018,
              height: sw * 0.018,
              decoration: const BoxDecoration(
                color: kAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: sw * 0.02),
          Flexible(
            child: Text(
              'India\'s #1 Campus-to-Career Platform',
              style: TextStyle(
                fontSize: sw * 0.028,
                fontWeight: FontWeight.w700,
                color: kAccent,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Headline ───────────────────────────────

  Widget _buildHeadline(double sw) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: sw * 0.090, // ~36px on 400px screen
          fontWeight: FontWeight.w800,
          height: 1.18,
          letterSpacing: -1.0,
          color: Colors.white,
        ),
        children: [
          const TextSpan(text: 'Your Tech\n'),
          WidgetSpan(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [kAccent, kViolet, kRose],
              ).createShader(bounds),
              child: Text(
                'Journey',
                style: TextStyle(
                  fontSize: sw * 0.090,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                  letterSpacing: -1.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' Starts\nRight Here'),
        ],
      ),
    );
  }

  // ── CTA Button ─────────────────────────────

  Widget _buildCTAButton(double sw) {
    return GestureDetector(
      onTapDown: (_) {
        _btnCtrl.forward();
        setState(() => _btnPressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
        context.go('/login');
      },
      onTapCancel: () {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
      },
      child: ScaleTransition(
        scale: _btnScale,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.09,
            vertical: sw * 0.045,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kViolet],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: _btnPressed
                ? []
                : [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.50),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: kViolet.withOpacity(0.30),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: sw * 0.043,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: sw * 0.025),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: sw * 0.050,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Social proof ───────────────────────────

  Widget _buildSocialProof(double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: sw * 0.20,
          height: sw * 0.08,
          child: Stack(
            children: [
              _miniAvatar('👨‍💻', 0, sw),
              _miniAvatar('👩‍💻', sw * 0.055, sw),
              _miniAvatar('👨‍🎓', sw * 0.11, sw),
            ],
          ),
        ),
        SizedBox(width: sw * 0.025),
        Flexible(
          child: Text(
            '2,400+ students already on NextStep',
            style: TextStyle(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniAvatar(String emoji, double left, double sw) {
    return Positioned(
      left: left,
      child: Container(
        width: sw * 0.075,
        height: sw * 0.075,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.30), width: 2),
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: sw * 0.035)),
        ),
      ),
    );
  }

  Widget _buildScrollArrow(double sw) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _pulse.value * 2 - 1),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withOpacity(0.30),
          size: sw * 0.055,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FEATURES SECTION
  // ─────────────────────────────────────────────

  Widget _buildFeaturesSection(Size size) {
    final sw = size.width;
    final sh = size.height;

    return Container(
      color: const Color(0xFFF0F4F8),
      padding: EdgeInsets.fromLTRB(sw * 0.05, sh * 0.05, sw * 0.05, sh * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.03,
              vertical: sw * 0.012,
            ),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EVERYTHING YOU NEED',
              style: TextStyle(
                fontSize: sw * 0.025,
                fontWeight: FontWeight.w800,
                color: kPrimary,
                letterSpacing: 1.0,
              ),
            ),
          ),
          SizedBox(height: sw * 0.035),
          Text(
            'One app.\nAll your career tools.',
            style: TextStyle(
              fontSize: sw * 0.065,
              fontWeight: FontWeight.w800,
              color: kInk,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: sw * 0.02),
          Text(
            'Built for engineering students, graduates,\npostgrads and school learners.',
            style: TextStyle(fontSize: sw * 0.033, color: kMuted, height: 1.6),
          ),
          SizedBox(height: sw * 0.07),

          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return FadeTransition(
              opacity: _cardFades[i],
              child: SlideTransition(
                position: _cardSlides[i],
                child: _buildFeatureCard(f, sw),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_Feature f, double sw) {
    return Container(
      margin: EdgeInsets.only(bottom: sw * 0.035),
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sw * 0.13,
            height: sw * 0.13,
            decoration: BoxDecoration(
              color: f.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: f.accent.withOpacity(0.20), width: 1.5),
            ),
            child: Center(
              child: Text(f.emoji, style: TextStyle(fontSize: sw * 0.060)),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                SizedBox(height: sw * 0.012),
                Text(
                  f.desc,
                  style: TextStyle(
                    fontSize: sw * 0.030,
                    color: kMuted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.025),
          Container(
            width: sw * 0.075,
            height: sw * 0.075,
            decoration: BoxDecoration(
              color: f.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: f.accent,
              size: sw * 0.033,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  STATS SECTION
  // ─────────────────────────────────────────────

  Widget _buildStatsSection(Size size) {
    final sw = size.width;
    final sh = size.height;

    const stats = [
      {'value': '2,400+', 'label': 'Students', 'emoji': '🎓'},
      {'value': '180+', 'label': 'Companies', 'emoji': '🏢'},
      {'value': '50+', 'label': 'Courses', 'emoji': '📚'},
      {'value': '95%', 'label': 'Placement', 'emoji': '🏆'},
    ];

    return AnimatedBuilder(
      animation: _statsCtrl,
      builder: (_, child) => Opacity(
        opacity: _statsFade.value,
        child: Transform.translate(
          offset: Offset(0, _statsSlide.value),
          child: child,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimary, kViolet],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: sh * 0.045,
          horizontal: sw * 0.05,
        ),
        child: Column(
          children: [
            Text(
              'Trusted by students across India',
              style: TextStyle(
                fontSize: sw * 0.033,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: sh * 0.035),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.map((s) {
                return Column(
                  children: [
                    Text(s['emoji']!, style: TextStyle(fontSize: sw * 0.065)),
                    SizedBox(height: sh * 0.010),
                    Text(
                      s['value']!,
                      style: TextStyle(
                        fontSize: sw * 0.055,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Text(
                      s['label']!,
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FOOTER
  // ─────────────────────────────────────────────

  Widget _buildFooter(Size size) {
    final sw = size.width;
    final sh = size.height;

    return FadeTransition(
      opacity: _footerFade,
      child: Container(
        color: kInk,
        padding: EdgeInsets.fromLTRB(
          sw * 0.06,
          sh * 0.04,
          sw * 0.06,
          sh * 0.06,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: sw * 0.09,
                  height: sw * 0.09,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('⚡', style: TextStyle(fontSize: sw * 0.045)),
                  ),
                ),
                SizedBox(width: sw * 0.025),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NextStep',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'by TechPath',
                      style: TextStyle(
                        fontSize: sw * 0.025,
                        color: kAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sh * 0.025),
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            SizedBox(height: sh * 0.025),

            Wrap(
              spacing: sw * 0.05,
              runSpacing: sw * 0.025,
              children:
                  [
                        'Jobs',
                        'Internships',
                        'Companies',
                        'Hackathons',
                        'Courses',
                        'School Portal',
                      ]
                      .map(
                        (l) => Text(
                          l,
                          style: TextStyle(
                            fontSize: sw * 0.030,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: sh * 0.030),

            GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kViolet],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    'Get Started — It\'s Free',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: sh * 0.030),

            Text(
              '© 2025 TechPath. Built for India\'s next generation of tech innovators.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.028,
                color: Colors.white.withOpacity(0.30),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
