import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────

class Course {
  final int    id;
  final String emoji;
  final String title;
  final String desc;
  final String duration;
  final String rating;
  final String students;
  final String age;
  final String level;
  final String price;
  final Color  bgColor;
  final String tag;
  final Color  tagBg;
  final Color  tagColor;

  const Course({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.duration,
    required this.rating,
    required this.students,
    required this.age,
    required this.level,
    required this.price,
    required this.bgColor,
    required this.tag,
    required this.tagBg,
    required this.tagColor,
  });
}

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue    = Color(0xFF1A73E8);
const kDeepBlue       = Color(0xFF0D47A1);
const kSkyBlue        = Color(0xFF00B0FF);
const kBgPage         = Color(0xFFF4F7FF);
const kCardBg         = Color(0xFFFFFFFF);
const kCardBorder     = Color(0xFFE0E8FB);
const kTextDark       = Color(0xFF1A2A5E);
const kTextMuted      = Color(0xFF6B80B3);
const kSelectedBg     = Color(0xFFE8F1FE);
const kSelectedBorder = Color(0xFF1A73E8);

final List<Course> kCourses = [
  const Course(
    id: 1, emoji: '🐍', title: 'Python for Kids',
    desc: 'Learn coding with fun real-world projects!',
    duration: '8 weeks', rating: '4.9', students: '340',
    age: '10-14', level: 'Beginner', price: '₹2,999',
    bgColor: Color(0xFFFFF3E0), tag: 'Popular',
    tagBg: Color(0xFFFFF3E0), tagColor: Color(0xFFE65100),
  ),
  const Course(
    id: 2, emoji: '🤖', title: 'Intro to AI & ML',
    desc: 'Discover how robots think and learn!',
    duration: '6 weeks', rating: '4.8', students: '218',
    age: '12-16', level: 'Beginner', price: '₹3,499',
    bgColor: Color(0xFFE3F2FD), tag: 'Trending',
    tagBg: Color(0xFFE3F2FD), tagColor: Color(0xFF1565C0),
  ),
  const Course(
    id: 3, emoji: '🎮', title: 'Scratch Programming',
    desc: 'Build awesome games from scratch!',
    duration: '4 weeks', rating: '5.0', students: '567',
    age: '8-12', level: 'Super Easy', price: '₹1,999',
    bgColor: Color(0xFFF3E5F5), tag: 'Best Seller',
    tagBg: Color(0xFFF3E5F5), tagColor: Color(0xFF7B1FA2),
  ),
  const Course(
    id: 4, emoji: '📱', title: 'App Development',
    desc: 'Create your own mobile app from day 1!',
    duration: '10 weeks', rating: '4.7', students: '189',
    age: '13-17', level: 'Intermediate', price: '₹3,999',
    bgColor: Color(0xFFE8F5E9), tag: 'New',
    tagBg: Color(0xFFE8F5E9), tagColor: Color(0xFF2E7D32),
  ),
  const Course(
    id: 5, emoji: '🦾', title: 'Robotics Basics',
    desc: 'Build and program your own robot!',
    duration: '6 weeks', rating: '4.9', students: '142',
    age: '10-14', level: 'Beginner', price: '₹3,299',
    bgColor: Color(0xFFFCE4EC), tag: 'Fun',
    tagBg: Color(0xFFFCE4EC), tagColor: Color(0xFFC62828),
  ),
  const Course(
    id: 6, emoji: '🎨', title: 'Web Design',
    desc: 'Design beautiful websites with HTML & CSS!',
    duration: '5 weeks', rating: '4.8', students: '276',
    age: '12-16', level: 'Beginner', price: '₹2,499',
    bgColor: Color(0xFFE0F7FA), tag: 'Creative',
    tagBg: Color(0xFFE0F7FA), tagColor: Color(0xFF00696A),
  ),
];

const List<String> kFilters = ['All', '8-12', '10-14', '12-16', '13-17'];

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────

class SchoolCoursesScreen extends StatefulWidget {
  const SchoolCoursesScreen({super.key});

  @override
  State<SchoolCoursesScreen> createState() => _SchoolCoursesScreenState();
}

