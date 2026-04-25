import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../api_services/CourseEnrollement.dart';
import '../../api_services/authservice.dart';
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
  double get ts => MediaQuery.textScalerOf(ctx).scale(1.0);

  bool get isTablet => w >= 600;
  bool get isLarge => w >= 900;

  double fs(double mobile, {double? tablet, double? large}) {
    if (isLarge && large != null) return large / ts.clamp(1.0, 1.3);
    if (isTablet && tablet != null) return tablet / ts.clamp(1.0, 1.3);
    return mobile / ts.clamp(1.0, 1.3);
  }

  double get hPad => isLarge
      ? w * 0.08
      : isTablet
      ? w * 0.05
      : 16.0;
  int get cardCols => isLarge ? 2 : 1;
}

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
  List<Course> _courses = [];
  bool _isLoading = true;

  final Set<int> _enrolledIds = {};
  final Set<int> _enrollingIds = {};

  // ✅ NEW: Saved courses tracking
  final Set<int> _savedIds = {};
  final Set<int> _savingIds = {};

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  List<Course> get _filtered => _ageFilter == 'All'
      ? _courses
      : _courses.where((c) => c.age == _ageFilter).toList();

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _loadCourses();
    _loadEnrolledIds();
    _loadSavedIds(); // ✅ NEW
  }

  Future<void> _loadCourses() async {
    try {
      final response = await AuthService().get(
        '/getCourses?target_group=school',
      );
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (json['success'] == true) {
          final list = json['data'] as List<dynamic>;
          if (mounted) {
            setState(() {
              _courses = list.map(_mapToCourse).toList();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('School courses error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEnrolledIds() async {
    try {
      final enrolled = await CourseService.getEnrolledCourses();
      if (!mounted) return;
      setState(() {
        _enrolledIds.addAll(
          enrolled
              .where((c) => c['course_id'] != null)
              .map<int>((c) => c['course_id'] as int),
        );
      });
    } catch (e) {
      debugPrint('Load enrolled error: $e');
    }
  }

  // ✅ NEW: Load saved course IDs from API
  Future<void> _loadSavedIds() async {
    try {
      final response = await AuthService().get('/saved-courses');
      if (!mounted) return;
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (json['success'] == true) {
          final list = json['data'] as List<dynamic>;
          setState(() {
            _savedIds.addAll(
              list
                  .where((c) => c['course_id'] != null)
                  .map<int>((c) => c['course_id'] as int),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Load saved courses error: $e');
    }
  }

  Future<void> _enroll(Course course) async {
    if (_enrolledIds.contains(course.id)) return;
    if (_enrollingIds.contains(course.id)) return;

    HapticFeedback.lightImpact();
    setState(() => _enrollingIds.add(course.id));
    try {
      final msg = await CourseService.enroll(course.id);
      if (!mounted) return;
      final success = msg == 'Enrolled successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: success ? kEnrolledGreen : const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      if (success) setState(() => _enrolledIds.add(course.id));
    } catch (e) {
      debugPrint('Enroll error: $e');
    } finally {
      if (mounted) setState(() => _enrollingIds.remove(course.id));
    }
  }

  Future<void> _unenroll(Course course) async {
    if (!_enrolledIds.contains(course.id)) return;
    if (_enrollingIds.contains(course.id)) return;

    HapticFeedback.lightImpact();
    setState(() => _enrollingIds.add(course.id));
    try {
      final msg = await CourseService.unenroll(course.id);
      if (!mounted) return;
      final success = msg == 'Unenrolled successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.remove_circle_rounded : Icons.error_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: success
              ? const Color(0xFFE53935)
              : const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      if (success) setState(() => _enrolledIds.remove(course.id));
    } catch (e) {
      debugPrint('Unenroll error: $e');
    } finally {
      if (mounted) setState(() => _enrollingIds.remove(course.id));
    }
  }

  // ✅ NEW: Save course via POST /saved-courses
  Future<void> _saveCourse(Course course) async {
    if (_savedIds.contains(course.id)) return;
    if (_savingIds.contains(course.id)) return;

    HapticFeedback.selectionClick();
    setState(() => _savingIds.add(course.id));
    try {
      final response = await AuthService().post('/saved-courses', {
        'course_id': course.id,
      });
      if (!mounted) return;
      final success = response.statusCode == 201 || response.statusCode == 200;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.bookmark_added_rounded : Icons.error_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? 'Course saved successfully'
                      : 'Failed to save course',
                ),
              ),
            ],
          ),
          backgroundColor: success ? kInterestedAmber : const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      if (success) setState(() => _savedIds.add(course.id));
    } catch (e) {
      debugPrint('Save course error: $e');
    } finally {
      if (mounted) setState(() => _savingIds.remove(course.id));
    }
  }

  // ✅ NEW: Unsave course via DELETE /saved-courses
  Future<void> _unsaveCourse(Course course) async {
    if (!_savedIds.contains(course.id)) return;
    if (_savingIds.contains(course.id)) return;

    HapticFeedback.selectionClick();
    setState(() => _savingIds.add(course.id));
    try {
      final response = await AuthService().delete('/saved-courses', {
        'course_id': course.id,
      });
      if (!mounted) return;
      final success = response.statusCode == 200;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.bookmark_remove_rounded : Icons.error_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success ? 'Course unsaved successfully' : 'Failed to unsave',
                ),
              ),
            ],
          ),
          backgroundColor: success ? kTextMuted : const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      if (success) setState(() => _savedIds.remove(course.id));
    } catch (e) {
      debugPrint('Unsave course error: $e');
    } finally {
      if (mounted) setState(() => _savingIds.remove(course.id));
    }
  }

  static Course _mapToCourse(dynamic e) {
    final category = (e['category'] as String?) ?? 'General';
    final title = (e['title'] as String?) ?? '';
    final ratingRaw = e['rating'];
    final priceRaw = e['price'];

    return Course(
      id: e['course_id'] as int? ?? 0,
      title: title,
      desc: (e['description'] as String?) ?? 'No description.',
      fullDescription: (e['description'] as String?) ?? 'No description.',
      age: '8-17',
      duration: (e['duration'] as String?) ?? 'Self-paced',
      students: '0',
      rating: ratingRaw != null ? (ratingRaw as num).toStringAsFixed(1) : 'N/A',
      level: (e['level'] as String?) ?? 'Beginner',
      price: (priceRaw == null || priceRaw == 0) ? 'Free' : '₹$priceRaw',
      tag: category,
      tagColor: _tagColorFor(category),
      tagBg: _tagBgFor(category),
      bgColor: _bgColorFor(category),
      emoji: _emojiFor(title, category),
      totalLessons: 'N/A',
      schedule: 'Self-paced',
      certificate: 'Yes',
      instructor: Instructor(
        name: (e['instructor'] as String?) ?? 'Instructor',
        role: (e['provider'] as String?) ?? category,
        experience: 'Expert Instructor',
        avatar: _emojiFor(title, category),
      ),
      technologies: e['skills'] != null && (e['skills'] as List).isNotEmpty
          ? List<String>.from(e['skills'])
          : [category],
      outcomes: [
        'Understand core concepts of $title',
        'Apply skills in real-world projects',
        'Earn a certificate of completion',
      ],
    );
  }

  static String _emojiFor(String title, String category) {
    final t = title.toLowerCase();
    final c = category.toLowerCase();
    if (t.contains('python')) return '🐍';
    if (t.contains('web') || t.contains('html')) return '🌐';
    if (t.contains('scratch') || t.contains('game')) return '🎮';
    if (t.contains('ai') || t.contains('artificial')) return '🤖';
    if (t.contains('math')) return '📐';
    if (t.contains('robot')) return '🦾';
    if (t.contains('coding') || t.contains('programming')) return '💻';
    if (c.contains('web')) return '🌐';
    if (c.contains('game')) return '🎮';
    if (c.contains('ai')) return '🤖';
    if (c.contains('math')) return '📐';
    if (c.contains('robot')) return '🦾';
    return '📘';
  }

  static Color _tagColorFor(String c) {
    switch (c.toLowerCase()) {
      case 'web development':
        return const Color(0xFF1D4ED8);
      case 'programming':
        return const Color(0xFF15803D);
      case 'game development':
        return const Color(0xFF7C3AED);
      case 'artificial intelligence':
        return const Color(0xFF0369A1);
      case 'mathematics':
        return const Color(0xFFB45309);
      case 'robotics':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  static Color _tagBgFor(String c) {
    switch (c.toLowerCase()) {
      case 'web development':
        return const Color(0xFFEFF6FF);
      case 'programming':
        return const Color(0xFFF0FDF4);
      case 'game development':
        return const Color(0xFFFDF4FF);
      case 'artificial intelligence':
        return const Color(0xFFE0F2FE);
      case 'mathematics':
        return const Color(0xFFFFFBEB);
      case 'robotics':
        return const Color(0xFFFFF1F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static Color _bgColorFor(String c) {
    switch (c.toLowerCase()) {
      case 'web development':
        return const Color(0xFFEFF6FF);
      case 'programming':
        return const Color(0xFFF0FDF4);
      case 'game development':
        return const Color(0xFFFDF4FF);
      case 'artificial intelligence':
        return const Color(0xFFE0F2FE);
      case 'mathematics':
        return const Color(0xFFFFFBEB);
      case 'robotics':
        return const Color(0xFFFFF1F2);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  void _openDetail(Course course, SchoolStateNotifier state) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseDetailSheet(
        course: course,
        isEnrolled: _enrolledIds.contains(course.id),
        isSaved: _savedIds.contains(course.id), // ✅ NEW
        status: state.statusOf(course.id),
        onStatus: (s) => state.setStatus(course.id, s),
        onEnroll: () => _enroll(course),
        onUnenroll: () => _unenroll(course),
        onSave: () => _saveCourse(course), // ✅ NEW
        onUnsave: () => _unsaveCourse(course), // ✅ NEW
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = SchoolStateProvider.of(context);
    final r = _R(context);

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state, r),
          _buildFilterBar(r),
          const SizedBox(height: 6),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCourseList(state, r),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SchoolStateNotifier state, _R r) {
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, 14, r.hPad, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          width: r.isTablet ? 42 : 36,
                          height: r.isTablet ? 42 : 36,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: r.isTablet ? 18 : 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Our Courses',
                          style: TextStyle(
                            fontSize: r.fs(20, tablet: 24, large: 26),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (_enrolledIds.isNotEmpty)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: r.isTablet ? 140 : 110,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                              horizontal: r.isTablet ? 14 : 10,
                              vertical: r.isTablet ? 7 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: FittedBox(
                              child: Text(
                                '${_enrolledIds.length} Enrolled',
                                style: TextStyle(
                                  fontSize: r.fs(12, tablet: 14),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fun tech learning for school students!',
                    style: TextStyle(
                      fontSize: r.fs(13, tablet: 15),
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _statChip('🎓', '${_courses.length} Courses', r),
                      _statChip('👦', 'Ages 8–17', r),
                      _statChip('⭐', '4.8 Avg Rating', r),
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

  Widget _statChip(String icon, String label, _R r) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: r.isTablet ? 14 : 11,
      vertical: r.isTablet ? 8 : 6,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: r.fs(13, tablet: 15))),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(12, tablet: 14),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget _buildFilterBar(_R r) {
    return Container(
      color: kCardBg,
      padding: EdgeInsets.fromLTRB(r.hPad, 12, r.hPad, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Age Group',
            style: TextStyle(
              fontSize: r.fs(12, tablet: 13),
              fontWeight: FontWeight.w700,
              color: kTextMuted,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: r.isTablet ? 42 : 36,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: r.isTablet ? 20 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? kPrimaryBlue : const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected ? kPrimaryBlue : kCardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: r.fs(13, tablet: 14),
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : kTextMuted,
                        ),
                      ),
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

  Widget _buildCourseList(SchoolStateNotifier state, _R r) {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔍', style: TextStyle(fontSize: r.fs(48, tablet: 56))),
            const SizedBox(height: 12),
            Text(
              'No courses for this age group yet.',
              style: TextStyle(
                color: kTextMuted,
                fontSize: r.fs(14, tablet: 16),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _ageFilter = 'All'),
              child: Text(
                'Show all courses',
                style: TextStyle(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: r.fs(14, tablet: 15),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        if (r.cardCols > 1) {
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(r.hPad, 10, r.hPad, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final course = list[i];
              return _AnimatedCourseCard(
                course: course,
                index: i,
                isEnrolled: _enrolledIds.contains(course.id),
                isEnrolling: _enrollingIds.contains(course.id),
                isSaved: _savedIds.contains(course.id), // ✅ NEW
                isSaving: _savingIds.contains(course.id), // ✅ NEW
                status: state.statusOf(course.id),
                onTap: () => _openDetail(course, state),
                onStatus: (s) => state.setStatus(course.id, s),
                onEnroll: () => _enroll(course),
                onUnenroll: () => _unenroll(course),
                onSave: () => _saveCourse(course), // ✅ NEW
                onUnsave: () => _unsaveCourse(course), // ✅ NEW
              );
            },
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(r.hPad, 10, r.hPad, 24),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final course = list[i];
            return _AnimatedCourseCard(
              course: course,
              index: i,
              isEnrolled: _enrolledIds.contains(course.id),
              isEnrolling: _enrollingIds.contains(course.id),
              isSaved: _savedIds.contains(course.id), // ✅ NEW
              isSaving: _savingIds.contains(course.id), // ✅ NEW
              status: state.statusOf(course.id),
              onTap: () => _openDetail(course, state),
              onStatus: (s) => state.setStatus(course.id, s),
              onEnroll: () => _enroll(course),
              onUnenroll: () => _unenroll(course),
              onSave: () => _saveCourse(course), // ✅ NEW
              onUnsave: () => _unsaveCourse(course), // ✅ NEW
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED COURSE CARD
// ─────────────────────────────────────────────

class _AnimatedCourseCard extends StatefulWidget {
  final Course course;
  final int index;
  final CourseStatus status;
  final bool isEnrolled;
  final bool isEnrolling;
  final bool isSaved; // ✅ NEW
  final bool isSaving; // ✅ NEW
  final VoidCallback onTap;
  final ValueChanged<CourseStatus> onStatus;
  final VoidCallback onEnroll;
  final VoidCallback onUnenroll;
  final VoidCallback onSave; // ✅ NEW
  final VoidCallback onUnsave; // ✅ NEW

  const _AnimatedCourseCard({
    required this.course,
    required this.index,
    required this.isEnrolled,
    required this.isEnrolling,
    required this.isSaved, // ✅ NEW
    required this.isSaving, // ✅ NEW
    required this.status,
    required this.onTap,
    required this.onStatus,
    required this.onEnroll,
    required this.onUnenroll,
    required this.onSave, // ✅ NEW
    required this.onUnsave, // ✅ NEW
  });

  @override
  State<_AnimatedCourseCard> createState() => _AnimatedCourseCardState();
}

class _AnimatedCourseCardState extends State<_AnimatedCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.isEnrolled) return kEnrolledGreen;
    switch (widget.status) {
      case CourseStatus.interested:
        return kInterestedAmber;
      default:
        return kCardBorder;
    }
  }

  Color get _bgColor {
    if (widget.isEnrolled) return const Color(0xFFF1FBF3);
    switch (widget.status) {
      case CourseStatus.interested:
        return const Color(0xFFFFF8F2);
      default:
        return kCardBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final r = _R(context);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
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
              margin: EdgeInsets.only(bottom: r.cardCols > 1 ? 0 : 14),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor, width: 1.8),
                boxShadow:
                    (widget.isEnrolled || widget.status != CourseStatus.none)
                    ? [
                        BoxShadow(
                          color: _borderColor.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isEnrolled)
                    _StatusBanner(status: CourseStatus.enrolled)
                  else if (widget.status != CourseStatus.none)
                    _StatusBanner(status: widget.status),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      r.isTablet ? 18 : 16,
                      16,
                      r.isTablet ? 18 : 16,
                      0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: r.isTablet ? 66 : 58,
                          height: r.isTablet ? 66 : 58,
                          decoration: BoxDecoration(
                            color: c.bgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              c.emoji,
                              style: TextStyle(fontSize: r.fs(28, tablet: 32)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.title,
                                      style: TextStyle(
                                        fontSize: r.fs(15, tablet: 16),
                                        fontWeight: FontWeight.w800,
                                        color: kTextDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: c.tagBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      c.tag,
                                      style: TextStyle(
                                        fontSize: r.fs(10, tablet: 11),
                                        fontWeight: FontWeight.w700,
                                        color: c.tagColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: r.fs(12, tablet: 13),
                                  color: kTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      r.isTablet ? 18 : 16,
                      12,
                      r.isTablet ? 18 : 16,
                      0,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _metaChip(Icons.schedule_rounded, c.duration, r),
                        _metaChip(
                          Icons.people_alt_rounded,
                          '${c.students} students',
                          r,
                        ),
                        _metaChip(Icons.child_care_rounded, 'Ages ${c.age}', r),
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(
                      r.isTablet ? 18 : 16,
                      14,
                      r.isTablet ? 18 : 16,
                      0,
                    ),
                    height: 1,
                    color: const Color(0xFFF0F4FF),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      r.isTablet ? 18 : 16,
                      12,
                      r.isTablet ? 18 : 16,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFFB300),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              c.rating,
                              style: TextStyle(
                                fontSize: r.fs(13, tablet: 14),
                                fontWeight: FontWeight.w700,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F1FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c.level,
                                style: TextStyle(
                                  fontSize: r.fs(11, tablet: 12),
                                  fontWeight: FontWeight.w700,
                                  color: kPrimaryBlue,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              c.price,
                              style: TextStyle(
                                fontSize: r.fs(16, tablet: 18),
                                fontWeight: FontWeight.w800,
                                color: kTextDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // ✅ NOW API-driven: save/unsave bookmark button
                            Expanded(
                              child: _InterestedButton(
                                isSaved: widget.isSaved,
                                isSaving: widget.isSaving,
                                onTap: () {
                                  widget.isSaved
                                      ? widget.onUnsave()
                                      : widget.onSave();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _EnrollButton(
                                isEnrolled: widget.isEnrolled,
                                isEnrolling: widget.isEnrolling,
                                onTap: widget.isEnrolled
                                    ? widget.onUnenroll
                                    : widget.onEnroll,
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
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, _R r) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: r.isTablet ? 11 : 9,
      vertical: r.isTablet ? 6 : 5,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: r.isTablet ? 14 : 12, color: kTextMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(11, tablet: 12),
            fontWeight: FontWeight.w700,
            color: kTextMuted,
          ),
        ),
      ],
    ),
  );
}

// ── Status banner ───────────────────────────────

class _StatusBanner extends StatelessWidget {
  final CourseStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isEnrolled = status == CourseStatus.enrolled;
    final r = _R(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isEnrolled
            ? kEnrolledGreen.withValues(alpha: 0.12)
            : kInterestedAmber.withValues(alpha: 0.10),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEnrolled ? Icons.check_circle_rounded : Icons.bookmark_rounded,
            size: r.isTablet ? 16 : 14,
            color: isEnrolled ? kEnrolledGreen : kInterestedAmber,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isEnrolled
                  ? "You're enrolled in this course"
                  : 'Saved as interested',
              style: TextStyle(
                fontSize: r.fs(12, tablet: 13),
                fontWeight: FontWeight.w700,
                color: isEnrolled ? kEnrolledGreen : kInterestedAmber,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Interested button (✅ now API-driven save/unsave) ──

class _InterestedButton extends StatefulWidget {
  final bool isSaved; // ✅ replaced: status
  final bool isSaving; // ✅ NEW: loading state
  final VoidCallback onTap;

  const _InterestedButton({
    required this.isSaved,
    required this.isSaving,
    required this.onTap,
  });

  @override
  State<_InterestedButton> createState() => _InterestedButtonState();
}

class _InterestedButtonState extends State<_InterestedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isSaving) widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: r.isTablet ? 16 : 12,
            vertical: r.isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: widget.isSaved
                ? kInterestedAmber.withValues(alpha: 0.12)
                : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isSaved ? kInterestedAmber : kCardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSaving)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kInterestedAmber,
                  ),
                )
              else
                Icon(
                  widget.isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: r.isTablet ? 16 : 14,
                  color: widget.isSaved ? kInterestedAmber : kTextMuted,
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.isSaving
                      ? '...'
                      : widget.isSaved
                      ? 'Saved'
                      : 'Save',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: r.fs(12, tablet: 13),
                    fontWeight: FontWeight.w700,
                    color: widget.isSaved ? kInterestedAmber : kTextMuted,
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

// ── Enroll button ──────────────────────────────

class _EnrollButton extends StatefulWidget {
  final bool isEnrolled;
  final bool isEnrolling;
  final VoidCallback onTap;
  const _EnrollButton({
    required this.isEnrolled,
    required this.isEnrolling,
    required this.onTap,
  });

  @override
  State<_EnrollButton> createState() => _EnrollButtonState();
}

class _EnrollButtonState extends State<_EnrollButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isEnrolling) widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: r.isTablet ? 20 : 16,
            vertical: r.isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            gradient: (widget.isEnrolled || widget.isEnrolling)
                ? null
                : const LinearGradient(
                    colors: [kPrimaryBlue, kDeepBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: widget.isEnrolled ? const Color(0xFFFFEBEE) : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isEnrolling)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else if (widget.isEnrolled) ...[
                const Icon(
                  Icons.cancel_rounded,
                  size: 14,
                  color: Color(0xFFE53935),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  widget.isEnrolling
                      ? 'Loading...'
                      : widget.isEnrolled
                      ? 'Unenroll'
                      : 'Enroll Now',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: r.fs(12, tablet: 13),
                    fontWeight: FontWeight.w800,
                    color: widget.isEnrolled
                        ? const Color(0xFFE53935)
                        : Colors.white,
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
//  COURSE DETAIL SHEET
// ─────────────────────────────────────────────

class _CourseDetailSheet extends StatefulWidget {
  final Course course;
  final bool isEnrolled;
  final bool isSaved; // ✅ NEW
  final CourseStatus status;
  final ValueChanged<CourseStatus> onStatus;
  final VoidCallback onEnroll;
  final VoidCallback onUnenroll;
  final VoidCallback onSave; // ✅ NEW
  final VoidCallback onUnsave; // ✅ NEW

  const _CourseDetailSheet({
    required this.course,
    required this.isEnrolled,
    required this.isSaved, // ✅ NEW
    required this.status,
    required this.onStatus,
    required this.onEnroll,
    required this.onUnenroll,
    required this.onSave, // ✅ NEW
    required this.onUnsave, // ✅ NEW
  });

  @override
  State<_CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<_CourseDetailSheet> {
  late CourseStatus _status;
  late bool _isEnrolled;
  late bool _isSaved; // ✅ NEW

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _isEnrolled = widget.isEnrolled;
    _isSaved = widget.isSaved; // ✅ NEW
  }

  void _setStatus(CourseStatus s) {
    setState(() => _status = s);
    widget.onStatus(s);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final mq = MediaQuery.of(context);
    final r = _R(context);

    final sheetWidth = r.isLarge
        ? mq.size.width * 0.55
        : r.isTablet
        ? mq.size.width * 0.75
        : mq.size.width;
    final sheetHeight = r.isTablet
        ? mq.size.height * 0.82
        : mq.size.height * 0.88;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: sheetWidth,
        height: sheetHeight,
        child: Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE3F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildSheetHeader(c, r),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(c, r),
                      const SizedBox(height: 22),
                      _sectionLabel('About this Course', r),
                      const SizedBox(height: 8),
                      Text(
                        c.fullDescription,
                        style: TextStyle(
                          fontSize: r.fs(13.5, tablet: 14.5),
                          color: kTextMuted,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildInstructorCard(c.instructor, r),
                      const SizedBox(height: 22),
                      _sectionLabel('Technologies Covered', r),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: c.technologies
                            .map((t) => _techChip(t, r))
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      _sectionLabel("What You'll Achieve", r),
                      const SizedBox(height: 10),
                      ...c.outcomes.map((o) => _outcomeRow(o, r)),
                      const SizedBox(height: 22),
                      _buildScheduleCard(c, r),
                      const SizedBox(height: 28),
                      _buildActionButtons(c, r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(Course c, _R r) => Container(
    margin: EdgeInsets.fromLTRB(r.hPad, 16, r.hPad, 0),
    padding: EdgeInsets.all(r.isTablet ? 22 : 18),
    decoration: BoxDecoration(
      color: c.bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Text(c.emoji, style: TextStyle(fontSize: r.fs(40, tablet: 48))),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.title,
                style: TextStyle(
                  fontSize: r.fs(18, tablet: 20),
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFFFB300),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    c.rating,
                    style: TextStyle(
                      fontSize: r.fs(13, tablet: 14),
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: c.tagBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.tag,
                      style: TextStyle(
                        fontSize: r.fs(10, tablet: 11),
                        fontWeight: FontWeight.w700,
                        color: c.tagColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                c.price,
                style: TextStyle(
                  fontSize: r.fs(20, tablet: 24),
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildInfoRow(Course c, _R r) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Row(
      children: [
        Expanded(
          child: _infoTile(Icons.schedule_rounded, 'Duration', c.duration, r),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(
            Icons.menu_book_rounded,
            'Lessons',
            c.totalLessons,
            r,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(Icons.child_care_rounded, 'Age', 'Ages ${c.age}', r),
        ),
      ],
    ),
  );

  Widget _infoTile(IconData icon, String label, String value, _R r) =>
      Container(
        padding: EdgeInsets.symmetric(
          vertical: r.isTablet ? 14 : 12,
          horizontal: r.isTablet ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: r.isTablet ? 22 : 18, color: kPrimaryBlue),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: r.fs(10, tablet: 11),
                color: kTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.fs(11, tablet: 12),
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
          ],
        ),
      );

  Widget _buildInstructorCard(Instructor ins, _R r) => Container(
    padding: EdgeInsets.all(r.isTablet ? 20 : 16),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F7FF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kCardBorder),
    ),
    child: Row(
      children: [
        Container(
          width: r.isTablet ? 62 : 52,
          height: r.isTablet ? 62 : 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1FE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              ins.avatar,
              style: TextStyle(fontSize: r.fs(26, tablet: 30)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 13, color: kTextMuted),
                  const SizedBox(width: 4),
                  const Text(
                    'Your Instructor',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                ins.name,
                style: TextStyle(
                  fontSize: r.fs(14, tablet: 15),
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ins.role,
                style: TextStyle(
                  fontSize: r.fs(12, tablet: 13),
                  color: kTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 12,
                    color: kPrimaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ins.experience,
                      style: TextStyle(
                        fontSize: r.fs(11, tablet: 12),
                        fontWeight: FontWeight.w700,
                        color: kPrimaryBlue,
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
  );

  Widget _techChip(String label, _R r) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: r.isTablet ? 14 : 12,
      vertical: r.isTablet ? 8 : 6,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F1FE),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kCardBorder),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: r.fs(12, tablet: 13),
        fontWeight: FontWeight.w700,
        color: kPrimaryBlue,
      ),
    ),
  );

  Widget _outcomeRow(String text, _R r) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: r.isTablet ? 22 : 18,
          height: r.isTablet ? 22 : 18,
          decoration: BoxDecoration(
            color: kEnrolledGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: r.isTablet ? 14 : 12,
            color: kEnrolledGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: r.fs(13.5, tablet: 14.5),
              color: kTextDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildScheduleCard(Course c, _R r) => Container(
    padding: EdgeInsets.all(r.isTablet ? 20 : 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE8F1FE), Color(0xFFF0F4FF)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kCardBorder),
    ),
    child: Column(
      children: [
        _scheduleRow(Icons.calendar_month_rounded, 'Schedule', c.schedule, r),
        const SizedBox(height: 10),
        _scheduleRow(Icons.school_rounded, 'Difficulty', c.level, r),
        const SizedBox(height: 10),
        _scheduleRow(
          Icons.workspace_premium_rounded,
          'Certificate',
          c.certificate,
          r,
        ),
      ],
    ),
  );

  Widget _scheduleRow(IconData icon, String label, String value, _R r) => Row(
    children: [
      Container(
        width: r.isTablet ? 38 : 32,
        height: r.isTablet ? 38 : 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: r.isTablet ? 19 : 16, color: kPrimaryBlue),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: r.fs(10, tablet: 11),
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: r.fs(12.5, tablet: 13.5),
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildActionButtons(Course c, _R r) {
    return Column(
      children: [
        // Enroll / Unenroll button — unchanged
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (_isEnrolled) {
              widget.onUnenroll();
              setState(() => _isEnrolled = false);
            } else {
              widget.onEnroll();
              setState(() => _isEnrolled = true);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: r.isTablet ? 18 : 16),
            decoration: BoxDecoration(
              gradient: _isEnrolled
                  ? null
                  : const LinearGradient(
                      colors: [kPrimaryBlue, kDeepBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: _isEnrolled ? const Color(0xFFFFEBEE) : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isEnrolled
                  ? []
                  : [
                      BoxShadow(
                        color: kPrimaryBlue.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isEnrolled
                      ? Icons.cancel_rounded
                      : Icons.rocket_launch_rounded,
                  size: r.isTablet ? 21 : 18,
                  color: _isEnrolled ? const Color(0xFFE53935) : Colors.white,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _isEnrolled
                        ? 'Unenroll from Course'
                        : 'Enroll Now — ${c.price}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.fs(15, tablet: 16),
                      fontWeight: FontWeight.w800,
                      color: _isEnrolled
                          ? const Color(0xFFE53935)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ✅ Save / Unsave button — now API-driven
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            if (_isSaved) {
              widget.onUnsave();
              setState(() => _isSaved = false);
            } else {
              widget.onSave();
              setState(() => _isSaved = true);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: r.isTablet ? 16 : 14),
            decoration: BoxDecoration(
              color: _isSaved
                  ? kInterestedAmber.withValues(alpha: 0.10)
                  : const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSaved ? kInterestedAmber : kCardBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: r.isTablet ? 20 : 17,
                  color: _isSaved ? kInterestedAmber : kTextMuted,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _isSaved ? 'Course Saved' : 'Save Course',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.fs(14, tablet: 15),
                      fontWeight: FontWeight.w700,
                      color: _isSaved ? kInterestedAmber : kTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, _R r) => Text(
    text,
    style: TextStyle(
      fontSize: r.fs(14, tablet: 15),
      fontWeight: FontWeight.w800,
      color: kTextDark,
    ),
  );
}
