import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'school_data.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  COURSES SCREEN
// ─────────────────────────────────────────────

class SchoolCoursesScreen extends StatefulWidget {
  const SchoolCoursesScreen({super.key});

  @override
  State<SchoolCoursesScreen> createState() => _SchoolCoursesScreenState();
}

class _SchoolCoursesScreenState extends State<SchoolCoursesScreen>
    with TickerProviderStateMixin {
  String _ageFilter = 'All';

  late AnimationController _headerAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  List<Course> get _filtered => _ageFilter == 'All'
      ? kCourses
      : kCourses.where((c) => c.age == _ageFilter).toList();

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() { _headerAnim.dispose(); super.dispose(); }

  void _openDetail(Course course, SchoolStateNotifier state) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseDetailSheet(
        course: course,
        status: state.statusOf(course.id),
        onStatus: (s) => state.setStatus(course.id, s),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = SchoolStateProvider.of(context);
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state),
          _buildFilterBar(),
          const SizedBox(height: 6),
          Expanded(child: _buildCourseList(state)),
        ],
      ),
    );
  }

  // ── Header — overflow fixed ────────────────
  // Root cause: enrolled chip had no Flexible wrapper.
  // Fix: use ConstrainedBox + FittedBox on the chip.

  Widget _buildHeader(SchoolStateNotifier state) {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title row — OVERFLOW FIX ──────────
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (context.canPop()) context.pop();
                          else context.go('/school/layout');
                        },
                        child: Container(
                          width: 36, height: 36,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 15, color: Colors.white),
                        ),
                      ),
                      // Title — Expanded so it never overflows
                      const Expanded(
                        child: Text(
                          'Our Courses',
                          style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      // Enrolled chip — constrained so it never overflows
                      AnimatedBuilder(
                        animation: state,
                        builder: (_, __) {
                          final n = state.enrolledCount;
                          if (n == 0) return const SizedBox.shrink();
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: FittedBox(
                                child: Text(
                                  '$n Enrolled',
                                  style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fun tech learning for school students!',
                    style: TextStyle(fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.78)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10, runSpacing: 8,
                    children: [
                      _statChip('🎓', '${kCourses.length} Courses'),
                      _statChip('👦', 'Ages 8–17'),
                      _statChip('⭐', '4.8 Avg Rating'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w700, color: Colors.white)),
    ]),
  );

  // ── Filter bar ─────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by Age Group',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: kTextMuted)),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kAgeFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = kAgeFilters[i];
                final selected = f == _ageFilter;
                final label = f == 'All' ? 'All Ages' : 'Ages $f';
                return GestureDetector(
                  onTap: () => setState(() => _ageFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? kPrimaryBlue : const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: selected ? kPrimaryBlue : kCardBorder,
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text(label,
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : kTextMuted)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Course list ────────────────────────────

  Widget _buildCourseList(SchoolStateNotifier state) {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('No courses for this age group yet.',
              style: TextStyle(color: kTextMuted, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _ageFilter = 'All'),
            child: const Text('Show all courses',
                style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
    }
    return AnimatedBuilder(
      animation: state,
      builder: (_, __) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final course = list[i];
          return _AnimatedCourseCard(
            course: course,
            index: i,
            status: state.statusOf(course.id),
            onTap: () => _openDetail(course, state),
            onStatus: (s) => state.setStatus(course.id, s),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED COURSE CARD
// ─────────────────────────────────────────────

class _AnimatedCourseCard extends StatefulWidget {
  final Course       course;
  final int          index;
  final CourseStatus status;
  final VoidCallback onTap;
  final ValueChanged<CourseStatus> onStatus;

  const _AnimatedCourseCard({
    required this.course, required this.index, required this.status,
    required this.onTap,  required this.onStatus,
  });

  @override
  State<_AnimatedCourseCard> createState() => _AnimatedCourseCardState();
}

class _AnimatedCourseCardState extends State<_AnimatedCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 90),
            () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _borderColor {
    switch (widget.status) {
      case CourseStatus.enrolled:   return kEnrolledGreen;
      case CourseStatus.interested: return kInterestedAmber;
      case CourseStatus.none:       return kCardBorder;
    }
  }

  Color get _bgColor {
    switch (widget.status) {
      case CourseStatus.enrolled:   return const Color(0xFFF1FBF3);
      case CourseStatus.interested: return const Color(0xFFFFF8F2);
      case CourseStatus.none:       return kCardBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown:  (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.975 : 1.0,
            duration: const Duration(milliseconds: 130),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor, width: 1.8),
                boxShadow: widget.status != CourseStatus.none
                    ? [BoxShadow(color: _borderColor.withValues(alpha: 0.15),
                    blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.status != CourseStatus.none)
                    _StatusBanner(status: widget.status),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58, height: 58,
                          decoration: BoxDecoration(
                              color: c.bgColor,
                              borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(c.emoji,
                              style: const TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(c.title,
                                      style: const TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.w800, color: kTextDark)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: c.tagBg,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(c.tag,
                                      style: TextStyle(fontSize: 10,
                                          fontWeight: FontWeight.w700, color: c.tagColor)),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text(c.desc, style: const TextStyle(
                                  fontSize: 12, color: kTextMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Meta chips
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        _metaChip(Icons.schedule_rounded,     c.duration),
                        _metaChip(Icons.people_alt_rounded,   '${c.students} students'),
                        _metaChip(Icons.child_care_rounded,   'Ages ${c.age}'),
                      ],
                    ),
                  ),
                  Container(margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      height: 1, color: const Color(0xFFF0F4FF)),
                  // Bottom: rating + level + price on row 1, buttons on row 2
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              size: 18, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(c.rating, style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700, color: kTextDark)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE8F1FE),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(c.level, style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: kPrimaryBlue)),
                          ),
                          const Spacer(),
                          Text(c.price, style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800, color: kTextDark)),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: _InterestedButton(
                            status: widget.status,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onStatus(widget.status == CourseStatus.interested
                                  ? CourseStatus.none : CourseStatus.interested);
                            },
                          )),
                          const SizedBox(width: 8),
                          Expanded(child: _EnrollButton(
                            status: widget.status,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onStatus(widget.status == CourseStatus.enrolled
                                  ? CourseStatus.none : CourseStatus.enrolled);
                            },
                          )),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: kTextMuted),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: kTextMuted)),
    ]),
  );
}