class _SchoolCoursesScreenState extends State<SchoolCoursesScreen>
    with TickerProviderStateMixin {

  String         _ageFilter = 'All';
  final Set<int> _enrolled  = {};

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
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilterBar(),
          const SizedBox(height: 6),
          Expanded(child: _buildCourseList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Our Courses',
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      if (_enrolled.isNotEmpty)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_enrolled.length} Enrolled',
                            style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fun tech learning for school students!',
                    style: TextStyle(
                      fontSize: 13, color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statChip('🎓', '${kCourses.length} Courses'),
                      const SizedBox(width: 10),
                      _statChip('👦', 'Ages 8–17'),
                      const SizedBox(width: 10),
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

  Widget _statChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Age Group',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: kTextMuted),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f        = kFilters[i];
                final selected = f == _ageFilter;
                final label    = f == 'All' ? 'All Ages' : 'Ages $f';
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
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
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

  Widget _buildCourseList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('No courses for this age group yet.',
                style: TextStyle(color: kTextMuted, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _ageFilter = 'All'),
              child: const Text('Show all courses',
                  style: TextStyle(
                      color: kPrimaryBlue, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => _AnimatedCourseCard(
        course:     list[i],
        index:      i,
        isEnrolled: _enrolled.contains(list[i].id),
        onEnroll:   () => _handleEnroll(list[i]),
      ),
    );
  }

  // KEY FIX: use context.go instead of Navigator.pushNamed
  void _handleEnroll(Course course) {
    setState(() => _enrolled.add(course.id));
    context.go('/school/booking');
  }
}

// ─────────────────────────────────────────────
//  ANIMATED COURSE CARD
// ─────────────────────────────────────────────

class _AnimatedCourseCard extends StatefulWidget {
  final Course       course;
  final int          index;
  final bool         isEnrolled;
  final VoidCallback onEnroll;

  const _AnimatedCourseCard({
    required this.course,
    required this.index,
    required this.isEnrolled,
    required this.onEnroll,
  });

  @override
  State<_AnimatedCourseCard> createState() => _AnimatedCourseCardState();
}

class _AnimatedCourseCardState extends State<_AnimatedCourseCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.14), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 + widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
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
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kCardBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: c.bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(c.emoji, style: const TextStyle(fontSize: 28)),
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
                                child: Text(c.title,
                                    style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w800,
                                      color: kTextDark,
                                    )),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: c.tagBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(c.tag,
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w700,
                                      color: c.tagColor,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.desc,
                              style: const TextStyle(
                                  fontSize: 12, color: kTextMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _metaChip(Icons.schedule_rounded,  c.duration),
                    const SizedBox(width: 8),
                    _metaChip(Icons.people_alt_rounded, '${c.students} students'),
                    const SizedBox(width: 8),
                    _metaChip(Icons.child_care_rounded, 'Ages ${c.age}'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                height: 1, color: const Color(0xFFF0F4FF),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 18, color: Color(0xFFFFB300)),
                    const SizedBox(width: 4),
                    Text(c.rating,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: kTextDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: kSelectedBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c.level,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: kPrimaryBlue)),
                    ),
                    const Spacer(),
                    Text(c.price,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800,
                            color: kTextDark)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _btnPressed = true),
                      onTapUp:   (_) {
                        setState(() => _btnPressed = false);
                        widget.onEnroll();
                      },
                      onTapCancel: () => setState(() => _btnPressed = false),
                      child: AnimatedScale(
                        scale: _btnPressed ? 0.94 : 1.0,
                        duration: const Duration(milliseconds: 140),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: widget.isEnrolled ? null :
                            const LinearGradient(
                              colors: [kPrimaryBlue, kDeepBlue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            color: widget.isEnrolled
                                ? const Color(0xFFE6F4EA) : null,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.isEnrolled)
                                const Icon(Icons.check_rounded,
                                    size: 14, color: Color(0xFF2E7D32)),
                              if (widget.isEnrolled) const SizedBox(width: 4),
                              Text(
                                widget.isEnrolled ? 'Enrolled' : 'Join Now',
                                style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w800,
                                  color: widget.isEnrolled
                                      ? const Color(0xFF2E7D32) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kTextMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: kTextMuted)),
        ],
      ),
    );
  }
}
