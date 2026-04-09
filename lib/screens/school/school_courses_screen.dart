import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────

enum CourseStatus { none, interested, enrolled }

class Instructor {
  final String name;
  final String role;
  final String avatar;
  final String experience;

  const Instructor({
    required this.name,
    required this.role,
    required this.avatar,
    required this.experience,
  });
}

class Course {
  final int id;
  final String emoji;
  final String title;
  final String desc;
  final String fullDescription;
  final String duration;
  final String rating;
  final String students;
  final String age;
  final String level;
  final String price;
  final Color bgColor;
  final String tag;
  final Color tagBg;
  final Color tagColor;
  final Instructor instructor;
  final List<String> technologies;
  final List<String> outcomes;
  final String schedule;
  final String totalLessons;
  final String certificate;

  const Course({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.fullDescription,
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
    required this.instructor,
    required this.technologies,
    required this.outcomes,
    required this.schedule,
    required this.totalLessons,
    required this.certificate,
  });
}

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue     = Color(0xFF1A73E8);
const kDeepBlue        = Color(0xFF0D47A1);
const kBgPage          = Color(0xFFF4F7FF);
const kCardBg          = Color(0xFFFFFFFF);
const kCardBorder      = Color(0xFFE0E8FB);
const kTextDark        = Color(0xFF1A2A5E);
const kTextMuted       = Color(0xFF6B80B3);
const kEnrolledGreen   = Color(0xFF2E7D32);
const kInterestedAmber = Color(0xFFE65100);

// ─────────────────────────────────────────────
//  SAMPLE DATA
// ─────────────────────────────────────────────

