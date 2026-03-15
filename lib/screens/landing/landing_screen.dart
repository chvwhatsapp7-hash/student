import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kSlate      = Color(0xFF334155);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);
const kBgPage     = Color(0xFFF0F4F8);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kSuccess    = Color(0xFF16A34A);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  LANDING SCREEN
// ─────────────────────────────────────────────

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {

  late AnimationController _navAnim;
  late AnimationController _heroAnim;
  late AnimationController _cardsAnim;
  late AnimationController _statsAnim;

  late Animation<double> _navFade;
  late Animation<double> _heroFade;
  late Animation<Offset>  _heroSlide;
  late Animation<double>  _cardsFade;
  late Animation<Offset>  _cardsSlide;
  late Animation<double>  _statsFade;

  // Button press states
  bool _primaryPressed  = false;
  bool _outlinePressed  = false;
  bool _engPressed      = false;
  bool _schoolPressed   = false;

  @override
  void initState() {
    super.initState();

    _navAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();
    _navFade = CurvedAnimation(parent: _navAnim, curve: Curves.easeOut);

    _heroAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );
    _heroFade  = CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroAnim, curve: Curves.easeOut));

    _cardsAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _cardsFade  = CurvedAnimation(parent: _cardsAnim, curve: Curves.easeOut);
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.14), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardsAnim, curve: Curves.easeOut));

    _statsAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _statsFade = CurvedAnimation(parent: _statsAnim, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _heroAnim.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _cardsAnim.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _statsAnim.forward();
    });
  }

  @override
  void dispose() {
    _navAnim.dispose();
    _heroAnim.dispose();
    _cardsAnim.dispose();
    _statsAnim.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kInk,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildNav(),
              _buildHero(),
              _buildPortalCards(),
              _buildStats(),
              _buildFeatures(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ── NAV BAR ────────────────────────────────

  Widget _buildNav() {
    return FadeTransition(
      opacity: _navFade,
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
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
                // Sign In
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: const Text('Sign In',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: kHint,
                        )),
                  ),
                ),
                const SizedBox(width: 6),
                // Get Started
                GestureDetector(
                  onTap: () => context.go('/signup'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Get Started',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO SECTION ───────────────────────────

  Widget _buildHero() {
    return Container(
      color: kInk,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: FadeTransition(
        opacity: _heroFade,
        child: SlideTransition(
          position: _heroSlide,
          child: Column(
            children: [
              // Pill badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: kPrimary.withOpacity(0.40), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: kAccent, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'India\'s #1 Campus-to-Career Platform',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Headline
              const Text(
                'Your Tech Journey\nStarts Here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1.2,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 16),
              // Subtext
              Text(
                'Connecting engineering students with top tech companies\nand inspiring young minds with programming.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, height: 1.6,
                  color: Colors.white.withOpacity(0.60),
                ),
              ),
              const SizedBox(height: 32),
              // CTA buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _heroBtn(
                    label: 'Launch Your Career',
                    isPrimary: true,
                    pressed: _primaryPressed,
                    onTapDown: () =>
                        setState(() => _primaryPressed = true),
                    onTapUp: () {
                      setState(() => _primaryPressed = false);
                      HapticFeedback.lightImpact();
                      context.go('/login');
                    },
                    onTapCancel: () =>
                        setState(() => _primaryPressed = false),
                  ),
                  const SizedBox(width: 10),
                  _heroBtn(
                    label: 'Learn to Code',
                    isPrimary: false,
                    pressed: _outlinePressed,
                    onTapDown: () =>
                        setState(() => _outlinePressed = true),
                    onTapUp: () {
                      setState(() => _outlinePressed = false);
                      HapticFeedback.lightImpact();
                      context.go('/school');
                    },
                    onTapCancel: () =>
                        setState(() => _outlinePressed = false),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Social proof
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatars
                  SizedBox(
                    width: 72,
                    height: 28,
                    child: Stack(
                      children: [
                        _avatar('👨‍💻', 0),
                        _avatar('👩‍💻', 20),
                        _avatar('👨‍🎓', 40),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '2,400+ students already on NextStep',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroBtn({
    required String label,
    required bool isPrimary,
    required bool pressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp:   (_) => onTapUp(),
      onTapCancel: onTapCancel,
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: isPrimary ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: isPrimary
                ? null
                : Border.all(
                color: Colors.white.withOpacity(0.25), width: 1.5),
            boxShadow: isPrimary && !pressed
                ? [
              BoxShadow(
                color: kPrimary.withOpacity(0.40),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800,
                color: isPrimary
                    ? Colors.white
                    : Colors.white.withOpacity(0.85),
              )),
        ),
      ),
    );
  }

  Widget _avatar(String emoji, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  // ── PORTAL CARDS ───────────────────────────

  Widget _buildPortalCards() {
    return Container(
      color: kBgPage,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: FadeTransition(
        opacity: _cardsFade,
        child: SlideTransition(
          position: _cardsSlide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose your portal',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: kMuted, letterSpacing: 0.8,
                  )),
              const SizedBox(height: 14),
              // Engineering card
              _portalCard(
                emoji: '💼',
                title: 'Engineering Students',
                subtitle:
                'Discover jobs, internships, hackathons and companies across India.',
                tags: ['Jobs', 'Internships', 'Companies', 'Hackathons'],
                tagColor: kPrimary,
                tagBg: kSelectedBg,
                accentColor: kPrimary,
                pressed: _engPressed,
                onTapDown: () => setState(() => _engPressed = true),
                onTapUp: () {
                  setState(() => _engPressed = false);
                  HapticFeedback.lightImpact();
                  context.go('/engineering');
                },
                onTapCancel: () => setState(() => _engPressed = false),
              ),
              const SizedBox(height: 16),
              // School card
              _portalCard(
                emoji: '🚀',
                title: 'School Students',
                subtitle:
                'Learn coding, AI, robotics and fun summer programmes — online & offline.',
                tags: ['Python', 'AI/ML', 'Robotics', 'Scratch'],
                tagColor: const Color(0xFF0F766E),
                tagBg: const Color(0xFFEFFCF9),
                accentColor: const Color(0xFF0D9488),
                pressed: _schoolPressed,
                onTapDown: () => setState(() => _schoolPressed = true),
                onTapUp: () {
                  setState(() => _schoolPressed = false);
                  HapticFeedback.lightImpact();
                  context.go('/school');
                },
                onTapCancel: () => setState(() => _schoolPressed = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _portalCard({
    required String emoji,
    required String title,
    required String subtitle,
    required List<String> tags,
    required Color tagColor,
    required Color tagBg,
    required Color accentColor,
    required bool pressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp:   (_) => onTapUp(),
      onTapCancel: onTapCancel,
      child: AnimatedScale(
        scale: pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: accentColor.withOpacity(0.25), width: 1.5),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                  ),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_forward,
                        color: accentColor, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: kMuted, height: 1.5)),
              const SizedBox(height: 14),
              // Tags
              Wrap(
                spacing: 7, runSpacing: 7,
                children: tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(t,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: tagColor,
                      )),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STATS SECTION ──────────────────────────

  Widget _buildStats() {
    return FadeTransition(
      opacity: _statsFade,
      child: Container(
        color: kPrimary,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('2,400+', 'Students'),
            _statDivider(),
            _statItem('180+',   'Companies'),
            _statDivider(),
            _statItem('50+',    'Courses'),
            _statDivider(),
            _statItem('95%',    'Placement'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -0.4,
            )),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.65),
            )),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1, height: 36,
      color: Colors.white.withOpacity(0.18),
    );
  }

  // ── FEATURES SECTION ───────────────────────

  Widget _buildFeatures() {
    const features = [
      {
        'icon': '🎯',
        'title': 'AI Job Matching',
        'desc': 'Our AI engine matches you with roles that fit your skills and interests.',
      },
      {
        'icon': '🗺️',
        'title': 'Company Map',
        'desc': 'Explore companies near you and see openings in real-time.',
      },
      {
        'icon': '📚',
        'title': 'Upskill Courses',
        'desc': 'Job-focused courses taught by industry experts — online & offline.',
      },
      {
        'icon': '🏆',
        'title': 'Hackathons',
        'desc': 'Compete in top hackathons across India and win prizes & PPOs.',
      },
    ];

    return Container(
      color: kBgPage,
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Everything you need',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: kMuted, letterSpacing: 0.8,
              )),
          const SizedBox(height: 14),
          const Text('One platform.\nAll your career tools.',
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800,
                color: kInk, height: 1.2, letterSpacing: -0.4,
              )),
          const SizedBox(height: 24),
          ...features.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(f['icon']!,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['title']!,
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: kInk,
                          )),
                      const SizedBox(height: 3),
                      Text(f['desc']!,
                          style: const TextStyle(
                              fontSize: 12, color: kMuted,
                              height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── FOOTER ─────────────────────────────────

  Widget _buildFooter() {
    return Container(
      color: kInk,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        children: [
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
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 20),
          // Quick links
          Row(
            children: [
              _footerLink('Jobs'),
              const SizedBox(width: 20),
              _footerLink('Internships'),
              const SizedBox(width: 20),
              _footerLink('Courses'),
              const SizedBox(width: 20),
              _footerLink('About'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© 2025 TechPath. Built for India\'s next generation of tech innovators.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11, color: Colors.white.withOpacity(0.35),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label) {
    return Text(label,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.50),
        ));
  }
}
