import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0A0F1E);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kViolet     = Color(0xFF7C3AED);
const kTeal       = Color(0xFF0D9488);
const kAmber      = Color(0xFFF59E0B);
const kRose       = Color(0xFFF43F5E);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);

// ─────────────────────────────────────────────
//  FLOATING ORBS MODEL
// ─────────────────────────────────────────────

class _Orb {
  final double x;
  final double y;
  final double size;
  final Color  color;
  final double phase;
  final double speed;
  const _Orb({
    required this.x, required this.y, required this.size,
    required this.color, required this.phase, required this.speed,
  });
}

const _orbs = [
  _Orb(x: 0.08, y: 0.10, size: 180, color: Color(0xFF1D4ED8), phase: 0.0,  speed: 0.6),
  _Orb(x: 0.75, y: 0.06, size: 140, color: Color(0xFF7C3AED), phase: 1.2,  speed: 0.8),
  _Orb(x: 0.85, y: 0.40, size: 100, color: Color(0xFF0D9488), phase: 2.4,  speed: 0.5),
  _Orb(x: 0.05, y: 0.55, size: 120, color: Color(0xFF38BDF8), phase: 0.7,  speed: 0.7),
  _Orb(x: 0.60, y: 0.75, size: 90,  color: Color(0xFFF43F5E), phase: 1.9,  speed: 0.9),
  _Orb(x: 0.20, y: 0.85, size: 110, color: Color(0xFFF59E0B), phase: 3.1,  speed: 0.6),
];

// ─────────────────────────────────────────────
//  FEATURE CARD MODEL
// ─────────────────────────────────────────────

class _Feature {
  final String emoji;
  final String title;
  final String desc;
  final Color  accent;
  final Color  bg;
  const _Feature({
    required this.emoji, required this.title,
    required this.desc,  required this.accent, required this.bg,
  });
}

const _features = [
  _Feature(
    emoji: '💼', title: 'Jobs & Internships',
    desc: 'Paid & unpaid internships + full-time roles from 180+ companies across India.',
    accent: kPrimary, bg: Color(0xFFEFF6FF),
  ),
  _Feature(
    emoji: '🏢', title: 'Explore Companies',
    desc: 'View company profiles, live locations, hiring requirements & culture insights.',
    accent: kTeal, bg: Color(0xFFEFFCF9),
  ),
  _Feature(
    emoji: '⚡', title: 'Hackathons',
    desc: 'Compete in top hackathons across India — win prizes, PPOs & recognition.',
    accent: kAmber, bg: Color(0xFFFFFBEB),
  ),
  _Feature(
    emoji: '📚', title: 'Specialisation Courses',
    desc: 'Industry-led courses to skill up for your dream job or internship fast.',
    accent: kViolet, bg: Color(0xFFF5F3FF),
  ),
  _Feature(
    emoji: '🚀', title: 'School Tech Programmes',
    desc: 'Python, AI, Robotics & more — online/offline summer classes for grades 5-12.',
    accent: kRose, bg: Color(0xFFFFF1F2),
  ),
  _Feature(
    emoji: '🗺️', title: 'Company Map',
    desc: 'Discover tech companies near you with live location and hiring status.',
    accent: kTeal, bg: Color(0xFFEFFCF9),
  ),
];

// ─────────────────────────────────────────────
//  FLOATING EMOJI PARTICLE MODEL
// ─────────────────────────────────────────────

