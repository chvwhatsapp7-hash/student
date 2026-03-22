import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
//  STATIC DATA
// ─────────────────────────────────────────────

const _stats = [
  {'icon': Icons.send,     'value': '14', 'label': 'Applied',       'color': Color(0xFF1D4ED8)},
  {'icon': Icons.star,     'value': '5',  'label': 'Shortlisted',   'color': Color(0xFFF59E0B)},
  {'icon': Icons.person,   'value': '72%','label': 'Profile Score', 'color': Color(0xFF16A34A)},
  {'icon': Icons.bookmark, 'value': '9',  'label': 'Saved',         'color': Color(0xFF7C3AED)},
];

const _recommendedJobs = [
  {
    'title':   'Frontend Developer',
    'company': 'TechNova India',
    'location':'Bengaluru',
    'salary':  '₹8–12 LPA',
    'match':   '92',
    'type':    'Full Time',
    'exp':     'Fresher',
    'tags':    ['React', 'TypeScript'],
    'desc':    'Build modern web UIs using React and TypeScript for a fast-growing product company.',
  },
  {
    'title':   'ML Engineer Intern',
    'company': 'DataMind Labs',
    'location':'Hyderabad',
    'salary':  '₹25K/month',
    'match':   '87',
    'type':    'Internship',
    'exp':     'Fresher',
    'tags':    ['Python', 'TensorFlow'],
    'desc':    'Work on cutting-edge ML models and pipelines for real-world data problems.',
  },
  {
    'title':   'Backend Developer',
    'company': 'CloudSoft Systems',
    'location':'Pune',
    'salary':  '₹6–9 LPA',
    'match':   '78',
    'type':    'Full Time',
    'exp':     '1–2 Years',
    'tags':    ['Node.js', 'AWS'],
    'desc':    'Design and build scalable REST APIs and microservices on AWS infrastructure.',
  },
];

const _nearbyCompanies = [
  {'name':'Infosys','city':'Bengaluru','distance':'2.3 km','openings':'12','domain':'IT Services'},
  {'name':'Wipro',  'city':'Hyderabad', 'distance':'5.1 km','openings':'8', 'domain':'Consulting'},
  {'name':'TCS',    'city':'Chennai',   'distance':'7.8 km','openings':'20','domain':'Technology'},
];

const _trendingCourses = [
  {'title':'Machine Learning A–Z',   'category':'AI/ML',   'level':'Intermediate','rating':'4.8','duration':'12 weeks'},
  {'title':'Full Stack Web Dev',     'category':'Web Dev', 'level':'Beginner',    'rating':'4.7','duration':'10 weeks'},
  {'title':'AWS Cloud Practitioner', 'category':'Cloud',   'level':'Beginner',    'rating':'4.9','duration':'6 weeks'},
];

const _hackathons = [
  {'title':'Smart India Hackathon','org':'MoE Govt of India','prize':'₹1L', 'date':'Jan 25','mode':'Offline'},
  {'title':'HackWithInfy 2025',    'org':'Infosys',          'prize':'₹50K','date':'Feb 3', 'mode':'Online'},
];

// ─────────────────────────────────────────────
//  SHARED ICON SYSTEM
// ─────────────────────────────────────────────

class _Theme {
  final IconData icon;
  final Color    grad1, grad2;
  const _Theme(this.icon, this.grad1, this.grad2);
}