// ── Status banner ──────────────────────────────

class _StatusBanner extends StatelessWidget {
  final CourseStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isEnrolled = status == CourseStatus.enrolled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isEnrolled
            ? kEnrolledGreen.withValues(alpha: 0.12)
            : kInterestedAmber.withValues(alpha: 0.10),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(isEnrolled ? Icons.check_circle_rounded : Icons.bookmark_rounded,
            size: 14, color: isEnrolled ? kEnrolledGreen : kInterestedAmber),
        const SizedBox(width: 6),
        Text(
          isEnrolled ? 'You\'re enrolled in this course' : 'Saved as interested',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: isEnrolled ? kEnrolledGreen : kInterestedAmber),
        ),
      ]),
    );
  }
}

// ── Interested button ──────────────────────────

class _InterestedButton extends StatefulWidget {
  final CourseStatus status;
  final VoidCallback onTap;
  const _InterestedButton({required this.status, required this.onTap});

  @override
  State<_InterestedButton> createState() => _InterestedButtonState();
}

class _InterestedButtonState extends State<_InterestedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.status == CourseStatus.interested;
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: active ? kInterestedAmber.withValues(alpha: 0.12)
                  : const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: active ? kInterestedAmber : kCardBorder, width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 14, color: active ? kInterestedAmber : kTextMuted),
              const SizedBox(width: 4),
              Text(active ? 'Saved' : 'Interested',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: active ? kInterestedAmber : kTextMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Enroll button ──────────────────────────────

class _EnrollButton extends StatefulWidget {
  final CourseStatus status;
  final VoidCallback onTap;
  const _EnrollButton({required this.status, required this.onTap});

  @override
  State<_EnrollButton> createState() => _EnrollButtonState();
}

class _EnrollButtonState extends State<_EnrollButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.status == CourseStatus.enrolled;
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              gradient: active ? null : const LinearGradient(
                  colors: [kPrimaryBlue, kDeepBlue],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
              color: active ? const Color(0xFFE6F4EA) : null,
              borderRadius: BorderRadius.circular(30)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active) ...[
                const Icon(Icons.check_rounded, size: 14, color: kEnrolledGreen),
                const SizedBox(width: 4),
              ],
              Text(active ? 'Enrolled' : 'Enroll Now',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: active ? kEnrolledGreen : Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COURSE DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────

class _CourseDetailSheet extends StatefulWidget {
  final Course       course;
  final CourseStatus status;
  final ValueChanged<CourseStatus> onStatus;

  const _CourseDetailSheet({
    required this.course, required this.status, required this.onStatus,
  });

  @override
  State<_CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<_CourseDetailSheet> {
  late CourseStatus _status;

  @override
  void initState() { super.initState(); _status = widget.status; }

  void _setStatus(CourseStatus s) {
    setState(() => _status = s);
    widget.onStatus(s);
  }

  @override
  Widget build(BuildContext context) {
    final c  = widget.course;
    final mq = MediaQuery.of(context);
    return Container(
      height: mq.size.height * 0.88,
      decoration: const BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFDDE3F0),
                borderRadius: BorderRadius.circular(2))),
        _buildSheetHeader(c),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildInfoRow(c),
              const SizedBox(height: 22),
              _sectionLabel('About this Course'),
              const SizedBox(height: 8),
              Text(c.fullDescription,
                  style: const TextStyle(fontSize: 13.5, color: kTextMuted, height: 1.65)),
              const SizedBox(height: 22),
              _buildInstructorCard(c.instructor),
              const SizedBox(height: 22),
              _sectionLabel('Technologies Covered'),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                  children: c.technologies.map((t) => _techChip(t)).toList()),
              const SizedBox(height: 22),
              _sectionLabel('What You\'ll Achieve'),
              const SizedBox(height: 10),
              ...c.outcomes.map((o) => _outcomeRow(o)),
              const SizedBox(height: 22),
              _buildScheduleCard(c),
              const SizedBox(height: 28),
              _buildActionButtons(c),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildSheetHeader(Course c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Text(c.emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.title, style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.w800, color: kTextDark)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB300)),
            const SizedBox(width: 3),
            Text(c.rating, style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700, color: kTextDark)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: c.tagBg, borderRadius: BorderRadius.circular(20)),
              child: Text(c.tag, style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: c.tagColor)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(c.price, style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.w900, color: kTextDark)),
        ])),
      ]),
    );
  }

  Widget _buildInfoRow(Course c) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(children: [
        Expanded(child: _infoTile(Icons.schedule_rounded,   'Duration', c.duration)),
        const SizedBox(width: 10),
        Expanded(child: _infoTile(Icons.menu_book_rounded,  'Lessons',  c.totalLessons)),
        const SizedBox(width: 10),
        Expanded(child: _infoTile(Icons.child_care_rounded, 'Age',      'Ages ${c.age}')),
      ]),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Icon(icon, size: 18, color: kPrimaryBlue),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 10,
          color: kTextMuted, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w800, color: kTextDark)),
    ]),
  );

  Widget _buildInstructorCard(Instructor ins) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kCardBorder)),
    child: Row(children: [
      Container(width: 52, height: 52,
          decoration: BoxDecoration(color: const Color(0xFFE8F1FE),
              borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(ins.avatar,
              style: const TextStyle(fontSize: 26)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person_rounded, size: 13, color: kTextMuted),
          const SizedBox(width: 4),
          const Text('Your Instructor', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w600, color: kTextMuted)),
        ]),
        const SizedBox(height: 4),
        Text(ins.name, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w800, color: kTextDark)),
        const SizedBox(height: 2),
        Text(ins.role, style: const TextStyle(fontSize: 12, color: kTextMuted)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.workspace_premium_rounded, size: 12, color: kPrimaryBlue),
          const SizedBox(width: 4),
          Expanded(child: Text(ins.experience, style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: kPrimaryBlue))),
        ]),
      ])),
    ]),
  );

  Widget _techChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFFE8F1FE),
        borderRadius: BorderRadius.circular(20), border: Border.all(color: kCardBorder)),
    child: Text(label, style: const TextStyle(fontSize: 12,
        fontWeight: FontWeight.w700, color: kPrimaryBlue)),
  );

  Widget _outcomeRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(margin: const EdgeInsets.only(top: 3),
          width: 18, height: 18,
          decoration: BoxDecoration(
              color: kEnrolledGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 12, color: kEnrolledGreen)),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5,
          color: kTextDark, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _buildScheduleCard(Course c) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE8F1FE), Color(0xFFF0F4FF)]),
        borderRadius: BorderRadius.circular(18), border: Border.all(color: kCardBorder)),
    child: Column(children: [
      _scheduleRow(Icons.calendar_month_rounded, 'Schedule',    c.schedule),
      const SizedBox(height: 10),
      _scheduleRow(Icons.school_rounded,          'Difficulty',  c.level),
      const SizedBox(height: 10),
      _scheduleRow(Icons.workspace_premium_rounded,'Certificate', c.certificate),
    ]),
  );

  Widget _scheduleRow(IconData icon, String label, String value) =>
      Row(children: [
        Container(width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: kPrimaryBlue)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10,
              fontWeight: FontWeight.w600, color: kTextMuted)),
          Text(value, style: const TextStyle(fontSize: 12.5,
              fontWeight: FontWeight.w700, color: kTextDark)),
        ])),
      ]);

  Widget _buildActionButtons(Course c) {
    final isEnrolled  = _status == CourseStatus.enrolled;
    final isInterested = _status == CourseStatus.interested;
    return Column(children: [
      GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _setStatus(isEnrolled ? CourseStatus.none : CourseStatus.enrolled);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              gradient: isEnrolled ? null : const LinearGradient(
                  colors: [kPrimaryBlue, kDeepBlue],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
              color: isEnrolled ? const Color(0xFFE6F4EA) : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isEnrolled ? [] : [BoxShadow(color: kPrimaryBlue.withValues(alpha: 0.35),
                  blurRadius: 16, offset: const Offset(0, 6))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isEnrolled ? Icons.check_circle_rounded : Icons.rocket_launch_rounded,
                size: 18, color: isEnrolled ? kEnrolledGreen : Colors.white),
            const SizedBox(width: 8),
            Text(isEnrolled ? 'You\'re Enrolled! Tap to undo' : 'Enroll Now — ${c.price}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: isEnrolled ? kEnrolledGreen : Colors.white)),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _setStatus(isInterested ? CourseStatus.none : CourseStatus.interested);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: isInterested ? kInterestedAmber.withValues(alpha: 0.10)
                  : const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isInterested ? kInterestedAmber : kCardBorder, width: 1.5)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isInterested ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 17, color: isInterested ? kInterestedAmber : kTextMuted),
            const SizedBox(width: 8),
            Text(isInterested ? 'Saved as Interested' : 'Mark as Interested',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: isInterested ? kInterestedAmber : kTextMuted)),
          ]),
        ),
      ),
    ]);
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kTextDark));
}