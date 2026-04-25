import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../api_services/authservice.dart';
import 'school_data.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kPrimaryBlue = Color(0xFF1976D2);
const kDeepBlue = Color(0xFF0D47A1);
const kBgPage = Color(0xFFF4F7FF);
const kCardBg = Color(0xFFFFFFFF);
const kCardBorder = Color(0xFFE8EEF7);
const kTextDark = Color(0xFF0A1931);
const kTextMuted = Color(0xFF8A97B0);
const kEnrolledGreen = Color(0xFF2E7D32);
const kInterestedAmber = Color(0xFFE65100);

// ─────────────────────────────────────────────
//  API MODELS
// ─────────────────────────────────────────────

class ProfileApiData {
  final String fullName;
  final String email;
  final int studentClass;
  final String schoolName;
  final String goal;
  final String? aboutMe;
  final int coursesEnrolled;
  final int coursesCompleted;
  final int achievements;
  final List<ApiCourse> courses;

  ProfileApiData({
    required this.fullName,
    required this.email,
    required this.studentClass,
    required this.schoolName,
    required this.goal,
    this.aboutMe,
    required this.coursesEnrolled,
    required this.coursesCompleted,
    required this.achievements,
    required this.courses,
  });

  factory ProfileApiData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final stats = json['stats'] as Map<String, dynamic>;
    final coursesList = (json['courses'] as List)
        .map((c) => ApiCourse.fromJson(c as Map<String, dynamic>))
        .toList();
    return ProfileApiData(
      fullName: user['full_name'] ?? '',
      email: user['email'] ?? '',
      studentClass: (user[r'class'] as num?)?.toInt() ?? 0,
      schoolName: user['school_name'] ?? '',
      goal: user['goal'] ?? '',
      aboutMe: user['about_me'],
      coursesEnrolled: stats['coursesEnrolled'] ?? 0,
      coursesCompleted: stats['coursesCompleted'] ?? 0,
      achievements: stats['achievements'] ?? 0,
      courses: coursesList,
    );
  }
}

class ApiCourse {
  final int courseId;
  final String title;
  final int progress;
  final bool completed;

  ApiCourse({
    required this.courseId,
    required this.title,
    required this.progress,
    required this.completed,
  });