class _Particle {
  final String emoji;
  final double x;
  final double y;
  final double size;
  final double phase;
  final double amplitude;
  const _Particle({
    required this.emoji, required this.x, required this.y,
    required this.size,  required this.phase, required this.amplitude,
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

  // ── Animation controllers ──────────────────
  late AnimationController _orbCtrl;      // infinite orb float
  late AnimationController _particleCtrl; // infinite particle float
  late AnimationController _pulseCtrl;    // hero badge pulse
  late AnimationController _heroCtrl;     // hero text entrance
  late AnimationController _btnCtrl;      // button scale
  late AnimationController _cardsCtrl;    // feature cards stagger
  late AnimationController _statsCtrl;    // stats counter
  late AnimationController _footerCtrl;   // footer entrance

  // ── Hero animations ────────────────────────
  late Animation<double> _heroFade;
  late Animation<Offset>  _heroSlide;
  late Animation<double>  _badgeFade;
  late Animation<double>  _pulse;

  // ── Button ─────────────────────────────────
  late Animation<double>  _btnScale;
  bool _btnPressed = false;

  // ── Cards stagger ──────────────────────────
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>>  _cardSlides;

  // ── Stats ──────────────────────────────────
  late Animation<double> _statsFade;
  late Animation<double> _statsSlide;

  // ── Footer ─────────────────────────────────
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    // ── Infinite float controllers ─────────────
    _orbCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 7),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 5),
    )..repeat();

    // ── Badge pulse ────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Hero entrance ──────────────────────────
    _heroCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.16), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _badgeFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    // ── Button ─────────────────────────────────
    _btnCtrl  = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );

    // ── Cards stagger ──────────────────────────
    _cardsCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );
    _cardFades  = List.generate(_features.length, (i) =>
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(i * 0.12, min(i * 0.12 + 0.4, 1.0),
              curve: Curves.easeOut),
        )));
    _cardSlides = List.generate(_features.length, (i) =>
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(i * 0.12, min(i * 0.12 + 0.4, 1.0),
              curve: Curves.easeOut),
        )));

    // ── Stats ──────────────────────────────────
    _statsCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );
    _statsFade  = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);
    _statsSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut),
    );

    // ── Footer ─────────────────────────────────
    _footerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _footerFade = CurvedAnimation(parent: _footerCtrl, curve: Curves.easeOut);

    // ── Staggered play ─────────────────────────
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

  // ── build ──────────────────────────────────

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
              _buildFeaturesSection(),
              _buildStatsSection(),
              _buildFooter(),
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
    return SizedBox(
      height: size.height * 0.92,
      child: Stack(
        children: [
          // ── Animated colour orbs ──────────────
          ..._orbs.map((orb) => _buildOrb(orb, size)),

          // ── Floating emoji particles ──────────
          ..._particles.map((p) => _buildParticle(p, size)),

          // ── Gradient overlay ──────────────────
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

          // ── Top nav bar ───────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildNavBar(),
          ),

          // ── Hero content ──────────────────────
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // ── Animated badge ─────────
                      FadeTransition(
                        opacity: _badgeFade,
                        child: _buildBadge(),
                      ),
                      const SizedBox(height: 28),

                      // ── Headline ───────────────
                      _buildHeadline(),
                      const SizedBox(height: 20),

                      // ── Subtext ────────────────
                      Text(
                        'From internships to AI courses —\nNextStep powers every stage of your journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15, height: 1.65,
                          color: Colors.white.withOpacity(0.62),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Single CTA button ──────
                      _buildCTAButton(),
                      const SizedBox(height: 32),

                      // ── Social proof ───────────
                      _buildSocialProof(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Scroll hint ───────────────────────
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: FadeTransition(
              opacity: _heroFade,
              child: Column(
                children: [
                  Text('Scroll to explore',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.30),
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 6),
                  _buildScrollArrow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Orb ────────────────────────────────────

  Widget _buildOrb(_Orb orb, Size size) {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (_, __) {
        final dy = sin(_orbCtrl.value * 2 * pi + orb.phase) * 28 * orb.speed;
        final dx = cos(_orbCtrl.value * 2 * pi * 0.4 + orb.phase) * 14;
        return Positioned(
          left: size.width  * orb.x + dx - orb.size / 2,
          top:  size.height * 0.92 * orb.y + dy - orb.size / 2,
          child: Container(
            width: orb.size, height: orb.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: orb.color.withOpacity(0.18),
            ),
          ),
        );
      },
    );
  }

  // ── Floating particle ──────────────────────

  Widget _buildParticle(_Particle p, Size size) {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        final dy = sin(_particleCtrl.value * 2 * pi + p.phase) * p.amplitude;
        return Positioned(
          left: size.width  * p.x,
          top:  size.height * 0.92 * p.y + dy,
          child: Opacity(
            opacity: 0.50,
            child: Text(p.emoji,
                style: TextStyle(fontSize: p.size)),
          ),
        );
      },
    );
  }

  // ── Nav bar ────────────────────────────────

  Widget _buildNavBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NextStep',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.3,
                    )),
                Text('by TechPath',
                    style: TextStyle(
                        fontSize: 10, color: kAccent,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            // Sign in — subtle text button only
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.18), width: 1),
                ),
                child: const Text('Sign In',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated badge ─────────────────────────

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
              width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: kAccent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'India\'s #1 Campus-to-Career Platform',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: kAccent, letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Headline ───────────────────────────────

  Widget _buildHeadline() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 36, fontWeight: FontWeight.w800,
          height: 1.18, letterSpacing: -1.0,
          color: Colors.white,
        ),
        children: [
          const TextSpan(text: 'Your Tech\n'),
          WidgetSpan(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [kAccent, kViolet, kRose],
              ).createShader(bounds),
              child: const Text(
                'Journey',
                style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w800,
                  height: 1.18, letterSpacing: -1.0,
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

  Widget _buildCTAButton() {
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
          padding: const EdgeInsets.symmetric(
              horizontal: 36, vertical: 18),
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
                blurRadius: 28, offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: kViolet.withOpacity(0.30),
                blurRadius: 40, offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Get Started',
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 0.2,
                  )),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Social proof ───────────────────────────

  Widget _buildSocialProof() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stacked avatars
        SizedBox(
          width: 80, height: 32,
          child: Stack(
            children: [
              _miniAvatar('👨‍💻', 0),
              _miniAvatar('👩‍💻', 22),
              _miniAvatar('👨‍🎓', 44),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '2,400+ students already on NextStep',
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.50),
          ),
        ),
      ],
    );
  }

  Widget _miniAvatar(String emoji, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withOpacity(0.30), width: 2),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  // ── Scroll arrow ───────────────────────────

  Widget _buildScrollArrow() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _pulse.value * 2 - 1),
        child: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withOpacity(0.30), size: 22),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FEATURES SECTION
  // ─────────────────────────────────────────────

  Widget _buildFeaturesSection() {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'EVERYTHING YOU NEED',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: kPrimary, letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'One app.\nAll your career tools.',
            style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800,
              color: kInk, height: 1.2, letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Built for engineering students, graduates,\npostgrads and school learners.',
            style: const TextStyle(
              fontSize: 13, color: kMuted, height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // Feature cards — staggered
          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return FadeTransition(
              opacity: _cardFades[i],
              child: SlideTransition(
                position: _cardSlides[i],
                child: _buildFeatureCard(f),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_Feature f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji tile
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: f.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: f.accent.withOpacity(0.20), width: 1.5),
            ),
            child: Center(
              child: Text(f.emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title,
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: kInk,
                    )),
                const SizedBox(height: 5),
                Text(f.desc,
                    style: const TextStyle(
                      fontSize: 12, color: kMuted, height: 1.55,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: f.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.arrow_forward_ios_rounded,
                color: f.accent, size: 13),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  STATS SECTION
  // ─────────────────────────────────────────────

  Widget _buildStatsSection() {
    const stats = [
      {'value': '2,400+', 'label': 'Students',  'emoji': '🎓'},
      {'value': '180+',   'label': 'Companies', 'emoji': '🏢'},
      {'value': '50+',    'label': 'Courses',   'emoji': '📚'},
      {'value': '95%',    'label': 'Placement', 'emoji': '🏆'},
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
        padding: const EdgeInsets.symmetric(
            vertical: 36, horizontal: 20),
        child: Column(
          children: [
            const Text(
              'Trusted by students across India',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.map((s) {
                return Column(
                  children: [
                    Text(s['emoji']!,
                        style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 8),
                    Text(s['value']!,
                        style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.5,
                        )),
                    const SizedBox(height: 4),
                    Text(s['label']!,
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.65),
                        )),
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

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _footerFade,
      child: Container(
        color: kInk,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          children: [
            // Logo row
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NextStep',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    Text('by TechPath',
                        style: TextStyle(
                            fontSize: 10, color: kAccent,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1,
                color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 20),

            // Feature quick links
            Wrap(
              spacing: 20, runSpacing: 10,
              children: [
                'Jobs', 'Internships', 'Companies',
                'Hackathons', 'Courses', 'School Portal',
              ].map((l) => Text(l,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.45),
                  ))).toList(),
            ),
            const SizedBox(height: 24),

            // Bottom CTA
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kViolet],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('Get Started — It\'s Free',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '© 2025 TechPath. Built for India\'s next generation of tech innovators.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
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
