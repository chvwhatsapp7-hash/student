import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../notifications/notification_page.dart';
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
//  STATIC DATA  (unchanged)
// ─────────────────────────────────────────────
const _stats = [
  {
    'icon': Icons.send,
    'value': '14',
    'label': 'Applied',
    'color': Color(0xFF1D4ED8),
  },
  {
    'icon': Icons.star,
    'value': '5',
    'label': 'Shortlisted',
    'color': Color(0xFFF59E0B),
  },
  {
    'icon': Icons.person,
    'value': '72%',
    'label': 'Profile Score',
    'color': Color(0xFF16A34A),
  },
  {
    'icon': Icons.bookmark,
    'value': '9',
    'label': 'Saved',
    'color': Color(0xFF7C3AED),
  },
];

const _recommendedJobs = [
  {
    'title': 'Frontend Developer',
    'company': 'TechNova India',
    'location': 'Bengaluru',
    'salary': '₹8–12 LPA',
    'match': '92',
    'type': 'Full Time',
    'exp': 'Fresher',
    'tags': ['React', 'TypeScript'],
    'desc':
        'Build modern web UIs using React and TypeScript for a fast-growing product company.',
  },
  {
    'title': 'ML Engineer Intern',
    'company': 'DataMind Labs',
    'location': 'Hyderabad',
    'salary': '₹25K/month',
    'match': '87',
    'type': 'Internship',
    'exp': 'Fresher',
    'tags': ['Python', 'TensorFlow'],
    'desc':
        'Work on cutting-edge ML models and pipelines for real-world data problems.',
  },
  {
    'title': 'Backend Developer',
    'company': 'CloudSoft Systems',
    'location': 'Pune',
    'salary': '₹6–9 LPA',
    'match': '78',
    'type': 'Full Time',
    'exp': '1–2 Years',
    'tags': ['Node.js', 'AWS'],
    'desc':
        'Design and build scalable REST APIs and microservices on AWS infrastructure.',
  },
];

const _nearbyCompanies = [
  {
    'name': 'Infosys',
    'city': 'Bengaluru',
    'distance': '2.3 km',
    'openings': '12',
    'domain': 'IT Services',
  },
  {
    'name': 'Wipro',
    'city': 'Hyderabad',
    'distance': '5.1 km',
    'openings': '8',
    'domain': 'Consulting',
  },
  {
    'name': 'TCS',
    'city': 'Chennai',
    'distance': '7.8 km',
    'openings': '20',
    'domain': 'Technology',
  },
];

const _trendingCourses = [
  {
    'title': 'Machine Learning A–Z',
    'category': 'AI/ML',
    'level': 'Intermediate',
    'rating': '4.8',
    'duration': '12 weeks',
  },
  {
    'title': 'Full Stack Web Dev',
    'category': 'Web Dev',
    'level': 'Beginner',
    'rating': '4.7',
    'duration': '10 weeks',
  },
  {
    'title': 'AWS Cloud Practitioner',
    'category': 'Cloud',
    'level': 'Beginner',
    'rating': '4.9',
    'duration': '6 weeks',
  },
];

const _hackathons = [
  {
    'title': 'Smart India Hackathon',
    'org': 'MoE Govt of India',
    'prize': '₹1L',
    'date': 'Jan 25',
    'mode': 'Offline',
  },
  {
    'title': 'HackWithInfy 2025',
    'org': 'Infosys',
    'prize': '₹50K',
    'date': 'Feb 3',
    'mode': 'Online',
  },
];

// ─────────────────────────────────────────────
//  SHARED ICON SYSTEM  (unchanged)
// ─────────────────────────────────────────────
class _Theme {
  final IconData icon;
  final Color grad1, grad2;
  const _Theme(this.icon, this.grad1, this.grad2);
}

