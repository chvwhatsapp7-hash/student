import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../api_services/applications.dart';
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
//  MODELS
// ─────────────────────────────────────────────
class RecommendedJob {
  final int jobId;
  final String title, location, jobType, applyUrl, companyName;
  final String? companyLogo, experienceLevel;
  final int? salaryMin, salaryMax;
  final List<String> matchedSkills, requiredSkills;
  final int matchedCount, totalRequired, matchPercentage;

  RecommendedJob.fromJson(Map<String, dynamic> j)
    : jobId = j['job_id'],
      title = j['title'] ?? '',
      location = j['location'] ?? '',
      jobType = j['job_type'] ?? '',
      applyUrl = j['apply_url'] ?? '',
      companyName = j['company_name'] ?? '',
      companyLogo = j['company_logo'],
      experienceLevel = j['experience_level'],
      salaryMin = j['salary_min'],
      salaryMax = j['salary_max'],
      matchedSkills = List<String>.from(j['matched_skills'] ?? []),
      requiredSkills = List<String>.from(j['required_skills'] ?? []),
      matchedCount = j['matched_count'] ?? 0,
      totalRequired = j['total_required'] ?? 0,
      matchPercentage = j['match_percentage'] ?? 0;
}

class RecommendedInternship {
  final int internshipId;
  final String title, location, applyUrl, companyName;
  final String? companyLogo, stipend, duration, internshipType, startDate;
  final List<String> matchedSkills, requiredSkills;
  final int matchedCount, totalRequired, matchPercentage;

  RecommendedInternship.fromJson(Map<String, dynamic> j)
    : internshipId = j['internship_id'],
      title = j['title'] ?? '',
      location = j['location'] ?? '',
      applyUrl = j['apply_url'] ?? '',
      companyName = j['company_name'] ?? '',
      companyLogo = j['company_logo'],
      stipend = j['stipend']?.toString(),
      duration = j['duration'],
      internshipType = j['internship_type'],
      startDate = j['start_date'],
      matchedSkills = List<String>.from(j['matched_skills'] ?? []),
      requiredSkills = List<String>.from(j['required_skills'] ?? []),
      matchedCount = j['matched_count'] ?? 0,
      totalRequired = j['total_required'] ?? 0,
      matchPercentage = j['match_percentage'] ?? 0;
}

class RecommendedCourse {
  final int courseId;
  final String title, provider, category, level;
  final String? description, duration, courseUrl, price;
  final double? rating;
  final List<String> courseSkills, missingSkills;
  final int totalSkills, alreadyKnown, gapFillCount;

  RecommendedCourse.fromJson(Map<String, dynamic> j)
    : courseId = j['course_id'],
      title = j['title'] ?? '',
      provider = j['provider'] ?? '',
      category = j['category'] ?? '',
      level = j['level'] ?? '',
      description = j['description'],
      duration = j['duration'],
      courseUrl = j['course_url'],
      price = j['price']?.toString(),
      rating = (j['rating'] as num?)?.toDouble(),
      courseSkills = List<String>.from(j['course_skills'] ?? []),
      missingSkills = List<String>.from(j['missing_skills'] ?? []),
      totalSkills = j['total_skills'] ?? 0,
      alreadyKnown = j['already_known'] ?? 0,
      gapFillCount = j['gap_fill_count'] ?? 0;
}

// ─────────────────────────────────────────────
//  THEME HELPERS
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
  if (t.contains('machine learning') || t.contains('ml'))
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
  if (t.contains('intern'))
    return const _Theme(Icons.school, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (c.contains('tech'))
    return const _Theme(Icons.code, Color(0xFF1D4ED8), Color(0xFF3B82F6));
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
  return const _Theme(Icons.menu_book, Color(0xFF1D4ED8), Color(0xFF6366F1));
}

