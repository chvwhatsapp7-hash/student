import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk = Color(0xFF0F172A);
const kSlate = Color(0xFF334155);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);
const kBgPage = Color(0xFFF0F4F8);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kPrimary = Color(0xFF1D4ED8);
const kAccent = Color(0xFF38BDF8);
const kSuccess = Color(0xFF16A34A);
const kWarning = Color(0xFFF59E0B);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────

class EngCourse {
  final int id;
  final String title;
  final String category;
  final String duration;
  final String price;
  final List<String> mode;
  final double rating;
  final int students;
  final String level;
  final String instructor;
  final String badge;
  final List<String> tags;
  final String desc;
  final Color bgColor;

  EngCourse({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.price,
    required this.mode,
    required this.rating,
    required this.students,
    required this.level,
    required this.instructor,
    required this.badge,
    required this.tags,
    required this.desc,
    required this.bgColor,
  });

  factory EngCourse.fromJson(Map<String, dynamic> json) {
    return EngCourse(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      price: json['price'] ?? '',
      mode: List<String>.from(json['mode'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      students: json['students'] ?? 0,
      level: json['level'] ?? '',
      instructor: json['instructor'] ?? '',
      badge: json['badge'] ?? '📘',
      tags: List<String>.from(json['tags'] ?? []),
      desc: json['desc'] ?? '',
      bgColor: Color(
        int.tryParse(json['bgColor'] ?? '0xFFEFF6FF') ?? 0xFFEFF6FF,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CATEGORY LIST
// ─────────────────────────────────────────────

const List<String> kCategories = [
  'All',
  'AI/ML',
  'Web Dev',
  'App Dev',
  'Data Science',
  'Cloud',
  'Cybersecurity',
];

_LevelStyle _levelStyle(String level) {
  switch (level) {
    case 'Beginner':
      return const _LevelStyle(bg: Color(0xFFF0FDF4), fg: Color(0xFF15803D));
    case 'Intermediate':
      return const _LevelStyle(bg: Color(0xFFFFFBEB), fg: Color(0xFFB45309));
    case 'Advanced':
      return const _LevelStyle(bg: Color(0xFFFFF1F2), fg: Color(0xFFBE123C));
    default:
      return const _LevelStyle(bg: Color(0xFFF1F5F9), fg: Color(0xFF475569));
  }
}

class _LevelStyle {
  final Color bg, fg;
  const _LevelStyle({required this.bg, required this.fg});
}

// ─────────────────────────────────────────────
//  COURSES SCREEN
// ─────────────────────────────────────────────

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with TickerProviderStateMixin {
  String _category = 'All';
  String _search = '';
  final Set<int> _enrolled = {};
  List<EngCourse> _courses = [];

  late AnimationController _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fetchCourses(); // 🔹 Fetch courses from API on screen load
  }

  Future<void> _fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse('https://studenthub-backend-woad.vercel.app/api/getCourses'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> dataList = jsonData['data'];

          setState(() {
            _courses = dataList
                .map(
                  (e) => EngCourse(
                    id: e['course_id'] ?? 0,
                    title: e['title'] ?? '',
                    category: e['category'] ?? '',
                    duration: e['duration'] ?? '',
                    price: e['price'].toString(),
                    mode: [
                      'Online',
                    ], // assuming all courses are online; adjust if API sends mode
                    rating: (e['rating'] ?? 0).toDouble(),
                    students: 0, // your API doesn't provide student count
                    level: e['level'] ?? '',
                    instructor: e['instructor'] ?? '',
                    badge: '📘',
                    tags: [], // your API doesn't provide tags
                    desc: e['description'] ?? '',
                    bgColor: const Color(0xFFEFF6FF), // default color
                  ),
                )
                .toList();

            // Animate cards
            for (int i = 0; i < _courses.length; i++) {
              final ctrl = AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 460),
              );
              _cardAnims[_courses[i].id] = ctrl;
              Future.delayed(Duration(milliseconds: 80 + i * 80), () {
                if (mounted) ctrl.forward();
              });
            }
          });
        } else {
          throw Exception('API returned success=false');
        }
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load courses: $e')));
    }
  }

  List<EngCourse> get _filtered {
    var list = _category == 'All'
        ? _courses
        : _courses.where((c) => c.category == _category).toList();
    if (_search.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.title.toLowerCase().contains(_search.toLowerCase()) ||
                c.category.toLowerCase().contains(_search.toLowerCase()) ||
                c.instructor.toLowerCase().contains(_search.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryBar(),
          Expanded(child: _buildCourseList()),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── title row ──────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Courses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Specialised programs to land your dream job',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_enrolled.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_enrolled.length} Enrolled',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _statPill('${_courses.length}', 'Courses'),
                    _statPill('95%', 'Placement'),
                    _statPill('6', 'Domains'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎓', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 5),
                          Text(
                            'Get Job-Ready',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
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

  Widget _statPill(String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            num,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kAccent,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: kInk,
        ),
        decoration: InputDecoration(
          hintText: 'Search courses, instructors…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(
            Icons.manage_search_rounded,
            color: kMuted,
            size: 22,
          ),
          filled: true,
          fillColor: kBgPage,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
        ),
      ),
    );
  }

  // ── CATEGORY BAR ───────────────────────────

  Widget _buildCategoryBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = kCategories[i];
            final selected = cat == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected ? kPrimary : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? kPrimary : kBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : kMuted,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── COURSE LIST ────────────────────────────

  Widget _buildCourseList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'No courses found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kSlate,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() {
                _search = '';
                _category = 'All';
              }),
              child: const Text(
                'Clear filters',
                style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => _EngCourseCard(
        course: list[i],
        isEnrolled: _enrolled.contains(list[i].id),
        onEnroll: () {
          HapticFeedback.lightImpact();
          setState(() => _enrolled.add(list[i].id));
        },
        ctrl: _cardAnims[list[i].id],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  COURSE CARD & CHIP HELPERS
  // ─────────────────────────────────────────────

  Widget _chip({
    required IconData icon,
    required String label,
    Color iconColor = kMuted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String mode) {
    final online = mode == 'Online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: online ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? Icons.wifi_rounded : Icons.location_on_rounded,
            size: 11,
            color: online ? kPrimary : kSuccess,
          ),
          const SizedBox(width: 4),
          Text(
            mode,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: online ? kPrimary : kSuccess,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ─────────────────────────────────────────────
//  COURSE CARD WIDGET
// ─────────────────────────────────────────────

class _EngCourseCard extends StatefulWidget {
  final EngCourse course;
  final bool isEnrolled;
  final VoidCallback onEnroll;
  final AnimationController? ctrl;

  const _EngCourseCard({
    required this.course,
    required this.isEnrolled,
    required this.onEnroll,
    this.ctrl,
  });

  @override
  State<_EngCourseCard> createState() => _EngCourseCardState();
}

class _EngCourseCardState extends State<_EngCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final ls = _levelStyle(c.level);
    final ctrl = widget.ctrl;

    return ctrl != null
        ? AnimatedBuilder(
            animation: ctrl,
            builder: (_, child) => Opacity(
              opacity: ctrl.value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - ctrl.value)),
                child: child,
              ),
            ),
            child: _card(c, ls),
          )
        : _card(c, ls);
  }

  Widget _card(EngCourse c, _LevelStyle ls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(c.badge, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ls.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c.level,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ls.fg,
                      ),
                    ),
                  ),
                  for (var m in c.mode) _modeChip(m),
                  _chip(icon: Icons.star_rounded, label: '${c.rating}'),
                  _chip(icon: Icons.people_rounded, label: _fmt(c.students)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => _btnCtrl.forward(),
                      onTapUp: (_) {
                        _btnCtrl.reverse();
                        if (!widget.isEnrolled) widget.onEnroll();
                      },
                      onTapCancel: () => _btnCtrl.reverse(),
                      child: ScaleTransition(
                        scale: _btnScale,
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.isEnrolled ? kMuted : kPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.isEnrolled ? 'Enrolled' : 'Enroll',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      c.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
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

  Widget _modeChip(String mode) {
    final online = mode == 'Online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: online ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? Icons.wifi_rounded : Icons.location_on_rounded,
            size: 11,
            color: online ? kPrimary : kSuccess,
          ),
          const SizedBox(width: 4),
          Text(
            mode,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: online ? kPrimary : kSuccess,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    Color iconColor = kMuted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}
