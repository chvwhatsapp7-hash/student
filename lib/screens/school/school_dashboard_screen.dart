import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';

import 'school_data.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  STATIC DATA
// ─────────────────────────────────────────────

const _upcoming = [
  {'day': 'Mon', 'time': '10:00 AM', 'subject': 'Python Basics',       'emoji': '🐍'},
  {'day': 'Wed', 'time': '3:00 PM',  'subject': 'Scratch Programming',  'emoji': '🎮'},
  {'day': 'Fri', 'time': '11:00 AM', 'subject': 'AI Concepts',          'emoji': '🤖'},
];

// ─────────────────────────────────────────────
//  SLIDER ITEM MODEL  (course-focused)
// ─────────────────────────────────────────────

class _SliderItem {
  final String title;
  final String subtitle;   // provider / instructor
  final String meta;       // duration / level
  final int    matchPct;   // repurposed as "relevance score" 0-100
  final Color  grad1;
  final Color  grad2;
  final IconData icon;
  final String emoji;
  final dynamic sourceObject; // Course

  const _SliderItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.matchPct,
    required this.grad1,
    required this.grad2,
    required this.icon,
    required this.emoji,
    required this.sourceObject,
  });
}

// ─────────────────────────────────────────────
//  COURSE → SLIDER ITEM CONVERTER
// ─────────────────────────────────────────────

_SliderItem _courseToSliderItem(Course c, int index) {
  // Give each course a vivid gradient based on its position / tag
  const gradients = [
    [Color(0xFF1D4ED8), Color(0xFF38BDF8)],  // blue-sky
    [Color(0xFF7C3AED), Color(0xFFA855F7)],  // violet
    [Color(0xFF059669), Color(0xFF10B981)],  // green
    [Color(0xFFD97706), Color(0xFFF59E0B)],  // amber
    [Color(0xFF0369A1), Color(0xFF0EA5E9)],  // steel-blue
    [Color(0xFFBE123C), Color(0xFFF43F5E)],  // rose
  ];
  final pair = gradients[index % gradients.length];

  // Map course emoji → icon
  IconData icon;
  switch (c.emoji) {
    case '🐍': icon = Icons.code; break;
    case '🎮': icon = Icons.sports_esports; break;
    case '🤖': icon = Icons.smart_toy; break;
    case '🌐': icon = Icons.language; break;
    case '📊': icon = Icons.analytics; break;
    case '☁️': icon = Icons.cloud; break;
    default:   icon = Icons.menu_book;
  }

  // Relevance: vary by index so cards feel distinct
  final relevance = 95 - (index * 8).clamp(0, 45);

  return _SliderItem(
    title:        c.title,
    subtitle:     c.tag,
    meta:         '${c.duration} · ${c.level}',
    matchPct:     relevance,
    grad1:        pair[0],
    grad2:        pair[1],
    icon:         icon,
    emoji:        c.emoji,
    sourceObject: c,
  );
}

// ─────────────────────────────────────────────
//  COURSE RECOMMENDED SLIDER
// ─────────────────────────────────────────────

class _CourseRecommendedSlider extends StatefulWidget {
  final List<_SliderItem> items;
  final void Function(_SliderItem item) onEnrollTap;

  const _CourseRecommendedSlider({
    required this.items,
    required this.onEnrollTap,
  });

  @override
  State<_CourseRecommendedSlider> createState() =>
      _CourseRecommendedSliderState();
}

