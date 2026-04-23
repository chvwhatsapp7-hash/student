import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'school_data.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  PROFILE SCREEN  (fully dynamic)
// ─────────────────────────────────────────────

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen>
    with TickerProviderStateMixin {

  // ── Ready guard ────────────────────────────
  bool _ready = false;

  // ── Animation controllers ──────────────────
  late AnimationController _headerAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  late AnimationController _strengthAnim;
  late Animation<double>   _strengthVal;

  // ── Tab controller ─────────────────────────
  late TabController _tabCtrl;

  // ─────────────────────────────────────────
  //  LIFECYCLE
  // ─────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Header slide-in
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
        begin: const Offset(0, -0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    // Strength bar
    _strengthAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _strengthVal  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _strengthAnim, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300),
            () { if (mounted) _strengthAnim.forward(); });

    // 4 tabs: Overview | Courses | Achievements | Account
    _tabCtrl = TabController(length: 4, vsync: this);

    // ✅ Mark ready AFTER all controllers are initialized
    _ready = true;
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _strengthAnim.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  PROFILE STRENGTH (dynamic)
  // ─────────────────────────────────────────

  double _profileStrength(StudentProfile p,
      List<Course> enrolled, List<Course> interested) {
    double s = 0.20; // base
    if (p.name.isNotEmpty && p.name != 'Student') s += 0.10;
    if (p.school.isNotEmpty && p.school != 'My School') s += 0.10;
    if (enrolled.isNotEmpty)   s += 0.20;
    if (enrolled.length >= 2)  s += 0.10;
    if (interested.isNotEmpty) s += 0.10;
    if (p.streakDays >= 7)     s += 0.10;
    if (p.totalPoints >= 500)  s += 0.10;
    return s.clamp(0.0, 1.0);
  }

  String _strengthHint(StudentProfile p,
      List<Course> enrolled, List<Course> interested) {
    if (p.name == 'Student' || p.name.isEmpty)
      return 'Add your name to boost your profile (+10%)';
    if (p.school.isEmpty || p.school == 'My School')
      return 'Add your school name (+10%)';
    if (enrolled.isEmpty)
      return 'Enroll in a course to get started (+20%)';
    if (enrolled.length < 2)
      return 'Enroll in one more course (+10%)';
    if (interested.isEmpty)
      return 'Bookmark courses you like (+10%)';
    if (p.streakDays < 7)
      return 'Keep a 7-day streak to level up (+10%)';
    return '🎉 Your profile is looking great!';
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ Safety guard — return empty widget if controllers not yet initialized
    if (!_ready) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: SchoolStateProvider.of(context),
      builder: (_, __) {
        final state      = SchoolStateProvider.of(context);
        final profile    = state.profile;
        final enrolled   = kCourses
            .where((c) => state.statusOf(c.id) == CourseStatus.enrolled)
            .toList();
        final interested = kCourses
            .where((c) => state.statusOf(c.id) == CourseStatus.interested)
            .toList();

        // Re-drive strength animation whenever state changes
        final strength = _profileStrength(profile, enrolled, interested);

        return Scaffold(
          backgroundColor: kBgPage,
          body: Column(
            children: [
              // ── Fixed gradient header ──────
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(context, state, profile,
                      enrolled, interested, strength),
                ),
              ),
              // ── Tab bar ────────────────────
              _buildTabBar(),
              // ── Tab views ──────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildOverviewTab(context, state, profile,
                        enrolled, interested, strength),
                    _buildCoursesTab(context, state, enrolled, interested),
                    _buildAchievementsTab(state, enrolled, interested),
                    _buildAccountTab(context, state, profile),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      List<Course> enrolled,
      List<Course> interested,
      double strength,
      ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryBlue, kDeepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          // ── App bar row ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _iconBtn(Icons.arrow_back_ios_new_rounded, () {
                HapticFeedback.lightImpact();
                if (context.canPop()) context.pop();
                else context.go('/school/layout');
              }),
              const Spacer(),
              const Text('My Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.2)),
              const Spacer(),
              _iconBtn(Icons.edit_rounded,
                      () => _openEditProfileSheet(context, state, p)),
            ]),
          ),

          // ── Avatar + name + chips ────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => _openAvatarPicker(context, state, p),
                child: Stack(children: [
                  Container(
                    width: 78, height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                    ),
                    child: Center(
                        child: Text(p.avatar,
                            style: const TextStyle(fontSize: 36))),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: kPrimaryBlue.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 13, color: kPrimaryBlue),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name.isNotEmpty ? p.name : 'Student',
                        style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 5),
                    _profileChip(Icons.school_rounded,        p.grade),
                    const SizedBox(height: 4),
                    _profileChip(Icons.location_city_rounded, p.school),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () =>
                          _openEditProfileSheet(context, state, p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.edit_rounded,
                              size: 11, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Edit Profile',
                              style: TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.90))),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          // ── Mini stats row ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _hStat('${enrolled.length}',   'Enrolled',  Icons.rocket_launch_rounded),
                  _hDiv(),
                  _hStat('${interested.length}', 'Saved',     Icons.bookmark_rounded),
                  _hDiv(),
                  _hStat('${p.totalPoints}',     'Points',    Icons.star_rounded),
                  _hDiv(),
                  _hStat('${p.streakDays}d',     'Streak',    Icons.local_fire_department_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _hStat(String value, String label, IconData icon) => Column(
    children: [
      Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.80)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w900, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.65))),
    ],
  );

  Widget _hDiv() => Container(
      width: 1, height: 32,
      color: Colors.white.withValues(alpha: 0.20));

  Widget _profileChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.75)),
      const SizedBox(width: 5),
      Flexible(
        child: Text(label,
            style: TextStyle(fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ),
    ],
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );

  // ─────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────

  Widget _buildTabBar() => Container(
    color: kCardBg,
    child: TabBar(
      controller: _tabCtrl,
      isScrollable: true,
      labelColor: kPrimaryBlue,
      unselectedLabelColor: kTextMuted,
      labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
      const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      indicatorColor: kPrimaryBlue,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.tab,
      padding: EdgeInsets.zero,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Courses'),
        Tab(text: 'Achievements'),
        Tab(text: 'Account'),
      ],
    ),
  );

  // ═════════════════════════════════════════
  //  TAB 1 — OVERVIEW
  // ═════════════════════════════════════════

  Widget _buildOverviewTab(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      List<Course> enrolled,
      List<Course> interested,
      double strength,
      ) {
    final hint = _strengthHint(p, enrolled, interested);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Profile strength card ──────────
        _sectionCard(
          child: Column(children: [
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPrimaryBlue, kDeepBlue]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Profile Strength',
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w800, color: kTextDark)),
              const Spacer(),
              AnimatedBuilder(
                animation: _strengthAnim,
                builder: (_, __) => Text(
                  '${(_strengthAnim.value * strength * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w900, color: kPrimaryBlue),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AnimatedBuilder(
                animation: _strengthAnim,
                builder: (_, __) => LinearProgressIndicator(
                  value: _strengthAnim.value * strength,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8F1FE),
                  valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.tips_and_updates_rounded,
                  size: 14, color: kTextMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(hint,
                    style: const TextStyle(fontSize: 12,
                        color: kTextMuted, fontStyle: FontStyle.italic)),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Quick info card ────────────────
        _sectionCard(
          child: Column(children: [
            _cardHeader('Account Details', Icons.person_rounded,
                onEdit: () => _openEditProfileSheet(context, state, p)),
            const SizedBox(height: 14),
            _infoRow(Icons.person_rounded, 'Name',
                p.name.isNotEmpty ? p.name : '—', false),
            _infoRow(Icons.school_rounded, 'Grade', p.grade, false),
            _infoRow(Icons.location_city_rounded, 'School',
                p.school.isNotEmpty ? p.school : '—', false),
            _infoRow(Icons.star_rounded, 'Points',
                '${p.totalPoints} pts', false),
            _infoRow(Icons.local_fire_department_rounded, 'Streak',
                '${p.streakDays} days', true),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Top enrolled courses preview ───
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Enrolled Courses', Icons.rocket_launch_rounded,
                  onEdit: () => _tabCtrl.animateTo(1)),
              const SizedBox(height: 14),
              if (enrolled.isEmpty)
                _emptyHint('🚀', 'No enrolled courses yet.\nGo to Courses and hit Enroll!')
              else
                ...enrolled.take(3).map((c) =>
                    _miniCourseRow(c, CourseStatus.enrolled)),
              if (enrolled.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () => _tabCtrl.animateTo(1),
                    child: Text('+${enrolled.length - 3} more courses',
                        style: const TextStyle(fontSize: 12,
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Bookmarked preview ─────────────
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Saved Courses', Icons.bookmark_rounded,
                  onEdit: () => _tabCtrl.animateTo(1)),
              const SizedBox(height: 14),
              if (interested.isEmpty)
                _emptyHint('🔖', 'Nothing bookmarked yet.')
              else
                ...interested.take(2).map((c) =>
                    _miniCourseRow(c, CourseStatus.interested)),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ═════════════════════════════════════════
  //  TAB 2 — COURSES
  // ═════════════════════════════════════════

  Widget _buildCoursesTab(
      BuildContext context,
      SchoolStateNotifier state,
      List<Course> enrolled,
      List<Course> interested,
      ) {
    return DefaultTabController(
      length: 2,
      child: Column(children: [
        // Sub-tab pills
        Container(
          color: kCardBg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            _subTabPill(enrolled.length,   '🚀 Enrolled',   0),
            const SizedBox(width: 10),
            _subTabPill(interested.length, '🔖 Interested', 1),
          ]),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _courseList(state, enrolled,   isEnrolled: true),
              _courseList(state, interested, isEnrolled: false),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _subTabPill(int count, String label, int index) {
    return _SubTabPill(count: count, label: label, index: index);
  }

  Widget _courseList(SchoolStateNotifier state, List<Course> list,
      {required bool isEnrolled}) {
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(isEnrolled ? '🚀' : '🔖',
              style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 12),
          Text(isEnrolled
              ? 'No enrolled courses yet.\nHead to Courses and hit Enroll!'
              : 'Nothing saved yet.\nMark courses as Interested.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13,
                  color: kTextMuted, height: 1.6)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => _ProfileCourseCard(
        course: list[i], index: i, isEnrolled: isEnrolled,
        onRemove: () => state.setStatus(list[i].id, CourseStatus.none),
      ),
    );
  }

  // ═════════════════════════════════════════
  //  TAB 3 — ACHIEVEMENTS
  // ═════════════════════════════════════════

  Widget _buildAchievementsTab(
      SchoolStateNotifier state,
      List<Course> enrolled,
      List<Course> interested,
      ) {
    final p = state.profile;

    final badges = [
      _BadgeData('🏅', 'First Enroll',  'Enroll in your first course',
          enrolled.isNotEmpty),
      _BadgeData('🔖', 'Explorer',      'Bookmark a course',
          interested.isNotEmpty),
      _BadgeData('🎓', 'Multi-Course',  'Enroll in 2+ courses',
          enrolled.length >= 2),
      _BadgeData('🔥', '2-Wk Streak',  'Maintain a 14-day streak',
          p.streakDays >= 14),
      _BadgeData('⭐', 'Point Champ',  'Earn 1000+ points',
          p.totalPoints >= 1000),
      _BadgeData('🚀','Overachiever',  'Enroll in 5+ courses',
          enrolled.length >= 5),
    ];

    final unlocked = badges.where((b) => b.unlocked).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Progress banner ────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kPrimaryBlue, kDeepBlue],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$unlocked / ${badges.length} Unlocked',
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: unlocked / badges.length,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(unlocked == badges.length
                    ? '🎉 All badges unlocked!'
                    : 'Keep going to unlock all badges!',
                    style: TextStyle(fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 20),

        // ── Badge grid ────────────────────
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Badges', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w800, color: kTextDark)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: badges.map((b) => _badgeTile(b)).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Stats summary ──────────────────
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stats', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w800, color: kTextDark)),
              const SizedBox(height: 14),
              _statProgressRow('Courses Enrolled',
                  enrolled.length, 5, kPrimaryBlue),
              const SizedBox(height: 12),
              _statProgressRow('Streak Days',
                  state.profile.streakDays, 14, const Color(0xFFE53935)),
              const SizedBox(height: 12),
              _statProgressRow('Points Earned',
                  state.profile.totalPoints, 1000, const Color(0xFFFFB300)),
              const SizedBox(height: 12),
              _statProgressRow('Bookmarks',
                  interested.length, 5, kInterestedAmber),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _statProgressRow(String label, int value, int max, Color color) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label,
            style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w700, color: kTextDark))),
        Text('$value / $max',
            style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w800, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          backgroundColor: const Color(0xFFE8F1FE),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }

  Widget _badgeTile(_BadgeData b) => GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(b.unlocked
            ? '${b.emoji} ${b.label} — Unlocked!'
            : '${b.emoji} ${b.label} — ${b.description}'),
        backgroundColor: b.unlocked ? kEnrolledGreen : kTextMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ));
    },
    child: Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity, height: 70,
        decoration: BoxDecoration(
          color: b.unlocked
              ? const Color(0xFFE8F1FE) : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: b.unlocked
                  ? kPrimaryBlue.withValues(alpha: 0.3) : kCardBorder),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: b.unlocked ? 1.0 : 0.28,
            child: Text(b.emoji,
                style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(b.label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: b.unlocked ? kTextDark : kTextMuted)),
    ]),
  );

  // ═════════════════════════════════════════
  //  TAB 4 — ACCOUNT
  // ═════════════════════════════════════════

  Widget _buildAccountTab(BuildContext context, SchoolStateNotifier state,
      StudentProfile p) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Edit profile ───────────────────
        _sectionCard(
          child: Column(children: [
            _cardHeader('Profile Info', Icons.person_rounded,
                onEdit: () => _openEditProfileSheet(context, state, p)),
            const SizedBox(height: 14),
            _tappableRow(Icons.person_rounded, 'Name',
                p.name.isNotEmpty ? p.name : '—', false,
                onTap: () => _openEditProfileSheet(context, state, p)),
            _tappableRow(Icons.school_rounded, 'Grade', p.grade, false,
                onTap: () => _openGradePicker(context, state)),
            _tappableRow(Icons.location_city_rounded, 'School',
                p.school.isNotEmpty ? p.school : '—', false,
                onTap: () => _openEditProfileSheet(context, state, p)),
            _tappableRow(Icons.emoji_events_rounded, 'Points',
                '${p.totalPoints} pts', false, onTap: () {}),
            _tappableRow(Icons.local_fire_department_rounded, 'Streak',
                '${p.streakDays} days', true, onTap: () {}),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Avatar ─────────────────────────
        _sectionCard(
          child: Column(children: [
            _cardHeader('Appearance', Icons.palette_rounded, onEdit: null),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _openAvatarPicker(context, state, p),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: kPrimaryBlue.withValues(alpha: 0.3),
                        width: 1.5),
                  ),
                  child: Center(child: Text(p.avatar,
                      style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Avatar', style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700, color: kTextDark)),
                      SizedBox(height: 3),
                      Text('Tap to change your emoji avatar',
                          style: TextStyle(fontSize: 11, color: kTextMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: kTextMuted),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Action rows ────────────────────
        _sectionCard(
          child: Column(children: [
            _actionRow(Icons.help_outline_rounded, 'Help & Support',
                kPrimaryBlue, const Color(0xFFE8F1FE), false,
                onTap: () => _showSnack('Opening Help & Support...')),
            _actionRow(Icons.privacy_tip_outlined, 'Privacy Policy',
                kTextMuted, const Color(0xFFF0F4FF), false,
                onTap: () => _showSnack('Opening Privacy Policy...')),
            _actionRow(Icons.logout_rounded, 'Sign Out',
                const Color(0xFFE53935), const Color(0xFFFCE8E6), true,
                onTap: () => _confirmSignOut(context)),
          ]),
        ),

        const SizedBox(height: 50),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  SHARED WIDGETS
  // ─────────────────────────────────────────

  Widget _sectionCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kCardBorder),
    ),
    child: child,
  );

  Widget _cardHeader(String title, IconData icon,
      {required VoidCallback? onEdit}) {
    return Row(children: [
      Icon(icon, size: 18, color: kPrimaryBlue),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w800, color: kTextDark)),
      const Spacer(),
      if (onEdit != null)
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.edit_rounded, size: 11, color: kPrimaryBlue),
              SizedBox(width: 5),
              Text('Edit', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: kPrimaryBlue)),
            ]),
          ),
        ),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value, bool isLast) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
            border: isLast ? null : const Border(
                bottom: BorderSide(color: Color(0xFFF0F4FF)))),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 15, color: kPrimaryBlue)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted))),
          Text(value, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w800, color: kTextDark)),
        ]),
      );

  Widget _tappableRow(IconData icon, String label, String value, bool isLast,
      {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              border: isLast ? null : const Border(
                  bottom: BorderSide(color: Color(0xFFF0F4FF)))),
          child: Row(children: [
            Container(width: 32, height: 32,
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 15, color: kPrimaryBlue)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted))),
            Flexible(child: Text(value,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w800, color: kTextDark),
                overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 15, color: kTextMuted),
          ]),
        ),
      );

  Widget _actionRow(IconData icon, String label,
      Color iconColor, Color iconBg, bool isLast,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 13),
        decoration: BoxDecoration(
            border: isLast ? null : const Border(
                bottom: BorderSide(color: Color(0xFFF0F4FF)))),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 15, color: iconColor)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLast ? const Color(0xFFE53935) : kTextDark))),
          const Icon(Icons.chevron_right_rounded,
              size: 15, color: kTextMuted),
        ]),
      ),
    );
  }

  Widget _miniCourseRow(Course c, CourseStatus status) {
    final color = status == CourseStatus.enrolled
        ? kEnrolledGreen : kInterestedAmber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(
                color: c.bgColor, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(c.emoji,
                style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.title, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w700, color: kTextDark),
                overflow: TextOverflow.ellipsis),
            Text(c.duration,
                style: const TextStyle(fontSize: 10, color: kTextMuted)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20)),
          child: Text(status == CourseStatus.enrolled ? 'Enrolled' : 'Saved',
              style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w800, color: color)),
        ),
      ]),
    );
  }

  Widget _emptyHint(String emoji, String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 32)),
      const SizedBox(height: 8),
      Text(msg, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12,
              color: kTextMuted, height: 1.6)),
    ]),
  );

  // ─────────────────────────────────────────
  //  BOTTOM SHEETS & DIALOGS
  // ─────────────────────────────────────────

  void _openEditProfileSheet(BuildContext context,
      SchoolStateNotifier state, StudentProfile p) {
    final nameCtrl   = TextEditingController(text: p.name);
    final schoolCtrl = TextEditingController(text: p.school);
    String grade     = p.grade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                      color: kCardBorder,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [kPrimaryBlue, kDeepBlue]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: Colors.white, size: 18)),
                  const SizedBox(width: 12),
                  const Text('Edit Profile', style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w800, color: kTextDark)),
                ]),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  _editTextField(nameCtrl,   'Full Name',   Icons.person_rounded),
                  const SizedBox(height: 14),
                  _editTextField(schoolCtrl, 'School Name', Icons.location_city_rounded),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final picked = await _pickGrade(ctx, grade);
                      if (picked != null) {
                        setSheetState(() => grade = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: kCardBorder, width: 1.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.school_rounded,
                            color: kTextMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(grade,
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kTextDark))),
                        const Icon(Icons.expand_more_rounded,
                            color: kTextMuted),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    state.updateProfile(p.copyWith(
                      name: nameCtrl.text.trim().isNotEmpty
                          ? nameCtrl.text.trim() : p.name,
                      school: schoolCtrl.text.trim().isNotEmpty
                          ? schoolCtrl.text.trim() : p.school,
                      grade: grade,
                    ));
                    Navigator.pop(ctx);
                    _strengthAnim
                      ..reset()
                      ..forward();
                    _showSnack('Profile updated successfully!');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kPrimaryBlue, kDeepBlue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimaryBlue.withValues(alpha: 0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const Center(child: Text('Save Changes',
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white))),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _editTextField(TextEditingController ctrl,
      String label, IconData icon) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600, color: kTextDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w600),
          prefixIcon: Icon(icon, color: kTextMuted, size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kCardBorder, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kCardBorder, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
        ),
      );

  Future<String?> _pickGrade(BuildContext ctx, String current) =>
      showModalBottomSheet<String>(
        context: ctx,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            const Text('Select Grade', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w800, color: kTextDark)),
            const SizedBox(height: 8),
            ...kGradeOptions.map((g) => ListTile(
              title: Text(g, style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: g == current ? kPrimaryBlue : kTextDark)),
              trailing: g == current
                  ? const Icon(Icons.check_rounded, color: kPrimaryBlue)
                  : null,
              onTap: () => Navigator.pop(ctx, g),
            )),
            const SizedBox(height: 16),
          ]),
        ),
      );

  void _openGradePicker(BuildContext context,
      SchoolStateNotifier state) async {
    final picked = await _pickGrade(context, state.profile.grade);
    if (picked != null) {
      state.updateProfile(state.profile.copyWith(grade: picked));
      _showSnack('Grade updated to $picked');
    }
  }

  void _openAvatarPicker(BuildContext context,
      SchoolStateNotifier state, StudentProfile p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            const Text('Choose Avatar', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w800, color: kTextDark)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                children: kAvatarOptions.map((av) => GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    state.updateProfile(p.copyWith(avatar: av));
                    Navigator.pop(context);
                    _showSnack('Avatar updated!');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: av == p.avatar
                          ? const Color(0xFFE8F1FE)
                          : const Color(0xFFF4F7FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: av == p.avatar
                              ? kPrimaryBlue : kCardBorder,
                          width: 1.5),
                    ),
                    child: Center(child: Text(av,
                        style: const TextStyle(fontSize: 24))),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w800, color: kTextDark)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: kTextMuted, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(
                  color: kTextMuted, fontWeight: FontWeight.w700))),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: kPrimaryBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────────────────────
