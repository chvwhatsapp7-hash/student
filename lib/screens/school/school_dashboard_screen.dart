import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue  = Color(0xFF1A73E8);
const kDeepBlue     = Color(0xFF0D47A1);
const kSkyBlue      = Color(0xFF00B0FF);
const kBgPage       = Color(0xFFF4F7FF);
const kCardBg       = Color(0xFFFFFFFF);
const kCardBorder   = Color(0xFFE0E8FB);
const kTextDark     = Color(0xFF1A2A5E);
const kTextMuted    = Color(0xFF6B80B3);
const kSelectedBg   = Color(0xFFE8F1FE);

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

const _upcoming = [
  {'day': 'Mon', 'time': '10:00 AM', 'subject': 'Python Basics',      'emoji': '🐍'},
  {'day': 'Wed', 'time': '3:00 PM',  'subject': 'Scratch Programming', 'emoji': '🎮'},
  {'day': 'Fri', 'time': '11:00 AM', 'subject': 'AI Concepts',         'emoji': '🤖'},
];

const _featuredCourses = [
  {
    'emoji': '🐍', 'title': 'Python for Kids',
    'desc': 'Create your first program', 'students': '340',
    'bg': Color(0xFFFFF3E0), 'tag': 'Popular',
    'tagBg': Color(0xFFFFF3E0), 'tagColor': Color(0xFFE65100),
  },
  {
    'emoji': '🤖', 'title': 'Intro to AI',
    'desc': 'Learn how machines think', 'students': '218',
    'bg': Color(0xFFE3F2FD), 'tag': 'Trending',
    'tagBg': Color(0xFFE3F2FD), 'tagColor': Color(0xFF1565C0),
  },
  {
    'emoji': '🎮', 'title': 'Scratch Games',
    'desc': 'Build your own game', 'students': '567',
    'bg': Color(0xFFF3E5F5), 'tag': 'Best Seller',
    'tagBg': Color(0xFFF3E5F5), 'tagColor': Color(0xFF7B1FA2),
  },
];

const _leaderboard = [
  {'rank': '1', 'name': 'Riya',  'points': '320', 'medal': '🥇'},
  {'rank': '2', 'name': 'Aarav', 'points': '280', 'medal': '🥈'},
  {'rank': '3', 'name': 'Kabir', 'points': '240', 'medal': '🥉'},
];

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────

class SchoolDashboardScreen extends StatefulWidget {
  const SchoolDashboardScreen({super.key});

