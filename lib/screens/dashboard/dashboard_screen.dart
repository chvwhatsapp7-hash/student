import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../profile/profile_screen.dart';

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
//  STATIC DATA (stats, hackathons, companies — unchanged)
// ─────────────────────────────────────────────
const stats = [
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
    'value': '72',
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

const nearbyCompanies = [
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

const hackathons = [
  {
    'title': 'Smart India Hackathon',
    'org': 'MoE, Govt of India',
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
//  SHARED ICON SYSTEM — unchanged
// ─────────────────────────────────────────────
class _Theme {
  final IconData icon;
  final Color grad1, grad2;
  const _Theme(this.icon, this.grad1, this.grad2);
}

_Theme jobTheme(String title, String company) {
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

_Theme courseTheme(String title, String category) {
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

_Theme companyTheme(String name) {
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

_Theme hackathonTheme(String title) {
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

Widget tile(IconData icon, Color g1, Color g2, double size) => Container(
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

class _LevelStyle {
  final Color bg, fg;
  const _LevelStyle(this.bg, this.fg);
}

_LevelStyle levelStyle(String level) {
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
  // ── Animations ─────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _xpAnim;
  late Animation<double> _xpValue;
  late List<AnimationController> _sectionAnims;
  late List<Animation<double>> _sectionFade;
  late List<Animation<Offset>> _sectionSlide;
  late final VoidCallback _profileListener;

  // ── State ──────────────────────────────────
  final Set<String> _savedJobs = {};
  String _fullName = '';
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'https://studenthub-backend-woad.vercel.app';

  // ── API data (replaces static recommendedJobs & trendingCourses) ──
  List<Map<String, dynamic>> _apiJobs = [];
  List<Map<String, dynamic>> _apiInternships = [];
  List<Map<String, dynamic>> _apiCourses = [];
  bool _recLoading = true;
  String? _recError;

  @override
  void initState() {
    super.initState();
    _loadName();
    profileState.fetchProfile();
    _fetchRecommendations(); // ← API call

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
      end: profileState.strength,
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

    _profileListener = () {
      if (!mounted) return;
      _xpAnim.reset();
      _xpValue = Tween<double>(
        begin: 0,
        end: profileState.strength,
      ).animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));
      _xpAnim.forward();
      setState(() {});
    };
    profileState.addListener(_profileListener);
  }

  // ── FETCH RECOMMENDATIONS FROM API ─────────
  Future<void> _fetchRecommendations() async {
    setState(() {
      _recLoading = true;
      _recError = null;
    });
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) throw Exception('Not logged in');

      final res = await http.get(
        Uri.parse('$_baseUrl/api/profile/recommendations?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        if (mounted) {
          setState(() {
            _apiJobs = List<Map<String, dynamic>>.from(data['jobs'] ?? []);
            _apiInternships = List<Map<String, dynamic>>.from(
              data['internships'] ?? [],
            );
            _apiCourses = List<Map<String, dynamic>>.from(
              data['courses'] ?? [],
            );
            _recLoading = false;
          });
        }
      } else {
        throw Exception(body['message'] ?? 'Failed to load recommendations');
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _recLoading = false;
          _recError = e.toString();
        });
    }
  }

  Future<void> _loadName() async {
    final name = await _storage.read(key: 'full_name');
    if (mounted) setState(() => _fullName = name ?? '');
  }

  @override
  void dispose() {
    profileState.removeListener(_profileListener);
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _sectionAnims) c.dispose();
    super.dispose();
  }

  Widget _fs(int i, Widget child) => FadeTransition(
    opacity: _sectionFade[i],
    child: SlideTransition(position: _sectionSlide[i], child: child),
  );

  // ── BUILD ──────────────────────────────────
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

                // ── Recommended Jobs (from API) ──
                _fs(
                  3,
                  sectionHeader(
                    'Recommended Jobs',
                    sub: 'Matched to your skills',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(3, _buildApiJobs(sw)),
                SizedBox(height: sw * 0.060),

                // ── Recommended Internships (from API) ──
                _fs(
                  3,
                  sectionHeader(
                    'Recommended Internships',
                    sub: 'Best matches for you',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(3, _buildApiInternships(sw)),
                SizedBox(height: sw * 0.060),

                // ── Trending Courses (from API) ──
                _fs(
                  4,
                  sectionHeader(
                    'Recommended Courses',
                    sub: 'Fill your skill gaps',
                    sw: sw,
                  ),
                ),
                SizedBox(height: sw * 0.030),
                _fs(4, _buildApiCourses(sw)),
                SizedBox(height: sw * 0.060),

                _fs(
                  5,
                  sectionHeader(
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
                  sectionHeader(
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

  // ── HEADER ─────────────────────────────────
  Widget _buildHeader(double sw) {
    final displayName = _fullName.isNotEmpty ? _fullName : 'there';
    final avatarLetter = _fullName.isNotEmpty
        ? _fullName[0].toUpperCase()
        : '?';
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
                            avatarLetter,
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
                                'Hey, $displayName ',
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
                                '${_apiJobs.length + _apiInternships.length} matches found for you',
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
                    Stack(
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
                  ],
                ),
                SizedBox(height: sw * 0.040),
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
                              'Profile at ${(profileState.strength * 100).toInt()}% — almost there!',
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              profileState.strengthHint,
                              style: TextStyle(
                                fontSize: sw * 0.025,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                          '${(profileState.strength * 100).toInt()}%',
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

  // ── SEARCH BAR ─────────────────────────────
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

  // ── STATS ROW ──────────────────────────────
  Widget _buildStatsRow(double sw) {
    return Row(
      children: List.generate(stats.length, (i) {
        final s = stats[i];
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

  // ── PROFILE STRENGTH ───────────────────────
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
                      profileState.strengthHint,
                      style: TextStyle(
                        fontSize: sw * 0.026,
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              _profileChip(
                Icons.workspace_premium,
                'Add Certs',
                profileState.certifications.isNotEmpty,
                sw,
              ),
              SizedBox(width: sw * 0.020),
              _profileChip(
                Icons.code,
                'Link GitHub',
                profileState.github.isNotEmpty,
                sw,
              ),
              SizedBox(width: sw * 0.020),
              _profileChip(
                Icons.check_circle,
                'Skills Added',
                profileState.skills.length >= 3,
                sw,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileChip(IconData icon, String label, bool done, double sw) =>
      Expanded(
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

  // ── QUICK ACTIONS ──────────────────────────
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
        sectionHeader('Quick Access', sub: 'Jump to any section', sw: sw),
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

  // ─────────────────────────────────────────────
  //  API-DRIVEN SECTIONS
  // ─────────────────────────────────────────────

  // ── Loading / Error / Empty helpers ────────
  Widget _loadingCard(double sw) => Container(
    padding: EdgeInsets.all(sw * 0.060),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: const Center(
      child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
    ),
  );

  Widget _errorCard(double sw) => Container(
    padding: EdgeInsets.all(sw * 0.040),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFCA5A5)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
        SizedBox(width: sw * 0.020),
        Expanded(
          child: Text(
            'Could not load recommendations. Tap to retry.',
            style: TextStyle(
              fontSize: sw * 0.030,
              color: const Color(0xFFDC2626),
            ),
          ),
        ),
        GestureDetector(
          onTap: _fetchRecommendations,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.025,
              vertical: sw * 0.015,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: sw * 0.028,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _emptyCard(String msg, double sw) => Container(
    padding: EdgeInsets.all(sw * 0.050),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorder),
    ),
    child: Center(
      child: Text(
        msg,
        style: TextStyle(fontSize: sw * 0.033, color: kMuted),
      ),
    ),
  );

  // ── API JOBS ───────────────────────────────
  Widget _buildApiJobs(double sw) {
    if (_recLoading) return _loadingCard(sw);
    if (_recError != null) return _errorCard(sw);
    if (_apiJobs.isEmpty)
      return _emptyCard('No matching jobs found yet. Add more skills!', sw);

    return Column(
      children: _apiJobs.take(4).map((job) {
        final title = job['title'] as String? ?? '';
        final company = job['company_name'] as String? ?? '';
        final location = job['location'] as String? ?? '';
        final salaryMin = job['salary_min'];
        final salaryMax = job['salary_max'];
        final jobType = job['job_type'] as String? ?? 'Full Time';
        final matchPct = job['match_percentage'] as int? ?? 0;
        final matchedSk = List<String>.from(job['matched_skills'] ?? []);
        final requiredSk = List<String>.from(job['required_skills'] ?? []);
        final applyUrl = job['apply_url'] as String?;
        final salary = (salaryMin != null && salaryMax != null)
            ? '₹$salaryMin–$salaryMax'
            : salaryMin != null
            ? '₹$salaryMin+'
            : 'Not disclosed';
        final theme = jobTheme(title, company);
        final saved = _savedJobs.contains(title);
        final matchColor = matchPct >= 90
            ? kSuccess
            : matchPct >= 70
            ? kWarning
            : kMuted;
        final matchBg = matchPct >= 90
            ? const Color(0xFFF0FDF4)
            : matchPct >= 70
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF1F5F9);

        return Container(
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
                        tile(theme.icon, theme.grad1, theme.grad2, sw * 0.125),
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
                                      color: kSelectedBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      jobType,
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
                    // Match bar
                    SizedBox(height: sw * 0.025),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: sw * 0.028,
                          color: matchColor,
                        ),
                        SizedBox(width: sw * 0.010),
                        Text(
                          '$matchPct% match',
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w700,
                            color: matchColor,
                          ),
                        ),
                        SizedBox(width: sw * 0.015),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: matchPct / 100,
                              minHeight: 6,
                              backgroundColor: kBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                matchColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          salary,
                          style: TextStyle(
                            fontSize: sw * 0.030,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ],
                    ),
                    // Matched skills chips
                    if (matchedSk.isNotEmpty) ...[
                      SizedBox(height: sw * 0.020),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: sw * 0.015,
                          runSpacing: sw * 0.010,
                          children: matchedSk
                              .take(4)
                              .map(
                                (s) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.020,
                                    vertical: sw * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kSuccess.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: kSuccess.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: sw * 0.025,
                                      fontWeight: FontWeight.w700,
                                      color: kSuccess,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    SizedBox(height: sw * 0.020),
                    GestureDetector(
                      onTap: () => _showJobDetailFromApi(job, sw),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.028),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.grad1, theme.grad2],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                              size: sw * 0.038,
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              'View & Apply',
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
        );
      }).toList(),
    );
  }

  // ── API INTERNSHIPS ────────────────────────
  Widget _buildApiInternships(double sw) {
    if (_recLoading) return _loadingCard(sw);
    if (_recError != null) return _errorCard(sw);
    if (_apiInternships.isEmpty)
      return _emptyCard('No matching internships found yet.', sw);

    return Column(
      children: _apiInternships.take(4).map((intern) {
        final title = intern['title'] as String? ?? '';
        final company = intern['company_name'] as String? ?? '';
        final location = intern['location'] as String? ?? '';
        final stipend = intern['stipend'];
        final duration = intern['duration'] as String? ?? '';
        final type = intern['internship_type'] as String? ?? 'Internship';
        final matchPct = intern['match_percentage'] as int? ?? 0;
        final matchedSk = List<String>.from(intern['matched_skills'] ?? []);
        final stipendStr = stipend != null ? '₹$stipend/month' : 'Unpaid';
        final theme = jobTheme(title, company);
        final matchColor = matchPct >= 90
            ? kSuccess
            : matchPct >= 70
            ? kWarning
            : kMuted;

        return Container(
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
                        tile(theme.icon, theme.grad1, theme.grad2, sw * 0.125),
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
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: TextStyle(
                                        fontSize: sw * 0.030,
                                        color: kMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.020,
                                vertical: sw * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: sw * 0.025,
                                  fontWeight: FontWeight.w700,
                                  color: kWarning,
                                ),
                              ),
                            ),
                            SizedBox(height: sw * 0.010),
                            if (duration.isNotEmpty)
                              Text(
                                duration,
                                style: TextStyle(
                                  fontSize: sw * 0.025,
                                  color: kHint,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.025),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: sw * 0.028,
                          color: matchColor,
                        ),
                        SizedBox(width: sw * 0.010),
                        Text(
                          '$matchPct% match',
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w700,
                            color: matchColor,
                          ),
                        ),
                        SizedBox(width: sw * 0.015),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: matchPct / 100,
                              minHeight: 6,
                              backgroundColor: kBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                matchColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          stipendStr,
                          style: TextStyle(
                            fontSize: sw * 0.030,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ],
                    ),
                    if (matchedSk.isNotEmpty) ...[
                      SizedBox(height: sw * 0.020),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: sw * 0.015,
                          runSpacing: sw * 0.010,
                          children: matchedSk
                              .take(4)
                              .map(
                                (s) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.020,
                                    vertical: sw * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kSuccess.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: kSuccess.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: sw * 0.025,
                                      fontWeight: FontWeight.w700,
                                      color: kSuccess,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    SizedBox(height: sw * 0.020),
                    GestureDetector(
                      onTap: () => context.push('/internships'),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.028),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.grad1, theme.grad2],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                              size: sw * 0.038,
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              'View & Apply',
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
        );
      }).toList(),
    );
  }

  // ── API COURSES ────────────────────────────
  Widget _buildApiCourses(double sw) {
    if (_recLoading) return _loadingCard(sw);
    if (_recError != null) return _errorCard(sw);
    if (_apiCourses.isEmpty)
      return _emptyCard('No course recommendations yet.', sw);

    return SizedBox(
      height: sw * 0.52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _apiCourses.take(4).length,
        itemBuilder: (_, i) {
          final course = _apiCourses[i];
          final ctitle = course['title'] as String? ?? '';
          final provider = course['provider'] as String? ?? '';
          final category = course['category'] as String? ?? '';
          final clevel = course['level'] as String? ?? 'Beginner';
          final duration = course['duration'] as String? ?? '';
          final rating = course['rating'];
          final gapFill = course['gap_fill_count'] as int? ?? 0;
          final missing = List<String>.from(course['missing_skills'] ?? []);
          final theme = courseTheme(ctitle, category);
          final ls = levelStyle(clevel);
          final ratingStr = rating != null ? rating.toStringAsFixed(1) : '—';

          return GestureDetector(
            onTap: () => context.push('/courses'),
            child: Container(
              width: sw * 0.60,
              margin: EdgeInsets.only(
                right: i < _apiCourses.length - 1 ? sw * 0.030 : 0,
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
                      tile(theme.icon, theme.grad1, theme.grad2, sw * 0.10),
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
                          clevel,
                          style: TextStyle(
                            fontSize: sw * 0.023,
                            fontWeight: FontWeight.w700,
                            color: ls.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.020),
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
                  if (provider.isNotEmpty) ...[
                    SizedBox(height: sw * 0.005),
                    Text(
                      provider,
                      style: TextStyle(fontSize: sw * 0.025, color: kMuted),
                    ),
                  ],
                  SizedBox(height: sw * 0.015),
                  // Gap fill badge
                  if (gapFill > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.018,
                        vertical: sw * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kPrimary.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Text(
                        '+$gapFill new skills',
                        style: TextStyle(
                          fontSize: sw * 0.025,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  if (missing.isNotEmpty) ...[
                    SizedBox(height: sw * 0.010),
                    Wrap(
                      spacing: sw * 0.010,
                      runSpacing: sw * 0.008,
                      children: missing
                          .take(3)
                          .map(
                            (s) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.015,
                                vertical: sw * 0.006,
                              ),
                              decoration: BoxDecoration(
                                color: kWarning.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: sw * 0.022,
                                  color: kWarning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: sw * 0.028, color: kWarning),
                      SizedBox(width: sw * 0.008),
                      Text(
                        ratingStr,
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w700,
                          color: kMuted,
                        ),
                      ),
                      const Spacer(),
                      if (duration.isNotEmpty) ...[
                        Icon(Icons.schedule, size: sw * 0.028, color: kHint),
                        SizedBox(width: sw * 0.008),
                        Text(
                          duration,
                          style: TextStyle(fontSize: sw * 0.025, color: kHint),
                        ),
                      ],
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

  // ── JOB DETAIL (API version) ───────────────
  void _showJobDetailFromApi(Map<String, dynamic> job, double sw) {
    final title = job['title'] as String? ?? '';
    final company = job['company_name'] as String? ?? '';
    final location = job['location'] as String? ?? '';
    final jobType = job['job_type'] as String? ?? '';
    final salaryMin = job['salary_min'];
    final salaryMax = job['salary_max'];
    final expLevel = job['experience_level'] as String? ?? 'Any';
    final matchPct = job['match_percentage'] as int? ?? 0;
    final matchedSk = List<String>.from(job['matched_skills'] ?? []);
    final requiredSk = List<String>.from(job['required_skills'] ?? []);
    final missingSk = requiredSk.where((s) => !matchedSk.contains(s)).toList();
    final applyUrl = job['apply_url'] as String?;
    final salary = (salaryMin != null && salaryMax != null)
        ? '₹$salaryMin–$salaryMax'
        : salaryMin != null
        ? '₹$salaryMin+'
        : 'Not disclosed';
    final theme = jobTheme(title, company);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.42,
        maxChildSize: 0.95,
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
                  tile(theme.icon, theme.grad1, theme.grad2, sw * 0.14),
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
                        SizedBox(height: sw * 0.015),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: sw * 0.030,
                              color: kHint,
                            ),
                            SizedBox(width: sw * 0.008),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: sw * 0.028,
                                  color: kMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.040),
              // Stats row
              Container(
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.08),
                      theme.grad2.withValues(alpha: 0.04),
                    ],
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
                    _vDiv,
                    _detailStat(Icons.school, expLevel, 'Experience', sw),
                    _vDiv,
                    _detailStat(Icons.work, jobType, 'Type', sw),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.035),
              // Match percentage
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
                      'Skill Match',
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$matchPct%',
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
                          value: matchPct / 100,
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
              SizedBox(height: sw * 0.035),
              // Matched skills
              if (matchedSk.isNotEmpty) ...[
                Text(
                  '✅ Your Matching Skills',
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                SizedBox(height: sw * 0.015),
                Wrap(
                  spacing: sw * 0.015,
                  runSpacing: sw * 0.015,
                  children: matchedSk
                      .map(
                        (s) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sw * 0.012,
                          ),
                          decoration: BoxDecoration(
                            color: kSuccess.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kSuccess.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w700,
                              color: kSuccess,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: sw * 0.030),
              ],
              // Missing skills
              if (missingSk.isNotEmpty) ...[
                Text(
                  '📚 Skills to Learn',
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                SizedBox(height: sw * 0.015),
                Wrap(
                  spacing: sw * 0.015,
                  runSpacing: sw * 0.015,
                  children: missingSk
                      .map(
                        (s) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sw * 0.012,
                          ),
                          decoration: BoxDecoration(
                            color: kWarning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kWarning.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w700,
                              color: kWarning,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: sw * 0.030),
              ],
              SizedBox(height: sw * 0.020),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/jobs');
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

  Widget _detailStat(IconData icon, String value, String label, double sw) =>
      Expanded(
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
                fontSize: sw * 0.028,
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
  Widget get _vDiv => Container(width: 1, height: 36, color: kBorder);

  // ── HACKATHONS ─────────────────────────────
  Widget _buildHackathons(double sw) {
    return Column(
      children: hackathons.map((h) {
        final htitle = h['title'] as String;
        final org = h['org'] as String;
        final prize = h['prize'] as String;
        final date = h['date'] as String;
        final mode = h['mode'] as String;
        final theme = hackathonTheme(htitle);
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
                      tile(theme.icon, theme.grad1, theme.grad2, sw * 0.115),
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

  // ── NEARBY COMPANIES ───────────────────────
  Widget _buildNearbyCompanies(double sw) {
    return Column(
      children: nearbyCompanies.map((c) {
        final cname = c['name'] as String;
        final city = c['city'] as String;
        final distance = c['distance'] as String;
        final openings = c['openings'] as String;
        final domain = c['domain'] as String;
        final theme = companyTheme(cname);
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
                tile(theme.icon, theme.grad1, theme.grad2, sw * 0.115),
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

  // ── MOTIVATION BANNER ──────────────────────
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
              'Top %',
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

  // ── HELPERS ────────────────────────────────
  Widget sectionHeader(String title, {String? sub, required double sw}) => Row(
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

  Widget _smallChip(
    IconData icon,
    String label,
    double sw, {
    Color iconColor = kMuted,
  }) => Container(
    padding: EdgeInsets.symmetric(horizontal: sw * 0.018, vertical: sw * 0.008),
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
