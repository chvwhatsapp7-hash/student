import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
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
//  DASHBOARD SCREEN
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

  late List<AnimationController> _sectionAnims;
  late List<Animation<double>>   _sectionFade;
  late List<Animation<Offset>>   _sectionSlide;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))..forward();

    _xpAnim  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800));
    _xpValue = Tween<double>(begin: 0.0, end: 0.7)
        .animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));

    _sectionAnims = List.generate(6, (_) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500)));
    _sectionFade  = _sectionAnims.map((c) =>
        CurvedAnimation(parent: c, curve: Curves.easeOut)).toList();
    _sectionSlide = _sectionAnims.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();

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
                  _fadeSlide(0, _buildXPCard(profile)),
                  const SizedBox(height: 14),
                  _fadeSlide(1, _buildDailyChallenge(state)),
                  const SizedBox(height: 20),
                  _fadeSlide(2, _buildSectionLabel('📅 Upcoming Classes')),
                  const SizedBox(height: 10),
                  _fadeSlide(2, _buildUpcomingList()),
                  const SizedBox(height: 20),
                  if (state.enrolledCount > 0) ...[
                    _fadeSlide(3, _buildSectionLabel('🚀 My Enrolled Courses')),
                    const SizedBox(height: 10),
                    _fadeSlide(3, _buildEnrolledList(state)),
                    const SizedBox(height: 20),
                  ],
                  _fadeSlide(3, _buildSectionLabel('🔥 Popular Courses')),
                  const SizedBox(height: 10),
                  _fadeSlide(3, _buildFeaturedCourseList()),
                  const SizedBox(height: 20),
                  _fadeSlide(4, _buildSectionLabel('🏆 Leaderboard')),
                  const SizedBox(height: 10),
                  _fadeSlide(4, _buildLeaderboard(profile)),
                ],
              ),
            ),
          ]),
        ),
        // Confetti
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

  // ── Header ─────────────────────────────────

  Widget _buildHeader(StudentProfile p) {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [kPrimaryBlue, kDeepBlue],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
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
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hey ${p.name.split(' ').first} 👋',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.3)),
                Text("Let's build something amazing today!",
                    style: TextStyle(fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.78))),
              ])),
              // ✅ Bell icon — wired to notifications screen
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

  // ── XP card ────────────────────────────────

  Widget _buildXPCard(StudentProfile p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        AnimatedBuilder(
          animation: _xpValue,
          builder: (_, __) => SizedBox(
            width: 72, height: 72,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                  value: _xpValue.value, strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(kSkyBlue)),
              Text('${(_xpValue.value * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Level Progress', style: TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: _xpValue,
              builder: (_, __) => LinearProgressIndicator(
                  value: _xpValue.value, minHeight: 8,
                  color: kSkyBlue, backgroundColor: Colors.white24),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text('${p.totalPoints} XP',
                style: const TextStyle(color: Colors.white70, fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('⚡ Level ${(p.totalPoints ~/ 300) + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ])),
      ]),
    );
  }

  // ── Daily challenge ────────────────────────

  Widget _buildDailyChallenge(SchoolStateNotifier state) {
    final done = state.challengeDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: done ? const Color(0xFFE6F4EA) : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: done ? const Color(0xFF81C784) : const Color(0xFFFFCC02),
              width: 1.5)),
      child: Row(children: [
        Text(done ? '✅' : '🔥', style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(done ? 'Challenge Completed!' : 'Daily Challenge',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14,
                  color: done ? const Color(0xFF2E7D32) : kTextDark)),
          const SizedBox(height: 3),
          Text(done ? 'You earned +50 XP 🎉' : 'Complete a Python quiz today!',
              style: TextStyle(fontSize: 12,
                  color: done ? const Color(0xFF388E3C) : kTextMuted)),
        ])),
        if (!done)
          GestureDetector(
            onTap: () {
              state.completeChallenge();
              _confetti.play();
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
                  borderRadius: BorderRadius.circular(30)),
              child: const Text('Start', style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
      ]),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kTextDark));

  // ── Enrolled courses (live) ────────────────

  Widget _buildEnrolledList(SchoolStateNotifier state) {
    final enrolled = kCourses
        .where((c) => state.statusOf(c.id) == CourseStatus.enrolled)
        .toList();
    return Column(
      children: enrolled.asMap().entries.map((e) {
        final c = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFF1FBF3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kEnrolledGreen.withValues(alpha: 0.35), width: 1.5)),
          child: Row(children: [
            Container(width: 48, height: 48,
                decoration: BoxDecoration(color: c.bgColor,
                    borderRadius: BorderRadius.circular(13)),
                child: Center(child: Text(c.emoji,
                    style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w800, color: kTextDark)),
              const SizedBox(height: 4),
              Text('${c.duration} · ${c.level}',
                  style: const TextStyle(fontSize: 11, color: kTextMuted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: kEnrolledGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_rounded, size: 12, color: kEnrolledGreen),
                const SizedBox(width: 4),
                const Text('Enrolled', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w800, color: kEnrolledGreen)),
              ]),
            ),
          ]),
        );
      }).toList(),
    );
  }

  // ── Featured courses ───────────────────────

  Widget _buildFeaturedCourseList() {
    final featured = kCourses.take(3).toList();
    return Column(
      children: featured.asMap().entries.map((e) =>
          _FeaturedCourseCard(course: e.value, index: e.key)).toList(),
    );
  }

  // ── Upcoming classes ───────────────────────

  Widget _buildUpcomingList() {
    return Column(
      children: _upcoming.asMap().entries.map((e) =>
          _UpcomingCard(data: e.value, index: e.key)).toList(),
    );
  }

  // ── Leaderboard ────────────────────────────

  Widget _buildLeaderboard(StudentProfile p) {
    final entries = [
      {'rank': '1', 'name': p.name,        'points': '${p.totalPoints}', 'medal': '🥇', 'isMe': true},
      {'rank': '2', 'name': 'Aarav Mehta', 'points': '980',  'medal': '🥈', 'isMe': false},
      {'rank': '3', 'name': 'Kabir Singh', 'points': '840',  'medal': '🥉', 'isMe': false},
    ];
    return Column(
      children: entries.asMap().entries.map((e) {
        final i    = e.key;
        final l    = e.value;
        final isMe = l['isMe'] == true;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: isMe ? kSelectedBg : kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isMe ? kPrimaryBlue : kCardBorder,
                  width: isMe ? 1.5 : 1)),
          child: Row(children: [
            Text(l['medal']! as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: isMe ? kSelectedBg : const Color(0xFFF0F4FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: isMe ? kPrimaryBlue : kCardBorder)),
                child: Center(child: Text(
                    (l['name']! as String)[0],
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: isMe ? kPrimaryBlue : kTextMuted)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(l['name']! as String,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                        color: isMe ? kPrimaryBlue : kTextDark),
                    overflow: TextOverflow.ellipsis)),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: kPrimaryBlue,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('You', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700, color: Colors.white))),
                ],
              ]),
              Text('Rank #${i + 1}',
                  style: const TextStyle(fontSize: 11, color: kTextMuted)),
            ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: isMe ? kPrimaryBlue : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${l['points']} XP',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                        color: isMe ? Colors.white : kTextMuted))),
          ]),
        );
      }).toList(),
    );
  }

  // ── FAB ────────────────────────────────────

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ));
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
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 480));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kCardBorder, width: 1.5)),
          child: Row(children: [
            Container(width: 44, height: 44,
                decoration: BoxDecoration(color: kSelectedBg,
                    borderRadius: BorderRadius.circular(13)),
                child: Center(child: Text(d['emoji']!,
                    style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d['subject']!, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w800, color: kTextDark)),
              const SizedBox(height: 3),
              Text(d['time']!, style: const TextStyle(fontSize: 12,
                  color: kTextMuted)),
            ])),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kCardBorder)),
                child: Text(d['day']!, style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w800, color: kPrimaryBlue))),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FEATURED COURSE CARD
// ─────────────────────────────────────────────

class _FeaturedCourseCard extends StatefulWidget {
  final Course course;
  final int    index;
  const _FeaturedCourseCard({required this.course, required this.index});

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
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 480));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
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
            Container(width: 54, height: 54,
                decoration: BoxDecoration(color: c.bgColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Center(child: Text(c.emoji,
                    style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w800, color: kTextDark)),
              const SizedBox(height: 3),
              Text(c.desc, style: const TextStyle(fontSize: 12,
                  color: kTextMuted)),
              const SizedBox(height: 8),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: c.tagBg,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(c.tag, style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w700, color: c.tagColor))),
            ])),
            const SizedBox(width: 12),
            Column(children: [
              Text(c.students, style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w800, color: kTextDark)),
              const Text('students', style: TextStyle(fontSize: 10,
                  color: kTextMuted)),
              const SizedBox(height: 8),
              Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: kSelectedBg,
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