//  SUB TAB PILL  (stateful — reads DefaultTabController)
// ─────────────────────────────────────────────

class _SubTabPill extends StatefulWidget {
  final int    count;
  final String label;
  final int    index;
  const _SubTabPill(
      {required this.count, required this.label, required this.index});

  @override
  State<_SubTabPill> createState() => _SubTabPillState();
}

class _SubTabPillState extends State<_SubTabPill> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DefaultTabController.of(context).addListener(_rebuild);
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    DefaultTabController.of(context).removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc       = DefaultTabController.of(context);
    final selected = tc.index == widget.index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        tc.animateTo(widget.index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kPrimaryBlue : kCardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: selected ? kPrimaryBlue : kCardBorder, width: 1.5),
        ),
        child: Row(children: [
          Text(widget.label, style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : kTextMuted)),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFFE8F1FE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${widget.count}', style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : kPrimaryBlue)),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE COURSE CARD  (swipe-to-remove)
// ─────────────────────────────────────────────

class _ProfileCourseCard extends StatefulWidget {
  final Course       course;
  final int          index;
  final bool         isEnrolled;
  final VoidCallback onRemove;

  const _ProfileCourseCard({
    required this.course,
    required this.index,
    required this.isEnrolled,
    required this.onRemove,
  });

  @override
  State<_ProfileCourseCard> createState() => _ProfileCourseCardState();
}

class _ProfileCourseCardState extends State<_ProfileCourseCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 420));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 80),
            () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c       = widget.course;
    final color   = widget.isEnrolled ? kEnrolledGreen : kInterestedAmber;
    final bgColor = widget.isEnrolled
        ? const Color(0xFFF1FBF3) : const Color(0xFFFFF8F2);
    final label   = widget.isEnrolled ? 'Enrolled' : 'Interested';
    final icon    = widget.isEnrolled
        ? Icons.check_circle_rounded : Icons.bookmark_rounded;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: Key('pc_${c.id}_${widget.isEnrolled}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFE53935), size: 24),
              SizedBox(height: 4),
              Text('Remove', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: Color(0xFFE53935))),
            ]),
          ),
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onRemove();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: color.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Row(children: [
              Container(width: 52, height: 52,
                  decoration: BoxDecoration(
                      color: c.bgColor,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(c.emoji,
                      style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w800, color: kTextDark)),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: kTextMuted),
                      const SizedBox(width: 3),
                      Text(c.duration,
                          style: const TextStyle(
                              fontSize: 11, color: kTextMuted)),
                      const SizedBox(width: 8),
                      const Icon(Icons.bar_chart_rounded,
                          size: 11, color: kTextMuted),
                      const SizedBox(width: 3),
                      Text(c.level,
                          style: const TextStyle(
                              fontSize: 11, color: kTextMuted)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 11, color: color),
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w800, color: color)),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(c.price, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w900, color: kTextDark)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────────

class _BadgeData {
  final String emoji, label, description;
  final bool   unlocked;
  const _BadgeData(this.emoji, this.label, this.description, this.unlocked);
}