  @override
  State<SchoolDashboardScreen> createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen>
    with TickerProviderStateMixin {

  late ConfettiController _confetti;
  late AnimationController _headerAnim;
  late AnimationController _xpAnim;
  late Animation<double>   _xpValue;

  // Section stagger
  late List<AnimationController> _sectionAnims;
  late List<Animation<double>>   _sectionFade;
  late List<Animation<Offset>>   _sectionSlide;

  bool _challengeDone = false;
  final double _xp = 0.7;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650),
    )..forward();

    _xpAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    );
    _xpValue = Tween<double>(begin: 0.0, end: _xp).animate(
      CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut),
    );

    // 6 sections: xp, challenge, upcoming, courses, leaderboard, fab
    _sectionAnims = List.generate(6, (_) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    ));
    _sectionFade  = _sectionAnims.map((c) =>
        CurvedAnimation(parent: c, curve: Curves.easeOut)
    ).toList();
    _sectionSlide = _sectionAnims.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        )
    ).toList();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _xpAnim.forward();
    });
    for (int i = 0; i < 6; i++) {
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
    child: SlideTransition(position: _sectionSlide[i], child: child),
  );

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      floatingActionButton: _buildFAB(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  children: [
                    _fadeSlide(0, _buildXPCard()),
                    const SizedBox(height: 14),
                    _fadeSlide(1, _buildDailyChallenge()),
                    const SizedBox(height: 20),
                    _fadeSlide(2, _buildSectionLabel('📅 Upcoming Classes')),
                    const SizedBox(height: 10),
                    _fadeSlide(2, _buildUpcomingList()),
                    const SizedBox(height: 20),
                    _fadeSlide(3, _buildSectionLabel('🔥 Popular Courses')),
                    const SizedBox(height: 10),
                    _fadeSlide(3, _buildCourseList()),
                    const SizedBox(height: 20),
                    _fadeSlide(4, _buildSectionLabel('🏆 Leaderboard')),
                    const SizedBox(height: 10),
                    _fadeSlide(4, _buildLeaderboard()),
                  ],
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(
        opacity: _headerAnim.value,
        child: child,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryBlue, kDeepBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👧', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hey Riya 👋',
                        style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        "Let's build something amazing today!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification bell
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white, size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── XP CARD ────────────────────────────────

  Widget _buildXPCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryBlue, kDeepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          // Animated ring
          AnimatedBuilder(
            animation: _xpValue,
            builder: (_, __) => SizedBox(
              width: 72, height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _xpValue.value,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(kSkyBlue),
                  ),
                  Text(
                    '${(_xpValue.value * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Level Progress',
                  style: TextStyle(
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // XP bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedBuilder(
                    animation: _xpValue,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _xpValue.value,
                      minHeight: 8,
                      color: kSkyBlue,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      '240 / 350 XP',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⚡ Level 4',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── DAILY CHALLENGE ────────────────────────

  Widget _buildDailyChallenge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _challengeDone
            ? const Color(0xFFE6F4EA)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _challengeDone
              ? const Color(0xFF81C784)
              : const Color(0xFFFFCC02),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            _challengeDone ? '✅' : '🔥',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _challengeDone ? 'Challenge Completed!' : 'Daily Challenge',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14,
                    color: _challengeDone
                        ? const Color(0xFF2E7D32)
                        : kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _challengeDone
                      ? 'You earned +50 XP 🎉'
                      : 'Complete a Python quiz today!',
                  style: TextStyle(
                    fontSize: 12,
                    color: _challengeDone
                        ? const Color(0xFF388E3C)
                        : kTextMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!_challengeDone)
            GestureDetector(
              onTap: () {
                setState(() => _challengeDone = true);
                _confetti.play();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SECTION LABEL ──────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17, fontWeight: FontWeight.w800,
        color: kTextDark,
      ),
    );
  }

  // ── UPCOMING CLASSES ───────────────────────

  Widget _buildUpcomingList() {
    return Column(
      children: _upcoming.asMap().entries.map((entry) {
        final i   = entry.key;
        final cls = entry.value;
        return _UpcomingCard(data: cls, index: i);
      }).toList(),
    );
  }

  // ── POPULAR COURSES ────────────────────────

  Widget _buildCourseList() {
    return Column(
      children: _featuredCourses.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        return _FeaturedCourseCard(data: c, index: i);
      }).toList(),
    );
  }

  // ── LEADERBOARD ────────────────────────────

  Widget _buildLeaderboard() {
    return Column(
      children: _leaderboard.asMap().entries.map((entry) {
        final i = entry.key;
        final l = entry.value;
        final isMe = l['name'] == 'Riya';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isMe ? kSelectedBg : kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMe ? kPrimaryBlue : kCardBorder,
              width: isMe ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Medal
              Text(
                l['medal']!,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 14),
              // Avatar circle
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isMe ? kSelectedBg : const Color(0xFFF0F4FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isMe ? kPrimaryBlue : kCardBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    l['name']![0],
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: isMe ? kPrimaryBlue : kTextMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l['name']!,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: isMe ? kPrimaryBlue : kTextDark,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Rank #${i + 1}',
                      style: const TextStyle(
                          fontSize: 11, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              // XP badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isMe ? kPrimaryBlue : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${l['points']} XP',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800,
                    color: isMe ? Colors.white : kTextMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── FAB ────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: kPrimaryBlue,
      elevation: 4,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('🤖', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text(
                  "Hi! I'm your coding robot!",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: kDeepBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        );
      },
      child: const Text('🤖', style: TextStyle(fontSize: 24)),
    );
  }
}

// ─────────────────────────────────────────────
//  UPCOMING CLASS CARD
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
      vsync: this, duration: const Duration(milliseconds: 480),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 + widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorder, width: 1.5),
          ),
          child: Row(
            children: [
              // Emoji tile
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(d['emoji']!, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              // Subject + time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['subject']!,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      d['time']!,
                      style: const TextStyle(fontSize: 12, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              // Day badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kCardBorder),
                ),
                child: Text(
                  d['day']!,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800,
                    color: kPrimaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FEATURED COURSE CARD
// ─────────────────────────────────────────────

class _FeaturedCourseCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  const _FeaturedCourseCard({required this.data, required this.index});

  @override
  State<_FeaturedCourseCard> createState() => _FeaturedCourseCardState();
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
      vsync: this, duration: const Duration(milliseconds: 480),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 + widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.data;
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
            border: Border.all(color: kCardBorder, width: 1.5),
          ),
          child: Row(
            children: [
              // Emoji tile
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: c['bg'] as Color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(c['emoji']!,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              // Title + desc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['title']!,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      c['desc']!,
                      style: const TextStyle(
                          fontSize: 12, color: kTextMuted),
                    ),
                    const SizedBox(height: 8),
                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: c['tagBg'] as Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c['tag']!,
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: c['tagColor'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Students + arrow
              Column(
                children: [
                  Text(
                    c['students']!,
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const Text(
                    'students',
                    style: TextStyle(fontSize: 10, color: kTextMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: kSelectedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14, color: kPrimaryBlue,
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
}