final List<Course> kCourses = [
  Course(
    id: 1,
    emoji: '🐍',
    title: 'Python for Kids',
    desc: 'Learn coding with fun real-world projects!',
    fullDescription:
    'Dive into the world of programming with Python — one of the most '
        'popular and beginner-friendly languages in the world. Through '
        'hands-on mini-projects like a quiz game, a weather app, and a '
        'simple chatbot, students learn the fundamentals of logic, '
        'problem-solving, and computational thinking. No prior experience needed!',
    duration: '8 weeks',
    rating: '4.9',
    students: '340',
    age: '10-14',
    level: 'Beginner',
    price: '₹2,999',
    bgColor: Color(0xFFFFF3E0),
    tag: 'Popular',
    tagBg: Color(0xFFFFF3E0),
    tagColor: Color(0xFFE65100),
    instructor: const Instructor(
      name: 'Priya Sharma',
      role: 'Software Engineer & Educator',
      avatar: '👩‍💻',
      experience: '6 yrs teaching kids coding',
    ),
    technologies: ['Python 3', 'Turtle Graphics', 'Pygame', 'VS Code'],
    outcomes: [
      'Write Python programs independently',
      'Understand loops, conditions & functions',
      'Build 3 complete mini-projects',
      'Debug and fix code with confidence',
    ],
    schedule: 'Mon & Wed · 4:00 PM – 5:30 PM',
    totalLessons: '16 live lessons',
    certificate: 'Yes — shareable digital certificate',
  ),
  Course(
    id: 2,
    emoji: '🤖',
    title: 'Intro to AI & ML',
    desc: 'Discover how robots think and learn!',
    fullDescription:
    'What makes a computer "smart"? In this course students explore '
        'the exciting world of Artificial Intelligence and Machine Learning '
        'through interactive demos, visual tools, and a final project where '
        'they train their own image classifier. No heavy math — just pure '
        'curiosity and experimentation!',
    duration: '6 weeks',
    rating: '4.8',
    students: '218',
    age: '12-16',
    level: 'Beginner',
    price: '₹3,499',
    bgColor: Color(0xFFE3F2FD),
    tag: 'Trending',
    tagBg: Color(0xFFE3F2FD),
    tagColor: Color(0xFF1565C0),
    instructor: const Instructor(
      name: 'Arjun Mehta',
      role: 'ML Engineer at TechCorp',
      avatar: '👨‍🔬',
      experience: '4 yrs in AI education',
    ),
    technologies: ['Teachable Machine', 'Scratch ML', 'Python Basics', 'Google Colab'],
    outcomes: [
      'Understand what AI & ML really means',
      'Train a simple image recognition model',
      'Build a smart sorting game',
      'Present an AI-powered mini project',
    ],
    schedule: 'Tue & Thu · 5:00 PM – 6:00 PM',
    totalLessons: '12 live lessons',
    certificate: 'Yes — with project showcase',
  ),
  Course(
    id: 3,
    emoji: '🎮',
    title: 'Scratch Programming',
    desc: 'Build awesome games from scratch!',
    fullDescription:
    'Scratch is the perfect launchpad for young coders. Using a fun '
        'drag-and-drop interface, students create animations, interactive '
        'stories, and their own video games — all while learning core '
        'programming concepts like sequences, events, loops, and variables. '
        'By the end, every student will have a game portfolio to show off!',
    duration: '4 weeks',
    rating: '5.0',
    students: '567',
    age: '8-12',
    level: 'Super Easy',
    price: '₹1,999',
    bgColor: Color(0xFFF3E5F5),
    tag: 'Best Seller',
    tagBg: Color(0xFFF3E5F5),
    tagColor: Color(0xFF7B1FA2),
    instructor: const Instructor(
      name: 'Kavya Nair',
      role: 'Primary School CS Teacher',
      avatar: '👩‍🏫',
      experience: '5 yrs with young learners',
    ),
    technologies: ['Scratch 3.0', 'MIT App Inventor', 'Canva for Kids'],
    outcomes: [
      'Create animated stories & characters',
      'Design a playable arcade game',
      'Understand events and broadcasting',
      'Share projects with the Scratch community',
    ],
    schedule: 'Sat · 10:00 AM – 12:00 PM',
    totalLessons: '8 live sessions',
    certificate: 'Yes — fun achievement badge',
  ),
  Course(
    id: 4,
    emoji: '📱',
    title: 'App Development',
    desc: 'Create your own mobile app from day 1!',
    fullDescription:
    'Ever wanted to build an app? Now you can! Starting from UI design '
        'to writing real code, students walk through every stage of making '
        'a mobile app. By the final week, each student ships a working app '
        'to their phone — something they built entirely themselves.',
    duration: '10 weeks',
    rating: '4.7',
    students: '189',
    age: '13-17',
    level: 'Intermediate',
    price: '₹3,999',
    bgColor: Color(0xFFE8F5E9),
    tag: 'New',
    tagBg: Color(0xFFE8F5E9),
    tagColor: Color(0xFF2E7D32),
    instructor: const Instructor(
      name: 'Rohan Desai',
      role: 'Flutter & Android Developer',
      avatar: '👨‍💻',
      experience: '7 yrs mobile development',
    ),
    technologies: ['Flutter', 'Dart', 'Figma', 'Firebase', 'Android Studio'],
    outcomes: [
      'Design app screens in Figma',
      'Write Dart code from scratch',
      'Connect app to a live database',
      'Publish your app to a device',
    ],
    schedule: 'Mon, Wed & Fri · 6:00 PM – 7:30 PM',
    totalLessons: '30 live lessons',
    certificate: 'Yes — industry-style certificate',
  ),
  Course(
    id: 5,
    emoji: '🦾',
    title: 'Robotics Basics',
    desc: 'Build and program your own robot!',
    fullDescription:
    'Get hands-on with real hardware! Students assemble a simple robot '
        'kit and write code that makes it move, sense obstacles, and react '
        'to the environment. A perfect mix of electronics, logic, and '
        'creativity — ideal for curious minds who love to build things.',
    duration: '6 weeks',
    rating: '4.9',
    students: '142',
    age: '10-14',
    level: 'Beginner',
    price: '₹3,299',
    bgColor: Color(0xFFFCE4EC),
    tag: 'Fun',
    tagBg: Color(0xFFFCE4EC),
    tagColor: Color(0xFFC62828),
    instructor: const Instructor(
      name: 'Siddharth Rao',
      role: 'Robotics & IoT Specialist',
      avatar: '🧑‍🔧',
      experience: '8 yrs in STEM education',
    ),
    technologies: ['Arduino', 'C++ Basics', 'Tinkercad', 'Sensor Modules'],
    outcomes: [
      'Assemble a working robot kit',
      'Write motor & sensor control code',
      'Design an obstacle-avoidance path',
      'Demonstrate robot at the final show',
    ],
    schedule: 'Sat & Sun · 11:00 AM – 12:30 PM',
    totalLessons: '12 live sessions',
    certificate: 'Yes — with robotics project report',
  ),
  Course(
    id: 6,
    emoji: '🎨',
    title: 'Web Design',
    desc: 'Design beautiful websites with HTML & CSS!',
    fullDescription:
    'Learn to turn ideas into real websites! This course takes students '
        'through designing and coding beautiful web pages using HTML, CSS, '
        'and just a sprinkle of JavaScript. They\'ll learn about layout, '
        'typography, colors, and responsive design — and finish with a '
        'personal portfolio website live on the internet.',
    duration: '5 weeks',
    rating: '4.8',
    students: '276',
    age: '12-16',
    level: 'Beginner',
    price: '₹2,499',
    bgColor: Color(0xFFE0F7FA),
    tag: 'Creative',
    tagBg: Color(0xFFE0F7FA),
    tagColor: Color(0xFF00696A),
    instructor: const Instructor(
      name: 'Ananya Iyer',
      role: 'UI/UX Designer & Frontend Dev',
      avatar: '👩‍🎨',
      experience: '5 yrs design & education',
    ),
    technologies: ['HTML5', 'CSS3', 'JavaScript', 'Figma', 'GitHub Pages'],
    outcomes: [
      'Build a multi-page website from scratch',
      'Style pages with modern CSS',
      'Make websites work on mobile screens',
      'Host a live portfolio site online',
    ],
    schedule: 'Tue & Thu · 4:30 PM – 6:00 PM',
    totalLessons: '10 live lessons',
    certificate: 'Yes — with portfolio review',
  ),
];