class _CourseRecommendedSliderState extends State<_CourseRecommendedSlider>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int    _currentPage = 0;
  Timer? _timer;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.items.isEmpty) return;
      final next = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final sw = MediaQuery.of(context).size.width;
    final cardH = sw * 0.40;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: cardH,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, index) {
              final item = widget.items[index];
              final isActive = index == _currentPage;
              return AnimatedScale(
                scale: isActive ? 1.0 : 0.93,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: _buildCard(item, sw, isActive),
              );
            },
          ),
        ),
        SizedBox(height: sw * 0.016),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? kPrimaryBlue : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCard(_SliderItem item, double sw, bool isActive) {
    final matchPct  = item.matchPct;
    final matchColor = matchPct >= 90
        ? const Color(0xFF22C55E)
        : matchPct >= 75
        ? const Color(0xFFF59E0B)
        : kSkyBlue;

    // Background decorative icons for school/course context
    const bgIcons = [
      Icons.menu_book,
      Icons.psychology,
      Icons.code,
      Icons.auto_awesome,
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: EdgeInsets.symmetric(
        horizontal: sw * 0.018,
        vertical:   sw * 0.008,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.grad1, item.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: item.grad1.withValues(alpha: isActive ? 0.40 : 0.15),
            blurRadius: isActive ? 22 : 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // ── Decorative animated background icons
            ...List.generate(bgIcons.length, (i) {
              final positions = [
                const Offset(0.72, 0.08),
                const Offset(0.85, 0.55),
                const Offset(0.60, 0.75),
                const Offset(0.92, 0.82),
              ];
              final sizes = [sw * 0.13, sw * 0.09, sw * 0.07, sw * 0.11];
              final pos   = positions[i];
              return Positioned(
                left: sw * 0.90 * pos.dx,
                top:  sw * 0.40 * pos.dy,
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (_, __) {
                    final pulse = sin(
                      (_shimmerController.value * 2 * pi) +
                          (i * pi / 2),
                    ) * 0.04;
                    return Transform.scale(
                      scale: 1.0 + pulse,
                      child: Icon(
                        bgIcons[i],
                        size: sizes[i],
                        color: Colors.white.withValues(
                          alpha: 0.10 + (i % 2 == 0 ? 0.04 : 0.0),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // ── Shimmer sweep on active card
            if (isActive)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (_, __) => ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment(
                          -1.5 + _shimmerController.value * 3.5, -0.3),
                      end: Alignment(
                          -0.5 + _shimmerController.value * 3.5, 0.3),
                    ).createShader(bounds),
                    child: Container(color: Colors.white),
                  ),
                ),
              ),

            // ── Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                sw * 0.040, sw * 0.026,
                sw * 0.040, sw * 0.024,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: type badge + relevance badge
                  Row(
                    children: [
                      _typeBadge(sw),
                      const Spacer(),
                      _relevanceBadge(matchPct, matchColor, sw),
                    ],
                  ),
                  SizedBox(height: sw * 0.018),

                  // Row 2: emoji icon + title/subtitle/meta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: sw * 0.100,
                        height: sw * 0.100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            item.emoji,
                            style: TextStyle(fontSize: sw * 0.042),
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.026),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: sw * 0.005),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: sw * 0.026,
                                color: Colors.white.withValues(alpha: 0.82),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: sw * 0.004),
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: sw * 0.024,
                                    color:
                                    Colors.white.withValues(alpha: 0.65)),
                                SizedBox(width: sw * 0.005),
                                Flexible(
                                  child: Text(
                                    item.meta,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: sw * 0.022,
                                      color: Colors.white
                                          .withValues(alpha: 0.65),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.018),

                  // Row 3: relevance bar + Enroll button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Relevance',
                                  style: TextStyle(
                                    fontSize: sw * 0.020,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$matchPct%',
                                  style: TextStyle(
                                    fontSize: sw * 0.020,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sw * 0.007),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: matchPct / 100.0,
                                minHeight: 5,
                                backgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: sw * 0.022),

                      // Enroll button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onEnrollTap(item);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.028,
                            vertical:   sw * 0.016,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  size: sw * 0.028, color: item.grad1),
                              SizedBox(width: sw * 0.006),
                              Text(
                                'Enroll',
                                style: TextStyle(
                                  fontSize: sw * 0.024,
                                  fontWeight: FontWeight.w800,
                                  color: item.grad1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(double sw) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.020,
      vertical:   sw * 0.007,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
    ),
    child: Text(
      '📚 Course',
      style: TextStyle(
        fontSize: sw * 0.020,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );

  Widget _relevanceBadge(int pct, Color color, double sw) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.018,
      vertical:   sw * 0.007,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.30),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      '$pct% match',
      style: TextStyle(
        fontSize: sw * 0.020,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  APP SHOWCASE BANNER  (image slides)
// ─────────────────────────────────────────────

class _AppShowcaseBanner extends StatefulWidget {
  const _AppShowcaseBanner();

  @override
  State<_AppShowcaseBanner> createState() => _AppShowcaseBannerState();
}

class _AppShowcaseBannerState extends State<_AppShowcaseBanner>
    with SingleTickerProviderStateMixin {
  final PageController _controller =
  PageController(viewportFraction: 0.92);
  int    _currentPage = 0;
  Timer? _timer;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  static const List<Map<String, dynamic>> _slides = [
    {
      'image': 'assets/images/sliding1.jpg',
      'title': 'Learn to Code!',
      'sub':   'Fun courses designed just for you 🎓',
      'tint':  Color(0xFF0F172A),
    },
    {
      'image': 'assets/images/sliding2.jpg',
      'title': 'Win Challenges',
      'sub':   'Daily quizzes & competitions to earn XP',
      'tint':  Color(0xFF1D4ED8),
    },
    {
      'image': 'assets/images/sliding3.jpg',
      'title': 'Upskill Fast',
      'sub':   'Master Python, AI & more in 30 days',
      'tint':  Color(0xFF7C3AED),
    },
    {
      'image': 'assets/images/sliding4.jpg',
      'title': 'Top the Leaderboard',
      'sub':   'Build skills, earn badges, stand out!',
      'tint':  Color(0xFF0369A1),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: sw * 0.46,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) {
              _fadeCtrl.reset();
              _fadeCtrl.forward();
              setState(() => _currentPage = i);
            },
            itemBuilder: (ctx, i) =>
                _buildSlide(_slides[i], sw, i),
          ),
        ),
        SizedBox(height: sw * 0.016),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? kPrimaryBlue
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSlide(
      Map<String, dynamic> slide, double sw, int index) {
    final isActive = index == _currentPage;
    final tint     = slide['tint'] as Color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: EdgeInsets.symmetric(
        horizontal: sw * 0.016,
        vertical:   sw * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: isActive ? 0.38 : 0.12),
            blurRadius: isActive ? 22 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Asset image
            Image.asset(
              slide['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryBlue, kDeepBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white.withValues(alpha: 0.30),
                  size: sw * 0.10,
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tint.withValues(alpha: 0.88),
                      tint.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            // Slide counter pill
            Positioned(
              top:   sw * 0.026,
              right: sw * 0.026,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.018,
                  vertical:   sw * 0.007,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1} / ${_slides.length}',
                  style: TextStyle(
                    fontSize: sw * 0.020,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Text content
            Positioned(
              bottom: sw * 0.038,
              left:   sw * 0.038,
              right:  sw * 0.038,
              child: FadeTransition(
                opacity: isActive
                    ? _fadeAnim
                    : const AlwaysStoppedAnimation(1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide['title'] as String,
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: sw * 0.007),
                    Text(
                      slide['sub'] as String,
                      style: TextStyle(
                        fontSize: sw * 0.026,
                        color: Colors.white.withValues(alpha: 0.80),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DASHBOARD SCREEN
// ─────────────────────────────────────────────

class SchoolDashboardScreen extends StatefulWidget {
  const SchoolDashboardScreen({super.key});

  @override
  State<SchoolDashboardScreen> createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen>
    with TickerProviderStateMixin {

  late ConfettiController   _confetti;
  late AnimationController  _headerAnim;
  late AnimationController  _xpAnim;
  late Animation<double>    _xpValue;

  late List<AnimationController> _sectionAnims;
  late List<Animation<double>>   _sectionFade;
  late List<Animation<Offset>>   _sectionSlide;

  // Build slider items from kCourses (static school data — no extra HTTP call)
  List<_SliderItem> get _sliderItems => kCourses
      .asMap()
      .entries
      .map((e) => _courseToSliderItem(e.value, e.key))
      .toList();

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();

    _xpAnim  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _xpValue = Tween<double>(begin: 0.0, end: 0.7)
        .animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));

    // 8 section animators: 0-5 original + 6 (showcase banner) + 7 (course slider)
    _sectionAnims = List.generate(
        8,
            (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 500)));
    _sectionFade  = _sectionAnims
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)
    as Animation<double>)
        .toList();
    _sectionSlide = _sectionAnims
        .map((c) => Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _xpAnim.forward();
    });
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: 120 + i * 90), () {
        if (mounted) _sectionAnims[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _sectionAnims) c.dispose();
    super.dispose();
  }

  Widget _fadeSlide(int i, Widget child) => FadeTransition(
      opacity: _sectionFade[i],
      child: SlideTransition(position: _sectionSlide[i], child: child));

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state   = SchoolStateProvider.of(context);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: kBgPage,
      floatingActionButton: _buildFAB(context),
      body: Stack(children: [
        AnimatedBuilder(
          animation: state,
          builder: (_, __) => Column(children: [
            _buildHeader(profile),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                children: [

                  // ── 1. XP card
                  _fadeSlide(0, _buildXPCard(profile)),
                  const SizedBox(height: 14),

                  // ── 2. Daily challenge
                  _fadeSlide(1, _buildDailyChallenge(state)),
                  const SizedBox(height: 20),

                  // ── 3. Top Course Picks Slider  ✨ NEW
                  if (_sliderItems.isNotEmpty) ...[
                    _fadeSlide(7, _buildSectionLabel('🎯 Top Picks For You')),
                    const SizedBox(height: 4),
                    _fadeSlide(7, Text(
                      'Courses matched to your interests',
                      style: TextStyle(
                        fontSize: 13,
                        color: kTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                    const SizedBox(height: 12),
                    _fadeSlide(
                      7,
                      Padding(
                        // Extend slider edge-to-edge past the list padding
                        padding:
                        const EdgeInsets.symmetric(horizontal: -0),
                        child: _CourseRecommendedSlider(
                          items: _sliderItems,
                          onEnrollTap: _handleSliderEnroll,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── 4. Upcoming classes
                  _fadeSlide(2, _buildSectionLabel('📅 Upcoming Classes')),
                  const SizedBox(height: 10),
                  _fadeSlide(2, _buildUpcomingList()),
                  const SizedBox(height: 20),

                  // ── 5. Enrolled courses (live from state)
                  if (state.enrolledCount > 0) ...[
                    _fadeSlide(3, _buildSectionLabel('🚀 My Enrolled Courses')),
                    const SizedBox(height: 10),
                    _fadeSlide(3, _buildEnrolledList(state)),
                    const SizedBox(height: 20),
                  ],

                  // ── 6. Popular courses
                  _fadeSlide(3, _buildSectionLabel('🔥 Popular Courses')),
                  const SizedBox(height: 10),
                  _fadeSlide(3, _buildFeaturedCourseList()),
                  const SizedBox(height: 20),

                  // ── 7. StudentHub Highlights banner  ✨ NEW
                  _fadeSlide(6, _buildSectionLabel('✨ School Highlights')),
                  const SizedBox(height: 4),
                  _fadeSlide(6, Text(
                    'Everything you need to ace your learning journey 🚀',
                    style: TextStyle(
                      fontSize: 13,
                      color: kTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                  const SizedBox(height: 12),
                  _fadeSlide(6, const _AppShowcaseBanner()),
                  const SizedBox(height: 20),

                  // ── 8. Leaderboard
                  _fadeSlide(4, _buildSectionLabel('🏆 Leaderboard')),
                  const SizedBox(height: 10),
                  _fadeSlide(4, _buildLeaderboard(profile)),
                ],
              ),
            ),
          ]),
        ),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 2,
            emissionFrequency: 0.06,
            numberOfParticles: 24,
            gravity: 0.28,
            colors: const [
              kPrimaryBlue, kSkyBlue, Color(0xFFFFB300),
              Color(0xFFE91E63), Color(0xFF4CAF50),
            ],
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────
  //  SLIDER ENROLL HANDLER
  // ─────────────────────────────────────────

  void _handleSliderEnroll(_SliderItem item) {
    final state  = SchoolStateProvider.of(context);
    final course = item.sourceObject as Course;

    if (state.statusOf(course.id) == CourseStatus.enrolled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Text('✅', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text('Already enrolled in ${course.title}!',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: kEnrolledGreen,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    state.setStatus(course.id, CourseStatus.enrolled);
    _confetti.play();
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(course.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Enrolled in ${course.title}! +50 XP 🎉',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ]),
      backgroundColor: kPrimaryBlue,
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─────────────────────────────────────────
  //  HEADER  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildHeader(StudentProfile p) {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [kPrimaryBlue, kDeepBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Row(children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (context.canPop()) context.pop();
                  else context.go('/');
                },
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
              // Avatar
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle),
                child: Center(child: Text(p.avatar,
                    style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hey ${p.name.split(' ').first} 👋',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3)),
                    Text("Let's build something amazing today!",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.78))),
                  ],
                ),
              ),
              // Bell → notifications
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/school/notifications');
                },
                child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 20)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  XP CARD  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildXPCard(StudentProfile p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        AnimatedBuilder(
          animation: _xpValue,
          builder: (_, __) => SizedBox(
            width: 72, height: 72,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                  value: _xpValue.value,
                  strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(kSkyBlue)),
              Text('${(_xpValue.value * 100).toInt()}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Level Progress',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _xpValue,
                  builder: (_, __) => LinearProgressIndicator(
                      value: _xpValue.value,
                      minHeight: 8,
                      color: kSkyBlue,
                      backgroundColor: Colors.white24),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text('${p.totalPoints} XP',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      '⚡ Level ${(p.totalPoints ~/ 300) + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────
  //  DAILY CHALLENGE  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildDailyChallenge(SchoolStateNotifier state) {
    final done = state.challengeDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: done
              ? const Color(0xFFE6F4EA)
              : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: done
                  ? const Color(0xFF81C784)
                  : const Color(0xFFFFCC02),
              width: 1.5)),
      child: Row(children: [
        Text(done ? '✅' : '🔥',
            style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  done ? 'Challenge Completed!' : 'Daily Challenge',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: done
                          ? const Color(0xFF2E7D32)
                          : kTextDark)),
              const SizedBox(height: 3),
              Text(
                  done
                      ? 'You earned +50 XP 🎉'
                      : 'Complete a Python quiz today!',
                  style: TextStyle(
                      fontSize: 12,
                      color: done
                          ? const Color(0xFF388E3C)
                          : kTextMuted)),
            ],
          ),
        ),
        if (!done)
          GestureDetector(
            onTap: () {
              state.completeChallenge();
              _confetti.play();
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFFFFB300),
                    Color(0xFFFF6F00),
                  ]),
                  borderRadius: BorderRadius.circular(30)),
              child: const Text('Start',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
      ]),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: kTextDark));

  // ─────────────────────────────────────────
  //  ENROLLED COURSES  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildEnrolledList(SchoolStateNotifier state) {
    final enrolled = kCourses
        .where((c) => state.statusOf(c.id) == CourseStatus.enrolled)
        .toList();
    return Column(
      children: enrolled.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFF1FBF3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: kEnrolledGreen.withValues(alpha: 0.35),
                  width: 1.5)),
          child: Row(children: [
            Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: c.bgColor,
                    borderRadius: BorderRadius.circular(13)),
                child: Center(
                    child: Text(c.emoji,
                        style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  const SizedBox(height: 4),
                  Text('${c.duration} · ${c.level}',
                      style: const TextStyle(
                          fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: kEnrolledGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_rounded,
                    size: 12, color: kEnrolledGreen),
                const SizedBox(width: 4),
                const Text('Enrolled',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kEnrolledGreen)),
              ]),
            ),
          ]),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  FEATURED COURSES  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildFeaturedCourseList() {
    final featured = kCourses.take(3).toList();
    return Column(
      children: featured
          .asMap()
          .entries
          .map((e) =>
          _FeaturedCourseCard(course: e.value, index: e.key))
          .toList(),
    );
  }

  // ─────────────────────────────────────────
  //  UPCOMING CLASSES  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildUpcomingList() {
    return Column(
      children: _upcoming
          .asMap()
          .entries
          .map((e) => _UpcomingCard(data: e.value, index: e.key))
          .toList(),
    );
  }

  // ─────────────────────────────────────────
  //  LEADERBOARD  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildLeaderboard(StudentProfile p) {
    final entries = [
      {
        'rank': '1', 'name': p.name,
        'points': '${p.totalPoints}', 'medal': '🥇', 'isMe': true
      },
      {
        'rank': '2', 'name': 'Aarav Mehta',
        'points': '980', 'medal': '🥈', 'isMe': false
      },
      {
        'rank': '3', 'name': 'Kabir Singh',
        'points': '840', 'medal': '🥉', 'isMe': false
      },
    ];
    return Column(
      children: entries.asMap().entries.map((e) {
        final i    = e.key;
        final l    = e.value;
        final isMe = l['isMe'] == true;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: isMe ? kSelectedBg : kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isMe ? kPrimaryBlue : kCardBorder,
                  width: isMe ? 1.5 : 1)),
          child: Row(children: [
            Text(l['medal']! as String,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: isMe
                        ? kSelectedBg
                        : const Color(0xFFF0F4FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isMe ? kPrimaryBlue : kCardBorder)),
                child: Center(
                    child: Text(
                      (l['name']! as String)[0],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isMe ? kPrimaryBlue : kTextMuted),
                    ))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(l['name']! as String,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isMe ? kPrimaryBlue : kTextDark),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: kPrimaryBlue,
                              borderRadius:
                              BorderRadius.circular(20)),
                          child: const Text('You',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))),
                    ],
                  ]),
                  Text('Rank #${i + 1}',
                      style: const TextStyle(
                          fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: isMe
                        ? kPrimaryBlue
                        : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${l['points']} XP',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isMe ? Colors.white : kTextMuted))),
          ]),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  FAB  (unchanged)
  // ─────────────────────────────────────────

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: kPrimaryBlue,
      elevation: 4,
      onPressed: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Text('🤖', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Text("Hi! I'm your coding robot!",
                style: TextStyle(fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: kDeepBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ));
      },
      child: const Text('🤖', style: TextStyle(fontSize: 24)),
    );
  }
}

