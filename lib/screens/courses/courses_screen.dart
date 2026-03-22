import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DESIGN TOKENS
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
//  MODEL  — untouched
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
      id:         json['id'] ?? 0,
      title:      json['title'] ?? '',
      category:   json['category'] ?? '',
      duration:   json['duration'] ?? '',
      price:      json['price'] ?? '',
      mode:       List<String>.from(json['mode'] ?? []),
      rating:     (json['rating'] ?? 0).toDouble(),
      students:   json['students'] ?? 0,
      level:      json['level'] ?? '',
      instructor: json['instructor'] ?? '',
      badge:      json['badge'] ?? '📘',
      tags:       List<String>.from(json['tags'] ?? []),
      desc:       json['desc'] ?? '',
      bgColor: Color(
        int.tryParse(json['bgColor'] ?? '0xFFEFF6FF') ?? 0xFFEFF6FF,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CATEGORY LIST — untouched
// ─────────────────────────────────────────────

const List<String> kCategories = [
  'All', 'AI/ML', 'Web Dev', 'App Dev',
  'Data Science', 'Cloud', 'Cybersecurity',
];

// ─────────────────────────────────────────────
//  LEVEL STYLE — untouched
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

// Accent strip colour per category — matches badge tile tint
Color _accentFor(String category) {
  switch (category.toLowerCase()) {
    case 'ai/ml':         return const Color(0xFF1D4ED8); // primary blue
    case 'web dev':       return const Color(0xFFF59E0B); // amber
    case 'app dev':       return const Color(0xFF16A34A); // green
    case 'data science':  return const Color(0xFF7C3AED); // purple
    case 'cloud':         return const Color(0xFF0EA5E9); // sky
    case 'cybersecurity': return const Color(0xFFDC2626); // red
    default:              return const Color(0xFF1D4ED8); // fallback blue
  }
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

  // ── state — untouched ──────────────────────
  String          _category  = 'All';
  String          _search    = '';
  final Set<int>  _enrolled  = {};
  List<EngCourse> _courses   = [];
  bool            _isLoading = true;

  late AnimationController            _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};

  // ── initState — untouched ──────────────────
  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fetchCourses();
  }

  // ── _fetchCourses — completely untouched ───
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
                .map((e) => EngCourse(
              id:         e['course_id'] ?? 0,
              title:      e['title'] ?? '',
              category:   e['category'] ?? '',
              duration:   e['duration'] ?? '',
              price:      e['price'].toString(),
              mode:       ['Online'],
              rating:     (e['rating'] ?? 0).toDouble(),
              students:   0,
              level:      e['level'] ?? '',
              instructor: e['instructor'] ?? '',
              badge:      _resolveBadge(
                e['title'] ?? '',
                e['category'] ?? '',
              ),
              tags:       [],
              desc:       e['description'] ?? '',
              bgColor:    _resolveBgColor(e['category'] ?? ''),
            ))
                .toList();

            _isLoading = false;

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
      setState(() => _isLoading = false);
      debugPrint('Error fetching courses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to load courses: $e')),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ── SMART BADGE RESOLVER — design only ─────
  // Maps course title/category keywords → perfect contextual emoji icon.
  // Completely isolated from API logic — safe to add/extend anytime.

  static String _resolveBadge(String title, String category) {
    final t = title.toLowerCase();
    final c = category.toLowerCase();

    // ── AI & Machine Learning ──────────────
    if (t.contains('machine learning') || t.contains('ml'))    return '🤖';
    if (t.contains('deep learning'))                           return '🧠';
    if (t.contains('neural'))                                  return '🕸️';
    if (t.contains('natural language') || t.contains('nlp'))   return '💬';
    if (t.contains('computer vision'))                         return '👁️';
    if (t.contains('generative') || t.contains('genai'))       return '✨';
    if (t.contains('llm') || t.contains('large language'))     return '🦾';
    if (t.contains('artificial intelligence') || t.contains(' ai ') || c == 'ai/ml') return '🤖';

    // ── Data Science & Analytics ───────────
    if (t.contains('data science'))                            return '📊';
    if (t.contains('data analyst') || t.contains('analytics')) return '📈';
    if (t.contains('tableau') || t.contains('power bi'))       return '📉';
    if (t.contains('excel') || t.contains('spreadsheet'))      return '📋';
    if (t.contains('sql') || t.contains('database'))           return '🗄️';
    if (t.contains('big data') || t.contains('hadoop'))        return '🌊';
    if (t.contains('spark') || t.contains('kafka'))            return '⚡';
    if (c == 'data science')                                   return '📊';

    // ── Web Development ────────────────────
    if (t.contains('react'))                                   return '⚛️';
    if (t.contains('angular'))                                 return '🔺';
    if (t.contains('vue'))                                     return '💚';
    if (t.contains('next.js') || t.contains('nextjs'))         return '▲';
    if (t.contains('node') || t.contains('express'))          return '🟢';
    if (t.contains('html') || t.contains('css'))               return '🎨';
    if (t.contains('javascript') || t.contains('js'))          return '🟨';
    if (t.contains('typescript'))                              return '🔷';
    if (t.contains('full stack') || t.contains('fullstack'))   return '🌐';
    if (t.contains('frontend') || t.contains('front-end'))     return '🖥️';
    if (t.contains('backend') || t.contains('back-end'))       return '⚙️';
    if (t.contains('api') || t.contains('rest'))               return '🔌';
    if (t.contains('graphql'))                                 return '◈';
    if (c == 'web dev')                                        return '🌐';

    // ── App Development ────────────────────
    if (t.contains('flutter'))                                 return '💙';
    if (t.contains('react native'))                            return '📱';
    if (t.contains('android'))                                 return '🤖';
    if (t.contains('ios') || t.contains('swift'))              return '🍎';
    if (t.contains('kotlin'))                                  return '🟣';
    if (t.contains('dart'))                                    return '🎯';
    if (t.contains('mobile') || c == 'app dev')                return '📱';

    // ── Cloud & DevOps ─────────────────────
    if (t.contains('aws') || t.contains('amazon web'))         return '☁️';
    if (t.contains('azure'))                                   return '🔵';
    if (t.contains('google cloud') || t.contains('gcp'))       return '🟡';
    if (t.contains('docker'))                                  return '🐳';
    if (t.contains('kubernetes') || t.contains('k8s'))         return '⎈';
    if (t.contains('devops') || t.contains('ci/cd'))           return '🔄';
    if (t.contains('terraform'))                               return '🏗️';
    if (t.contains('linux') || t.contains('unix'))             return '🐧';
    if (t.contains('cloud') || c == 'cloud')                   return '☁️';

    // ── Cybersecurity ──────────────────────
    if (t.contains('ethical hacking') || t.contains('penetration')) return '🔓';
    if (t.contains('cybersecurity') || t.contains('cyber security')) return '🔐';
    if (t.contains('network security'))                        return '🛡️';
    if (t.contains('cryptography'))                            return '🔒';
    if (t.contains('kali') || t.contains('hacking'))           return '💻';
    if (c == 'cybersecurity')                                  return '🔐';

    // ── Programming Languages ──────────────
    if (t.contains('python'))                                  return '🐍';
    if (t.contains('java') && !t.contains('javascript'))       return '☕';
    if (t.contains('c++') || t.contains('cpp'))                return '⚡';
    if (t.contains('c#') || t.contains('csharp'))              return '🎮';
    if (t.contains('golang') || t.contains(' go '))            return '🐹';
    if (t.contains('rust'))                                    return '🦀';
    if (t.contains('php'))                                     return '🐘';
    if (t.contains('ruby'))                                    return '💎';
    if (t.contains('scala'))                                   return '🔴';
    if (t.contains('r programming') || t.contains('r language')) return '📐';

    // ── Design & UI/UX ─────────────────────
    if (t.contains('ui/ux') || t.contains('ux design'))        return '🎨';
    if (t.contains('figma'))                                   return '🖌️';
    if (t.contains('graphic design'))                          return '✏️';
    if (t.contains('motion') || t.contains('animation'))       return '🎬';

    // ── Blockchain & Web3 ──────────────────
    if (t.contains('blockchain'))                              return '⛓️';
    if (t.contains('web3') || t.contains('defi'))              return '🌐';
    if (t.contains('solidity') || t.contains('smart contract')) return '📜';
    if (t.contains('nft') || t.contains('crypto'))             return '💎';

    // ── Game Development ───────────────────
    if (t.contains('game dev') || t.contains('unity'))         return '🎮';
    if (t.contains('unreal'))                                  return '🕹️';

    // ── IoT & Embedded ─────────────────────
    if (t.contains('iot') || t.contains('internet of things')) return '🔌';
    if (t.contains('embedded') || t.contains('arduino'))       return '🔧';
    if (t.contains('raspberry'))                               return '🍓';
    if (t.contains('robotics'))                                return '🦾';

    // ── Business & Soft Skills ─────────────
    if (t.contains('project management'))                      return '📋';
    if (t.contains('agile') || t.contains('scrum'))            return '🔄';
    if (t.contains('communication'))                           return '🗣️';
    if (t.contains('leadership'))                              return '🏆';

    // ── Default fallback by category ───────
    switch (c) {
      case 'ai/ml':          return '🤖';
      case 'web dev':        return '🌐';
      case 'app dev':        return '📱';
      case 'data science':   return '📊';
      case 'cloud':          return '☁️';
      case 'cybersecurity':  return '🔐';
      default:               return '💡';
    }
  }

  // ── SMART BG COLOR RESOLVER — design only ──
  // Gives each category a distinct, pleasant background tint for badge tiles.

  static Color _resolveBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'ai/ml':         return const Color(0xFFEFF6FF); // soft blue
      case 'web dev':       return const Color(0xFFFFF7ED); // warm amber
      case 'app dev':       return const Color(0xFFF0FDF4); // soft green
      case 'data science':  return const Color(0xFFFDF4FF); // soft purple
      case 'cloud':         return const Color(0xFFF0F9FF); // sky
      case 'cybersecurity': return const Color(0xFFFFF1F2); // soft red
      default:              return const Color(0xFFF8FAFC); // neutral
    }
  }

  // ── _filtered — untouched ──────────────────
  List<EngCourse> get _filtered {
    var list = _category == 'All'
        ? _courses
        : _courses.where((c) => c.category == _category).toList();
    if (_search.isNotEmpty) {
      list = list.where((c) =>
      c.title.toLowerCase().contains(_search.toLowerCase()) ||
          c.category.toLowerCase().contains(_search.toLowerCase()) ||
          c.instructor.toLowerCase().contains(_search.toLowerCase())).toList();
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
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Courses',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.4,
                              )),
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
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: kAccent, size: 13),
                            const SizedBox(width: 4),
                            Text('${_enrolled.length} Enrolled',
                                style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: kAccent,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _statPill(Icons.menu_book,        '${_courses.length}', 'Courses'),
                    _statPill(Icons.workspace_premium, '95%',               'Placement'),
                    _statPill(Icons.category,          '6',                 'Domains'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎓', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 5),
                          Text('Get Job-Ready',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
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

  Widget _statPill(IconData icon, String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kAccent),
          const SizedBox(width: 4),
          Text(num,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: kAccent)),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.55),
              )),
        ],
      ),
    );
  }

  // ── SEARCH BAR — untouched logic ───────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search courses, instructors…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search, color: kMuted, size: 22),
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

  // ── CATEGORY BAR — untouched logic ─────────

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
                  child: Text(cat,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : kMuted,
                      )),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── COURSE LIST — skeleton added ───────────

  Widget _buildCourseList() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: 4,
        itemBuilder: (_, __) => const _SkeletonCard(),
      );
    }

    final list = _filtered;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: kSelectedBg, shape: BoxShape.circle),
              child: const Icon(Icons.search_off, color: kPrimary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No courses found',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: kSlate)),
            const SizedBox(height: 6),
            const Text('Try a different category or keyword',
                style: TextStyle(fontSize: 12, color: kMuted)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() {
                _search   = '';
                _category = 'All';
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Clear filters',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 13)),
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
        course:     list[i],
        isEnrolled: _enrolled.contains(list[i].id),
        onEnroll: () {
          HapticFeedback.lightImpact();
          setState(() => _enrolled.add(list[i].id));
        },
        ctrl: _cardAnims[list[i].id],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SKELETON LOADER — design only
// ─────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _anim;
  late Animation<double>   _shimmer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmer = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Opacity(
        opacity: _shimmer.value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _box(46, 46, radius: 13),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(15, double.infinity),
                        const SizedBox(height: 7),
                        _box(11, 140),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _box(24, 70, radius: 20),
                ],
              ),
              const SizedBox(height: 14),
              _box(12, 220),
              const SizedBox(height: 6),
              _box(12, 180),
              const SizedBox(height: 14),
              Row(children: [
                _box(26, 80, radius: 8),
                const SizedBox(width: 8),
                _box(26, 60, radius: 8),
                const SizedBox(width: 8),
                _box(26, 55, radius: 8),
              ]),
              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _box(34, 80, radius: 12),
                  const Spacer(),
                  _box(34, 110, radius: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double h, double w, {double radius = 8}) => Container(
    height: h,
    width: w == double.infinity ? null : w,
    decoration: BoxDecoration(
      color: const Color(0xFFE2E8F0),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

// ─────────────────────────────────────────────
//  COURSE ICON SYSTEM — design only
//  Resolves a professional Flutter IconData + gradient colours
//  from course title / category. Model & API completely untouched.
// ─────────────────────────────────────────────

class _CourseTheme {
  final IconData icon;
  final Color    grad1;   // gradient start
  final Color    grad2;   // gradient end
  const _CourseTheme(this.icon, this.grad1, this.grad2);
}

_CourseTheme _resolveCourseTheme(String title, String category) {
  final t = title.toLowerCase();
  final c = category.toLowerCase();

  // ── AI & Machine Learning ──────────────────
  if (t.contains('machine learning') || t.contains(' ml ') || t.contains('ml '))
    return const _CourseTheme(Icons.psychology,            Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('deep learning') || t.contains('neural'))
    return const _CourseTheme(Icons.hub,                   Color(0xFF7C3AED), Color(0xFF4F46E5));
  if (t.contains('natural language') || t.contains('nlp') || t.contains('chatbot'))
    return const _CourseTheme(Icons.chat_bubble,           Color(0xFF8B5CF6), Color(0xFFA855F7));
  if (t.contains('computer vision'))
    return const _CourseTheme(Icons.remove_red_eye,        Color(0xFF6366F1), Color(0xFF3B82F6));
  if (t.contains('generative') || t.contains('genai') || t.contains('llm'))
    return const _CourseTheme(Icons.auto_awesome,          Color(0xFF7C3AED), Color(0xFFEC4899));
  if (t.contains('artificial intelligence') || t.contains('ai') || c == 'ai/ml')
    return const _CourseTheme(Icons.smart_toy,             Color(0xFF4F46E5), Color(0xFF6366F1));

  // ── Data Science & Analytics ───────────────
  if (t.contains('data science'))
    return const _CourseTheme(Icons.analytics,             Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('data analyst') || t.contains('analytics'))
    return const _CourseTheme(Icons.bar_chart,             Color(0xFF8B5CF6), Color(0xFF7C3AED));
  if (t.contains('tableau') || t.contains('power bi'))
    return const _CourseTheme(Icons.pie_chart,             Color(0xFF2563EB), Color(0xFF7C3AED));
  if (t.contains('sql') || t.contains('database') || t.contains('mysql') || t.contains('postgresql'))
    return const _CourseTheme(Icons.storage,               Color(0xFF0369A1), Color(0xFF0284C7));
  if (t.contains('big data') || t.contains('hadoop') || t.contains('spark'))
    return const _CourseTheme(Icons.waves,                 Color(0xFF0891B2), Color(0xFF0E7490));
  if (c == 'data science')
    return const _CourseTheme(Icons.query_stats,           Color(0xFF7C3AED), Color(0xFF6366F1));

  // ── Web Development ────────────────────────
  if (t.contains('react'))
    return const _CourseTheme(Icons.loop,                  Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('angular'))
    return const _CourseTheme(Icons.change_history,        Color(0xFFDC2626), Color(0xFFEF4444));
  if (t.contains('vue'))
    return const _CourseTheme(Icons.filter_vintage,        Color(0xFF16A34A), Color(0xFF22C55E));
  if (t.contains('next.js') || t.contains('nextjs'))
    return const _CourseTheme(Icons.arrow_forward,         Color(0xFF0F172A), Color(0xFF334155));
  if (t.contains('node') || t.contains('express') || t.contains('backend'))
    return const _CourseTheme(Icons.settings_ethernet,     Color(0xFF15803D), Color(0xFF16A34A));
  if (t.contains('html') || t.contains('css'))
    return const _CourseTheme(Icons.code,                  Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('javascript') || t.contains(' js'))
    return const _CourseTheme(Icons.javascript,            Color(0xFFCA8A04), Color(0xFFEAB308));
  if (t.contains('typescript'))
    return const _CourseTheme(Icons.data_object,           Color(0xFF1D4ED8), Color(0xFF2563EB));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const _CourseTheme(Icons.layers,                Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('graphql'))
    return const _CourseTheme(Icons.share,                 Color(0xFFE10098), Color(0xFFEC4899));
  if (t.contains('api') || t.contains('rest'))
    return const _CourseTheme(Icons.cable,                 Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (c == 'web dev')
    return const _CourseTheme(Icons.language,              Color(0xFF1D4ED8), Color(0xFF0EA5E9));

  // ── App Development ────────────────────────
  if (t.contains('flutter'))
    return const _CourseTheme(Icons.phone_android,         Color(0xFF0284C7), Color(0xFF38BDF8));
  if (t.contains('react native'))
    return const _CourseTheme(Icons.smartphone,            Color(0xFF0EA5E9), Color(0xFF6366F1));
  if (t.contains('android') || t.contains('kotlin'))
    return const _CourseTheme(Icons.android,               Color(0xFF16A34A), Color(0xFF4ADE80));
  if (t.contains('ios') || t.contains('swift'))
    return const _CourseTheme(Icons.apple,                 Color(0xFF0F172A), Color(0xFF334155));
  if (t.contains('dart'))
    return const _CourseTheme(Icons.adjust,                Color(0xFF0284C7), Color(0xFF0EA5E9));
  if (c == 'app dev')
    return const _CourseTheme(Icons.devices,               Color(0xFF0369A1), Color(0xFF0284C7));

  // ── Cloud & DevOps ─────────────────────────
  if (t.contains('aws') || t.contains('amazon web'))
    return const _CourseTheme(Icons.cloud,                 Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('azure'))
    return const _CourseTheme(Icons.cloud_queue,           Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('google cloud') || t.contains('gcp'))
    return const _CourseTheme(Icons.cloud_done,            Color(0xFF1D4ED8), Color(0xFFDC2626));
  if (t.contains('docker'))
    return const _CourseTheme(Icons.view_in_ar,            Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('kubernetes') || t.contains('k8s'))
    return const _CourseTheme(Icons.settings_backup_restore, Color(0xFF1D4ED8), Color(0xFF6366F1));
  if (t.contains('devops') || t.contains('ci/cd'))
    return const _CourseTheme(Icons.sync_alt,              Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('linux') || t.contains('unix'))
    return const _CourseTheme(Icons.terminal,              Color(0xFF0F172A), Color(0xFF1E293B));
  if (c == 'cloud')
    return const _CourseTheme(Icons.cloud_upload,          Color(0xFF0369A1), Color(0xFF0EA5E9));

  // ── Cybersecurity ──────────────────────────
  if (t.contains('ethical hacking') || t.contains('penetration'))
    return const _CourseTheme(Icons.security,              Color(0xFFDC2626), Color(0xFFEF4444));
  if (t.contains('network security'))
    return const _CourseTheme(Icons.shield,                Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('cryptography'))
    return const _CourseTheme(Icons.lock,                  Color(0xFF0F172A), Color(0xFF334155));
  if (c == 'cybersecurity')
    return const _CourseTheme(Icons.gpp_good,              Color(0xFFB91C1C), Color(0xFFDC2626));

  // ── Programming Languages ──────────────────
  if (t.contains('python'))
    return const _CourseTheme(Icons.code,                  Color(0xFF1D4ED8), Color(0xFFF59E0B));
  if (t.contains('java') && !t.contains('javascript'))
    return const _CourseTheme(Icons.local_cafe,            Color(0xFFB45309), Color(0xFFD97706));
  if (t.contains('c++') || t.contains('cpp'))
    return const _CourseTheme(Icons.memory,                Color(0xFF1D4ED8), Color(0xFF6366F1));
  if (t.contains('golang') || t.contains(' go '))
    return const _CourseTheme(Icons.speed,                 Color(0xFF0369A1), Color(0xFF38BDF8));
  if (t.contains('rust'))
    return const _CourseTheme(Icons.hardware,              Color(0xFFB45309), Color(0xFFD97706));

  // ── Blockchain ─────────────────────────────
  if (t.contains('blockchain') || t.contains('web3') || t.contains('solidity'))
    return const _CourseTheme(Icons.link,                  Color(0xFF7C3AED), Color(0xFF6366F1));

  // ── Game Development ───────────────────────
  if (t.contains('game') || t.contains('unity') || t.contains('unreal'))
    return const _CourseTheme(Icons.sports_esports,        Color(0xFF7C3AED), Color(0xFFEC4899));

  // ── UI/UX Design ───────────────────────────
  if (t.contains('ui') || t.contains('ux') || t.contains('figma') || t.contains('design'))
    return const _CourseTheme(Icons.brush,                 Color(0xFFEC4899), Color(0xFFF43F5E));

  // ── IoT & Embedded ─────────────────────────
  if (t.contains('iot') || t.contains('embedded') || t.contains('arduino'))
    return const _CourseTheme(Icons.memory,                Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('robotics'))
    return const _CourseTheme(Icons.precision_manufacturing, Color(0xFF1D4ED8), Color(0xFF6366F1));

  // ── Default fallback ───────────────────────
  switch (c) {
    case 'ai/ml':         return const _CourseTheme(Icons.smart_toy,    Color(0xFF4F46E5), Color(0xFF6366F1));
    case 'web dev':       return const _CourseTheme(Icons.language,     Color(0xFF1D4ED8), Color(0xFF0EA5E9));
    case 'app dev':       return const _CourseTheme(Icons.devices,      Color(0xFF0369A1), Color(0xFF0284C7));
    case 'data science':  return const _CourseTheme(Icons.analytics,    Color(0xFF7C3AED), Color(0xFF6366F1));
    case 'cloud':         return const _CourseTheme(Icons.cloud,        Color(0xFF0369A1), Color(0xFF0EA5E9));
    case 'cybersecurity': return const _CourseTheme(Icons.gpp_good,     Color(0xFFB91C1C), Color(0xFFDC2626));
    default:              return const _CourseTheme(Icons.school,       Color(0xFF1D4ED8), Color(0xFF6366F1));
  }
}

/// Professional course icon tile with gradient background.
/// Drop-in replacement for the emoji badge — model untouched.
class _CourseIconTile extends StatelessWidget {
  final String title;
  final String category;
  final double size;

  const _CourseIconTile({
    required this.title,
    required this.category,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _resolveCourseTheme(title, category);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.grad1, theme.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: theme.grad1.withOpacity(0.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        theme.icon,
        color: Colors.white,
        size: size * 0.48,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COURSE CARD WIDGET
// ─────────────────────────────────────────────

class _EngCourseCard extends StatefulWidget {
  final EngCourse            course;
  final bool                 isEnrolled;
  final VoidCallback         onEnroll;
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
  late Animation<double>   _btnScale;
  bool _btnPressed = false;

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
  void dispose() { _btnCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c    = widget.course;
    final ls   = _levelStyle(c.level);
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
      child: _buildCard(c, ls),
    )
        : _buildCard(c, ls);
  }

  Widget _buildCard(EngCourse c, _LevelStyle ls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── coloured top accent strip ──────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _accentFor(c.category),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── header row ─────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Professional icon tile (replaces emoji badge)
                      _CourseIconTile(
                        title:    c.title,
                        category: c.category,
                        size:     46,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800,
                                  color: kInk,
                                )),
                            const SizedBox(height: 3),
                            if (c.instructor.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 12, color: kHint),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(c.instructor,
                                        style: const TextStyle(
                                          fontSize: 11, color: kMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ls.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(c.level,
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700,
                              color: ls.fg,
                            )),
                      ),
                    ],
                  ),

                  // ── description ────────────────
                  if (c.desc.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(c.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: kHint, height: 1.5)),
                  ],

                  // ── meta chips ─────────────────
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7, runSpacing: 6,
                    children: [
                      if (c.duration.isNotEmpty)
                        _chip(icon: Icons.schedule, label: c.duration),
                      if (c.rating > 0)
                        _chip(icon: Icons.star, label: c.rating.toStringAsFixed(1),
                            iconColor: kWarning),
                      if (c.students > 0)
                        _chip(icon: Icons.people, label: _fmt(c.students)),
                      for (final m in c.mode) _modeChip(m),
                    ],
                  ),

                  // ── tech tags ──────────────────
                  if (c.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
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
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: kSlate,
                            )),
                      )).toList(),
                    ),
                  ],

                  // ── divider ────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 1, color: const Color(0xFFF1F5F9),
                  ),

                  // ── price + enroll ─────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF86EFAC), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.currency_rupee,
                                size: 13, color: kSuccess),
                            Text(c.price,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13,
                                  color: kSuccess,
                                )),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTapDown: (_) {
                          _btnCtrl.forward();
                          setState(() => _btnPressed = true);
                        },
                        onTapUp: (_) {
                          _btnCtrl.reverse();
                          setState(() => _btnPressed = false);
                          if (!widget.isEnrolled) widget.onEnroll();
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
                                horizontal: 22, vertical: 10),
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
                              boxShadow: widget.isEnrolled || _btnPressed
                                  ? null
                                  : [
                                BoxShadow(
                                  color: kPrimary.withOpacity(0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.isEnrolled)
                                  const Icon(Icons.check,
                                      size: 14, color: kSuccess),
                                if (widget.isEnrolled)
                                  const SizedBox(width: 5),
                                Text(
                                  widget.isEnrolled ? 'Enrolled' : 'Enroll Now',
                                  style: TextStyle(
                                    color: widget.isEnrolled
                                        ? kSuccess
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
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
    );
  }

  Widget _chip({required IconData icon, required String label,
    Color iconColor = kMuted}) {
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
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: kMuted)),
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
          Icon(online ? Icons.wifi : Icons.location_on,
              size: 11, color: online ? kPrimary : kSuccess),
          const SizedBox(width: 4),
          Text(mode,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: online ? kPrimary : kSuccess,
              )),
        ],
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}