const List<String> kFilters = ['All', '8-12', '10-14', '12-16', '13-17'];

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────

class SchoolCoursesScreen extends StatefulWidget {
  const SchoolCoursesScreen({super.key});

  @override
  State<SchoolCoursesScreen> createState() => _SchoolCoursesScreenState();
}

class _SchoolCoursesScreenState extends State<SchoolCoursesScreen>
    with TickerProviderStateMixin {
  String _ageFilter = 'All';
  final Map<int, CourseStatus> _statuses = {};

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  List<Course> get _filtered => _ageFilter == 'All'
      ? kCourses
      : kCourses.where((c) => c.age == _ageFilter).toList();

  int get _enrolledCount =>
      _statuses.values.where((s) => s == CourseStatus.enrolled).length;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade =
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  void _onStatusChanged(int id, CourseStatus status) =>
      setState(() => _statuses[id] = status);

  void _openDetail(Course course) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseDetailSheet(
        course: course,
        status: _statuses[course.id] ?? CourseStatus.none,
        onStatus: (s) => _onStatusChanged(course.id, s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildFilterBar(),
          const SizedBox(height: 6),
          Expanded(child: _buildCourseList()),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────

  Widget _buildHeader(BuildContext context) {
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
                      // ── Back button ──────────────────────────
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'Our Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      if (_enrolledCount > 0)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_enrolledCount Enrolled',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.78)),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    _statChip('🎓', '${kCourses.length} Courses'),
                    const SizedBox(width: 10),
                    _statChip('👦', 'Ages 8–17'),
                    const SizedBox(width: 10),
                    _statChip('⭐', '4.8 Avg Rating'),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String icon, String label) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    ]),
  );

  // ── Filter bar ──────────────────────────────

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
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kTextMuted),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = kFilters[i];
                final selected = f == _ageFilter;
                final label = f == 'All' ? 'All Ages' : 'Ages $f';
                return GestureDetector(
                  onTap: () => setState(() => _ageFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? kPrimaryBlue
                          : const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color:
                        selected ? kPrimaryBlue : kCardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : kTextMuted,
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

  // ── Course list ─────────────────────────────

  Widget _buildCourseList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'No courses for this age group yet.',
            style: TextStyle(color: kTextMuted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _ageFilter = 'All'),
            child: const Text(
              'Show all courses',
              style: TextStyle(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final course = list[i];
        return _AnimatedCourseCard(
          course: course,
          index: i,
          status: _statuses[course.id] ?? CourseStatus.none,
          onTap: () => _openDetail(course),
          onStatus: (s) => _onStatusChanged(course.id, s),
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
  final VoidCallback onTap;
  final ValueChanged<CourseStatus> onStatus;

  const _AnimatedCourseCard({
    required this.course,
    required this.index,
    required this.status,
    required this.onTap,
    required this.onStatus,
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

    Future.delayed(
        Duration(milliseconds: 60 + widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _highlightBorder {
    switch (widget.status) {
      case CourseStatus.enrolled:
        return kEnrolledGreen;
      case CourseStatus.interested:
        return kInterestedAmber;
      case CourseStatus.none:
        return kCardBorder;
    }
  }

  Color get _highlightBg {
    switch (widget.status) {
      case CourseStatus.enrolled:
        return const Color(0xFFF1FBF3);
      case CourseStatus.interested:
        return const Color(0xFFFFF8F2);
      case CourseStatus.none:
        return kCardBg;
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
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _highlightBg,
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: _highlightBorder, width: 1.8),
                boxShadow: widget.status != CourseStatus.none
                    ? [
                  BoxShadow(
                    color:
                    _highlightBorder.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status banner
                  if (widget.status != CourseStatus.none)
                    _StatusBanner(status: widget.status),

                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: c.bgColor,
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(c.emoji,
                                style: const TextStyle(
                                    fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(
                                    c.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                      FontWeight.w800,
                                      color: kTextDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3),
                                  decoration: BoxDecoration(
                                    color: c.tagBg,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    c.tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: c.tagColor,
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text(
                                c.desc,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: kTextMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Meta chips row ────────────────────────
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _metaChip(
                            Icons.schedule_rounded, c.duration),
                        _metaChip(Icons.people_alt_rounded,
                            '${c.students} students'),
                        _metaChip(Icons.child_care_rounded,
                            'Ages ${c.age}'),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.fromLTRB(
                        16, 14, 16, 0),
                    height: 1,
                    color: const Color(0xFFF0F4FF),
                  ),

                  // ── FIX: Split bottom row into two lines ─
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // Row 1: rating + level + price
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFFFB300)),
                            const SizedBox(width: 4),
                            Text(
                              c.rating,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: kTextDark),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                const Color(0xFFE8F1FE),
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                c.level,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimaryBlue),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              c.price,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kTextDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Row 2: action buttons (full width, no overflow)
                        Row(
                          children: [
                            Expanded(
                              child: _InterestedButton(
                                status: widget.status,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onStatus(
                                    widget.status ==
                                        CourseStatus.interested
                                        ? CourseStatus.none
                                        : CourseStatus.interested,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _EnrollButton(
                                status: widget.status,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  widget.onStatus(
                                    widget.status ==
                                        CourseStatus.enrolled
                                        ? CourseStatus.none
                                        : CourseStatus.enrolled,
                                  );
                                },
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

  Widget _metaChip(IconData icon, String label) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: kTextMuted),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kTextMuted),
      ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: isEnrolled
            ? kEnrolledGreen.withOpacity(0.12)
            : kInterestedAmber.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEnrolled
                ? Icons.check_circle_rounded
                : Icons.bookmark_rounded,
            size: 14,
            color: isEnrolled ? kEnrolledGreen : kInterestedAmber,
          ),
          const SizedBox(width: 6),
          Text(
            isEnrolled
                ? 'You\'re enrolled in this course'
                : 'Saved as interested',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:
              isEnrolled ? kEnrolledGreen : kInterestedAmber,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Interested button ──────────────────────────

class _InterestedButton extends StatefulWidget {
  final CourseStatus status;
  final VoidCallback onTap;
  const _InterestedButton(
      {required this.status, required this.onTap});

  @override
  State<_InterestedButton> createState() =>
      _InterestedButtonState();
}

class _InterestedButtonState extends State<_InterestedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.status == CourseStatus.interested;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? kInterestedAmber.withOpacity(0.12)
                : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: active ? kInterestedAmber : kCardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 14,
                color: active ? kInterestedAmber : kTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                active ? 'Saved' : 'Interested',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? kInterestedAmber : kTextMuted,
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
  final CourseStatus status;
  final VoidCallback onTap;
  const _EnrollButton(
      {required this.status, required this.onTap});

  @override
  State<_EnrollButton> createState() => _EnrollButtonState();
}

class _EnrollButtonState extends State<_EnrollButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.status == CourseStatus.enrolled;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? null
                : const LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: active
                ? const Color(0xFFE6F4EA)
                : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (active) ...[
                const Icon(Icons.check_rounded,
                    size: 14, color: kEnrolledGreen),
                const SizedBox(width: 4),
              ],
              Text(
                active ? 'Enrolled' : 'Enroll Now',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? kEnrolledGreen : Colors.white,
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
//  COURSE DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────

class _CourseDetailSheet extends StatefulWidget {
  final Course course;
  final CourseStatus status;
  final ValueChanged<CourseStatus> onStatus;

  const _CourseDetailSheet({
    required this.course,
    required this.status,
    required this.onStatus,
  });

  @override
  State<_CourseDetailSheet> createState() =>
      _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<_CourseDetailSheet> {
  late CourseStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  void _setStatus(CourseStatus s) {
    setState(() => _status = s);
    widget.onStatus(s);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final mq = MediaQuery.of(context);

    return Container(
      height: mq.size.height * 0.88,
      decoration: const BoxDecoration(
        color: kCardBg,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(28)),
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
          _buildSheetHeader(c),
          Expanded(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(c),
                  const SizedBox(height: 22),
                  _sectionLabel('About this Course'),
                  const SizedBox(height: 8),
                  Text(
                    c.fullDescription,
                    style: const TextStyle(
                        fontSize: 13.5,
                        color: kTextMuted,
                        height: 1.65),
                  ),
                  const SizedBox(height: 22),
                  _buildInstructorCard(c.instructor),
                  const SizedBox(height: 22),
                  _sectionLabel('Technologies Covered'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: c.technologies
                        .map((t) => _techChip(t))
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  _sectionLabel('What You\'ll Achieve'),
                  const SizedBox(height: 10),
                  ...c.outcomes.map((o) => _outcomeRow(o)),
                  const SizedBox(height: 22),
                  _buildScheduleCard(c),
                  const SizedBox(height: 28),
                  _buildActionButtons(c),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(Course c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Text(c.emoji,
            style: const TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kTextDark),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 15,
                      color: Color(0xFFFFB300)),
                  const SizedBox(width: 3),
                  Text(
                    c.rating,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kTextDark),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.tagBg,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.tag,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: c.tagColor),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(
                  c.price,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kTextDark),
                ),
              ]),
        ),
      ]),
    );
  }

  Widget _buildInfoRow(Course c) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(children: [
        Expanded(
            child: _infoTile(Icons.schedule_rounded,
                'Duration', c.duration)),
        const SizedBox(width: 10),
        Expanded(
            child: _infoTile(Icons.menu_book_rounded,
                'Lessons', c.totalLessons)),
        const SizedBox(width: 10),
        Expanded(
            child: _infoTile(Icons.child_care_rounded,
                'Age', 'Ages ${c.age}')),
      ]),
    );
  }

  Widget _infoTile(
      IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: kPrimaryBlue),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10,
              color: kTextMuted,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: kTextDark),
        ),
      ]),
    );
  }

  Widget _buildInstructorCard(Instructor ins) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1FE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(ins.avatar,
                style: const TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.person_rounded,
                      size: 13, color: kTextMuted),
                  const SizedBox(width: 4),
                  const Text(
                    'Your Instructor',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kTextMuted),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(
                  ins.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kTextDark),
                ),
                const SizedBox(height: 2),
                Text(
                  ins.role,
                  style: const TextStyle(
                      fontSize: 12, color: kTextMuted),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(
                      Icons.workspace_premium_rounded,
                      size: 12,
                      color: kPrimaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    ins.experience,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryBlue),
                  ),
                ]),
              ]),
        ),
      ]),
    );
  }

  Widget _techChip(String label) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F1FE),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kCardBorder),
    ),
    child: Text(
      label,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kPrimaryBlue),
    ),
  );

  Widget _outcomeRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: kEnrolledGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 12, color: kEnrolledGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13.5,
                  color: kTextDark,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ]),
  );

  Widget _buildScheduleCard(Course c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F1FE), Color(0xFFF0F4FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(children: [
        _scheduleRow(Icons.calendar_month_rounded,
            'Schedule', c.schedule),
        const SizedBox(height: 10),
        _scheduleRow(
            Icons.school_rounded, 'Difficulty', c.level),
        const SizedBox(height: 10),
        _scheduleRow(Icons.workspace_premium_rounded,
            'Certificate', c.certificate),
      ]),
    );
  }

  Widget _scheduleRow(
      IconData icon, String label, String value) =>
      Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: kPrimaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: kTextMuted),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: kTextDark),
                ),
              ]),
        ),
      ]);

  Widget _buildActionButtons(Course c) {
    final isEnrolled = _status == CourseStatus.enrolled;
    final isInterested = _status == CourseStatus.interested;

    return Column(children: [
      GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _setStatus(isEnrolled
              ? CourseStatus.none
              : CourseStatus.enrolled);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isEnrolled
                ? null
                : const LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: isEnrolled
                ? const Color(0xFFE6F4EA)
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnrolled
                ? []
                : [
              BoxShadow(
                color: kPrimaryBlue.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEnrolled
                    ? Icons.check_circle_rounded
                    : Icons.rocket_launch_rounded,
                size: 18,
                color: isEnrolled
                    ? kEnrolledGreen
                    : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                isEnrolled
                    ? 'You\'re Enrolled! Tap to undo'
                    : 'Enroll Now — ${c.price}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isEnrolled
                      ? kEnrolledGreen
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _setStatus(isInterested
              ? CourseStatus.none
              : CourseStatus.interested);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isInterested
                ? kInterestedAmber.withOpacity(0.1)
                : const Color(0xFFF4F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isInterested
                  ? kInterestedAmber
                  : kCardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isInterested
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 17,
                color: isInterested
                    ? kInterestedAmber
                    : kTextMuted,
              ),
              const SizedBox(width: 8),
              Text(
                isInterested
                    ? 'Saved as Interested'
                    : 'Mark as Interested',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isInterested
                      ? kInterestedAmber
                      : kTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: kTextDark),
  );
}