Widget _tile(IconData icon, Color g1, Color g2, double size) => Container(
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
  static const _baseUrl = 'https://studenthub-backend-woad.vercel.app';
  final _storage = const FlutterSecureStorage();

  late AnimationController _headerAnim;
  late AnimationController _xpAnim;
  late Animation<double> _xpValue;
  late List<AnimationController> _sectionAnims;
  late List<Animation<double>> _sectionFade;
  late List<Animation<Offset>> _sectionSlide;

  String _userName = '';
  String _userId = '';
  bool _isLoading = true;
  String? _error;

  List<RecommendedJob> _jobs = [];
  List<RecommendedInternship> _internships = [];
  List<RecommendedCourse> _courses = [];

  final Set<int> _appliedJobIds = {};
  final Set<int> _appliedInternshipIds = {};

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
    _xpValue = Tween<double>(begin: 0, end: 0).animate(_xpAnim);
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
    profileState.addListener(_onProfileChanged);
    _loadAll();
  }

  void _onProfileChanged() {
    if (!mounted) return;
    setState(() {
      _xpAnim.reset();
      _xpValue = Tween<double>(
        begin: 0,
        end: profileState.strength,
      ).animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));
      _xpAnim.forward();
    });
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _userName = await _storage.read(key: 'full_name') ?? '';
      _userId = await _storage.read(key: 'user_id') ?? '';
      await Future.wait([
        profileState.fetchProfile(),
        _fetchRecommendations(),
        _loadAppliedIds(),
      ]);
      _xpValue = Tween<double>(
        begin: 0,
        end: profileState.strength,
      ).animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _xpAnim.forward();
      });
      for (int i = 0; i < 8; i++) {
        Future.delayed(Duration(milliseconds: 80 + i * 80), () {
          if (mounted) _sectionAnims[i].forward();
        });
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAppliedIds() async {
    final appsData = await ApplicationsService.getApplications();
    if (appsData != null && appsData['data'] != null) {
      final dataList = appsData['data'] as List;
      if (mounted) {
        setState(() {
          _appliedJobIds
            ..clear()
            ..addAll(
              dataList
                  .where((a) => a['job_id'] != null)
                  .map<int>((a) => a['job_id'] as int),
            );
          _appliedInternshipIds
            ..clear()
            ..addAll(
              dataList
                  .where((a) => a['internship_id'] != null)
                  .map<int>((a) => a['internship_id'] as int),
            );
        });
      }
    }
  }

  Future<void> _fetchRecommendations() async {
    if (_userId.isEmpty) return;
    final res = await http.get(
      Uri.parse('$_baseUrl/api/profile/recommendations?user_id=$_userId'),
    );
    if (res.statusCode != 200)
      throw Exception('Failed to load recommendations');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception('API error');
    final data = body['data'] as Map<String, dynamic>;
    if (mounted) {
      setState(() {
        _jobs = (data['jobs'] as List)
            .map((j) => RecommendedJob.fromJson(j))
            .toList();
        _internships = (data['internships'] as List)
            .map((i) => RecommendedInternship.fromJson(i))
            .toList();
        _courses = (data['courses'] as List)
            .map((c) => RecommendedCourse.fromJson(c))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    profileState.removeListener(_onProfileChanged);
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBgPage,
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kSlate),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _loadAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(sw),
          _buildSearchBar(sw),
          Expanded(
            child: RefreshIndicator(
              color: kPrimary,
              onRefresh: _loadAll,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.040,
                  sw * 0.040,
                  sw * 0.040,
                  sw * 0.080,
                ),
                children: [
                  _fs(0, _buildStatsGrid(sw)),
                  SizedBox(height: sw * 0.040),
                  _fs(1, _buildProfileStrength(sw)),
                  SizedBox(height: sw * 0.055),
                  _fs(2, _buildQuickActions(context, sw)),
                  SizedBox(height: sw * 0.060),

                  // ── Recommended Jobs
                  _fs(
                    3,
                    _sectionHeader(
                      'Recommended Jobs',
                      sub: 'Based on your skills • ${_jobs.length} matches',
                      sw: sw,
                    ),
                  ),
                  SizedBox(height: sw * 0.030),
                  _jobs.isEmpty
                      ? _fs(
                          3,
                          _emptyCard(
                            'No job matches yet. Add more skills!',
                            sw,
                          ),
                        )
                      : _fs(3, _buildRecommendedJobs(sw)),
                  if (_jobs.length > 4) ...[
                    SizedBox(height: sw * 0.020),
                    _fs(
                      3,
                      _viewAllButton(
                        'View all ${_jobs.length} jobs',
                        '/jobs',
                        context,
                        sw,
                      ),
                    ),
                  ],
                  SizedBox(height: sw * 0.060),

                  // ── Recommended Internships
                  _fs(
                    4,
                    _sectionHeader(
                      'Recommended Internships',
                      sub: 'Fresher-friendly • ${_internships.length} matches',
                      sw: sw,
                    ),
                  ),
                  SizedBox(height: sw * 0.030),
                  _internships.isEmpty
                      ? _fs(4, _emptyCard('No internship matches yet.', sw))
                      : _fs(4, _buildRecommendedInternships(sw)),
                  if (_internships.length > 4) ...[
                    SizedBox(height: sw * 0.020),
                    _fs(
                      4,
                      _viewAllButton(
                        'View all ${_internships.length} internships',
                        '/internships',
                        context,
                        sw,
                      ),
                    ),
                  ],
                  SizedBox(height: sw * 0.060),

                  // ── Courses
                  _fs(
                    5,
                    _sectionHeader(
                      'Courses For You',
                      sub: 'Fill your skill gaps • ${_courses.length} courses',
                      sw: sw,
                    ),
                  ),
                  SizedBox(height: sw * 0.030),
                  _courses.isEmpty
                      ? _fs(5, _emptyCard('No course recommendations yet.', sw))
                      : _fs(5, _buildRecommendedCourses(sw)),
                  SizedBox(height: sw * 0.060),

                  _fs(6, _buildMotivationBanner(sw)),
                ],
              ),
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
    final displayName = profileState.name.isNotEmpty
        ? profileState.name
        : _userName.isNotEmpty
        ? _userName
        : 'There';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final pct = (profileState.strength * 100).toInt();

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
                            initial,
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
                              Flexible(
                                child: Text(
                                  'Hey, $displayName ',
                                  style: TextStyle(
                                    fontSize: sw * 0.048,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '👋',
                                style: TextStyle(fontSize: sw * 0.040),
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
                                '${_jobs.length} job matches today',
                                style: TextStyle(
                                  fontSize: sw * 0.028,
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
                              'Profile at $pct% — ${profileState.strengthHint}',
                              style: TextStyle(
                                fontSize: sw * 0.028,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Complete profile to unlock more matches',
                              style: TextStyle(
                                fontSize: sw * 0.024,
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
                          '$pct%',
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
  //  STATS GRID — 2 × 2
  // ─────────────────────────────────────────
  Widget _buildStatsGrid(double sw) {
    final stats = [
      {
        'icon': Icons.send_rounded,
        'value': '${profileState.applications.length}',
        'label': 'Applied',
        'sub': 'Total applications',
        'color': const Color(0xFF1D4ED8),
      },
      {
        'icon': Icons.star_rounded,
        'value': '${_jobs.where((j) => j.matchPercentage >= 80).length}',
        'label': 'Top Matches',
        'sub': '80%+ skill match',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.person_rounded,
        'value': '${(profileState.strength * 100).toInt()}%',
        'label': 'Profile Score',
        'sub': profileState.strengthHint,
        'color': const Color(0xFF16A34A),
      },
      {
        'icon': Icons.code_rounded,
        'value': '${profileState.skills.length}',
        'label': 'Skills',
        'sub': 'Added to profile',
        'color': const Color(0xFF7C3AED),
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            _statCard(stats[0], sw),
            SizedBox(width: sw * 0.030),
            _statCard(stats[1], sw),
          ],
        ),
        SizedBox(height: sw * 0.030),
        Row(
          children: [
            _statCard(stats[2], sw),
            SizedBox(width: sw * 0.030),
            _statCard(stats[3], sw),
          ],
        ),
      ],
    );
  }

  Widget _statCard(Map<String, dynamic> s, double sw) {
    final color = s['color'] as Color;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(sw * 0.045),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.115,
              height: sw * 0.115,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                s['icon'] as IconData,
                size: sw * 0.050,
                color: Colors.white,
              ),
            ),
            SizedBox(width: sw * 0.030),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['value'] as String,
                    style: TextStyle(
                      fontSize: sw * 0.055,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: sw * 0.004),
                  Text(
                    s['label'] as String,
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      fontWeight: FontWeight.w700,
                      color: kSlate,
                    ),
                  ),
                  SizedBox(height: sw * 0.003),
                  Text(
                    s['sub'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sw * 0.024,
                      color: kMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                      profileState.strengthHint,
                      style: TextStyle(
                        fontSize: sw * 0.026,
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
                profileState.skills.isNotEmpty,
                sw,
              ),
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
  //  QUICK ACTIONS — 2 rows × 3 columns
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

    Widget actionItem(Map<String, dynamic> a, {bool isLast = false}) {
      final g1 = a['g1'] as Color;
      final g2 = a['g2'] as Color;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(a['route'] as String);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.155,
                height: sw * 0.155,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [g1, g2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: g1.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  a['icon'] as IconData,
                  color: Colors.white,
                  size: sw * 0.065,
                ),
              ),
              SizedBox(height: sw * 0.018),
              Text(
                a['label'] as String,
                style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Quick Access', sub: 'Jump to any section', sw: sw),
        SizedBox(height: sw * 0.030),
        // ── Row 1: Jobs, Internships, Companies
        Row(
          children: [
            actionItem(actions[0]),
            SizedBox(width: sw * 0.025),
            actionItem(actions[1]),
            SizedBox(width: sw * 0.025),
            actionItem(actions[2]),
          ],
        ),
        SizedBox(height: sw * 0.035),
        // ── Row 2: Hackathons, Courses, Profile
        Row(
          children: [
            actionItem(actions[3]),
            SizedBox(width: sw * 0.025),
            actionItem(actions[4]),
            SizedBox(width: sw * 0.025),
            actionItem(actions[5]),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  SKILL CHIP
  // ─────────────────────────────────────────
  Widget _skillChip(String skill, bool isMatched, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.022,
        vertical: sw * 0.008,
      ),
      decoration: BoxDecoration(
        color: isMatched ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMatched
              ? kSuccess.withValues(alpha: 0.40)
              : Colors.red.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMatched ? Icons.check_circle : Icons.cancel,
            size: sw * 0.025,
            color: isMatched ? kSuccess : Colors.red,
          ),
          SizedBox(width: sw * 0.008),
          Text(
            skill,
            style: TextStyle(
              fontSize: sw * 0.025,
              color: isMatched ? kSuccess : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  VIEW & APPLY BUTTON
  // ─────────────────────────────────────────
  Widget _viewDetailsButton({
    required double sw,
    required VoidCallback onTap,
    required Color grad1,
    required Color grad2,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: sw * 0.032),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [grad1, grad2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: grad1.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: sw * 0.040),
              SizedBox(width: sw * 0.018),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: sw * 0.032,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  VIEW ALL BUTTON
  // ─────────────────────────────────────────
  Widget _viewAllButton(
    String label,
    String route,
    BuildContext context,
    double sw,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(route);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
        decoration: BoxDecoration(
          color: kSelectedBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: kPrimary.withValues(alpha: 0.30),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.032,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
            SizedBox(width: sw * 0.015),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: sw * 0.032,
              color: kPrimary,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  APPLIED BANNER HELPERS
  // ─────────────────────────────────────────
  Widget _appliedPill(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.030,
        vertical: sw * 0.013,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kSuccess, Color(0xFF15803D)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: sw * 0.030),
          SizedBox(width: sw * 0.008),
          Text(
            'Applied',
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submittedBadge(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.025,
        vertical: sw * 0.013,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: kSuccess, size: sw * 0.030),
          SizedBox(width: sw * 0.008),
          Text(
            'Application Submitted',
            style: TextStyle(
              fontSize: sw * 0.024,
              fontWeight: FontWeight.w700,
              color: kSuccess,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  RECOMMENDED JOBS — max 4
  // ─────────────────────────────────────────
  Widget _buildRecommendedJobs(double sw) {
    return Column(
      children: _jobs.take(4).map((job) {
        final theme = _jobTheme(job.title, job.companyName);
        final match = job.matchPercentage;
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
        final isApplied = _appliedJobIds.contains(job.jobId);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: EdgeInsets.only(bottom: sw * 0.030),
          decoration: BoxDecoration(
            gradient: isApplied
                ? LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.09),
                      theme.grad2.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isApplied ? null : kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isApplied ? theme.grad1.withValues(alpha: 0.50) : kBorder,
              width: isApplied ? 2 : 1.5,
            ),
            boxShadow: isApplied
                ? [
                    BoxShadow(
                      color: theme.grad1.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Container(
                height: isApplied ? 4 : 3,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.115),
                        SizedBox(width: sw * 0.030),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  fontWeight: FontWeight.w800,
                                  color: isApplied ? kPrimary : kInk,
                                ),
                              ),
                              SizedBox(height: sw * 0.005),
                              Text(
                                job.companyName,
                                style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: kMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sw * 0.013,
                          ),
                          decoration: BoxDecoration(
                            color: matchBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$match% match',
                            style: TextStyle(
                              fontSize: sw * 0.025,
                              fontWeight: FontWeight.w800,
                              color: matchColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.025),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: sw * 0.033, color: kHint),
                        SizedBox(width: sw * 0.010),
                        Text(
                          job.location,
                          style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                        ),
                        SizedBox(width: sw * 0.030),
                        Icon(
                          Icons.work_outline,
                          size: sw * 0.033,
                          color: kHint,
                        ),
                        SizedBox(width: sw * 0.010),
                        Text(
                          job.jobType,
                          style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                        ),
                        if (job.salaryMin != null && job.salaryMax != null) ...[
                          SizedBox(width: sw * 0.030),
                          Icon(
                            Icons.currency_rupee,
                            size: sw * 0.033,
                            color: kHint,
                          ),
                          Text(
                            '${job.salaryMin}–${job.salaryMax} LPA',
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              color: kMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: sw * 0.020),
                    if (job.requiredSkills.isNotEmpty) ...[
                      Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: sw * 0.026,
                          color: kMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: sw * 0.010),
                      Wrap(
                        spacing: sw * 0.015,
                        runSpacing: sw * 0.010,
                        children: job.requiredSkills.take(5).map((skill) {
                          return _skillChip(
                            skill,
                            job.matchedSkills.contains(skill),
                            sw,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: sw * 0.025),
                    ],
                    if (isApplied)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_appliedPill(sw), _submittedBadge(sw)],
                      )
                    else
                      _viewDetailsButton(
                        sw: sw,
                        grad1: theme.grad1,
                        grad2: theme.grad2,
                        icon: Icons.open_in_new,
                        label: 'View & Apply',
                        onTap: () => _showJobBottomSheet(job, sw),
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

  // ─────────────────────────────────────────
  //  JOB BOTTOM SHEET
  // ─────────────────────────────────────────
  void _showJobBottomSheet(RecommendedJob job, double sw) {
    final theme = _jobTheme(job.title, job.companyName);
    bool _applying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    sw * 0.05,
                    sw * 0.025,
                    sw * 0.05,
                    sw * 0.040,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: sw * 0.10,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.40),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: sw * 0.030),
                      Row(
                        children: [
                          Container(
                            width: sw * 0.140,
                            height: sw * 0.140,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              theme.icon,
                              color: Colors.white,
                              size: sw * 0.065,
                            ),
                          ),
                          SizedBox(width: sw * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: TextStyle(
                                    fontSize: sw * 0.042,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: sw * 0.008),
                                Text(
                                  job.companyName,
                                  style: TextStyle(
                                    fontSize: sw * 0.030,
                                    color: Colors.white.withValues(alpha: 0.80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025,
                              vertical: sw * 0.013,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${job.matchPercentage}% match',
                              style: TextStyle(
                                fontSize: sw * 0.026,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: EdgeInsets.all(sw * 0.050),
                    children: [
                      Wrap(
                        spacing: sw * 0.020,
                        runSpacing: sw * 0.015,
                        children: [
                          _metaChip(Icons.location_on, job.location, sw),
                          _metaChip(Icons.work_outline, job.jobType, sw),
                          if (job.experienceLevel != null)
                            _metaChip(
                              Icons.bar_chart,
                              job.experienceLevel!,
                              sw,
                            ),
                          if (job.salaryMin != null && job.salaryMax != null)
                            _metaChip(
                              Icons.currency_rupee,
                              '${job.salaryMin}–${job.salaryMax} LPA',
                              sw,
                            ),
                        ],
                      ),
                      SizedBox(height: sw * 0.035),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryBox(
                              '${job.matchedCount}/${job.totalRequired}',
                              'Skills Matched',
                              kSuccess,
                              const Color(0xFFF0FDF4),
                              sw,
                            ),
                          ),
                          SizedBox(width: sw * 0.020),
                          Expanded(
                            child: _summaryBox(
                              '${job.matchPercentage}%',
                              'Match Score',
                              kPrimary,
                              const Color(0xFFEFF6FF),
                              sw,
                            ),
                          ),
                          SizedBox(width: sw * 0.020),
                          Expanded(
                            child: _summaryBox(
                              '${job.totalRequired - job.matchedCount}',
                              'Skills Gap',
                              Colors.red,
                              const Color(0xFFFFF1F2),
                              sw,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.035),
                      Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                        ),
                      ),
                      SizedBox(height: sw * 0.015),
                      Wrap(
                        spacing: sw * 0.015,
                        runSpacing: sw * 0.010,
                        children: job.requiredSkills
                            .map(
                              (s) => _skillChip(
                                s,
                                job.matchedSkills.contains(s),
                                sw,
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: sw * 0.040),
                      GestureDetector(
                        onTap: _applying
                            ? null
                            : () async {
                                setSheetState(() => _applying = true);
                                final result = await ApplicationsService.apply(
                                  jobId: job.jobId,
                                );
                                if (!mounted) return;
                                if (result == 'Applied successfully') {
                                  setState(() => _appliedJobIds.add(job.jobId));
                                  Navigator.pop(sheetCtx);
                                  profileState.addApplication(
                                    job.title,
                                    job.companyName,
                                    type: 'Job',
                                  );
                                  _showSnack('Applied to ${job.title} ✅');
                                  _showJobAppliedDialog(job);
                                } else {
                                  setSheetState(() => _applying = false);
                                  _showSnack(result ?? 'Something went wrong');
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _applying
                                  ? [kMuted, kHint]
                                  : [theme.grad1, theme.grad2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _applying
                                ? []
                                : [
                                    BoxShadow(
                                      color: theme.grad1.withValues(
                                        alpha: 0.30,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: _applying
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: sw * 0.020),
                                      Text(
                                        'Apply Now',
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
                      ),
                      SizedBox(height: sw * 0.020),
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
  //  RECOMMENDED INTERNSHIPS — max 4
  // ─────────────────────────────────────────
  Widget _buildRecommendedInternships(double sw) {
    return Column(
      children: _internships.take(4).map((intern) {
        final theme = _jobTheme(intern.title, intern.companyName);
        final match = intern.matchPercentage;
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
        final isApplied = _appliedInternshipIds.contains(intern.internshipId);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: EdgeInsets.only(bottom: sw * 0.030),
          decoration: BoxDecoration(
            gradient: isApplied
                ? LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.09),
                      theme.grad2.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isApplied ? null : kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isApplied ? theme.grad1.withValues(alpha: 0.50) : kBorder,
              width: isApplied ? 2 : 1.5,
            ),
            boxShadow: isApplied
                ? [
                    BoxShadow(
                      color: theme.grad1.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Container(
                height: isApplied ? 4 : 3,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.115),
                        SizedBox(width: sw * 0.030),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                intern.title,
                                style: TextStyle(
                                  fontSize: sw * 0.035,
                                  fontWeight: FontWeight.w800,
                                  color: isApplied ? kPrimary : kInk,
                                ),
                              ),
                              SizedBox(height: sw * 0.005),
                              Text(
                                intern.companyName,
                                style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: kMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sw * 0.013,
                          ),
                          decoration: BoxDecoration(
                            color: matchBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$match% match',
                            style: TextStyle(
                              fontSize: sw * 0.025,
                              fontWeight: FontWeight.w800,
                              color: matchColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.025),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: sw * 0.033, color: kHint),
                        SizedBox(width: sw * 0.010),
                        Text(
                          intern.location,
                          style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                        ),
                        if (intern.stipend != null) ...[
                          SizedBox(width: sw * 0.030),
                          Icon(
                            Icons.currency_rupee,
                            size: sw * 0.033,
                            color: kHint,
                          ),
                          Text(
                            '${intern.stipend}/mo',
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              color: kMuted,
                            ),
                          ),
                        ],
                        if (intern.duration != null) ...[
                          SizedBox(width: sw * 0.030),
                          Icon(
                            Icons.timer_outlined,
                            size: sw * 0.033,
                            color: kHint,
                          ),
                          Text(
                            intern.duration!,
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              color: kMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: sw * 0.020),
                    if (intern.requiredSkills.isNotEmpty) ...[
                      Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: sw * 0.026,
                          color: kMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: sw * 0.010),
                      Wrap(
                        spacing: sw * 0.015,
                        runSpacing: sw * 0.010,
                        children: intern.requiredSkills.take(5).map((skill) {
                          return _skillChip(
                            skill,
                            intern.matchedSkills.contains(skill),
                            sw,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: sw * 0.025),
                    ],
                    if (isApplied)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_appliedPill(sw), _submittedBadge(sw)],
                      )
                    else
                      _viewDetailsButton(
                        sw: sw,
                        grad1: theme.grad1,
                        grad2: theme.grad2,
                        icon: Icons.open_in_new,
                        label: 'View & Apply',
                        onTap: () => _showInternshipBottomSheet(intern, sw),
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

  // ─────────────────────────────────────────
  //  INTERNSHIP BOTTOM SHEET
  // ─────────────────────────────────────────
  void _showInternshipBottomSheet(RecommendedInternship intern, double sw) {
    final theme = _jobTheme(intern.title, intern.companyName);
    bool _applying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    sw * 0.05,
                    sw * 0.025,
                    sw * 0.05,
                    sw * 0.040,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: sw * 0.10,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.40),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: sw * 0.030),
                      Row(
                        children: [
                          Container(
                            width: sw * 0.140,
                            height: sw * 0.140,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              theme.icon,
                              color: Colors.white,
                              size: sw * 0.065,
                            ),
                          ),
                          SizedBox(width: sw * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  intern.title,
                                  style: TextStyle(
                                    fontSize: sw * 0.042,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: sw * 0.008),
                                Text(
                                  intern.companyName,
                                  style: TextStyle(
                                    fontSize: sw * 0.030,
                                    color: Colors.white.withValues(alpha: 0.80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025,
                              vertical: sw * 0.013,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${intern.matchPercentage}% match',
                              style: TextStyle(
                                fontSize: sw * 0.026,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: EdgeInsets.all(sw * 0.050),
                    children: [
                      Wrap(
                        spacing: sw * 0.020,
                        runSpacing: sw * 0.015,
                        children: [
                          _metaChip(Icons.location_on, intern.location, sw),
                          if (intern.internshipType != null)
                            _metaChip(
                              Icons.work_outline,
                              intern.internshipType!,
                              sw,
                            ),
                          if (intern.duration != null)
                            _metaChip(
                              Icons.timer_outlined,
                              intern.duration!,
                              sw,
                            ),
                          if (intern.stipend != null)
                            _metaChip(
                              Icons.currency_rupee,
                              '₹${intern.stipend}/mo',
                              sw,
                            ),
                          if (intern.startDate != null)
                            _metaChip(
                              Icons.calendar_today,
                              intern.startDate!,
                              sw,
                            ),
                        ],
                      ),
                      SizedBox(height: sw * 0.035),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryBox(
                              '${intern.matchedCount}/${intern.totalRequired}',
                              'Skills Matched',
                              kSuccess,
                              const Color(0xFFF0FDF4),
                              sw,
                            ),
                          ),
                          SizedBox(width: sw * 0.020),
                          Expanded(
                            child: _summaryBox(
                              '${intern.matchPercentage}%',
                              'Match Score',
                              kPrimary,
                              const Color(0xFFEFF6FF),
                              sw,
                            ),
                          ),
                          SizedBox(width: sw * 0.020),
                          Expanded(
                            child: _summaryBox(
                              '${intern.totalRequired - intern.matchedCount}',
                              'Skills Gap',
                              Colors.red,
                              const Color(0xFFFFF1F2),
                              sw,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.035),
                      Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                        ),
                      ),
                      SizedBox(height: sw * 0.015),
                      Wrap(
                        spacing: sw * 0.015,
                        runSpacing: sw * 0.010,
                        children: intern.requiredSkills
                            .map(
                              (s) => _skillChip(
                                s,
                                intern.matchedSkills.contains(s),
                                sw,
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: sw * 0.040),
                      GestureDetector(
                        onTap: _applying
                            ? null
                            : () async {
                                setSheetState(() => _applying = true);
                                final result = await ApplicationsService.apply(
                                  internshipId: intern.internshipId,
                                );
                                if (!mounted) return;
                                if (result == 'Applied successfully') {
                                  setState(
                                    () => _appliedInternshipIds.add(
                                      intern.internshipId,
                                    ),
                                  );
                                  Navigator.pop(sheetCtx);
                                  profileState.addApplication(
                                    intern.title,
                                    intern.companyName,
                                    type: 'Internship',
                                  );
                                  _showSnack('Applied to ${intern.title} ✅');
                                  _showInternshipAppliedDialog(intern);
                                } else {
                                  setSheetState(() => _applying = false);
                                  _showSnack(result ?? 'Something went wrong');
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _applying
                                  ? [kMuted, kHint]
                                  : [theme.grad1, theme.grad2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _applying
                                ? []
                                : [
                                    BoxShadow(
                                      color: theme.grad1.withValues(
                                        alpha: 0.30,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: _applying
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: sw * 0.020),
                                      Text(
                                        'Apply Now',
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
                      ),
                      SizedBox(height: sw * 0.020),
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
  //  RECOMMENDED COURSES
  // ─────────────────────────────────────────
  Widget _buildRecommendedCourses(double sw) {
    return Column(
      children: _courses.map((course) {
        final theme = _courseTheme(course.title, course.category);
        final ls = _levelStyle(course.level);

        return Container(
          margin: EdgeInsets.only(bottom: sw * 0.030),
          padding: EdgeInsets.all(sw * 0.040),
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
                  _tile(theme.icon, theme.grad1, theme.grad2, sw * 0.130),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Text(
                          course.provider,
                          style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                        ),
                        SizedBox(height: sw * 0.015),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.020,
                                vertical: sw * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: ls.bg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                course.level,
                                style: TextStyle(
                                  fontSize: sw * 0.023,
                                  color: ls.fg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (course.duration != null) ...[
                              SizedBox(width: sw * 0.015),
                              Text(
                                course.duration!,
                                style: TextStyle(
                                  fontSize: sw * 0.025,
                                  color: kHint,
                                ),
                              ),
                            ],
                            if (course.rating != null) ...[
                              SizedBox(width: sw * 0.015),
                              Icon(
                                Icons.star,
                                color: kWarning,
                                size: sw * 0.030,
                              ),
                              Text(
                                course.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: sw * 0.025,
                                  color: kWarning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (course.gapFillCount > 0) ...[
                SizedBox(height: sw * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sw * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kSuccess.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: kSuccess,
                        size: sw * 0.033,
                      ),
                      SizedBox(width: sw * 0.010),
                      Text(
                        'Fills ${course.gapFillCount} skill gap${course.gapFillCount > 1 ? 's' : ''} in your profile',
                        style: TextStyle(
                          fontSize: sw * 0.026,
                          color: kSuccess,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (course.missingSkills.isNotEmpty) ...[
                SizedBox(height: sw * 0.015),
                Text(
                  'You will learn',
                  style: TextStyle(
                    fontSize: sw * 0.026,
                    color: kMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: sw * 0.010),
                Wrap(
                  spacing: sw * 0.015,
                  runSpacing: sw * 0.010,
                  children: course.missingSkills.take(4).map((s) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.022,
                        vertical: sw * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(
                            0xFF7C3AED,
                          ).withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: sw * 0.025,
                          color: const Color(0xFF7C3AED),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: sw * 0.025),
              _viewDetailsButton(
                sw: sw,
                grad1: theme.grad1,
                grad2: theme.grad2,
                icon: Icons.play_circle_outline,
                label: 'Start Course',
                onTap: () {},
              ),
            ],
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
      padding: EdgeInsets.all(sw * 0.050),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚀 Keep going, ${profileState.name.isNotEmpty ? profileState.name.split(' ').first : 'Champion'}!',
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: sw * 0.010),
                Text(
                  'You have ${_jobs.length + _internships.length} active matches. Apply today!',
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.emoji_events, color: Colors.white, size: sw * 0.12),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SUCCESS DIALOGS
  // ─────────────────────────────────────────
  void _showJobAppliedDialog(RecommendedJob job) {
    final sw = MediaQuery.of(context).size.width;
    final theme = _jobTheme(job.title, job.companyName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.grad1.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.grad1, theme.grad2]),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.06,
                  sw * 0.05,
                  sw * 0.06,
                  sw * 0.06,
                ),
                child: Column(
                  children: [
                    Container(
                      width: sw * 0.175,
                      height: sw * 0.175,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            kSuccess.withValues(alpha: 0.15),
                            kSuccess.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: kSuccess.withValues(alpha: 0.30),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          color: kSuccess,
                          size: sw * 0.09,
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.030),
                    Text(
                      'Application Sent! 🎉',
                      style: TextStyle(
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: sw * 0.010),
                    Text(
                      'Your application for ${job.title} has been submitted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        color: kMuted,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sw * 0.035),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.035),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _tile(
                                theme.icon,
                                theme.grad1,
                                theme.grad2,
                                sw * 0.100,
                              ),
                              SizedBox(width: sw * 0.025),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: TextStyle(
                                        fontSize: sw * 0.030,
                                        fontWeight: FontWeight.w800,
                                        color: kInk,
                                      ),
                                    ),
                                    Text(
                                      job.companyName,
                                      style: TextStyle(
                                        fontSize: sw * 0.026,
                                        color: kMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.020),
                          Container(height: 1, color: kBorder),
                          SizedBox(height: sw * 0.020),
                          _dialogRow(
                            Icons.location_on,
                            'Location',
                            job.location,
                            sw,
                          ),
                          SizedBox(height: sw * 0.012),
                          _dialogRow(
                            Icons.work_outline,
                            'Type',
                            job.jobType,
                            sw,
                          ),
                          if (job.salaryMin != null &&
                              job.salaryMax != null) ...[
                            SizedBox(height: sw * 0.012),
                            _dialogRow(
                              Icons.currency_rupee,
                              'Salary',
                              '${job.salaryMin}–${job.salaryMax} LPA',
                              sw,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.040),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.033),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.grad1, theme.grad2],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'OK, Got it!',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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

  void _showInternshipAppliedDialog(RecommendedInternship intern) {
    final sw = MediaQuery.of(context).size.width;
    final theme = _jobTheme(intern.title, intern.companyName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.grad1.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.grad1, theme.grad2]),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.06,
                  sw * 0.05,
                  sw * 0.06,
                  sw * 0.06,
                ),
                child: Column(
                  children: [
                    Container(
                      width: sw * 0.175,
                      height: sw * 0.175,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            kSuccess.withValues(alpha: 0.15),
                            kSuccess.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: kSuccess.withValues(alpha: 0.30),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          color: kSuccess,
                          size: sw * 0.09,
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.030),
                    Text(
                      'Application Sent! 🎉',
                      style: TextStyle(
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: sw * 0.010),
                    Text(
                      'Your application for ${intern.title} has been submitted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        color: kMuted,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sw * 0.035),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.035),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _tile(
                                theme.icon,
                                theme.grad1,
                                theme.grad2,
                                sw * 0.100,
                              ),
                              SizedBox(width: sw * 0.025),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      intern.title,
                                      style: TextStyle(
                                        fontSize: sw * 0.030,
                                        fontWeight: FontWeight.w800,
                                        color: kInk,
                                      ),
                                    ),
                                    Text(
                                      intern.companyName,
                                      style: TextStyle(
                                        fontSize: sw * 0.026,
                                        color: kMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.020),
                          Container(height: 1, color: kBorder),
                          SizedBox(height: sw * 0.020),
                          _dialogRow(
                            Icons.location_on,
                            'Location',
                            intern.location,
                            sw,
                          ),
                          SizedBox(height: sw * 0.012),
                          _dialogRow(
                            Icons.work_outline,
                            'Type',
                            intern.internshipType ?? 'Internship',
                            sw,
                          ),
                          if (intern.stipend != null) ...[
                            SizedBox(height: sw * 0.012),
                            _dialogRow(
                              Icons.currency_rupee,
                              'Stipend',
                              '₹${intern.stipend}/mo',
                              sw,
                            ),
                          ],
                          if (intern.duration != null) ...[
                            SizedBox(height: sw * 0.012),
                            _dialogRow(
                              Icons.timer_outlined,
                              'Duration',
                              intern.duration!,
                              sw,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.040),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.033),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.grad1, theme.grad2],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'OK, Got it!',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────
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
        style: TextStyle(color: kMuted, fontSize: sw * 0.030),
      ),
    ),
  );

  Widget _metaChip(IconData icon, String label, double sw) => Container(
    padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.013),
    decoration: BoxDecoration(
      color: kBgPage,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: sw * 0.033, color: kMuted),
        SizedBox(width: sw * 0.010),
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.028,
            color: kSlate,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _summaryBox(
    String value,
    String label,
    Color color,
    Color bg,
    double sw,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: sw * 0.025,
        horizontal: sw * 0.015,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: sw * 0.038,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: sw * 0.005),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.022,
              color: color.withValues(alpha: 0.80),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(IconData icon, String label, String value, double sw) {
    return Row(
      children: [
        Container(
          width: sw * 0.070,
          height: sw * 0.070,
          decoration: BoxDecoration(
            color: kSelectedBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: sw * 0.035, color: kPrimary),
        ),
        SizedBox(width: sw * 0.020),
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.028,
            color: kMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w800,
              color: kInk,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    String title, {
    required String sub,
    required double sw,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.045,
            fontWeight: FontWeight.w800,
            color: kInk,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: sw * 0.005),
        Text(
          sub,
          style: TextStyle(fontSize: sw * 0.030, color: kMuted),
        ),
      ],
    );
  }
}