_Theme _jobTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();
  if (t.contains('frontend') || t.contains('react'))
    return const _Theme(Icons.web, Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') || t.contains('node') || t.contains('server'))
    return const _Theme(Icons.dns, Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const _Theme(Icons.layers, Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('machine learning') || t.contains('ml engineer'))
    return const _Theme(Icons.psychology, Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('data scien') || t.contains('data analyst'))
    return const _Theme(Icons.analytics, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('android') || t.contains('mobile') || t.contains('flutter'))
    return const _Theme(
      Icons.phone_android,
      Color(0xFF0284C7),
      Color(0xFF38BDF8),
    );
  if (t.contains('cloud') || t.contains('aws') || t.contains('devops'))
    return const _Theme(Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('security') || t.contains('cyber'))
    return const _Theme(Icons.shield, Color(0xFFB91C1C), Color(0xFFDC2626));
  if (t.contains('design') || t.contains('ux'))
    return const _Theme(Icons.brush, Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('intern'))
    return const _Theme(Icons.school, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (c.contains('technova') || c.contains('tech'))
    return const _Theme(Icons.code, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (c.contains('datamind') || c.contains('data'))
    return const _Theme(Icons.analytics, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (c.contains('cloud') || c.contains('soft'))
    return const _Theme(Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  return const _Theme(Icons.work_outline, Color(0xFF1D4ED8), Color(0xFF6366F1));
}

_Theme _courseTheme(String title, String category) {
  final t = title.toLowerCase();
  final c = category.toLowerCase();
  if (t.contains('machine learning') || t.contains('ml') || c == 'ai/ml')
    return const _Theme(Icons.psychology, Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('full stack') || t.contains('web dev') || c == 'web dev')
    return const _Theme(Icons.language, Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (t.contains('aws') || t.contains('cloud') || c == 'cloud')
    return const _Theme(Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('data') || c == 'data science')
    return const _Theme(Icons.analytics, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (c == 'app dev' || t.contains('android') || t.contains('flutter'))
    return const _Theme(
      Icons.phone_android,
      Color(0xFF0284C7),
      Color(0xFF38BDF8),
    );
  if (c == 'cybersecurity' || t.contains('cyber'))
    return const _Theme(Icons.gpp_good, Color(0xFFB91C1C), Color(0xFFDC2626));
  return const _Theme(Icons.menu_book, Color(0xFF1D4ED8), Color(0xFF6366F1));
}

_Theme _companyTheme(String name) {
  final n = name.toLowerCase();
  if (n.contains('infosys'))
    return const _Theme(Icons.business, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (n.contains('wipro'))
    return const _Theme(
      Icons.account_tree,
      Color(0xFF059669),
      Color(0xFF10B981),
    );
  if (n.contains('tcs'))
    return const _Theme(
      Icons.corporate_fare,
      Color(0xFF0369A1),
      Color(0xFF0EA5E9),
    );
  if (n.contains('google'))
    return const _Theme(Icons.search, Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (n.contains('microsoft'))
    return const _Theme(Icons.window, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (n.contains('amazon'))
    return const _Theme(Icons.cloud, Color(0xFFD97706), Color(0xFFF59E0B));
  if (n.contains('flipkart'))
    return const _Theme(
      Icons.shopping_bag,
      Color(0xFFD97706),
      Color(0xFFF59E0B),
    );
  return const _Theme(Icons.domain, Color(0xFF374151), Color(0xFF6B7280));
}

_Theme _hackathonTheme(String title) {
  final t = title.toLowerCase();
  if (t.contains('smart india') || t.contains('sih'))
    return const _Theme(
      Icons.account_balance,
      Color(0xFF0369A1),
      Color(0xFF0EA5E9),
    );
  if (t.contains('infos') || t.contains('infy'))
    return const _Theme(Icons.business, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  return const _Theme(Icons.emoji_events, Color(0xFFD97706), Color(0xFFF59E0B));
}

Widget _tile(IconData icon, Color g1, Color g2, double size) {
  return Container(
    width: size,
    height: size,
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
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: size * 0.46),
  );
}

class _LevelStyle {
  final Color bg, fg;
  const _LevelStyle(this.bg, this.fg);
}

_LevelStyle _levelStyle(String level) {
  switch (level) {
    case 'Beginner':
      return const _LevelStyle(Color(0xFFF0FDF4), Color(0xFF15803D));
    case 'Intermediate':
      return const _LevelStyle(Color(0xFFFFFBEB), Color(0xFFB45309));
    case 'Advanced':
      return const _LevelStyle(Color(0xFFFFF1F2), Color(0xFFBE123C));
    default:
      return const _LevelStyle(Color(0xFFF1F5F9), Color(0xFF475569));
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
  late AnimationController _headerAnim;
  late AnimationController _xpAnim;
  late Animation<double> _xpValue;
  late List<AnimationController> _sectionAnims;
  late List<Animation<double>> _sectionFade;
  late List<Animation<Offset>> _sectionSlide;

  final Set<String> _savedJobs = {};

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _xpAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _xpValue = Tween<double>(
      begin: 0,
      end: 0.72,
    ).animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));
    _sectionAnims = List.generate(
      8,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );
    _sectionFade = _sectionAnims
        .map(
          (c) =>
              CurvedAnimation(parent: c, curve: Curves.easeOut)
                  as Animation<double>,
        )
        .toList();
    _sectionSlide = _sectionAnims
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.10),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
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
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(sw),
          _buildSearchBar(sw),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                sw * 0.040,
                sw * 0.040,
                sw * 0.040,
                sw * 0.080,
              ),
              children: [
                _fs(0, _buildStatsRow(sw)),
                SizedBox(height: sw * 0.040),
                _fs(1, _buildProfileStrength(sw)),
                SizedBox(height: sw * 0.055),
                _fs(2, _buildQuickActions(context, sw)),
                SizedBox(height: sw * 0.060),
                _fs(
                  3,
                  _sectionHeader(
                    'Recommended for You',
                    sub: 'Based on your profile & skills',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(3, _buildRecommendedJobs(sw)),
                SizedBox(height: sw * 0.060),
                _fs(
                  4,
                  _sectionHeader(
                    'Trending Courses',
                    sub: 'Boost your profile score',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(4, _buildTrendingCourses(sw)),
                SizedBox(height: sw * 0.060),
                _fs(
                  5,
                  _sectionHeader(
                    'Hackathons',
                    sub: 'Compete & win prizes',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(5, _buildHackathons(sw)),
                SizedBox(height: sw * 0.060),
                _fs(
                  6,
                  _sectionHeader(
                    'Companies Near You',
                    sub: 'Hiring actively in your area',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(6, _buildNearbyCompanies(sw)),
                SizedBox(height: sw * 0.060),
                _fs(7, _buildMotivationBanner(sw)),
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
  Widget _buildHeader(double sw) {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
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
            padding: EdgeInsets.fromLTRB(
              sw * 0.05,
              sw * 0.035,
              sw * 0.05,
              sw * 0.05,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: sw * 0.125,
                      height: sw * 0.125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [kPrimary, kAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.40),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1B4B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              fontSize: sw * 0.050,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.035),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hey, Arjun ',
                                style: TextStyle(
                                  fontSize: sw * 0.050,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                '👋',
                                style: TextStyle(fontSize: sw * 0.045),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.005),
                          Row(
                            children: [
                              Container(
                                width: sw * 0.018,
                                height: sw * 0.018,
                                decoration: const BoxDecoration(
                                  color: kAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: sw * 0.013),
                              Text(
                                '3 new job matches today',
                                style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: Colors.white.withValues(alpha: 0.70),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationPage(notifications: []),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: sw * 0.10,
                            height: sw * 0.10,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: sw * 0.050,
                            ),
                          ),
                          Positioned(
                            top: sw * 0.022,
                            right: sw * 0.022,
                            child: Container(
                              width: sw * 0.020,
                              height: sw * 0.020,
                              decoration: BoxDecoration(
                                color: kAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1E1B4B),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: sw * 0.040),
                // Progress ticker
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.035,
                    vertical: sw * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: sw * 0.085,
                        height: sw * 0.085,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimary, kAccent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: sw * 0.040,
                        ),
                      ),
                      SizedBox(width: sw * 0.030),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile at 72% — almost there!',
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Add GitHub + 2 certs to unlock Premium Badge',
                              style: TextStyle(
                                fontSize: sw * 0.025,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.020,
                          vertical: sw * 0.010,
                        ),
                        decoration: BoxDecoration(
                          color: kAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '72%',
                          style: TextStyle(
                            fontSize: sw * 0.030,
                            fontWeight: FontWeight.w800,
                            color: kAccent,
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
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────
  Widget _buildSearchBar(double sw) {
    return Container(
      color: kCardBg,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.040,
        vertical: sw * 0.030,
      ),
      child: TextField(
        style: TextStyle(
          fontSize: sw * 0.035,
          fontWeight: FontWeight.w600,
          color: kInk,
        ),
        decoration: InputDecoration(
          hintText: 'Search jobs, courses, companies…',
          hintStyle: TextStyle(fontSize: sw * 0.033, color: kHint),
          prefixIcon: Icon(Icons.search, color: kMuted, size: sw * 0.050),
          suffixIcon: Container(
            margin: EdgeInsets.all(sw * 0.020),
            padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune, color: kPrimary, size: sw * 0.045),
          ),
          filled: true,
          fillColor: kBgPage,
          contentPadding: EdgeInsets.symmetric(
            horizontal: sw * 0.040,
            vertical: sw * 0.033,
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

  // ─────────────────────────────────────────
  //  STATS ROW
  // ─────────────────────────────────────────
  Widget _buildStatsRow(double sw) {
    return Row(
      children: List.generate(_stats.length, (i) {
        final s = _stats[i];
        final color = s['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? sw * 0.025 : 0),
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.025,
              vertical: sw * 0.035,
            ),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: sw * 0.085,
                  height: sw * 0.085,
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
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    s['icon'] as IconData,
                    size: sw * 0.040,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: sw * 0.025),
                Text(
                  s['value'] as String,
                  style: TextStyle(
                    fontSize: sw * 0.050,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: sw * 0.003),
                Text(
                  s['label'] as String,
                  style: TextStyle(
                    fontSize: sw * 0.025,
                    color: kMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
  Widget _buildProfileStrength(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.050),
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
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.105,
                height: sw * 0.105,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: sw * 0.050,
                ),
              ),
              SizedBox(width: sw * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Strength',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      'Add certifications to reach 90%',
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _xpValue,
                builder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(_xpValue.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: sw * 0.070,
                        fontWeight: FontWeight.w800,
                        color: kAccent,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: sw * 0.023,
                        color: kHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.040),
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
          SizedBox(height: sw * 0.035),
          Row(
            children: [
              _profileChip(Icons.workspace_premium, 'Add Certs', false, sw),
              SizedBox(width: sw * 0.020),
              _profileChip(Icons.code, 'Link GitHub', false, sw),
              SizedBox(width: sw * 0.020),
              _profileChip(Icons.check_circle, 'Skills Added', true, sw),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileChip(IconData icon, String label, bool done, double sw) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: sw * 0.020,
          horizontal: sw * 0.020,
        ),
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
            Icon(icon, size: sw * 0.030, color: done ? kSuccess : kHint),
            SizedBox(width: sw * 0.013),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sw * 0.023,
                  fontWeight: FontWeight.w700,
                  color: done ? kSuccess : kHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  QUICK ACTIONS
  // ─────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, double sw) {
    final actions = [
      {
        'icon': Icons.work_outline,
        'label': 'Jobs',
        'g1': const Color(0xFF1D4ED8),
        'g2': const Color(0xFF3B82F6),
        'route': '/jobs',
      },
      {
        'icon': Icons.school,
        'label': 'Internships',
        'g1': const Color(0xFF7C3AED),
        'g2': const Color(0xFFA855F7),
        'route': '/internships',
      },
      {
        'icon': Icons.business,
        'label': 'Companies',
        'g1': const Color(0xFF0369A1),
        'g2': const Color(0xFF0EA5E9),
        'route': '/companies',
      },
      {
        'icon': Icons.emoji_events,
        'label': 'Hackathons',
        'g1': const Color(0xFFD97706),
        'g2': const Color(0xFFF59E0B),
        'route': '/hackathons',
      },
      {
        'icon': Icons.menu_book,
        'label': 'Courses',
        'g1': const Color(0xFF059669),
        'g2': const Color(0xFF10B981),
        'route': '/courses',
      },
      {
        'icon': Icons.person,
        'label': 'Profile',
        'g1': const Color(0xFFEC4899),
        'g2': const Color(0xFFF43F5E),
        'route': '/profile',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Access', sub: 'Jump to any section', sw: sw),
        SizedBox(height: sw * 0.030),
        Row(
          children: List.generate(actions.length, (i) {
            final a = actions[i];
            final g1 = a['g1'] as Color;
            final g2 = a['g2'] as Color;
            final icon = a['icon'] as IconData;
            final label = a['label'] as String;
            final route = a['route'] as String;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go(route);
                },
                child: Container(
                  margin: EdgeInsets.only(right: i < 5 ? sw * 0.020 : 0),
                  child: Column(
                    children: [
                      Container(
                        width: sw * 0.125,
                        height: sw * 0.125,
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
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: sw * 0.055,
                        ),
                      ),
                      SizedBox(height: sw * 0.015),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: sw * 0.025,
                          fontWeight: FontWeight.w700,
                          color: kSlate,
                        ),
                      ),
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
  Widget _buildRecommendedJobs(double sw) {
    return Column(
      children: List.generate(_recommendedJobs.length, (i) {
        final job = _recommendedJobs[i];
        final title = job['title'] as String;
        final company = job['company'] as String;
        final location = job['location'] as String;
        final salary = job['salary'] as String;
        final matchStr = job['match'] as String;
        final type = job['type'] as String;
        final tags = job['tags'] as List<String>;
        final theme = _jobTheme(title, company);
        final match = int.tryParse(matchStr) ?? 0;
        final isIntern = type == 'Internship';
        final saved = _savedJobs.contains(title);
        final matchColor = match >= 90
            ? kSuccess
            : match >= 80
            ? kWarning
            : kMuted;
        final matchBg = match >= 90
            ? const Color(0xFFF0FDF4)
            : match >= 80
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF1F5F9);

        return GestureDetector(
          onTap: () => _showJobDetail(job, sw),
          child: Container(
            margin: EdgeInsets.only(bottom: sw * 0.030),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(sw * 0.040),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tile(
                            theme.icon,
                            theme.grad1,
                            theme.grad2,
                            sw * 0.125,
                          ),
                          SizedBox(width: sw * 0.030),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w800,
                                    color: kInk,
                                  ),
                                ),
                                SizedBox(height: sw * 0.005),
                                Text(
                                  company,
                                  style: TextStyle(
                                    fontSize: sw * 0.030,
                                    color: kMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: sw * 0.013),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: sw * 0.030,
                                      color: kHint,
                                    ),
                                    SizedBox(width: sw * 0.008),
                                    Text(
                                      location,
                                      style: TextStyle(
                                        fontSize: sw * 0.030,
                                        color: kMuted,
                                      ),
                                    ),
                                    SizedBox(width: sw * 0.020),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: sw * 0.020,
                                        vertical: sw * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isIntern
                                            ? const Color(0xFFFFFBEB)
                                            : kSelectedBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: sw * 0.025,
                                          fontWeight: FontWeight.w700,
                                          color: isIntern ? kWarning : kPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Bookmark
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (saved)
                                  _savedJobs.remove(title);
                                else
                                  _savedJobs.add(title);
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: sw * 0.085,
                              height: sw * 0.085,
                              decoration: BoxDecoration(
                                color: saved ? kSelectedBg : kBgPage,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: saved ? kPrimary : kBorder,
                                ),
                              ),
                              child: Icon(
                                saved ? Icons.bookmark : Icons.bookmark_border,
                                size: sw * 0.043,
                                color: saved ? kPrimary : kHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: sw * 0.030),
                        height: 1,
                        color: const Color(0xFFF1F5F9),
                      ),
                      Row(
                        children: [
                          ...tags.map(
                            (t) => Container(
                              margin: EdgeInsets.only(right: sw * 0.015),
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.023,
                                vertical: sw * 0.010,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.grad1.withValues(alpha: 0.09),
                                    theme.grad2.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.grad1.withValues(alpha: 0.20),
                                ),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: sw * 0.028,
                                  fontWeight: FontWeight.w700,
                                  color: theme.grad1,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            salary,
                            style: TextStyle(
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w800,
                              color: kInk,
                            ),
                          ),
                          SizedBox(width: sw * 0.020),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.023,
                              vertical: sw * 0.013,
                            ),
                            decoration: BoxDecoration(
                              color: matchBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: sw * 0.025,
                                  color: matchColor,
                                ),
                                SizedBox(width: sw * 0.008),
                                Text(
                                  '$match%',
                                  style: TextStyle(
                                    fontSize: sw * 0.028,
                                    fontWeight: FontWeight.w800,
                                    color: matchColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.020),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: sw * 0.028,
                            color: kHint.withValues(alpha: 0.70),
                          ),
                          SizedBox(width: sw * 0.010),
                          Text(
                            'Tap to view full details & apply',
                            style: TextStyle(
                              fontSize: sw * 0.025,
                              color: kHint.withValues(alpha: 0.70),
                              fontStyle: FontStyle.italic,
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
      }),
    );
  }

  // Job detail bottom sheet
  void _showJobDetail(Map<String, dynamic> job, double sw) {
    final title = job['title'] as String;
    final company = job['company'] as String;
    final location = job['location'] as String;
    final salary = job['salary'] as String;
    final matchStr = job['match'] as String;
    final type = job['type'] as String;
    final exp = job['exp'] as String;
    final desc = job['desc'] as String;
    final tags = job['tags'] as List<String>;
    final theme = _jobTheme(title, company);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: ctrl,
            padding: EdgeInsets.fromLTRB(sw * 0.05, 0, sw * 0.05, sw * 0.08),
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: sw * 0.030),
                  width: sw * 0.10,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.14),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: sw * 0.008),
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: sw * 0.020),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: sw * 0.033,
                              color: kHint,
                            ),
                            SizedBox(width: sw * 0.010),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                color: kMuted,
                              ),
                            ),
                            SizedBox(width: sw * 0.025),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.020,
                                vertical: sw * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: kSelectedBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: sw * 0.025,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimary,
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
              SizedBox(height: sw * 0.050),
              // Stats bar
              Container(
                padding: EdgeInsets.all(sw * 0.040),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.08),
                      theme.grad2.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.grad1.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    _detailStat(Icons.currency_rupee, salary, 'Salary', sw),
                    _vDiv(),
                    _detailStat(Icons.school, exp, 'Experience', sw),
                    _vDiv(),
                    _detailStat(Icons.access_time, 'Recently', 'Posted', sw),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.050),
              // AI Match bar
              Container(
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: sw * 0.040, color: kWarning),
                    SizedBox(width: sw * 0.020),
                    Text(
                      'AI Match',
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$matchStr%',
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w800,
                        color: kSuccess,
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (int.tryParse(matchStr) ?? 0) / 100,
                          minHeight: 8,
                          backgroundColor: kBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            kSuccess,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.050),
              Text(
                'Required Skills',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.025),
              Wrap(
                spacing: sw * 0.020,
                runSpacing: sw * 0.020,
                children: tags
                    .map(
                      (t) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.030,
                          vertical: sw * 0.015,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.grad1.withValues(alpha: 0.10),
                              theme.grad2.withValues(alpha: 0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.grad1.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: sw * 0.030,
                            fontWeight: FontWeight.w700,
                            color: theme.grad1,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: sw * 0.050),
              Text(
                'About the Role',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.025),
              Container(
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Text(
                  desc,
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    color: kSlate,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: sw * 0.060),
              // Apply CTA
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  context.go('/jobs');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.038),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: sw * 0.040),
                      SizedBox(width: sw * 0.020),
                      Text(
                        'Apply for this Role',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: sw * 0.038,
                        ),
                      ),
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

  Widget _detailStat(IconData icon, String value, String label, double sw) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: sw * 0.040, color: kPrimary),
          SizedBox(height: sw * 0.013),
          Text(
            value,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w800,
              color: kInk,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: sw * 0.025, color: kMuted),
          ),
        ],
      ),
    );
  }

  Widget _vDiv() => Container(width: 1, height: 36, color: kBorder);

  // ─────────────────────────────────────────
  //  TRENDING COURSES
  // ─────────────────────────────────────────
  Widget _buildTrendingCourses(double sw) {
    return SizedBox(
      height: sw * 0.40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingCourses.length,
        itemBuilder: (_, i) {
          final course = _trendingCourses[i];
          final ctitle = course['title'] as String;
          final category = course['category'] as String;
          final level = course['level'] as String;
          final rating = course['rating'] as String;
          final duration = course['duration'] as String;
          final theme = _courseTheme(ctitle, category);
          final ls = _levelStyle(level);

          return GestureDetector(
            onTap: () => context.go('/courses'),
            child: Container(
              width: sw * 0.50,
              margin: EdgeInsets.only(
                right: i < _trendingCourses.length - 1 ? sw * 0.030 : 0,
              ),
              padding: EdgeInsets.all(sw * 0.035),
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
                      _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.10),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.018,
                          vertical: sw * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: ls.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: sw * 0.023,
                            fontWeight: FontWeight.w700,
                            color: ls.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.025),
                  Text(
                    ctitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: sw * 0.028, color: kWarning),
                      SizedBox(width: sw * 0.008),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w700,
                          color: kMuted,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule, size: sw * 0.028, color: kHint),
                      SizedBox(width: sw * 0.008),
                      Text(
                        duration,
                        style: TextStyle(fontSize: sw * 0.025, color: kHint),
                      ),
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
  Widget _buildHackathons(double sw) {
    return Column(
      children: _hackathons.map((h) {
        final htitle = h['title'] as String;
        final org = h['org'] as String;
        final prize = h['prize'] as String;
        final date = h['date'] as String;
        final mode = h['mode'] as String;
        final theme = _hackathonTheme(htitle);
        final online = mode == 'Online';

        return GestureDetector(
          onTap: () => context.go('/hackathons'),
          child: Container(
            margin: EdgeInsets.only(bottom: sw * 0.025),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(sw * 0.035),
                  child: Row(
                    children: [
                      _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.115),
                      SizedBox(width: sw * 0.030),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              htitle,
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w800,
                                color: kInk,
                              ),
                            ),
                            SizedBox(height: sw * 0.005),
                            Text(
                              org,
                              style: TextStyle(
                                fontSize: sw * 0.028,
                                color: kMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: sw * 0.015),
                            Row(
                              children: [
                                _smallChip(Icons.calendar_today, date, sw),
                                SizedBox(width: sw * 0.015),
                                _smallChip(
                                  Icons.emoji_events,
                                  prize,
                                  sw,
                                  iconColor: kWarning,
                                ),
                                SizedBox(width: sw * 0.015),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.020,
                                    vertical: sw * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: online
                                        ? kSelectedBg
                                        : const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    mode,
                                    style: TextStyle(
                                      fontSize: sw * 0.023,
                                      fontWeight: FontWeight.w700,
                                      color: online ? kPrimary : kSuccess,
                                    ),
                                  ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.030,
                            vertical: sw * 0.020,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.grad1, theme.grad2],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.grad1.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
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
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  NEARBY COMPANIES
  // ─────────────────────────────────────────
  Widget _buildNearbyCompanies(double sw) {
    return Column(
      children: _nearbyCompanies.map((c) {
        final cname = c['name'] as String;
        final city = c['city'] as String;
        final distance = c['distance'] as String;
        final openings = c['openings'] as String;
        final domain = c['domain'] as String;
        final theme = _companyTheme(cname);

        return GestureDetector(
          onTap: () => context.go('/companies'),
          child: Container(
            margin: EdgeInsets.only(bottom: sw * 0.025),
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.040,
              vertical: sw * 0.035,
            ),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Row(
              children: [
                _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.115),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cname,
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                        ),
                      ),
                      SizedBox(height: sw * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: sw * 0.028,
                            color: kHint,
                          ),
                          SizedBox(width: sw * 0.008),
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: kMuted,
                            ),
                          ),
                          SizedBox(width: sw * 0.015),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: kHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: sw * 0.015),
                          Icon(Icons.near_me, size: sw * 0.028, color: kHint),
                          SizedBox(width: sw * 0.008),
                          Text(
                            distance,
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: kMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.008),
                      Text(
                        domain,
                        style: TextStyle(
                          fontSize: sw * 0.025,
                          color: kHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.030,
                    vertical: sw * 0.020,
                  ),
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
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$openings open',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
  //  MOTIVATION BANNER
  // ─────────────────────────────────────────
  Widget _buildMotivationBanner(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.12,
            height: sw * 0.12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kWarning.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: sw * 0.060,
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're in the top 15%!",
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                SizedBox(height: sw * 0.008),
                Text(
                  'Your profile is viewed 3× more than average.',
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    color: kMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.020),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.030,
              vertical: sw * 0.020,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              '🔥 Top',
              style: TextStyle(
                fontSize: sw * 0.028,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────
  Widget _sectionHeader(String title, {String? sub, required double sw}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  letterSpacing: -0.2,
                ),
              ),
              if (sub != null)
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _smallChip(
    IconData icon,
    String label,
    double sw, {
    Color iconColor = kMuted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.018,
        vertical: sw * 0.008,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.025, color: iconColor),
          SizedBox(width: sw * 0.008),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.025,
              fontWeight: FontWeight.w700,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