_Theme _jobTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();
  if (t.contains('frontend') || t.contains('react')) {
    return const _Theme(Icons.web,           Color(0xFF0EA5E9), Color(0xFF38BDF8));
  }
  if (t.contains('backend') || t.contains('node') || t.contains('server')) {
    return const _Theme(Icons.dns,           Color(0xFF15803D), Color(0xFF22C55E));
  }
  if (t.contains('full stack') || t.contains('fullstack')) {
    return const _Theme(Icons.layers,        Color(0xFF1D4ED8), Color(0xFF7C3AED));
  }
  if (t.contains('machine learning') || t.contains('ml engineer')) {
    return const _Theme(Icons.psychology,    Color(0xFF6366F1), Color(0xFF8B5CF6));
  }
  if (t.contains('data scien') || t.contains('data analyst')) {
    return const _Theme(Icons.analytics,     Color(0xFF7C3AED), Color(0xFF6366F1));
  }
  if (t.contains('android') || t.contains('mobile') || t.contains('flutter')) {
    return const _Theme(Icons.phone_android, Color(0xFF0284C7), Color(0xFF38BDF8));
  }
  if (t.contains('cloud') || t.contains('aws') || t.contains('devops')) {
    return const _Theme(Icons.cloud,         Color(0xFF0369A1), Color(0xFF0EA5E9));
  }
  if (t.contains('security') || t.contains('cyber')) {
    return const _Theme(Icons.shield,        Color(0xFFB91C1C), Color(0xFFDC2626));
  }
  if (t.contains('design') || t.contains('ux')) {
    return const _Theme(Icons.brush,         Color(0xFFEC4899), Color(0xFFF43F5E));
  }
  if (t.contains('intern')) {
    return const _Theme(Icons.school,        Color(0xFF7C3AED), Color(0xFF6366F1));
  }
  if (c.contains('technova') || c.contains('tech')) {
    return const _Theme(Icons.code,          Color(0xFF1D4ED8), Color(0xFF3B82F6));
  }
  if (c.contains('datamind') || c.contains('data')) {
    return const _Theme(Icons.analytics,     Color(0xFF7C3AED), Color(0xFF6366F1));
  }
  if (c.contains('cloud') || c.contains('soft')) {
    return const _Theme(Icons.cloud,         Color(0xFF0369A1), Color(0xFF0EA5E9));
  }
  return const _Theme(Icons.work_outline,    Color(0xFF1D4ED8), Color(0xFF6366F1));
}