// ─────────────────────────────────────────────
//  UPCOMING CLASS CARD  (unchanged)
// ─────────────────────────────────────────────

class _UpcomingCard extends StatefulWidget {
  final Map<String, String> data;
  final int index;
  const _UpcomingCard({required this.data, required this.index});

  @override
  State<_UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<_UpcomingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 80),
            () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kCardBorder, width: 1.5)),
          child: Row(children: [
            Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(13)),
                child: Center(
                    child: Text(d['emoji']!,
                        style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['subject']!,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  const SizedBox(height: 3),
                  Text(d['time']!,
                      style: const TextStyle(
                          fontSize: 12, color: kTextMuted)),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kCardBorder)),
                child: Text(d['day']!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: kPrimaryBlue))),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FEATURED COURSE CARD  (unchanged)
// ─────────────────────────────────────────────

class _FeaturedCourseCard extends StatefulWidget {
  final Course course;
  final int    index;
  const _FeaturedCourseCard(
      {required this.course, required this.index});

  @override
  State<_FeaturedCourseCard> createState() =>
      _FeaturedCourseCardState();
}

class _FeaturedCourseCardState extends State<_FeaturedCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 90),
            () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kCardBorder, width: 1.5)),
          child: Row(children: [
            Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                    color: c.bgColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                    child: Text(c.emoji,
                        style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  const SizedBox(height: 3),
                  Text(c.desc,
                      style: const TextStyle(
                          fontSize: 12, color: kTextMuted)),
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                          color: c.tagBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(c.tag,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: c.tagColor))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(children: [
              Text(c.students,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTextDark)),
              const Text('students',
                  style: TextStyle(fontSize: 10, color: kTextMuted)),
              const SizedBox(height: 8),
              Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                      color: kSelectedBg,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: kPrimaryBlue)),
            ]),
          ]),
        ),
      ),
    );
  }
}
