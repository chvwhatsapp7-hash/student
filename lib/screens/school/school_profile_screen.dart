import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'school_data.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  RESPONSIVE HELPER
// ─────────────────────────────────────────────

class _R {
  final BuildContext ctx;
  const _R(this.ctx);

  double get w => MediaQuery.sizeOf(ctx).width;
  double get h => MediaQuery.sizeOf(ctx).height;
  double get ts => MediaQuery.textScalerOf(ctx).scale(1.0).clamp(1.0, 1.3);

  bool get isTablet => w >= 600;
  bool get isLarge => w >= 900;

  double fs(double mobile, {double? tablet, double? large}) {
    double base = mobile;
    if (isLarge && large != null) base = large;
    if (isTablet && tablet != null) base = tablet;
    return base / ts;
  }

  double get hPad => isLarge
      ? w * 0.08
      : isTablet
      ? w * 0.05
      : 16.0;
  double get cardR => isTablet ? 24.0 : 20.0;
  double get iconSz => isTablet ? 42.0 : 34.0;
}

// ─────────────────────────────────────────────
//  PROFILE SCREEN
// ─────────────────────────────────────────────

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  int _tab = 0; // 0 = Enrolled, 1 = Interested

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    return AnimatedBuilder(
      animation: SchoolStateProvider.of(context),
      builder: (_, __) {
        final state = SchoolStateProvider.of(context);
        final profile = state.profile;
        final enrolled = kCourses
            .where((c) => state.statusOf(c.id) == CourseStatus.enrolled)
            .toList();
        final interested = kCourses
            .where((c) => state.statusOf(c.id) == CourseStatus.interested)
            .toList();

        return Scaffold(
          backgroundColor: kBgPage,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, profile, r)),
              SliverToBoxAdapter(
                child: _buildStatsRow(state, enrolled, interested, r),
              ),
              SliverToBoxAdapter(
                child: _buildCourseTabs(enrolled, interested, r),
              ),
              SliverToBoxAdapter(
                child: _buildTabContent(state, enrolled, interested, r),
              ),
              SliverToBoxAdapter(
                child: _buildAchievements(state, enrolled, interested, r),
              ),
              SliverToBoxAdapter(
                child: _buildInfoSection(context, state, profile, r),
              ),
              SliverToBoxAdapter(child: _buildDangerZone(context, r)),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
        );
      },
    );
  }

  // ── Gradient header ────────────────────────

  Widget _buildHeader(BuildContext context, StudentProfile p, _R r) {
    final avatarSize = r.isTablet ? 96.0 : 80.0;
    final badgeSize = r.isTablet ? 30.0 : 24.0;

    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
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
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: EdgeInsets.fromLTRB(r.hPad, 12, r.hPad, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (context.canPop())
                            context.pop();
                          else
                            context.go('/school/layout');
                        },
                        child: Container(
                          width: r.isTablet ? 44 : 38,
                          height: r.isTablet ? 44 : 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: r.isTablet ? 18 : 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: r.fs(18, tablet: 20),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _openEditProfileSheet(context),
                        child: Container(
                          width: r.isTablet ? 44 : 38,
                          height: r.isTablet ? 44 : 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: r.isTablet ? 19 : 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar + name
                Padding(
                  padding: EdgeInsets.fromLTRB(r.hPad, 22, r.hPad, 28),
                  child: Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => _openAvatarPicker(context),
                        child: Stack(
                          children: [
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  p.avatar,
                                  style: TextStyle(
                                    fontSize: r.fs(38, tablet: 46),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: badgeSize,
                                height: badgeSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: kPrimaryBlue.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: r.isTablet ? 16 : 13,
                                  color: kPrimaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: r.fs(20, tablet: 22),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            _profileChip(Icons.school_rounded, p.grade, r),
                            const SizedBox(height: 5),
                            _profileChip(
                              Icons.location_city_rounded,
                              p.school,
                              r,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => _openEditProfileSheet(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: r.isTablet ? 16 : 12,
                                  vertical: r.isTablet ? 7 : 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.edit_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: r.fs(11, tablet: 12),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(
                                          alpha: 0.90,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileChip(IconData icon, String label, _R r) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: r.isTablet ? 15 : 13,
        color: Colors.white.withValues(alpha: 0.75),
      ),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          label,
          style: TextStyle(
            fontSize: r.fs(12, tablet: 13),
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  // ── Stats row ──────────────────────────────

  Widget _buildStatsRow(
    SchoolStateNotifier state,
    List<Course> enrolled,
    List<Course> interested,
    _R r,
  ) {
    return Container(
      color: kCardBg,
      padding: EdgeInsets.symmetric(
        vertical: r.isTablet ? 22 : 18,
        horizontal: r.hPad,
      ),
      child: Row(
        children: [
          Expanded(
            child: _statTile(
              '${enrolled.length}',
              'Enrolled',
              Icons.rocket_launch_rounded,
              kPrimaryBlue,
              const Color(0xFFE8F1FE),
              r,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statTile(
              '${interested.length}',
              'Interested',
              Icons.bookmark_rounded,
              kInterestedAmber,
              const Color(0xFFFFF3E8),
              r,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statTile(
              '${state.profile.totalPoints}',
              'Points',
              Icons.star_rounded,
              const Color(0xFFFFB300),
              const Color(0xFFFFF8E1),
              r,
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statTile(
              '${state.profile.streakDays}d',
              'Streak',
              Icons.local_fire_department_rounded,
              const Color(0xFFE53935),
              const Color(0xFFFCE8E6),
              r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 44, color: const Color(0xFFF0F4FF));

  Widget _statTile(
    String value,
    String label,
    IconData icon,
    Color iconColor,
    Color iconBg,
    _R r,
  ) {
    final tileSize = r.isTablet ? 44.0 : 38.0;
    return Column(
      children: [
        Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(r.isTablet ? 14 : 12),
          ),
          child: Icon(icon, size: r.isTablet ? 22 : 18, color: iconColor),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            fontSize: r.fs(16, tablet: 18),
            fontWeight: FontWeight.w900,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(10, tablet: 11),
            fontWeight: FontWeight.w600,
            color: kTextMuted,
          ),
        ),
      ],
    );
  }

  // ── Course tabs ────────────────────────────

  Widget _buildCourseTabs(
    List<Course> enrolled,
    List<Course> interested,
    _R r,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, 20, r.hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Courses',
            style: TextStyle(
              fontSize: r.fs(15, tablet: 16),
              fontWeight: FontWeight.w800,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _tabPill(0, '🚀 Enrolled', enrolled.length, r),
              const SizedBox(width: 10),
              _tabPill(1, '🔖 Interested', interested.length, r),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabPill(int index, String label, int count, _R r) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: EdgeInsets.symmetric(
          horizontal: r.isTablet ? 20 : 16,
          vertical: r.isTablet ? 11 : 9,
        ),
        decoration: BoxDecoration(
          color: selected ? kPrimaryBlue : kCardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? kPrimaryBlue : kCardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: r.fs(13, tablet: 14),
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : kTextMuted,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: EdgeInsets.symmetric(
                horizontal: r.isTablet ? 9 : 7,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFE8F1FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: r.fs(11, tablet: 12),
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab content ────────────────────────────

  Widget _buildTabContent(
    SchoolStateNotifier state,
    List<Course> enrolled,
    List<Course> interested,
    _R r,
  ) {
    final list = _tab == 0 ? enrolled : interested;
    final emptyEmoji = _tab == 0 ? '🚀' : '🔖';
    final emptyMessage = _tab == 0
        ? 'No enrolled courses yet.\nHead to Courses and hit Enroll!'
        : 'Nothing saved yet.\nMark courses as Interested to see them here.';

    if (list.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(r.hPad, 16, r.hPad, 0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: r.isTablet ? 40 : 32),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(r.cardR),
            border: Border.all(color: kCardBorder),
          ),
          child: Column(
            children: [
              Text(
                emptyEmoji,
                style: TextStyle(fontSize: r.fs(38, tablet: 46)),
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.fs(13, tablet: 14),
                  color: kTextMuted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Two-column grid on large screens
    if (r.isLarge) {
      final rows = (list.length / 2).ceil();
      return Padding(
        padding: EdgeInsets.fromLTRB(r.hPad, 14, r.hPad, 0),
        child: Column(
          children: List.generate(rows, (row) {
            final a = list[row * 2];
            final b = (row * 2 + 1 < list.length) ? list[row * 2 + 1] : null;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ProfileCourseCard(
                    course: a,
                    index: row * 2,
                    isEnrolled: _tab == 0,
                    onRemove: () => state.setStatus(a.id, CourseStatus.none),
                    r: r,
                  ),
                ),
                if (b != null) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ProfileCourseCard(
                      course: b,
                      index: row * 2 + 1,
                      isEnrolled: _tab == 0,
                      onRemove: () => state.setStatus(b.id, CourseStatus.none),
                      r: r,
                    ),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            );
          }),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, 14, r.hPad, 0),
      child: Column(
        children: list
            .asMap()
            .entries
            .map(
              (e) => _ProfileCourseCard(
                course: e.value,
                index: e.key,
                isEnrolled: _tab == 0,
                onRemove: () => state.setStatus(e.value.id, CourseStatus.none),
                r: r,
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Achievements ───────────────────────────

  Widget _buildAchievements(
    SchoolStateNotifier state,
    List<Course> enrolled,
    List<Course> interested,
    _R r,
  ) {
    final badges = [
      _BadgeData('🏅', 'First Enroll', enrolled.isNotEmpty),
      _BadgeData('🔖', 'Explorer', interested.isNotEmpty),
      _BadgeData('🔥', '2-Wk Streak', state.profile.streakDays >= 14),
      _BadgeData('⭐', 'Point Champ', state.profile.totalPoints >= 1000),
      _BadgeData('🎓', 'Multi-Course', enrolled.length >= 2),
    ];

    // On large screens, show badges in a wider row with more spacing
    final badgeSize = r.isTablet ? 60.0 : 52.0;
    final badgeLabelW = r.isTablet ? 68.0 : 58.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, 22, r.hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: r.fs(15, tablet: 16),
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const Spacer(),
              Text(
                '${badges.where((b) => b.unlocked).length}/${badges.length} unlocked',
                style: TextStyle(
                  fontSize: r.fs(12, tablet: 13),
                  color: kTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(r.isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(r.cardR),
              border: Border.all(color: kCardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: badges
                  .map((b) => _badgeTile(b, badgeSize, badgeLabelW, r))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(_BadgeData b, double size, double labelW, _R r) =>
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                b.unlocked
                    ? '${b.emoji} ${b.label} — Achievement unlocked!'
                    : '${b.emoji} ${b.label} — Keep going to unlock this!',
              ),
              backgroundColor: b.unlocked ? kEnrolledGreen : kTextMuted,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: b.unlocked
                    ? const Color(0xFFE8F1FE)
                    : const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(r.isTablet ? 16 : 14),
                border: Border.all(
                  color: b.unlocked
                      ? kPrimaryBlue.withValues(alpha: 0.3)
                      : kCardBorder,
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: b.unlocked ? 1.0 : 0.28,
                  child: Text(
                    b.emoji,
                    style: TextStyle(fontSize: r.fs(24, tablet: 28)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: labelW,
              child: Text(
                b.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.fs(9, tablet: 10),
                  fontWeight: FontWeight.w700,
                  color: b.unlocked ? kTextDark : kTextMuted,
                ),
              ),
            ),
          ],
        ),
      );

  // ── Info section ───────────────────────────

  Widget _buildInfoSection(
    BuildContext context,
    SchoolStateNotifier state,
    StudentProfile p,
    _R r,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, 22, r.hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Account Details',
                style: TextStyle(
                  fontSize: r.fs(15, tablet: 16),
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openEditProfileSheet(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.isTablet ? 16 : 12,
                    vertical: r.isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: kPrimaryBlue,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: r.fs(12, tablet: 13),
                          fontWeight: FontWeight.w700,
                          color: kPrimaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(r.cardR),
              border: Border.all(color: kCardBorder),
            ),
            child: Column(
              children: [
                _infoRowTappable(
                  Icons.person_rounded,
                  'Name',
                  p.name,
                  r,
                  onTap: () => _openEditProfileSheet(context),
                  isLast: false,
                ),
                _infoRowTappable(
                  Icons.school_rounded,
                  'Grade',
                  p.grade,
                  r,
                  onTap: () => _openGradePicker(context, state),
                  isLast: false,
                ),
                _infoRowTappable(
                  Icons.location_city_rounded,
                  'School',
                  p.school,
                  r,
                  onTap: () => _openEditProfileSheet(context),
                  isLast: false,
                ),
                _infoRowTappable(
                  Icons.emoji_events_rounded,
                  'Points',
                  '${p.totalPoints} pts',
                  r,
                  onTap: () {},
                  isLast: false,
                ),
                _infoRowTappable(
                  Icons.local_fire_department_rounded,
                  'Streak',
                  '${p.streakDays} days',
                  r,
                  onTap: () {},
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowTappable(
    IconData icon,
    String label,
    String value,
    _R r, {
    required VoidCallback onTap,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.isTablet ? 20 : 16,
          vertical: r.isTablet ? 16 : 14,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF0F4FF))),
        ),
        child: Row(
          children: [
            Container(
              width: r.iconSz,
              height: r.iconSz,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(r.isTablet ? 12 : 10),
              ),
              child: Icon(
                icon,
                size: r.isTablet ? 19 : 16,
                color: kPrimaryBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: r.fs(13, tablet: 14),
                  fontWeight: FontWeight.w600,
                  color: kTextMuted,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: r.fs(13, tablet: 14),
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: r.isTablet ? 19 : 16,
              color: kTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ── Danger zone ────────────────────────────

  Widget _buildDangerZone(BuildContext context, _R r) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, 22, r.hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              fontSize: r.fs(15, tablet: 16),
              fontWeight: FontWeight.w800,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(r.cardR),
              border: Border.all(color: kCardBorder),
            ),
            child: Column(
              children: [
                _actionRow(
                  Icons.help_outline_rounded,
                  'Help & Support',
                  kPrimaryBlue,
                  const Color(0xFFE8F1FE),
                  false,
                  r,
                  onTap: () => _showInfoSnack('Opening Help & Support...'),
                ),
                _actionRow(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  kTextMuted,
                  const Color(0xFFF0F4FF),
                  false,
                  r,
                  onTap: () => _showInfoSnack('Opening Privacy Policy...'),
                ),
                _actionRow(
                  Icons.logout_rounded,
                  'Sign Out',
                  const Color(0xFFE53935),
                  const Color(0xFFFCE8E6),
                  true,
                  r,
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(
    IconData icon,
    String label,
    Color iconColor,
    Color iconBg,
    bool isLast,
    _R r, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.isTablet ? 20 : 16,
          vertical: r.isTablet ? 16 : 14,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF0F4FF))),
        ),
        child: Row(
          children: [
            Container(
              width: r.iconSz,
              height: r.iconSz,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(r.isTablet ? 12 : 10),
              ),
              child: Icon(icon, size: r.isTablet ? 19 : 16, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: r.fs(13, tablet: 14),
                  fontWeight: FontWeight.w700,
                  color: isLast ? const Color(0xFFE53935) : kTextDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: r.isTablet ? 19 : 16,
              color: kTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BOTTOM SHEETS & DIALOGS
  // ─────────────────────────────────────────

  void _openEditProfileSheet(BuildContext context) {
    final state = SchoolStateProvider.of(context);
    final p = state.profile;
    final nameCtrl = TextEditingController(text: p.name);
    final schoolCtrl = TextEditingController(text: p.school);
    String grade = p.grade;
    final r = _R(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final sheetR = _R(ctx);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Center(
              // Cap sheet width on wide screens
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: sheetR.isLarge
                      ? 560
                      : sheetR.isTablet
                      ? 520
                      : double.infinity,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: kCardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sheetR.hPad),
                        child: Row(
                          children: [
                            Container(
                              width: sheetR.isTablet ? 46 : 40,
                              height: sheetR.isTablet ? 46 : 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [kPrimaryBlue, kDeepBlue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: sheetR.isTablet ? 21 : 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: sheetR.fs(18, tablet: 20),
                                fontWeight: FontWeight.w800,
                                color: kTextDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sheetR.hPad),
                        child: Column(
                          children: [
                            _editField(
                              nameCtrl,
                              'Full Name',
                              Icons.person_rounded,
                              sheetR,
                            ),
                            const SizedBox(height: 14),
                            _editField(
                              schoolCtrl,
                              'School Name',
                              Icons.location_city_rounded,
                              sheetR,
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () async {
                                final picked = await _pickGrade(ctx, grade);
                                if (picked != null)
                                  setSheetState(() => grade = picked);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: sheetR.isTablet ? 20 : 16,
                                  vertical: sheetR.isTablet ? 16 : 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: kCardBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      color: kTextMuted,
                                      size: sheetR.isTablet ? 22 : 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        grade,
                                        style: TextStyle(
                                          fontSize: sheetR.fs(14, tablet: 15),
                                          fontWeight: FontWeight.w600,
                                          color: kTextDark,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.expand_more_rounded,
                                      color: kTextMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sheetR.hPad),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            state.updateProfile(
                              p.copyWith(
                                name: nameCtrl.text.trim().isNotEmpty
                                    ? nameCtrl.text.trim()
                                    : p.name,
                                school: schoolCtrl.text.trim().isNotEmpty
                                    ? schoolCtrl.text.trim()
                                    : p.school,
                                grade: grade,
                              ),
                            );
                            Navigator.pop(ctx);
                            _showInfoSnack('Profile updated successfully!');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: sheetR.isTablet ? 18 : 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kPrimaryBlue, kDeepBlue],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryBlue.withValues(alpha: 0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: sheetR.fs(15, tablet: 16),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _editField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    _R r,
  ) => TextField(
    controller: ctrl,
    style: TextStyle(
      fontSize: r.fs(14, tablet: 15),
      fontWeight: FontWeight.w600,
      color: kTextDark,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: r.fs(13, tablet: 14),
        color: kTextMuted,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: kTextMuted, size: r.isTablet ? 22 : 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(
        horizontal: r.isTablet ? 20 : 16,
        vertical: r.isTablet ? 16 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kCardBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kCardBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
      ),
    ),
  );

  Future<String?> _pickGrade(BuildContext ctx, String current) async {
    final r = _R(ctx);
    return showModalBottomSheet<String>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: r.isLarge
                ? 560
                : r.isTablet
                ? 520
                : double.infinity,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Grade',
                  style: TextStyle(
                    fontSize: r.fs(16, tablet: 17),
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...kGradeOptions.map(
                  (g) => ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: r.hPad),
                    title: Text(
                      g,
                      style: TextStyle(
                        fontSize: r.fs(14, tablet: 15),
                        fontWeight: FontWeight.w700,
                        color: g == current ? kPrimaryBlue : kTextDark,
                      ),
                    ),
                    trailing: g == current
                        ? const Icon(Icons.check_rounded, color: kPrimaryBlue)
                        : null,
                    onTap: () => Navigator.pop(ctx, g),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openGradePicker(BuildContext context, SchoolStateNotifier state) async {
    final picked = await _pickGrade(context, state.profile.grade);
    if (picked != null) {
      state.updateProfile(state.profile.copyWith(grade: picked));
      _showInfoSnack('Grade updated to $picked');
    }
  }

  void _openAvatarPicker(BuildContext context) {
    final state = SchoolStateProvider.of(context);
    final r = _R(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: r.isLarge
                ? 560
                : r.isTablet
                ? 520
                : double.infinity,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Avatar',
                  style: TextStyle(
                    fontSize: r.fs(16, tablet: 17),
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.hPad),
                  child: GridView.count(
                    // More columns on wider screens
                    crossAxisCount: r.isLarge
                        ? 9
                        : r.isTablet
                        ? 8
                        : 6,
                    shrinkWrap: true,
                    crossAxisSpacing: r.isTablet ? 14 : 12,
                    mainAxisSpacing: r.isTablet ? 14 : 12,
                    children: kAvatarOptions
                        .map(
                          (av) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              state.updateProfile(
                                state.profile.copyWith(avatar: av),
                              );
                              Navigator.pop(context);
                              _showInfoSnack('Avatar updated!');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: av == state.profile.avatar
                                    ? const Color(0xFFE8F1FE)
                                    : const Color(0xFFF4F7FF),
                                borderRadius: BorderRadius.circular(
                                  r.isTablet ? 16 : 14,
                                ),
                                border: Border.all(
                                  color: av == state.profile.avatar
                                      ? kPrimaryBlue
                                      : kCardBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  av,
                                  style: TextStyle(
                                    fontSize: r.fs(24, tablet: 28),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final r = _R(context);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Cap dialog width on large screens
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.isTablet ? 420 : 320),
          child: Padding(
            padding: EdgeInsets.all(r.isTablet ? 28 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign Out?',
                  style: TextStyle(
                    fontSize: r.fs(17, tablet: 19),
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kTextMuted,
                    fontSize: r.fs(14, tablet: 15),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: kTextMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: r.fs(14, tablet: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: r.fs(14, tablet: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: kPrimaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE COURSE CARD
// ─────────────────────────────────────────────

class _ProfileCourseCard extends StatefulWidget {
  final Course course;
  final int index;
  final bool isEnrolled;
  final VoidCallback onRemove;
  final _R r;

  const _ProfileCourseCard({
    required this.course,
    required this.index,
    required this.isEnrolled,
    required this.onRemove,
    required this.r,
  });

  @override
  State<_ProfileCourseCard> createState() => _ProfileCourseCardState();
}

class _ProfileCourseCardState extends State<_ProfileCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 50 + widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final r = widget.r;
    final color = widget.isEnrolled ? kEnrolledGreen : kInterestedAmber;
    final bgColor = widget.isEnrolled
        ? const Color(0xFFF1FBF3)
        : const Color(0xFFFFF8F2);
    final label = widget.isEnrolled ? 'Enrolled' : 'Interested';
    final icon = widget.isEnrolled
        ? Icons.check_circle_rounded
        : Icons.bookmark_rounded;
    final emojiBoxSize = r.isTablet ? 60.0 : 52.0;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: Key('course_${c.id}_${widget.isEnrolled}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE53935),
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onRemove();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(r.isTablet ? 16 : 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(r.isTablet ? 20 : 18),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: emojiBoxSize,
                  height: emojiBoxSize,
                  decoration: BoxDecoration(
                    color: c.bgColor,
                    borderRadius: BorderRadius.circular(r.isTablet ? 16 : 14),
                  ),
                  child: Center(
                    child: Text(
                      c.emoji,
                      style: TextStyle(fontSize: r.fs(24, tablet: 28)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: TextStyle(
                          fontSize: r.fs(14, tablet: 15),
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: r.isTablet ? 13 : 11,
                            color: kTextMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            c.duration,
                            style: TextStyle(
                              fontSize: r.fs(11, tablet: 12),
                              color: kTextMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.bar_chart_rounded,
                            size: r.isTablet ? 13 : 11,
                            color: kTextMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            c.level,
                            style: TextStyle(
                              fontSize: r.fs(11, tablet: 12),
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.isTablet ? 11 : 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: r.isTablet ? 13 : 11, color: color),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: r.fs(10, tablet: 11),
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.price,
                      style: TextStyle(
                        fontSize: r.fs(14, tablet: 15),
                        fontWeight: FontWeight.w900,
                        color: kTextDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────

class _BadgeData {
  final String emoji, label;
  final bool unlocked;
  const _BadgeData(this.emoji, this.label, this.unlocked);
}