_Theme _courseTheme(String title, String category) {
  final t = title.toLowerCase();
  final c = category.toLowerCase();
  if (t.contains('machine learning') || t.contains('ml') || c == 'ai/ml') {
    return const _Theme(Icons.psychology,    Color(0xFF6366F1), Color(0xFF8B5CF6));
  }
  if (t.contains('full stack') || t.contains('web dev') || c == 'web dev') {
    return const _Theme(Icons.language,      Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  }
  if (t.contains('aws') || t.contains('cloud') || c == 'cloud') {
    return const _Theme(Icons.cloud,         Color(0xFF0369A1), Color(0xFF0EA5E9));
  }
  if (t.contains('data') || c == 'data science') {
    return const _Theme(Icons.analytics,     Color(0xFF7C3AED), Color(0xFF6366F1));
  }
  if (c == 'app dev' || t.contains('android') || t.contains('flutter')) {
    return const _Theme(Icons.phone_android, Color(0xFF0284C7), Color(0xFF38BDF8));
  }
  if (c == 'cybersecurity' || t.contains('cyber')) {
    return const _Theme(Icons.gpp_good,      Color(0xFFB91C1C), Color(0xFFDC2626));
  }
  return const _Theme(Icons.menu_book,       Color(0xFF1D4ED8), Color(0xFF6366F1));
}

_Theme _companyTheme(String name) {
  final n = name.toLowerCase();
  if (n.contains('infosys'))   { return const _Theme(Icons.business,       Color(0xFF1D4ED8), Color(0xFF3B82F6)); }
  if (n.contains('wipro'))     { return const _Theme(Icons.account_tree,   Color(0xFF059669), Color(0xFF10B981)); }
  if (n.contains('tcs'))       { return const _Theme(Icons.corporate_fare, Color(0xFF0369A1), Color(0xFF0EA5E9)); }
  if (n.contains('google'))    { return const _Theme(Icons.search,         Color(0xFF1D4ED8), Color(0xFF0EA5E9)); }
  if (n.contains('microsoft')) { return const _Theme(Icons.window,         Color(0xFF1D4ED8), Color(0xFF3B82F6)); }
  if (n.contains('amazon'))    { return const _Theme(Icons.cloud,          Color(0xFFD97706), Color(0xFFF59E0B)); }
  if (n.contains('flipkart'))  { return const _Theme(Icons.shopping_bag,   Color(0xFFD97706), Color(0xFFF59E0B)); }
  return                              const _Theme(Icons.domain,           Color(0xFF374151), Color(0xFF6B7280));
}

_Theme _hackathonTheme(String title) {
  final t = title.toLowerCase();
  if (t.contains('smart india') || t.contains('sih')) {
    return const _Theme(Icons.account_balance, Color(0xFF0369A1), Color(0xFF0EA5E9));
  }
  if (t.contains('infos') || t.contains('infy')) {
    return const _Theme(Icons.business,        Color(0xFF1D4ED8), Color(0xFF3B82F6));
  }
  return const _Theme(Icons.emoji_events,      Color(0xFFD97706), Color(0xFFF59E0B));
}

Widget _tile(IconData icon, Color g1, Color g2, double size) {
  return Container(
    width: size, height: size,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [g1, g2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(size * 0.27),
      boxShadow: [
        BoxShadow(
          color: g1.withValues(alpha: 0.28),
          blurRadius: 8, offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: size * 0.46),
  );
}

class _LevelStyle { final Color bg, fg; const _LevelStyle(this.bg, this.fg); }
_LevelStyle _levelStyle(String level) {
  switch (level) {
    case 'Beginner':     return const _LevelStyle(Color(0xFFF0FDF4), Color(0xFF15803D));
    case 'Intermediate': return const _LevelStyle(Color(0xFFFFFBEB), Color(0xFFB45309));
    case 'Advanced':     return const _LevelStyle(Color(0xFFFFF1F2), Color(0xFFBE123C));
    default:             return const _LevelStyle(Color(0xFFF1F5F9), Color(0xFF475569));
  }
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController           _headerAnim;
  late AnimationController           _xpAnim;
  late Animation<double>             _xpValue;
  late List<AnimationController>     _sectionAnims;
  late List<Animation<double>>       _sectionFade;
  late List<Animation<Offset>>       _sectionSlide;

  final Set<String> _savedJobs = {};

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650),
    )..forward();

    _xpAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    );
    _xpValue = Tween<double>(begin: 0, end: 0.72).animate(
      CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut),
    );

    _sectionAnims = List.generate(8, (_) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480),
    ));
    _sectionFade  = _sectionAnims
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)
    as Animation<double>)
        .toList();
    _sectionSlide = _sectionAnims
        .map((c) => Tween<Offset>(
      begin: const Offset(0, 0.10), end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _xpAnim.forward();
    });
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 80), () {
        if (mounted) _sectionAnims[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _sectionAnims) c.dispose();
    super.dispose();
  }

  Widget _fs(int i, Widget child) => FadeTransition(
    opacity: _sectionFade[i],
    child: SlideTransition(position: _sectionSlide[i], child: child),
  );

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _fs(0, _buildStatsRow()),
                const SizedBox(height: 16),
                _fs(1, _buildProfileStrength()),
                const SizedBox(height: 22),
                _fs(2, _buildQuickActions(context)),
                const SizedBox(height: 24),
                _fs(3, _sectionHeader('Recommended for You',
                    sub: 'Based on your profile & skills')),
                const SizedBox(height: 12),
                _fs(3, _buildRecommendedJobs()),
                const SizedBox(height: 24),
                _fs(4, _sectionHeader('Trending Courses',
                    sub: 'Boost your profile score')),
                const SizedBox(height: 12),
                _fs(4, _buildTrendingCourses()),
                const SizedBox(height: 24),
                _fs(5, _sectionHeader('Hackathons',
                    sub: 'Compete & win prizes')),
                const SizedBox(height: 12),
                _fs(5, _buildHackathons()),
                const SizedBox(height: 24),
                _fs(6, _sectionHeader('Companies Near You',
                    sub: 'Hiring actively in your area')),
                const SizedBox(height: 12),
                _fs(6, _buildNearbyCompanies()),
                const SizedBox(height: 24),
                _fs(7, _buildMotivationBanner()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar with gradient ring
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [kPrimary, kAccent]),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.40),
                            blurRadius: 12, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1B4B),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('A',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('Hey, Arjun ',
                                  style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800,
                                    color: Colors.white, letterSpacing: -0.3,
                                  )),
                              Text('👋', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: const BoxDecoration(
                                    color: kAccent, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text('3 new job matches today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Notification bell
                    Stack(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const Icon(Icons.notifications_none,
                              color: Colors.white, size: 20),
                        ),
                        Positioned(
                          top: 9, right: 9,
                          child: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: kAccent, shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF1E1B4B), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress ticker
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimary, kAccent]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Profile at 72% — almost there!',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                            Text(
                              'Add GitHub + 2 certs to unlock Premium Badge',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('72%',
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: kAccent,
                            )),
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

  // ─────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search jobs, courses, companies…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search, color: kMuted, size: 20),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune, color: kPrimary, size: 18),
          ),
          filled: true, fillColor: kBgPage,
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

  // ─────────────────────────────────────────
  //  STATS ROW
  // ─────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: List.generate(_stats.length, (i) {
        final s     = _stats[i];
        final color = s['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.70)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.22),
                        blurRadius: 6, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(s['icon'] as IconData,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(s['value'] as String,
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: kInk, letterSpacing: -0.5,
                    )),
                const SizedBox(height: 1),
                Text(s['label'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: kMuted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────
  //  PROFILE STRENGTH
  // ─────────────────────────────────────────

  Widget _buildProfileStrength() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kInk.withValues(alpha: 0.18),
            blurRadius: 20, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPrimary, kAccent]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile Strength',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    SizedBox(height: 2),
                    Text('Add certifications to reach 90%',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _xpValue,
                builder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(_xpValue.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800,
                          color: kAccent, letterSpacing: -1,
                        )),
                    const Text('Complete',
                        style: TextStyle(
                            fontSize: 9, color: kHint,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedBuilder(
              animation: _xpValue,
              builder: (_, __) => LinearProgressIndicator(
                value: _xpValue.value,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _profileChip(Icons.workspace_premium, 'Add Certs',    false),
              const SizedBox(width: 8),
              _profileChip(Icons.code,              'Link GitHub',  false),
              const SizedBox(width: 8),
              _profileChip(Icons.check_circle,      'Skills Added', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileChip(IconData icon, String label, bool done) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: done
              ? kSuccess.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: done
                ? kSuccess.withValues(alpha: 0.40)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: done ? kSuccess : kHint),
            const SizedBox(width: 5),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: done ? kSuccess : kHint,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  QUICK ACTIONS — with active navigation
  // ─────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    // Each entry: icon, label, gradient colours, route path
    // Routes must match your router.dart exactly
    final actions = [
      {
        'icon':  Icons.work_outline,
        'label': 'Jobs',
        'g1':    const Color(0xFF1D4ED8),
        'g2':    const Color(0xFF3B82F6),
        'route': '/jobs',
      },
      {
        'icon':  Icons.school,
        'label': 'Internships',
        'g1':    const Color(0xFF7C3AED),
        'g2':    const Color(0xFFA855F7),
        'route': '/internships',
      },
      {
        'icon':  Icons.business,
        'label': 'Companies',
        'g1':    const Color(0xFF0369A1),
        'g2':    const Color(0xFF0EA5E9),
        'route': '/companies',
      },
      {
        'icon':  Icons.emoji_events,
        'label': 'Hackathons',
        'g1':    const Color(0xFFD97706),
        'g2':    const Color(0xFFF59E0B),
        'route': '/hackathons',
      },
      {
        'icon':  Icons.menu_book,
        'label': 'Courses',
        'g1':    const Color(0xFF059669),
        'g2':    const Color(0xFF10B981),
        'route': '/courses',
      },
      {
        'icon':  Icons.person,
        'label': 'Profile',
        'g1':    const Color(0xFFEC4899),
        'g2':    const Color(0xFFF43F5E),
        'route': '/profile',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Access', sub: 'Jump to any section'),
        const SizedBox(height: 12),
        Row(
          children: List.generate(actions.length, (i) {
            final a     = actions[i];
            final g1    = a['g1']    as Color;
            final g2    = a['g2']    as Color;
            final icon  = a['icon']  as IconData;
            final label = a['label'] as String;
            final route = a['route'] as String;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go(route);   // ← active navigation
                },
                child: Container(
                  margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                  child: Column(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [g1, g2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: g1.withValues(alpha: 0.28),
                              blurRadius: 8, offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(label,
                          style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: kSlate,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  RECOMMENDED JOBS
  // ─────────────────────────────────────────

  Widget _buildRecommendedJobs() {
    return Column(
      children: List.generate(_recommendedJobs.length, (i) {
        final job      = _recommendedJobs[i];
        final title    = job['title']    as String;
        final company  = job['company']  as String;
        final location = job['location'] as String;
        final salary   = job['salary']   as String;
        final matchStr = job['match']    as String;
        final type     = job['type']     as String;
        final tags     = job['tags']     as List<String>;

        final theme    = _jobTheme(title, company);
        final match    = int.tryParse(matchStr) ?? 0;
        final isIntern = type == 'Internship';
        final saved    = _savedJobs.contains(title);

        final matchColor = match >= 90 ? kSuccess
            : match >= 80 ? kWarning : kMuted;
        final matchBg = match >= 90 ? const Color(0xFFF0FDF4)
            : match >= 80 ? const Color(0xFFFFFBEB)
            : const Color(0xFFF1F5F9);

        return GestureDetector(
          onTap: () => _showJobDetail(job),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              children: [
                // Accent strip
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tile(theme.icon, theme.grad1, theme.grad2, 50),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w800,
                                      color: kInk,
                                    )),
                                const SizedBox(height: 2),
                                Text(company,
                                    style: const TextStyle(
                                        fontSize: 12, color: kMuted,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 12, color: kHint),
                                    const SizedBox(width: 3),
                                    Text(location,
                                        style: const TextStyle(
                                            fontSize: 12, color: kMuted)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isIntern
                                            ? const Color(0xFFFFFBEB)
                                            : kSelectedBg,
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(type,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isIntern
                                                ? kWarning
                                                : kPrimary,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Bookmark — does NOT bubble to card tap
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (saved) {
                                  _savedJobs.remove(title);
                                } else {
                                  _savedJobs.add(title);
                                }
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: saved ? kSelectedBg : kBgPage,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: saved ? kPrimary : kBorder),
                              ),
                              child: Icon(
                                saved ? Icons.bookmark : Icons.bookmark_border,
                                size: 17,
                                color: saved ? kPrimary : kHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 1, color: const Color(0xFFF1F5F9),
                      ),
                      Row(
                        children: [
                          ...tags.map((t) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                theme.grad1.withValues(alpha: 0.09),
                                theme.grad2.withValues(alpha: 0.05),
                              ]),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: theme.grad1.withValues(alpha: 0.20)),
                            ),
                            child: Text(t,
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: theme.grad1,
                                )),
                          )),
                          const Spacer(),
                          Text(salary,
                              style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800,
                                color: kInk,
                              )),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: matchBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    size: 10, color: matchColor),
                                const SizedBox(width: 3),
                                Text('$match%',
                                    style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w800,
                                      color: matchColor,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.touch_app,
                              size: 11, color: kHint.withValues(alpha: 0.70)),
                          const SizedBox(width: 4),
                          Text('Tap to view full details & apply',
                              style: TextStyle(
                                fontSize: 10,
                                color: kHint.withValues(alpha: 0.70),
                                fontStyle: FontStyle.italic,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Job detail bottom sheet
  void _showJobDetail(Map<String, dynamic> job) {
    final title    = job['title']    as String;
    final company  = job['company']  as String;
    final location = job['location'] as String;
    final salary   = job['salary']   as String;
    final matchStr = job['match']    as String;
    final type     = job['type']     as String;
    final exp      = job['exp']      as String;
    final desc     = job['desc']     as String;
    final tags     = job['tags']     as List<String>;
    final theme    = _jobTheme(title, company);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize:     0.42,
        maxChildSize:     0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tile(theme.icon, theme.grad1, theme.grad2, 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800,
                              color: kInk, letterSpacing: -0.3,
                            )),
                        const SizedBox(height: 3),
                        Text(company,
                            style: const TextStyle(
                                fontSize: 13, color: kMuted,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 13, color: kHint),
                            const SizedBox(width: 4),
                            Text(location,
                                style: const TextStyle(
                                    fontSize: 12, color: kMuted)),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: kSelectedBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(type,
                                  style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: kPrimary,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    theme.grad1.withValues(alpha: 0.08),
                    theme.grad2.withValues(alpha: 0.04),
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.grad1.withValues(alpha: 0.20), width: 1.5),
                ),
                child: Row(
                  children: [
                    _detailStat(Icons.currency_rupee, salary,     'Salary'),
                    _vDiv(),
                    _detailStat(Icons.school,         exp,        'Experience'),
                    _vDiv(),
                    _detailStat(Icons.access_time,    'Recently', 'Posted'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // AI Match bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 16, color: kWarning),
                    const SizedBox(width: 8),
                    const Text('AI Match',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: kInk)),
                    const Spacer(),
                    Text('$matchStr%',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kSuccess,
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (int.tryParse(matchStr) ?? 0) / 100,
                          minHeight: 8,
                          backgroundColor: kBorder,
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(kSuccess),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Required Skills',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: kInk)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      theme.grad1.withValues(alpha: 0.10),
                      theme.grad2.withValues(alpha: 0.06),
                    ]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.grad1.withValues(alpha: 0.25)),
                  ),
                  child: Text(t,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: theme.grad1,
                      )),
                )).toList(),
              ),
              const SizedBox(height: 20),
              const Text('About the Role',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: kInk)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Text(desc,
                    style: const TextStyle(
                        fontSize: 13, color: kSlate, height: 1.6)),
              ),
              const SizedBox(height: 24),
              // Apply CTA → navigates to Jobs screen
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  context.go('/jobs');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.grad1.withValues(alpha: 0.30),
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Apply for this Role',
                          style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontSize: 15,
                          )),
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

  Widget _detailStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: kPrimary),
          const SizedBox(height: 5),
          Text(value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: kInk)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: kMuted)),
        ],
      ),
    );
  }

  Widget _vDiv() => Container(width: 1, height: 36, color: kBorder);

  // ─────────────────────────────────────────
  //  TRENDING COURSES
  // ─────────────────────────────────────────

  Widget _buildTrendingCourses() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingCourses.length,
        itemBuilder: (_, i) {
          final course   = _trendingCourses[i];
          final ctitle   = course['title']    as String;
          final category = course['category'] as String;
          final level    = course['level']    as String;
          final rating   = course['rating']   as String;
          final duration = course['duration'] as String;
          final theme    = _courseTheme(ctitle, category);
          final ls       = _levelStyle(level);

          return GestureDetector(
            onTap: () => context.go('/courses'),
            child: Container(
              width: 200,
              margin: EdgeInsets.only(
                  right: i < _trendingCourses.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kBorder, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tile(theme.icon, theme.grad1, theme.grad2, 40),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: ls.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(level,
                            style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: ls.fg,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ctitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: kInk, height: 1.3,
                      )),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 11, color: kWarning),
                      const SizedBox(width: 3),
                      Text(rating,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: kMuted)),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 11, color: kHint),
                      const SizedBox(width: 3),
                      Text(duration,
                          style: const TextStyle(
                              fontSize: 10, color: kHint)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HACKATHONS
  // ─────────────────────────────────────────

  Widget _buildHackathons() {
    return Column(
      children: _hackathons.map((h) {
        final htitle = h['title'] as String;
        final org    = h['org']   as String;
        final prize  = h['prize'] as String;
        final date   = h['date']  as String;
        final mode   = h['mode']  as String;
        final theme  = _hackathonTheme(htitle);
        final online = mode == 'Online';

        return GestureDetector(
          onTap: () => context.go('/hackathons'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              children: [
                // Accent strip
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _tile(theme.icon, theme.grad1, theme.grad2, 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(htitle,
                                style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w800,
                                  color: kInk,
                                )),
                            const SizedBox(height: 2),
                            Text(org,
                                style: const TextStyle(
                                    fontSize: 11, color: kMuted,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _smallChip(Icons.calendar_today, date),
                                const SizedBox(width: 6),
                                _smallChip(Icons.emoji_events, prize,
                                    iconColor: kWarning),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: online
                                        ? kSelectedBg
                                        : const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(mode,
                                      style: TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.w700,
                                        color: online ? kPrimary : kSuccess,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/hackathons');
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [theme.grad1, theme.grad2]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.grad1.withValues(alpha: 0.25),
                                blurRadius: 6, offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text('Register',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  NEARBY COMPANIES
  // ─────────────────────────────────────────

  Widget _buildNearbyCompanies() {
    return Column(
      children: _nearbyCompanies.map((c) {
        final cname    = c['name']     as String;
        final city     = c['city']     as String;
        final distance = c['distance'] as String;
        final openings = c['openings'] as String;
        final domain   = c['domain']   as String;
        final theme    = _companyTheme(cname);

        return GestureDetector(
          onTap: () => context.go('/companies'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Row(
              children: [
                _tile(theme.icon, theme.grad1, theme.grad2, 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cname,
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: kInk,
                          )),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: kHint),
                          const SizedBox(width: 3),
                          Text(city,
                              style: const TextStyle(
                                  fontSize: 12, color: kMuted)),
                          const SizedBox(width: 6),
                          Container(
                            width: 3, height: 3,
                            decoration: const BoxDecoration(
                                color: kHint, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.near_me, size: 11, color: kHint),
                          const SizedBox(width: 3),
                          Text(distance,
                              style: const TextStyle(
                                  fontSize: 12, color: kMuted)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(domain,
                          style: const TextStyle(
                              fontSize: 10, color: kHint,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.grad1.withValues(alpha: 0.25),
                        blurRadius: 6, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text('$openings open',
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  MOTIVATION BANNER
  // ─────────────────────────────────────────

  Widget _buildMotivationBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kWarning.withValues(alpha: 0.28),
                  blurRadius: 8, offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.emoji_events,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You're in the top 15%!",
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: kInk,
                    )),
                SizedBox(height: 3),
                Text(
                  'Your profile is viewed 3× more than average.',
                  style: TextStyle(
                      fontSize: 11, color: kMuted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Text('🔥 Top',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                )),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────

  Widget _sectionHeader(String title, {String? sub}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: kInk, letterSpacing: -0.2,
                  )),
              if (sub != null)
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: kMuted,
                        fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallChip(IconData icon, String label,
      {Color iconColor = kMuted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: iconColor),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: kMuted)),
        ],
      ),
    );
  }
}