  factory ApiCourse.fromJson(Map<String, dynamic> json) => ApiCourse(
    courseId: json['course_id'] ?? 0,
    title: json['title'] ?? '',
    progress: json['progress'] ?? 0,
    completed: json['completed'] ?? false,
  );
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen>
    with TickerProviderStateMixin {
  bool _ready = false;

  ProfileApiData? _apiData;
  bool _apiLoading = true;
  String? _apiError;
  bool _isSaving = false;

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late AnimationController _strengthAnim;
  late Animation<double> _strengthVal;
  late TabController _tabCtrl;

  // ─────────────────────────────────────────
  //  LIFECYCLE
  // ─────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _strengthAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _strengthVal = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _strengthAnim, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _strengthAnim.forward();
    });

    _tabCtrl = TabController(length: 4, vsync: this);
    _ready = true;
    _fetchProfile();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _strengthAnim.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  GET — fetch profile
  // ─────────────────────────────────────────

  Future<void> _fetchProfile() async {
    try {
      final response = await AuthService().dio.get('/profile/profile-school');
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true) {
          final data = ProfileApiData.fromJson(
            body['data'] as Map<String, dynamic>,
          );
          if (mounted) {
            setState(() {
              _apiData = data;
              _apiLoading = false;
            });
            _strengthAnim
              ..reset()
              ..forward();
          }
        } else {
          if (mounted)
            setState(() {
              _apiError = body['message'] ?? 'Something went wrong';
              _apiLoading = false;
            });
        }
      }
    } on DioException catch (e) {
      if (mounted)
        setState(() {
          _apiError =
              e.response?.data?['message'] ?? e.message ?? 'Request failed';
          _apiLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _apiError = e.toString();
          _apiLoading = false;
        });
    }
  }

  // ─────────────────────────────────────────
  //  PUT — update profile
  // ─────────────────────────────────────────

  Future<void> _updateProfile({
    required String fullName,
    required String schoolName,
    required String goal,
    required int studentClass,
  }) async {
    final userId = AuthService().userId;
    if (userId == null) {
      _showSnack('User ID not found. Please re-login.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final response = await AuthService().dio.put(
        '/profile/getUsers',
        data: {
          'user_id': userId,
          'full_name': fullName,
          'school_name': schoolName,
          'goal': goal,
          'class': studentClass,
        },
      );
      if (response.statusCode == 200 &&
          (response.data as Map<String, dynamic>)['success'] == true) {
        await _fetchProfile();
        _showSnack('Profile updated successfully! ✅');
      } else {
        _showSnack(response.data?['message'] ?? 'Update failed');
      }
    } on DioException catch (e) {
      _showSnack(e.response?.data?['message'] ?? 'Update failed. Try again.');
    } catch (e) {
      _showSnack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─────────────────────────────────────────
  //  PROFILE STRENGTH
  // ─────────────────────────────────────────

  double _profileStrength(
    StudentProfile p,
    List<Course> enrolled,
    List<Course> interested,
  ) {
    double s = 0.20;
    if (p.name.isNotEmpty && p.name != 'Student') s += 0.10;
    if (p.school.isNotEmpty && p.school != 'My School') s += 0.10;
    if (enrolled.isNotEmpty) s += 0.20;
    if (enrolled.length >= 2) s += 0.10;
    if (interested.isNotEmpty) s += 0.10;
    if (p.streakDays >= 7) s += 0.10;
    if (p.totalPoints >= 500) s += 0.10;
    return s.clamp(0.0, 1.0);
  }

  String _strengthHint(
    StudentProfile p,
    List<Course> enrolled,
    List<Course> interested,
  ) {
    if (p.name == 'Student' || p.name.isEmpty)
      return 'Add your name to boost your profile (+10%)';
    if (p.school.isEmpty || p.school == 'My School')
      return 'Add your school name (+10%)';
    if (enrolled.isEmpty) return 'Enroll in a course to get started (+20%)';
    if (enrolled.length < 2) return 'Enroll in one more course (+10%)';
    if (interested.isEmpty) return 'Bookmark courses you like (+10%)';
    if (p.streakDays < 7) return 'Keep a 7-day streak to level up (+10%)';
    return '🎉 Your profile is looking great!';
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    if (_apiLoading) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(fontSize: 14, color: kTextMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (_apiError != null) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: kTextMuted),
              const SizedBox(height: 12),
              Text(
                'Failed to load profile\n$_apiError',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: kTextMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _apiLoading = true;
                    _apiError = null;
                  });
                  _fetchProfile();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: SchoolStateProvider.of(context),
      builder: (_, __) {
        final state = SchoolStateProvider.of(context);
        final profile = state.profile;
        final enrolled = kCourses
            .where((c) => state.statusOf(c.id) == CourseStatus.enrolled)
            .toList();
        final interested = kCourses
            .where((c) => state.statusOf(c.id) == CourseStatus.interested)
            .toList();
        final strength = _profileStrength(profile, enrolled, interested);

        return Scaffold(
          backgroundColor: kBgPage,
          body: Column(
            children: [
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(
                    context,
                    state,
                    profile,
                    enrolled,
                    interested,
                    strength,
                  ),
                ),
              ),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildOverviewTab(
                      context,
                      state,
                      profile,
                      enrolled,
                      interested,
                      strength,
                    ),
                    // ✅ API courses passed to Courses tab
                    _buildCoursesTab(
                      context,
                      state,
                      enrolled,
                      interested,
                      _apiData?.courses ?? [],
                    ),
                    _buildAchievementsTab(state, enrolled, interested),
                    _buildAccountTab(context, state, profile),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  API STATS BANNER
  // ─────────────────────────────────────────

  Widget _buildApiStatsBanner() {
    if (_apiData == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryBlue, kDeepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Your Stats',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (_apiData!.goal.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Goal: ${_apiData!.goal}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _apiBanner('${_apiData!.coursesEnrolled}', 'Enrolled', '🚀'),
              _apiBanner('${_apiData!.coursesCompleted}', 'Completed', '🎓'),
              _apiBanner('${_apiData!.achievements}', 'Badges', '🏅'),
              _apiBanner('${_apiData!.courses.length}', 'Courses', '📚'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _apiBanner(String value, String label, String emoji) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    SchoolStateNotifier state,
    StudentProfile p,
    List<Course> enrolled,
    List<Course> interested,
    double strength,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryBlue, kDeepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _iconBtn(Icons.arrow_back_ios_new_rounded, () {
                    HapticFeedback.lightImpact();
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/school/layout');
                  }),
                  const Spacer(),
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  _iconBtn(
                    Icons.edit_rounded,
                    () => _openEditProfileSheet(context, state, p),
                  ),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.logout_rounded, () async {
                    HapticFeedback.lightImpact();
                    await AuthService().clearTokens();
                    if (mounted) context.go('/login');
                  }),
                ],
              ),
            ),

            // Avatar + name
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAvatarPicker(context, state, p),
                    child: Stack(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.avatar,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryBlue.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 13,
                              color: kPrimaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _apiData?.fullName.isNotEmpty == true
                              ? _apiData!.fullName
                              : (p.name.isNotEmpty ? p.name : 'Student'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _profileChip(
                          Icons.school_rounded,
                          _apiData != null
                              ? 'Class ${_apiData!.studentClass}'
                              : p.grade,
                        ),
                        const SizedBox(height: 4),
                        _profileChip(
                          Icons.location_city_rounded,
                          _apiData?.schoolName.isNotEmpty == true
                              ? _apiData!.schoolName
                              : p.school,
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _openEditProfileSheet(context, state, p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.90),
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
            ),

            // Mini stats
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _hStat(
                      '${_apiData?.courses.length ?? enrolled.length}',
                      'Enrolled',
                      Icons.rocket_launch_rounded,
                    ),
                    _hDiv(),
                    _hStat(
                      '${interested.length}',
                      'Saved',
                      Icons.bookmark_rounded,
                    ),
                    _hDiv(),
                    _hStat('${p.totalPoints}', 'Points', Icons.star_rounded),
                    _hDiv(),
                    _hStat(
                      '${p.streakDays}d',
                      'Streak',
                      Icons.local_fire_department_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _hStat(String value, String label, IconData icon) => Column(
    children: [
      Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.80)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    ],
  );

  Widget _hDiv() => Container(
    width: 1,
    height: 32,
    color: Colors.white.withValues(alpha: 0.20),
  );

  Widget _profileChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.75)),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );

  // ─────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────

  Widget _buildTabBar() => Container(
    color: kCardBg,
    child: TabBar(
      controller: _tabCtrl,
      isScrollable: true,
      labelColor: kPrimaryBlue,
      unselectedLabelColor: kTextMuted,
      labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      indicatorColor: kPrimaryBlue,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.tab,
      padding: EdgeInsets.zero,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Courses'),
        Tab(text: 'Achievements'),
        Tab(text: 'Account'),
      ],
    ),
  );

  // ═══════════════════════════════════════════
  //  TAB 1 — OVERVIEW
  // ═══════════════════════════════════════════

  Widget _buildOverviewTab(
    BuildContext context,
    SchoolStateNotifier state,
    StudentProfile p,
    List<Course> enrolled,
    List<Course> interested,
    double strength,
  ) {
    final hint = _strengthHint(p, enrolled, interested);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats banner
        _buildApiStatsBanner(),

        // Profile strength
        _sectionCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimaryBlue, kDeepBlue],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Profile Strength',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _strengthAnim,
                    builder: (_, __) => Text(
                      '${(_strengthAnim.value * strength * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _strengthAnim,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _strengthAnim.value * strength,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8F1FE),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      kPrimaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    size: 14,
                    color: kTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Account details
        _sectionCard(
          child: Column(
            children: [
              _cardHeader(
                'Account Details',
                Icons.person_rounded,
                onEdit: () => _openEditProfileSheet(context, state, p),
              ),
              const SizedBox(height: 14),
              _infoRow(
                Icons.person_rounded,
                'Name',
                _apiData?.fullName.isNotEmpty == true
                    ? _apiData!.fullName
                    : (p.name.isNotEmpty ? p.name : '—'),
                false,
              ),
              _infoRow(
                Icons.email_rounded,
                'Email',
                _apiData?.email ?? '—',
                false,
              ),
              _infoRow(
                Icons.school_rounded,
                'Class',
                _apiData != null ? 'Class ${_apiData!.studentClass}' : p.grade,
                false,
              ),
              _infoRow(
                Icons.location_city_rounded,
                'School',
                _apiData?.schoolName.isNotEmpty == true
                    ? _apiData!.schoolName
                    : (p.school.isNotEmpty ? p.school : '—'),
                false,
              ),
              _infoRow(
                Icons.flag_rounded,
                'Goal',
                _apiData?.goal.isNotEmpty == true ? _apiData!.goal : '—',
                false,
              ),
              _infoRow(
                Icons.star_rounded,
                'Points',
                '${p.totalPoints} pts',
                false,
              ),
              _infoRow(
                Icons.local_fire_department_rounded,
                'Streak',
                '${p.streakDays} days',
                true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ✅ "My Courses" section COMPLETELY REMOVED from here
        const SizedBox(height: 16),

        // ✅ API Enrolled Courses preview in Overview
        if (_apiData != null && _apiData!.courses.isNotEmpty)
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader(
                  'Enrolled Courses',
                  Icons.rocket_launch_rounded,
                  onEdit: () => _tabCtrl.animateTo(1),
                ),
                const SizedBox(height: 14),
                ..._apiData!.courses
                    .take(3)
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F1FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.book_rounded,
                                  color: kPrimaryBlue,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: kTextDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: c.progress / 100,
                                      minHeight: 5,
                                      backgroundColor: const Color(0xFFE8F1FE),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            kPrimaryBlue,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${c.progress}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (_apiData!.courses.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => _tabCtrl.animateTo(1),
                      child: const Text(
                        'View all courses →',
                        style: TextStyle(
                          fontSize: 12,
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Saved courses preview
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader(
                'Saved Courses',
                Icons.bookmark_rounded,
                onEdit: () => _tabCtrl.animateTo(1),
              ),
              const SizedBox(height: 14),
              if (interested.isEmpty)
                _emptyHint('🔖', 'Nothing bookmarked yet.')
              else
                ...interested
                    .take(2)
                    .map((c) => _miniCourseRow(c, CourseStatus.interested)),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  TAB 2 — COURSES
  // ═══════════════════════════════════════════

  Widget _buildCoursesTab(
    BuildContext context,
    SchoolStateNotifier state,
    List<Course> enrolled,
    List<Course> interested,
    List<ApiCourse> apiCourses, // ✅ API courses from backend
  ) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: kCardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // ✅ Count from API courses
                _subTabPill(apiCourses.length, '🚀 Enrolled', 0),
                const SizedBox(width: 10),
                _subTabPill(interested.length, '🔖 Interested', 1),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ✅ Enrolled tab shows API courses (same list as "My Courses" was)
                _apiEnrolledList(apiCourses),
                _courseList(state, interested, isEnrolled: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Renders API courses in Enrolled tab
  Widget _apiEnrolledList(List<ApiCourse> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 12),
            const Text(
              'No enrolled courses yet.\nGo to Courses and hit Enroll!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kTextMuted, height: 1.6),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: courses.length,
      itemBuilder: (_, i) {
        final c = courses[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1FBF3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: kEnrolledGreen.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.book_rounded,
                    color: kPrimaryBlue,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: c.progress / 100,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE8F1FE),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          kPrimaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${c.progress}% complete',
                      style: const TextStyle(fontSize: 11, color: kTextMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kEnrolledGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 11,
                          color: kEnrolledGreen,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Enrolled',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: kEnrolledGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (c.completed) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✅ Done',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kPrimaryBlue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _subTabPill(int count, String label, int index) =>
      _SubTabPill(count: count, label: label, index: index);

  Widget _courseList(
    SchoolStateNotifier state,
    List<Course> list, {
    required bool isEnrolled,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEnrolled ? '🚀' : '🔖',
              style: const TextStyle(fontSize: 42),
            ),
            const SizedBox(height: 12),
            Text(
              isEnrolled
                  ? 'No enrolled courses yet.\nHead to Courses and hit Enroll!'
                  : 'Nothing saved yet.\nMark courses as Interested.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: kTextMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => _ProfileCourseCard(
        course: list[i],
        index: i,
        isEnrolled: isEnrolled,
        onRemove: () => state.setStatus(list[i].id, CourseStatus.none),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  TAB 3 — ACHIEVEMENTS
  // ═══════════════════════════════════════════

  Widget _buildAchievementsTab(
    SchoolStateNotifier state,
    List<Course> enrolled,
    List<Course> interested,
  ) {
    final p = state.profile;
    final badges = [
      _BadgeData(
        '🏅',
        'First Enroll',
        'Enroll in your first course',
        enrolled.isNotEmpty,
      ),
      _BadgeData('🔖', 'Explorer', 'Bookmark a course', interested.isNotEmpty),
      _BadgeData(
        '🎓',
        'Multi-Course',
        'Enroll in 2+ courses',
        enrolled.length >= 2,
      ),
      _BadgeData(
        '🔥',
        '2-Wk Streak',
        'Maintain a 14-day streak',
        p.streakDays >= 14,
      ),
      _BadgeData(
        '⭐',
        'Point Champ',
        'Earn 1000+ points',
        p.totalPoints >= 1000,
      ),
      _BadgeData(
        '🚀',
        'Overachiever',
        'Enroll in 5+ courses',
        enrolled.length >= 5,
      ),
    ];
    final unlocked = badges.where((b) => b.unlocked).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked / ${badges.length} Unlocked',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: unlocked / badges.length,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      unlocked == badges.length
                          ? '🎉 All badges unlocked!'
                          : 'Keep going to unlock all badges!',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Badges',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: badges.map((b) => _badgeTile(b)).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 14),
              _statProgressRow(
                'Courses Enrolled',
                enrolled.length,
                5,
                kPrimaryBlue,
              ),
              const SizedBox(height: 12),
              _statProgressRow(
                'Streak Days',
                p.streakDays,
                14,
                const Color(0xFFE53935),
              ),
              const SizedBox(height: 12),
              _statProgressRow(
                'Points Earned',
                p.totalPoints,
                1000,
                const Color(0xFFFFB300),
              ),
              const SizedBox(height: 12),
              _statProgressRow(
                'Bookmarks',
                interested.length,
                5,
                kInterestedAmber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _statProgressRow(String label, int value, int max, Color color) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
            ),
            Text(
              '$value / $max',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8F1FE),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _badgeTile(_BadgeData b) => GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            b.unlocked
                ? '${b.emoji} ${b.label} — Unlocked!'
                : '${b.emoji} ${b.label} — ${b.description}',
          ),
          backgroundColor: b.unlocked ? kEnrolledGreen : kTextMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    },
    child: Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            color: b.unlocked
                ? const Color(0xFFE8F1FE)
                : const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: b.unlocked
                  ? kPrimaryBlue.withValues(alpha: 0.3)
                  : kCardBorder,
            ),
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: b.unlocked ? 1.0 : 0.28,
              child: Text(b.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          b.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: b.unlocked ? kTextDark : kTextMuted,
          ),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════
  //  TAB 4 — ACCOUNT
  // ═══════════════════════════════════════════

  Widget _buildAccountTab(
    BuildContext context,
    SchoolStateNotifier state,
    StudentProfile p,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          child: Column(
            children: [
              _cardHeader(
                'Profile Info',
                Icons.person_rounded,
                onEdit: () => _openEditProfileSheet(context, state, p),
              ),
              const SizedBox(height: 14),
              _tappableRow(
                Icons.person_rounded,
                'Name',
                _apiData?.fullName.isNotEmpty == true
                    ? _apiData!.fullName
                    : (p.name.isNotEmpty ? p.name : '—'),
                false,
                onTap: () => _openEditProfileSheet(context, state, p),
              ),
              _tappableRow(
                Icons.email_rounded,
                'Email',
                _apiData?.email ?? '—',
                false,
                onTap: () {},
              ),
              _tappableRow(
                Icons.school_rounded,
                'Grade',
                _apiData != null ? 'Class ${_apiData!.studentClass}' : p.grade,
                false,
                onTap: () => _openEditProfileSheet(context, state, p),
              ),
              _tappableRow(
                Icons.location_city_rounded,
                'School',
                _apiData?.schoolName.isNotEmpty == true
                    ? _apiData!.schoolName
                    : (p.school.isNotEmpty ? p.school : '—'),
                false,
                onTap: () => _openEditProfileSheet(context, state, p),
              ),
              _tappableRow(
                Icons.flag_rounded,
                'Goal',
                _apiData?.goal.isNotEmpty == true ? _apiData!.goal : '—',
                false,
                onTap: () => _openEditProfileSheet(context, state, p),
              ),
              _tappableRow(
                Icons.emoji_events_rounded,
                'Points',
                '${p.totalPoints} pts',
                false,
                onTap: () {},
              ),
              _tappableRow(
                Icons.local_fire_department_rounded,
                'Streak',
                '${p.streakDays} days',
                true,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _sectionCard(
          child: Column(
            children: [
              _cardHeader('Appearance', Icons.palette_rounded, onEdit: null),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _openAvatarPicker(context, state, p),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kPrimaryBlue.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.avatar,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Avatar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kTextDark,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Tap to change your emoji avatar',
                            style: TextStyle(fontSize: 11, color: kTextMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: kTextMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _sectionCard(
          child: Column(
            children: [
              _actionRow(
                Icons.help_outline_rounded,
                'Help & Support',
                kPrimaryBlue,
                const Color(0xFFE8F1FE),
                false,
                onTap: () => _showSnack('Opening Help & Support...'),
              ),
              _actionRow(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                kTextMuted,
                const Color(0xFFF0F4FF),
                false,
                onTap: () => _showSnack('Opening Privacy Policy...'),
              ),
              _actionRow(
                Icons.logout_rounded,
                'Sign Out',
                const Color(0xFFE53935),
                const Color(0xFFFCE8E6),
                true,
                onTap: () async {
                  await AuthService().clearTokens();
                  if (mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  SHARED WIDGETS
  // ─────────────────────────────────────────

  Widget _sectionCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kCardBorder),
    ),
    child: child,
  );

  Widget _cardHeader(
    String title,
    IconData icon, {
    required VoidCallback? onEdit,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: kTextDark,
          ),
        ),
        const Spacer(),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, size: 11, color: kPrimaryBlue),
                  SizedBox(width: 5),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isLast) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF0F4FF))),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: kPrimaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
          ],
        ),
      );

  Widget _tappableRow(
    IconData icon,
    String label,
    String value,
    bool isLast, {
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF0F4FF))),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: kPrimaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 15, color: kTextMuted),
        ],
      ),
    ),
  );

  Widget _actionRow(
    IconData icon,
    String label,
    Color iconColor,
    Color iconBg,
    bool isLast, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF0F4FF))),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLast ? const Color(0xFFE53935) : kTextDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 15,
              color: kTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCourseRow(Course c, CourseStatus status) {
    final color = status == CourseStatus.enrolled
        ? kEnrolledGreen
        : kInterestedAmber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(c.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  c.duration,
                  style: const TextStyle(fontSize: 10, color: kTextMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status == CourseStatus.enrolled ? 'Enrolled' : 'Saved',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String emoji, String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: kTextMuted, height: 1.6),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────
  //  EDIT PROFILE SHEET
  // ─────────────────────────────────────────

  void _openEditProfileSheet(
    BuildContext context,
    SchoolStateNotifier state,
    StudentProfile p,
  ) {
    final nameCtrl = TextEditingController(
      text: _apiData?.fullName.isNotEmpty == true ? _apiData!.fullName : p.name,
    );
    final schoolCtrl = TextEditingController(
      text: _apiData?.schoolName.isNotEmpty == true
          ? _apiData!.schoolName
          : p.school,
    );
    final goalCtrl = TextEditingController(
      text: _apiData?.goal.isNotEmpty == true ? _apiData!.goal : '',
    );
    String grade = _apiData != null
        ? 'Class ${_apiData!.studentClass}'
        : p.grade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimaryBlue, kDeepBlue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _editTextField(
                        nameCtrl,
                        'Full Name',
                        Icons.person_rounded,
                      ),
                      const SizedBox(height: 14),
                      _editTextField(
                        schoolCtrl,
                        'School Name',
                        Icons.location_city_rounded,
                      ),
                      const SizedBox(height: 14),
                      _editTextField(
                        goalCtrl,
                        'Goal (e.g. Engineer)',
                        Icons.flag_rounded,
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () async {
                          final picked = await _pickGrade(ctx, grade);
                          if (picked != null) {
                            setSheetState(() => grade = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kCardBorder, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                color: kTextMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  grade,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kTextDark,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.expand_more_rounded,
                                color: kTextMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _isSaving
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            final classNum =
                                int.tryParse(
                                  grade.replaceAll(RegExp(r'[^0-9]'), ''),
                                ) ??
                                0;
                            state.updateProfile(
                              p.copyWith(
                                name: nameCtrl.text.trim().isNotEmpty
                                    ? nameCtrl.text.trim()
                                    : p.name,
                                school: schoolCtrl.text.trim().isNotEmpty
                                    ? schoolCtrl.text.trim()
                                    : p.school,
                                grade: grade,
                              ),
                            );
                            Navigator.pop(ctx);
                            await _updateProfile(
                              fullName: nameCtrl.text.trim().isNotEmpty
                                  ? nameCtrl.text.trim()
                                  : (_apiData?.fullName ?? p.name),
                              schoolName: schoolCtrl.text.trim().isNotEmpty
                                  ? schoolCtrl.text.trim()
                                  : (_apiData?.schoolName ?? p.school),
                              goal: goalCtrl.text.trim(),
                              studentClass: classNum,
                            );
                            _strengthAnim
                              ..reset()
                              ..forward();
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _isSaving
                            ? null
                            : const LinearGradient(
                                colors: [kPrimaryBlue, kDeepBlue],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: _isSaving ? kTextMuted : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isSaving
                            ? null
                            : [
                                BoxShadow(
                                  color: kPrimaryBlue.withValues(alpha: 0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) => TextField(
    controller: ctrl,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: kTextDark,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 13,
        color: kTextMuted,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: kTextMuted, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kCardBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kCardBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
      ),
    ),
  );

  Future<String?> _pickGrade(BuildContext ctx, String current) =>
      showModalBottomSheet<String>(
        context: ctx,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: kCardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Grade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              ...kGradeOptions.map(
                (g) => ListTile(
                  title: Text(
                    g,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: g == current ? kPrimaryBlue : kTextDark,
                    ),
                  ),
                  trailing: g == current
                      ? const Icon(Icons.check_rounded, color: kPrimaryBlue)
                      : null,
                  onTap: () => Navigator.pop(ctx, g),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

  void _openAvatarPicker(
    BuildContext context,
    SchoolStateNotifier state,
    StudentProfile p,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: kCardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Avatar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 6,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: kAvatarOptions
                      .map(
                        (av) => GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            state.updateProfile(p.copyWith(avatar: av));
                            Navigator.pop(context);
                            _showSnack('Avatar updated!');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: av == p.avatar
                                  ? const Color(0xFFE8F1FE)
                                  : const Color(0xFFF4F7FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: av == p.avatar
                                    ? kPrimaryBlue
                                    : kCardBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                av,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: kPrimaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUB TAB PILL
// ─────────────────────────────────────────────

class _SubTabPill extends StatefulWidget {
  final int count;
  final String label;
  final int index;
  const _SubTabPill({
    required this.count,
    required this.label,
    required this.index,
  });
  @override
  State<_SubTabPill> createState() => _SubTabPillState();
}

class _SubTabPillState extends State<_SubTabPill> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DefaultTabController.of(context).addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DefaultTabController.of(context).removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = DefaultTabController.of(context);
    final selected = tc.index == widget.index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        tc.animateTo(widget.index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kPrimaryBlue : kCardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? kPrimaryBlue : kCardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : kTextMuted,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFE8F1FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.count}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE COURSE CARD (Interested tab — swipe to remove)
// ─────────────────────────────────────────────

class _ProfileCourseCard extends StatefulWidget {
  final Course course;
  final int index;
  final bool isEnrolled;
  final VoidCallback onRemove;
  const _ProfileCourseCard({
    required this.course,
    required this.index,
    required this.isEnrolled,
    required this.onRemove,
  });
  @override
  State<_ProfileCourseCard> createState() => _ProfileCourseCardState();
}

class _ProfileCourseCardState extends State<_ProfileCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final color = kInterestedAmber;
    final bgColor = const Color(0xFFFFF8F2);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: Key('pcc_${c.id}_saved'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE53935),
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (_) {
            HapticFeedback.mediumImpact();
            widget.onRemove();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: kTextMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            c.duration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.bar_chart_rounded,
                            size: 11,
                            color: kTextMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            c.level,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_rounded, size: 11, color: color),
                          const SizedBox(width: 4),
                          Text(
                            'Saved',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: kTextDark,
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
}

// ─────────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────────

class _BadgeData {
  final String emoji, label, description;
  final bool unlocked;
  const _BadgeData(this.emoji, this.label, this.description, this.unlocked);
}
