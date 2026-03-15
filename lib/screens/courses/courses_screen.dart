import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — Engineering Theme
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kSlate      = Color(0xFF334155);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);
const kBgPage     = Color(0xFFF0F4F8);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kSuccess    = Color(0xFF16A34A);
const kWarning    = Color(0xFFF59E0B);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────

class EngCourse {
  final int          id;
  final String       title;
  final String       category;
  final String       duration;
  final String       price;
  final List<String> mode;
  final double       rating;
  final int          students;
  final String       level;
  final String       instructor;
  final String       badge;
  final List<String> tags;
  final String       desc;
  final Color        bgColor;

  const EngCourse({
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
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

final List<EngCourse> kEngCourses = [
  const EngCourse(
    id: 1, badge: '🤖', title: 'Machine Learning Masterclass',
    category: 'AI/ML', duration: '3 months', price: '₹4,999',
    mode: ['Online', 'Offline'], rating: 4.8, students: 1240,
    level: 'Intermediate', instructor: 'Dr. Priya Sharma',
    tags: ['Python', 'TensorFlow', 'Scikit-learn'],
    desc: 'From basics to deployment. Build real ML models with industry datasets.',
    bgColor: Color(0xFFEFF6FF),
  ),
  const EngCourse(
    id: 2, badge: '🌐', title: 'Full Stack Web Development',
    category: 'Web Dev', duration: '4 months', price: '₹5,999',
    mode: ['Online'], rating: 4.9, students: 2100,
    level: 'Beginner', instructor: 'Ravi Kumar',
    tags: ['React', 'Node.js', 'MongoDB'],
    desc: 'Build complete production-grade web apps from scratch.',
    bgColor: Color(0xFFF0FDF4),
  ),
  const EngCourse(
    id: 3, badge: '📱', title: 'Flutter App Development',
    category: 'App Dev', duration: '2 months', price: '₹3,499',
    mode: ['Online', 'Offline'], rating: 4.7, students: 870,
    level: 'Beginner', instructor: 'Ananya Rao',
    tags: ['Flutter', 'Dart', 'Firebase'],
    desc: 'Build beautiful cross-platform apps for iOS and Android.',
    bgColor: Color(0xFFFFF7ED),
  ),
  const EngCourse(
    id: 4, badge: '📊', title: 'Data Science with Python',
    category: 'Data Science', duration: '3 months', price: '₹4,499',
    mode: ['Online'], rating: 4.6, students: 1560,
    level: 'Intermediate', instructor: 'Kiran Mehta',
    tags: ['Python', 'Pandas', 'Tableau'],
    desc: 'Analyze, visualize and communicate data insights effectively.',
    bgColor: Color(0xFFFDF4FF),
  ),
  const EngCourse(
    id: 5, badge: '☁️', title: 'AWS Cloud Practitioner',
    category: 'Cloud', duration: '6 weeks', price: '₹2,999',
    mode: ['Online'], rating: 4.8, students: 3200,
    level: 'Beginner', instructor: 'Suresh Nair',
    tags: ['AWS', 'Cloud', 'DevOps'],
    desc: 'Become cloud-ready and crack the AWS certification in 6 weeks.',
    bgColor: Color(0xFFF0F9FF),
  ),
  const EngCourse(
    id: 6, badge: '🔐', title: 'Ethical Hacking & Cybersecurity',
    category: 'Cybersecurity', duration: '2 months', price: '₹3,999',
    mode: ['Online', 'Offline'], rating: 4.7, students: 940,
    level: 'Intermediate', instructor: 'Arjun Pillai',
    tags: ['Security', 'Kali Linux', 'Networking'],
    desc: 'Learn offensive security, penetration testing and system protection.',
    bgColor: Color(0xFFFFF1F2),
  ),
];

const List<String> kCategories = [
  'All', 'AI/ML', 'Web Dev', 'App Dev',
  'Data Science', 'Cloud', 'Cybersecurity',
];

// ─────────────────────────────────────────────
//  LEVEL STYLE
// ─────────────────────────────────────────────

class _LevelStyle {
  final Color bg, fg;
  const _LevelStyle({required this.bg, required this.fg});
}

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

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with TickerProviderStateMixin {

  String     _category = 'All';
  String     _search   = '';
  final Set<int> _enrolled = {};

  late AnimationController _headerAnim;

  final Map<int, AnimationController> _cardAnims = {};

  List<EngCourse> get _filtered {
    var list = _category == 'All'
        ? kEngCourses
        : kEngCourses.where((c) => c.category == _category).toList();
    if (_search.isNotEmpty) {
      list = list.where((c) =>
      c.title.toLowerCase().contains(_search.toLowerCase()) ||
          c.category.toLowerCase().contains(_search.toLowerCase()) ||
          c.instructor.toLowerCase().contains(_search.toLowerCase())).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _initCardAnims();
  }

  void _initCardAnims() {
    for (int i = 0; i < kEngCourses.length; i++) {
      final c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 460),
      );
      _cardAnims[kEngCourses[i].id] = c;
      Future.delayed(Duration(milliseconds: 80 + i * 80), () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────

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
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Courses',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.4,
                              )),
                          Text('Specialized programs to land your dream job',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    // Enrolled count badge
                    if (_enrolled.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_enrolled.length} Enrolled',
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: kAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats + banner row
                Row(
                  children: [
                    _statPill('${kEngCourses.length}', 'Courses'),
                    const SizedBox(width: 10),
                    _statPill('95%', 'Placement'),
                    const SizedBox(width: 10),
                    _statPill('6', 'Domains'),
                    const Spacer(),
                    // Banner pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('🎓',
                              style: TextStyle(fontSize: 13)),
                          SizedBox(width: 6),
                          Text('Get Job-Ready',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: kAccent)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600)),
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
            fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search courses, instructors, or topics…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search_rounded,
              color: kMuted, size: 20),
          filled: true,
          fillColor: kBgPage,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
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
            final cat      = kCategories[i];
            final selected = cat == _category;
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 0),
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
                      fontSize: 12, fontWeight: FontWeight.w700,
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
            const Text('No courses found',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: kSlate)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() {
                _search   = '';
                _category = 'All';
              }),
              child: const Text('Clear filters',
                  style: TextStyle(
                      color: kPrimary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => _EngCourseCard(
        course:     list[i],
        index:      i,
        isEnrolled: _enrolled.contains(list[i].id),
        onEnroll:   () {
          HapticFeedback.lightImpact();
          setState(() => _enrolled.add(list[i].id));
        },
        ctrl: _cardAnims[list[i].id],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COURSE CARD WIDGET
// ─────────────────────────────────────────────

class _EngCourseCard extends StatefulWidget {
  final EngCourse           course;
  final int                 index;
  final bool                isEnrolled;
  final VoidCallback        onEnroll;
  final AnimationController? ctrl;

  const _EngCourseCard({
    required this.course,
    required this.index,
    required this.isEnrolled,
    required this.onEnroll,
    this.ctrl,
  });

  @override
  State<_EngCourseCard> createState() => _EngCourseCardState();
}

class _EngCourseCardState extends State<_EngCourseCard>
    with SingleTickerProviderStateMixin {

  bool _btnPressed = false;
  late AnimationController _btnCtrl;
  late Animation<double>   _btnScale;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 140),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c    = widget.course;
    final ls   = _levelStyle(c.level);
    final ctrl = widget.ctrl;

    final fade  = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TOP ROW ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge tile
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: c.bgColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: kBorder),
                      ),
                      child: Center(
                        child: Text(c.badge,
                            style: const TextStyle(fontSize: 26)),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: kInk,
                                    )),
                              ),
                              const SizedBox(width: 8),
                              // Level badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ls.bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(c.level,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: ls.fg,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_rounded,
                                  size: 12, color: kHint),
                              const SizedBox(width: 4),
                              Text(c.instructor,
                                  style: const TextStyle(
                                      fontSize: 12, color: kMuted,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.desc,
                              style: const TextStyle(
                                  fontSize: 12, color: kHint,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── META CHIPS ───────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _metaChip(Icons.schedule_rounded, c.duration),
                    const SizedBox(width: 7),
                    _metaChip(Icons.star_rounded, c.rating.toString(),
                        iconColor: kWarning),
                    const SizedBox(width: 7),
                    _metaChip(Icons.people_alt_rounded,
                        '${_formatCount(c.students)} students'),
                    const SizedBox(width: 7),
                    // Mode chips
                    ...c.mode.map((m) => Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: m == 'Online'
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(m,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: m == 'Online'
                                  ? kPrimary
                                  : kSuccess,
                            )),
                      ),
                    )),
                  ],
                ),
              ),

              // ── DIVIDER ──────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                height: 1, color: const Color(0xFFF1F5F9),
              ),

              // ── TAGS + PRICE + BUTTON ─────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    // Tags
                    Expanded(
                      child: Wrap(
                        spacing: 6, runSpacing: 6,
                        children: c.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kSlate,
                              )),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price + button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(c.price,
                            style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTapDown: (_) {
                            _btnCtrl.forward();
                            setState(() => _btnPressed = true);
                          },
                          onTapUp: (_) {
                            _btnCtrl.reverse();
                            setState(() => _btnPressed = false);
                            widget.onEnroll();
                          },
                          onTapCancel: () {
                            _btnCtrl.reverse();
                            setState(() => _btnPressed = false);
                          },
                          child: ScaleTransition(
                            scale: _btnScale,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: widget.isEnrolled
                                    ? const Color(0xFFF0FDF4)
                                    : kPrimary,
                                borderRadius: BorderRadius.circular(30),
                                border: widget.isEnrolled
                                    ? Border.all(
                                    color: const Color(0xFF86EFAC),
                                    width: 1.5)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.isEnrolled)
                                    const Icon(Icons.check_rounded,
                                        size: 14,
                                        color: kSuccess),
                                  if (widget.isEnrolled)
                                    const SizedBox(width: 4),
                                  Text(
                                    widget.isEnrolled
                                        ? 'Enrolled'
                                        : 'Register',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: widget.isEnrolled
                                          ? kSuccess
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  Widget _metaChip(IconData icon, String label,
      {Color iconColor = kHint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: kMuted)),
        ],
      ),
    );
  }

  String _formatCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}