import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../api_services/authservice.dart';
import '../../services/api_config.dart';
import 'school_data.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kPrimaryBlue  = Color(0xFF1976D2);
const kDeepBlue     = Color(0xFF0D47A1);
const kBgPage       = Color(0xFFF4F7FF);
const kCardBg       = Color(0xFFFFFFFF);
const kCardBorder   = Color(0xFFE8EEF7);
const kTextDark     = Color(0xFF0A1931);
const kTextMuted    = Color(0xFF8A97B0);
const kEnrolledGreen  = Color(0xFF2E7D32);
const kInterestedAmber = Color(0xFFE65100);
const kSelectedBg   = Color(0xFFE8F1FE);
const kSkyBlue      = Color(0xFF38BDF8);
const kSuccess      = Color(0xFF16A34A);
const kWarning      = Color(0xFFF59E0B);

// ─────────────────────────────────────────────
//  SAFE HELPERS  (same pattern as engineering portal)
// ─────────────────────────────────────────────

String _str(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _dbl(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

bool _bool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}

// ─────────────────────────────────────────────
//  SCORE CATEGORY  (mirrors engineering portal)
// ─────────────────────────────────────────────

class SchoolScoreCategory {
  final String label;
  final IconData icon;
  final double earned;
  final double max;
  final Color color;
  final String hint;

  const SchoolScoreCategory({
    required this.label,
    required this.icon,
    required this.earned,
    required this.max,
    required this.color,
    required this.hint,
  });

  bool   get complete  => earned >= max;
  double get fraction  => (earned / max).clamp(0.0, 1.0);
}

// ─────────────────────────────────────────────
//  API MODELS
// ─────────────────────────────────────────────

class ApiSavedCourse {
  final int    courseId;
  final String title;
  final String description;
  final String savedAt;

  ApiSavedCourse({
    required this.courseId,
    required this.title,
    required this.description,
    required this.savedAt,
  });

  factory ApiSavedCourse.fromJson(Map<String, dynamic> json) => ApiSavedCourse(
    courseId:    json['course_id'] ?? 0,
    title:       json['title']       ?? '',
    description: json['description'] ?? '',
    savedAt:     json['saved_at']    ?? '',
  );
}

class ProfileApiData {
  final String fullName;
  final String email;
  final int    studentClass;
  final String schoolName;
  final String goal;
  final String? aboutMe;
  final String? profileImageUrl;
  final int    coursesEnrolled;
  final int    coursesCompleted;
  final int    achievements;
  final List<ApiCourse>      courses;
  final List<ApiSavedCourse> savedCourses;

  ProfileApiData({
    required this.fullName,
    required this.email,
    required this.studentClass,
    required this.schoolName,
    required this.goal,
    this.aboutMe,
    this.profileImageUrl,
    required this.coursesEnrolled,
    required this.coursesCompleted,
    required this.achievements,
    required this.courses,
    required this.savedCourses,
  });

  factory ProfileApiData.fromJson(Map<String, dynamic> json) {
    final user  = json['user']  as Map<String, dynamic>;
    final stats = json['stats'] as Map<String, dynamic>;
    final coursesList = (json['courses'] as List? ?? [])
        .map((c) => ApiCourse.fromJson(c as Map<String, dynamic>))
        .toList();
    final savedList = (json['savedCourses'] as List? ?? [])
        .map((c) => ApiSavedCourse.fromJson(c as Map<String, dynamic>))
        .toList();

    return ProfileApiData(
      fullName:         _str(user['full_name']),
      email:            _str(user['email']),
      studentClass:     _int(user[r'class']),
      schoolName:       _str(user['school_name']),
      goal:             _str(user['goal']),
      aboutMe:          user['about_me'] != null ? _str(user['about_me']) : null,
      profileImageUrl:  user['profile_image_url'] != null
          ? _str(user['profile_image_url'])
          : null,
      coursesEnrolled:  _int(stats['coursesEnrolled']),
      coursesCompleted: _int(stats['coursesCompleted']),
      achievements:     _int(stats['achievements']),
      courses:          coursesList,
      savedCourses:     savedList,
    );
  }

  // ── Score categories (school-flavoured, mirrors engineering ScoreCategory) ──
  List<SchoolScoreCategory> get scoreCategories => [
    SchoolScoreCategory(
      label: 'Basic Info',
      icon:  Icons.person_outline,
      earned: (fullName.isNotEmpty ? 5.0 : 0) +
          (email.isNotEmpty    ? 5.0 : 0) +
          (studentClass > 0    ? 5.0 : 0),
      max:   15,
      color: const Color(0xFF1D4ED8),
      hint:  'Fill in name, email and class',
    ),
    SchoolScoreCategory(
      label: 'School',
      icon:  Icons.location_city,
      earned: schoolName.isNotEmpty ? 10.0 : 0,
      max:   10,
      color: const Color(0xFF0EA5E9),
      hint:  'Add your school name (+10 pts)',
    ),
    SchoolScoreCategory(
      label: 'Goal',
      icon:  Icons.flag_outlined,
      earned: goal.isNotEmpty ? 8.0 : 0,
      max:   8,
      color: const Color(0xFF7C3AED),
      hint:  'Set your learning goal (+8 pts)',
    ),
    SchoolScoreCategory(
      label: 'Profile Photo',
      icon:  Icons.photo_camera_outlined,
      earned: (profileImageUrl != null && profileImageUrl!.isNotEmpty) ? 12.0 : 0,
      max:   12,
      color: const Color(0xFFEC4899),
      hint:  'Upload a profile photo (+12 pts)',
    ),
    SchoolScoreCategory(
      label: 'Enrolled',
      icon:  Icons.rocket_launch_outlined,
      earned: coursesEnrolled == 0 ? 0
          : coursesEnrolled >= 3 ? 20.0
          : coursesEnrolled >= 1 ? 12.0
          : 0,
      max:   20,
      color: const Color(0xFF059669),
      hint:  'Enroll in 3+ courses for full points',
    ),
    SchoolScoreCategory(
      label: 'Completed',
      icon:  Icons.workspace_premium_outlined,
      earned: coursesCompleted == 0 ? 0
          : coursesCompleted >= 2 ? 15.0
          : 8.0,
      max:   15,
      color: const Color(0xFFF59E0B),
      hint:  'Complete 2+ courses (+15 pts)',
    ),
    SchoolScoreCategory(
      label: 'Achievements',
      icon:  Icons.emoji_events_outlined,
      earned: achievements == 0  ? 0
          : achievements >= 3 ? 20.0
          : 10.0,
      max:   20,
      color: const Color(0xFFD97706),
      hint:  'Earn 3+ badges (+20 pts)',
    ),
  ];

  double get totalScore =>
      scoreCategories.fold(0.0, (sum, c) => sum + c.earned).clamp(0.0, 100.0);

  double get strength => (totalScore / 100.0).clamp(0.0, 1.0);

  String get scoreLevel {
    final s = totalScore;
    if (s >= 90) return '🏆 Elite';
    if (s >= 75) return '🚀 Advanced';
    if (s >= 55) return '⭐ Intermediate';
    if (s >= 35) return '📈 Beginner';
    return '🌱 Starter';
  }

  Color get scoreLevelColor {
    final s = totalScore;
    if (s >= 90) return const Color(0xFFD97706);
    if (s >= 75) return const Color(0xFF7C3AED);
    if (s >= 55) return kPrimaryBlue;
    if (s >= 35) return const Color(0xFF059669);
    return const Color(0xFF64748B);
  }

  String get strengthHint {
    if (profileImageUrl == null || profileImageUrl!.isEmpty)
      return 'Upload a profile photo (+12 pts)';
    if (schoolName.isEmpty)         return 'Add your school name (+10 pts)';
    if (goal.isEmpty)               return 'Set your goal (+8 pts)';
    if (coursesEnrolled < 3)        return 'Enroll in more courses (+pts)';
    if (coursesCompleted < 2)       return 'Complete a course (+15 pts)';
    return '🎉 Profile is looking great!';
  }
}

class ApiCourse {
  final int    courseId;
  final String title;
  final int    progress;
  final bool   completed;

  ApiCourse({
    required this.courseId,
    required this.title,
    required this.progress,
    required this.completed,
  });

  factory ApiCourse.fromJson(Map<String, dynamic> json) => ApiCourse(
    courseId:  json['course_id'] ?? 0,
    title:     json['title']     ?? '',
    progress:  _int(json['progress']),
    completed: _bool(json['completed']),
  );
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class SchoolProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SchoolProfileScreen({super.key, this.onBack});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen>
    with TickerProviderStateMixin {

  static String get _baseUrl => ApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();

  // ── API state ────────────────────────────
  ProfileApiData? _apiData;
  bool   _apiLoading = true;
  String? _apiError;
  bool   _isSaving        = false;
  bool   _isUploadingPhoto = false;
  File?  _localProfilePhoto;

  // ── Score expanded toggle ────────────────
  bool _scoreExpanded = false;

  // ── Animations ───────────────────────────
  late TabController            _tabCtrl;
  late AnimationController      _headerAnim;
  late Animation<double>        _headerFade;
  late Animation<Offset>        _headerSlide;
  late AnimationController      _xpAnim;
  late Animation<double>        _xpValue;
  late List<AnimationController> _catAnims;
  late List<Animation<double>>  _catValues;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _xpAnim  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _xpValue = Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));

    // 7 category bar animators
    _catAnims = List.generate(
      7,
          (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 900)),
    );
    _catValues = _catAnims
        .map((c) => Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOut))
    as Animation<double>)
        .toList();

    _tabCtrl = TabController(length: 4, vsync: this);
    _fetchProfile();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _catAnims) c.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  REBUILD ANIMATIONS after data loads
  // ─────────────────────────────────────────

  void _rebuildAnimations() {
    if (_apiData == null) return;

    _xpAnim.reset();
    _xpValue = Tween<double>(begin: 0, end: _apiData!.strength)
        .animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _xpAnim.forward();
    });

    final cats = _apiData!.scoreCategories;
    for (int i = 0; i < _catAnims.length && i < cats.length; i++) {
      _catAnims[i].reset();
      _catValues[i] = Tween<double>(begin: 0, end: cats[i].fraction)
          .animate(CurvedAnimation(parent: _catAnims[i], curve: Curves.easeOut));
      Future.delayed(Duration(milliseconds: 200 + i * 100), () {
        if (mounted) _catAnims[i].forward();
      });
    }
  }

  // ─────────────────────────────────────────
  //  GET — fetch profile
  // ─────────────────────────────────────────

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    setState(() { _apiLoading = true; _apiError = null; });

    try {
      final response =
      await AuthService().dio.get('/profile/profile-school');

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true) {
          final data = ProfileApiData.fromJson(
            body['data'] as Map<String, dynamic>,
          );
          if (mounted) {
            setState(() {
              _apiData    = data;
              _apiLoading = false;
            });
            _rebuildAnimations();
          }
        } else {
          if (mounted) setState(() {
            _apiError   = _str(body['message']) .isEmpty
                ? 'Something went wrong'
                : _str(body['message']);
            _apiLoading = false;
          });
        }
      }
    } on DioException catch (e) {
      if (mounted) setState(() {
        _apiError   = e.response?.data?['message'] ?? e.message ?? 'Request failed';
        _apiLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _apiError   = e.toString();
        _apiLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────
  //  PUT — update profile text fields
  // ─────────────────────────────────────────

  Future<void> _updateProfile({
    required String fullName,
    required String schoolName,
    required String goal,
    required int    studentClass,
  }) async {
    final userId = AuthService().userId;
    if (userId == null) { _showSnack('User ID not found. Please re-login.'); return; }

    setState(() => _isSaving = true);
    try {
      final response = await AuthService().dio.put(
        '/profile/getUsers',
        data: {
          'user_id':     userId,
          'full_name':   fullName,
          'school_name': schoolName,
          'goal':        goal,
          'class':       studentClass,
        },
      );
      if (response.statusCode == 200 &&
          (response.data as Map<String, dynamic>)['success'] == true) {
        await _fetchProfile();
        _showSnack('Profile updated successfully! ✅');
      } else {
        _showSnack(_str(response.data?['message']).isEmpty
            ? 'Update failed'
            : _str(response.data?['message']));
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
  //  UPLOAD PROFILE PHOTO  (mirrors engineering portal)
  // ─────────────────────────────────────────

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;

      final file = File(picked.path);
      if (!await file.exists()) {
        if (mounted) _showSnack('Could not read selected photo.');
        return;
      }

      final fileName = picked.name.isNotEmpty
          ? picked.name
          : 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() {
        _localProfilePhoto = file;
        _isUploadingPhoto  = true;
      });

      await AuthService().loadTokens();
      final token  = AuthService().accessToken;
      final userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) {
        setState(() { _isUploadingPhoto = false; _localProfilePhoto = null; });
        _showSnack('Session expired. Please re-login.');
        return;
      }

      final ext = fileName.split('.').last.toLowerCase();
      final mediaType = MediaType('image', ext == 'jpg' ? 'jpeg' : ext);

      final uri     = Uri.parse('$_baseUrl/profile/getUsers');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['user_id']     = userId
        ..fields['upload_type'] = 'profile'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
          contentType: mediaType,
        ));

      final streamed = await request.send();
      final res      = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        // Re-fetch profile so URL is updated from server
        await _fetchProfile();
        if (mounted) {
          setState(() {
            _localProfilePhoto = null;
            _isUploadingPhoto  = false;
          });
          _showSnack('Profile photo updated! ✅');
        }
      } else {
        if (mounted) {
          setState(() { _isUploadingPhoto = false; });
          _showSnack('Upload failed — showing local preview.');
        }
        debugPrint('uploadProfilePhoto error: ${res.body}');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() { _isUploadingPhoto = false; _localProfilePhoto = null; });
        if (e.code == 'photo_access_denied' || e.code == 'camera_access_denied') {
          _showPermissionDialog();
        } else {
          _showSnack('Could not open gallery: ${e.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isUploadingPhoto = false; _localProfilePhoto = null; });
        _showSnack('Error: $e');
      }
    }
  }

  // ─────────────────────────────────────────
  //  SHOW PHOTO / AVATAR PICKER SHEET
  // ─────────────────────────────────────────

  void _showPhotoPickerSheet(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      ) {
    final sw = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          int selectedTab = 0; // 0 = Gallery/Camera, 1 = Avatar

          return StatefulBuilder(
            builder: (ctx2, setTab) => Container(
              decoration: const BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(top: 14, bottom: 18),
                    decoration: BoxDecoration(
                      color: kCardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimaryBlue, kDeepBlue]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_camera,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text('Update Profile Picture',
                          style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800,
                            color: kTextDark,
                          )),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  // Tab selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      _tabPill('📷 Photo', selectedTab == 0,
                              () => setTab(() => selectedTab = 0), sw),
                      const SizedBox(width: 10),
                      _tabPill('😊 Avatar', selectedTab == 1,
                              () => setTab(() => selectedTab = 1), sw),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  if (selectedTab == 0) ...[
                    // ── Photo options ──────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: [
                        // Current photo preview
                        Center(
                          child: Container(
                            width: sw * 0.24,
                            height: sw * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: kPrimaryBlue.withValues(alpha: 0.35),
                                  width: 2.5),
                            ),
                            child: ClipOval(child: _buildAvatarWidget(sw, p, size: sw * 0.24)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isUploadingPhoto)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Column(children: [
                              CircularProgressIndicator(color: kPrimaryBlue),
                              SizedBox(height: 10),
                              Text('Uploading photo…',
                                  style: TextStyle(color: kTextMuted, fontSize: 13)),
                            ]),
                          )
                        else ...[
                          _photoOptionTile(
                            icon: Icons.photo_library_rounded,
                            label: 'Choose from Gallery',
                            sub: 'Pick any photo from your phone',
                            color: kPrimaryBlue,
                            onTap: () async {
                              Navigator.pop(context);
                              await _pickAndUploadPhoto(ImageSource.gallery);
                            },
                          ),
                          const SizedBox(height: 12),
                          _photoOptionTile(
                            icon: Icons.camera_alt_rounded,
                            label: 'Take a Photo',
                            sub: 'Use camera for an instant shot',
                            color: const Color(0xFF0EA5E9),
                            onTap: () async {
                              Navigator.pop(context);
                              await _pickAndUploadPhoto(ImageSource.camera);
                            },
                          ),
                          if (_apiData?.profileImageUrl != null &&
                              _apiData!.profileImageUrl!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _photoOptionTile(
                              icon: Icons.delete_outline_rounded,
                              label: 'Remove Current Photo',
                              sub: 'Revert to initials avatar',
                              color: Colors.red,
                              onTap: () {
                                Navigator.pop(context);
                                _showSnack('Use your avatar instead!');
                              },
                            ),
                          ],
                        ],
                      ]),
                    ),
                  ] else ...[
                    // ── Avatar options ─────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select an emoji avatar',
                              style: TextStyle(
                                fontSize: 13, color: kTextMuted,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 6,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: kAvatarOptions.map((av) {
                              final isSelected = av == p.avatar;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  SchoolStateProvider.of(context)
                                      .updateProfile(p.copyWith(avatar: av));
                                  Navigator.pop(context);
                                  _showSnack('Avatar updated!');
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE8F1FE)
                                        : const Color(0xFFF4F7FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? kPrimaryBlue : kCardBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(av,
                                        style: const TextStyle(fontSize: 24)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabPill(String label, bool active, VoidCallback onTap, double sw) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? kPrimaryBlue : kCardBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? kPrimaryBlue : kCardBorder,
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : kTextMuted,
            )),
      ),
    );
  }

  Widget _photoOptionTile({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: kTextDark,
                    )),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(fontSize: 11, color: kTextMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: kTextMuted, size: 20),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  AVATAR WIDGET (photo → local preview → initials)
  // ─────────────────────────────────────────

  Widget _buildAvatarWidget(double sw, StudentProfile p,
      {double? size}) {
    final s = size ?? sw * 0.22;

    if (_isUploadingPhoto && _localProfilePhoto != null) {
      return Stack(alignment: Alignment.center, children: [
        Image.file(_localProfilePhoto!, fit: BoxFit.cover,
            width: s, height: s,
            errorBuilder: (_, __, ___) => _initialsBox(s, p)),
        Container(
          width: s, height: s,
          color: Colors.black.withValues(alpha: 0.35),
          child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white)),
        ),
      ]);
    }

    if (_localProfilePhoto != null) {
      return Image.file(_localProfilePhoto!, fit: BoxFit.cover,
          width: s, height: s,
          errorBuilder: (_, __, ___) => _initialsBox(s, p));
    }

    final photoUrl = _apiData?.profileImageUrl ?? '';
    if (photoUrl.isNotEmpty) {
      return Image.network(photoUrl, fit: BoxFit.cover, width: s, height: s,
          loadingBuilder: (_, child, prog) {
            if (prog == null) return child;
            return Container(
              color: kPrimaryBlue,
              child: const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
            );
          },
          errorBuilder: (_, __, ___) => _initialsBox(s, p));
    }

    return _initialsBox(s, p);
  }

  Widget _initialsBox(double s, StudentProfile p) {
    final name = _apiData?.fullName.isNotEmpty == true
        ? _apiData!.fullName
        : p.name;
    return Container(
      width: s, height: s, color: kPrimaryBlue,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : p.avatar,
          style: TextStyle(
            fontSize: s * 0.38,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  PERMISSION DIALOG
  // ─────────────────────────────────────────

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kCardBg,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.no_photography_rounded,
                color: kWarning, size: 48),
            const SizedBox(height: 16),
            const Text('Photo Access Denied',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: kTextDark)),
            const SizedBox(height: 10),
            const Text(
                'Please allow photo access in your device\nSettings → Privacy → Photos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kTextMuted, height: 1.55)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kCardBorder, width: 1.5)),
                    child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                color: kTextMuted, fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await const MethodChannel('flutter/platform')
                          .invokeMethod('openAppSettings');
                    } catch (_) {}
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kPrimaryBlue, kDeepBlue]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Text('Open Settings',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800))),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_apiLoading) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: kPrimaryBlue),
            SizedBox(height: 16),
            Text('Loading profile…',
                style: TextStyle(fontSize: 14, color: kTextMuted)),
          ]),
        ),
      );
    }

    if (_apiError != null) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: kTextMuted),
              const SizedBox(height: 12),
              Text('Failed to load profile\n$_apiError',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: kTextMuted)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _fetchProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                      color: kPrimaryBlue,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('Retry',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: SchoolStateProvider.of(context),
      builder: (_, __) {
        final state   = SchoolStateProvider.of(context);
        final profile = state.profile;
        final sw      = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: kBgPage,
          body: Column(children: [
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(context, state, profile, sw),
              ),
            ),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildOverviewTab(context, state, profile, sw),
                  _buildCoursesTab(context, state, sw),
                  _buildAchievementsTab(state, sw),
                  _buildAccountTab(context, state, profile, sw),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      double sw,
      ) {
    final savedCount = _apiData?.savedCourses.length ?? 0;

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
        child: Column(children: [
          // ── Top bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _iconBtn(Icons.arrow_back_ios_new_rounded, () {
                HapticFeedback.lightImpact();
                widget.onBack?.call();
              }),
              const Spacer(),
              const Text('My Profile',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -0.2,
                  )),
              const Spacer(),
              _iconBtn(Icons.edit_rounded,
                      () => _openEditProfileSheet(context, state, p)),
              const SizedBox(width: 8),
              _iconBtn(Icons.logout_rounded, () async {
                HapticFeedback.lightImpact();
                await AuthService().clearTokens();
                if (mounted) context.go('/login');
              }),
            ]),
          ),

          // ── Avatar + info ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Tappable avatar with camera badge
              GestureDetector(
                onTap: () => _showPhotoPickerSheet(context, state, p),
                child: Stack(children: [
                  Container(
                    width: sw * 0.20,
                    height: sw * 0.20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.50),
                          width: 2.5),
                      boxShadow: [
                        BoxShadow(
                            color: kDeepBlue.withValues(alpha: 0.40),
                            blurRadius: 14, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarWidget(sw, p, size: sw * 0.20),
                    ),
                  ),
                  // Camera + icon badge
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: sw * 0.075,
                      height: sw * 0.075,
                      decoration: BoxDecoration(
                        color: kSkyBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: kDeepBlue, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: kSkyBlue.withValues(alpha: 0.40),
                              blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: _isUploadingPhoto
                          ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : Icon(Icons.add_a_photo_rounded,
                          color: Colors.white, size: sw * 0.035),
                    ),
                  ),
                ]),
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
                          fontSize: 20, fontWeight: FontWeight.w900,
                          color: Colors.white, letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _profileChip(Icons.school_rounded,
                          _apiData != null
                              ? 'Class ${_apiData!.studentClass}'
                              : p.grade),
                      const SizedBox(height: 4),
                      _profileChip(Icons.location_city_rounded,
                          _apiData?.schoolName.isNotEmpty == true
                              ? _apiData!.schoolName
                              : p.school),
                      if (_apiData?.goal.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        _profileChip(Icons.flag_rounded, _apiData!.goal),
                      ],
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _openEditProfileSheet(context, state, p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.edit_rounded,
                                size: 11, color: Colors.white),
                            const SizedBox(width: 5),
                            Text('Edit Profile',
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.90),
                                )),
                          ]),
                        ),
                      ),
                    ]),
              ),
            ]),
          ),

          // ── Stats bar ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _hStat(
                    '${_apiData?.coursesEnrolled ?? 0}',
                    'Enrolled',
                    Icons.rocket_launch_rounded,
                  ),
                  _hDiv(),
                  _hStat(
                    '${_apiData?.savedCourses.length ?? 0}',
                    'Saved',
                    Icons.bookmark_rounded,
                  ),
                  _hDiv(),
                  _hStat(
                    '${_apiData?.totalScore.toInt() ?? 0}',
                    'Score',
                    Icons.bolt,
                  ),
                  _hDiv(),
                  _hStat(
                    '${_apiData?.achievements ?? 0}',
                    'Badges',
                    Icons.emoji_events_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

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
          fontSize: 12.5, fontWeight: FontWeight.w600),
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
  //  TAB 1 — OVERVIEW  (now fully dynamic)
  // ═══════════════════════════════════════════

  Widget _buildOverviewTab(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      double sw,
      ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Dynamic Score Card (mirrors engineering) ──
        _buildDynamicScoreCard(sw),
        const SizedBox(height: 16),

        // ── About me ──
        if (_apiData?.aboutMe?.isNotEmpty == true)
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader('About Me', Icons.notes, onEdit: null),
                const SizedBox(height: 12),
                Text(_apiData!.aboutMe!,
                    style: const TextStyle(
                        fontSize: 13, color: kTextMuted, height: 1.6)),
              ],
            ),
          ),
        if (_apiData?.aboutMe?.isNotEmpty == true)
          const SizedBox(height: 16),

        // ── Account details ──
        _sectionCard(
          child: Column(children: [
            _cardHeader('Account Details', Icons.person_rounded,
                onEdit: () => _openEditProfileSheet(context, state, p)),
            const SizedBox(height: 14),
            _infoRow(Icons.person_rounded, 'Name',
                _apiData?.fullName.isNotEmpty == true
                    ? _apiData!.fullName
                    : (p.name.isNotEmpty ? p.name : '—'),
                false),
            _infoRow(Icons.email_rounded, 'Email',
                _apiData?.email ?? '—', false),
            _infoRow(Icons.school_rounded, 'Class',
                _apiData != null ? 'Class ${_apiData!.studentClass}' : p.grade,
                false),
            _infoRow(Icons.location_city_rounded, 'School',
                _apiData?.schoolName.isNotEmpty == true
                    ? _apiData!.schoolName
                    : (p.school.isNotEmpty ? p.school : '—'),
                false),
            _infoRow(Icons.flag_rounded, 'Goal',
                _apiData?.goal.isNotEmpty == true ? _apiData!.goal : '—',
                true),
          ]),
        ),
        const SizedBox(height: 16),

        // ── API Stats Banner ──
        _buildApiStatsBanner(),
        const SizedBox(height: 16),

        // ── Enrolled courses preview ──
        if (_apiData != null && _apiData!.courses.isNotEmpty)
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeader('Enrolled Courses', Icons.rocket_launch_rounded,
                    onEdit: () => _tabCtrl.animateTo(1)),
                const SizedBox(height: 14),
                ..._apiData!.courses.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FE),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Icon(Icons.book_rounded,
                              color: kPrimaryBlue, size: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: kTextDark),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: c.progress / 100,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFE8F1FE),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  kPrimaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${c.progress}%',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800,
                            color: kPrimaryBlue)),
                  ]),
                )),
                if (_apiData!.courses.length > 3)
                  GestureDetector(
                    onTap: () => _tabCtrl.animateTo(1),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('View all courses →',
                          style: TextStyle(
                              fontSize: 12, color: kPrimaryBlue,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
        if (_apiData != null && _apiData!.courses.isNotEmpty)
          const SizedBox(height: 16),

        // ── Saved courses ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Saved Courses', Icons.bookmark_rounded,
                  onEdit: () => _tabCtrl.animateTo(1)),
              const SizedBox(height: 14),
              if (_apiData?.savedCourses.isEmpty ?? true)
                _emptyHint('🔖', 'Nothing bookmarked yet.')
              else
                ...(_apiData!.savedCourses.take(2)
                    .map((c) => _miniApiSavedRow(c))),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  DYNAMIC SCORE CARD  (mirrors engineering exactly)
  // ─────────────────────────────────────────

  Widget _buildDynamicScoreCard(double sw) {
    if (_apiData == null) return const SizedBox.shrink();

    final cats       = _apiData!.scoreCategories;
    final total      = _apiData!.totalScore.toInt();
    final level      = _apiData!.scoreLevel;
    final levelColor = _apiData!.scoreLevelColor;
    final completed  = cats.where((c) => c.complete).length;

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1A1040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: kDeepBlue.withValues(alpha: 0.22),
              blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + title + circle ──
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: sw * 0.100,
              height: sw * 0.100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kPrimaryBlue, kSkyBlue]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.bolt, color: Colors.white, size: sw * 0.048),
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile Score',
                      style: TextStyle(
                          fontSize: sw * 0.036, fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  SizedBox(height: sw * 0.005),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.022, vertical: sw * 0.007),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: levelColor.withValues(alpha: 0.40)),
                    ),
                    child: Text(level,
                        style: TextStyle(
                            fontSize: sw * 0.022, color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: sw * 0.008),
                  Text('$completed/${cats.length} categories complete',
                      style: TextStyle(
                          fontSize: sw * 0.022,
                          color: Colors.white.withValues(alpha: 0.50))),
                ],
              ),
            ),
            // Circular score ring
            SizedBox(
              width: sw * 0.165,
              height: sw * 0.165,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: sw * 0.165,
                  height: sw * 0.165,
                  child: AnimatedBuilder(
                    animation: _xpValue,
                    builder: (_, __) => CircularProgressIndicator(
                      value: _xpValue.value,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                    ),
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedBuilder(
                    animation: _xpValue,
                    builder: (_, __) => Text(
                      '${(_xpValue.value * 100).toInt()}',
                      style: TextStyle(
                          fontSize: sw * 0.050, fontWeight: FontWeight.w900,
                          color: kSkyBlue, letterSpacing: -1),
                    ),
                  ),
                  Text('/100',
                      style: TextStyle(
                          fontSize: sw * 0.020,
                          color: Colors.white.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
          ]),
          SizedBox(height: sw * 0.030),

          // ── Overall progress bar ──
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _xpValue,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _xpValue.value,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: sw * 0.018),
            Text('$total pts',
                style: TextStyle(
                    fontSize: sw * 0.026, fontWeight: FontWeight.w800,
                    color: kSkyBlue)),
          ]),
          SizedBox(height: sw * 0.030),

          // ── Hint ──
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.028, vertical: sw * 0.018),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(children: [
              Icon(Icons.tips_and_updates, color: kSkyBlue, size: sw * 0.030),
              SizedBox(width: sw * 0.015),
              Expanded(
                child: Text(_apiData!.strengthHint,
                    style: TextStyle(
                        fontSize: sw * 0.024,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontStyle: FontStyle.italic),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          SizedBox(height: sw * 0.030),

          // ── Category rows ──
          ..._buildCategoryRows(cats, sw),

          // ── Expand / collapse ──
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _scoreExpanded = !_scoreExpanded);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.022),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _scoreExpanded ? 'Show less' : 'See full breakdown',
                    style: TextStyle(
                        fontSize: sw * 0.026, fontWeight: FontWeight.w700,
                        color: kSkyBlue),
                  ),
                  SizedBox(width: sw * 0.012),
                  Icon(
                    _scoreExpanded ? Icons.expand_less : Icons.expand_more,
                    color: kSkyBlue, size: sw * 0.028,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sw * 0.022),

          // ── CTA ──
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showPhotoPickerSheet(
                context,
                SchoolStateProvider.of(context),
                SchoolStateProvider.of(context).profile,
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.030),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [kPrimaryBlue, levelColor],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: kPrimaryBlue.withValues(alpha: 0.30),
                      blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bolt, color: Colors.white, size: sw * 0.036),
                  SizedBox(width: sw * 0.015),
                  Text('Boost My Score',
                      style: TextStyle(
                          fontSize: sw * 0.030, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: 0.2)),
                  SizedBox(width: sw * 0.012),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.70),
                      size: sw * 0.026),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryRows(List<SchoolScoreCategory> cats, double sw) {
    final List<SchoolScoreCategory> toShow;
    if (_scoreExpanded) {
      toShow = cats;
    } else {
      final incomplete = cats.where((c) => !c.complete).take(3).toList();
      final complete   = cats.where((c) =>  c.complete).toList();
      toShow = [...incomplete, ...complete];
    }

    return toShow.asMap().entries.map((entry) {
      final i   = cats.indexOf(entry.value);
      final cat = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: sw * 0.024),
        child: _categoryRow(cat, i, sw),
      );
    }).toList();
  }

  Widget _categoryRow(SchoolScoreCategory cat, int index, double sw) {
    final animValue = (index < _catValues.length)
        ? _catValues[index]
        : const AlwaysStoppedAnimation<double>(0);

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: sw * 0.068,
        height: sw * 0.068,
        decoration: BoxDecoration(
          color: cat.complete
              ? cat.color.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: cat.complete
                ? cat.color.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Icon(
          cat.complete ? Icons.check_rounded : cat.icon,
          size: sw * 0.030,
          color: cat.complete
              ? cat.color
              : Colors.white.withValues(alpha: 0.55),
        ),
      ),
      SizedBox(width: sw * 0.018),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(cat.label,
                style: TextStyle(
                    fontSize: sw * 0.026, fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const Spacer(),
            Text('${cat.earned.toInt()}/${cat.max.toInt()} pts',
                style: TextStyle(
                    fontSize: sw * 0.022, fontWeight: FontWeight.w700,
                    color: cat.complete
                        ? cat.color
                        : Colors.white.withValues(alpha: 0.50))),
          ]),
          SizedBox(height: sw * 0.007),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedBuilder(
              animation: animValue,
              builder: (_, __) => LinearProgressIndicator(
                value: animValue.value,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation<Color>(
                  cat.complete ? cat.color : cat.color.withValues(alpha: 0.70),
                ),
              ),
            ),
          ),
          if (!cat.complete) ...[
            SizedBox(height: sw * 0.005),
            Text(cat.hint,
                style: TextStyle(
                    fontSize: sw * 0.020,
                    color: Colors.white.withValues(alpha: 0.38)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ]),
      ),
    ]);
  }

  // ─────────────────────────────────────────
  //  API STATS BANNER
  // ─────────────────────────────────────────

  Widget _buildApiStatsBanner() {
    if (_apiData == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [kPrimaryBlue, kDeepBlue],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.insights_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text('Your Stats',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const Spacer(),
            if (_apiData!.goal.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Goal: ${_apiData!.goal}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
          ]),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _apiBanner('${_apiData!.coursesEnrolled}', 'Enrolled',  '🚀'),
              _apiBanner('${_apiData!.coursesCompleted}', 'Completed', '🎓'),
              _apiBanner('${_apiData!.achievements}',     'Badges',    '🏅'),
              _apiBanner('${_apiData!.savedCourses.length}', 'Saved',  '🔖'),
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
      Text(value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900,
              color: Colors.white)),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600)),
    ],
  );

  // ═══════════════════════════════════════════
  //  TAB 2 — COURSES (dynamic from API)
  // ═══════════════════════════════════════════

  Widget _buildCoursesTab(
      BuildContext context,
      SchoolStateNotifier state,
      double sw,
      ) {
    final apiCourses = _apiData?.courses ?? [];
    final apiSaved   = _apiData?.savedCourses ?? [];

    return DefaultTabController(
      length: 2,
      child: Column(children: [
        Container(
          color: kCardBg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            _subTabPill(apiCourses.length, '🚀 Enrolled', 0),
            const SizedBox(width: 10),
            _subTabPill(apiSaved.length, '🔖 Saved', 1),
          ]),
        ),
        Expanded(
          child: TabBarView(children: [
            _apiEnrolledList(apiCourses),
            _apiSavedList(apiSaved),
          ]),
        ),
      ]),
    );
  }

  Widget _apiEnrolledList(List<ApiCourse> courses) {
    if (courses.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🚀', style: TextStyle(fontSize: 42)),
          SizedBox(height: 12),
          Text('No enrolled courses yet.\nGo to Courses and hit Enroll!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: kTextMuted, height: 1.6)),
        ]),
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
                color: kEnrolledGreen.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FE),
                  borderRadius: BorderRadius.circular(14)),
              child: const Center(
                  child: Icon(Icons.book_rounded,
                      color: kPrimaryBlue, size: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.progress / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE8F1FE),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          kPrimaryBlue),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${c.progress}% complete',
                      style: const TextStyle(
                          fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: kEnrolledGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle_rounded,
                      size: 11, color: kEnrolledGreen),
                  SizedBox(width: 4),
                  Text('Enrolled',
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: kEnrolledGreen)),
                ]),
              ),
              if (c.completed) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: kPrimaryBlue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('✅ Done',
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: kPrimaryBlue)),
                ),
              ],
            ]),
          ]),
        );
      },
    );
  }

  Widget _apiSavedList(List<ApiSavedCourse> courses) {
    if (courses.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🔖', style: TextStyle(fontSize: 42)),
          SizedBox(height: 12),
          Text('Nothing saved yet.\nGo to Courses and tap Save!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: kTextMuted, height: 1.6)),
        ]),
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
            color: const Color(0xFFFFF8F2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: kInterestedAmber.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  color: kInterestedAmber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14)),
              child: const Center(
                  child: Icon(Icons.bookmark_rounded,
                      color: kInterestedAmber, size: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  if (c.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(c.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: kTextMuted)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: kInterestedAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.bookmark_rounded, size: 11, color: kInterestedAmber),
                SizedBox(width: 4),
                Text('Saved',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: kInterestedAmber)),
              ]),
            ),
          ]),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  //  TAB 3 — ACHIEVEMENTS (dynamic)
  // ═══════════════════════════════════════════

  Widget _buildAchievementsTab(SchoolStateNotifier state, double sw) {
    final p        = state.profile;
    final enrolled = _apiData?.coursesEnrolled ?? 0;
    final saved    = _apiData?.savedCourses.length ?? 0;
    final completed = _apiData?.coursesCompleted ?? 0;

    final badges = [
      _BadgeData('🏅', 'First Enroll',  'Enroll in your first course',   enrolled >= 1),
      _BadgeData('🔖', 'Explorer',      'Bookmark a course',              saved >= 1),
      _BadgeData('🎓', 'Multi-Course',  'Enroll in 2+ courses',           enrolled >= 2),
      _BadgeData('✅', 'Completer',     'Complete your first course',      completed >= 1),
      _BadgeData('⭐', 'Point Champ',   'Earn 1000+ XP points',           p.totalPoints >= 1000),
      _BadgeData('🚀', 'Overachiever',  'Enroll in 5+ courses',           enrolled >= 5),
    ];
    final unlocked = badges.where((b) => b.unlocked).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Banner ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kPrimaryBlue, kDeepBlue],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$unlocked / ${badges.length} Unlocked',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: unlocked / badges.length,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
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
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Badges grid ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Badges',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: kTextDark)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: badges.map((b) => _badgeTile(b)).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Stats ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stats',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: kTextDark)),
              const SizedBox(height: 14),
              _statProgressRow('Courses Enrolled', enrolled, 5, kPrimaryBlue),
              const SizedBox(height: 12),
              _statProgressRow('Courses Completed', completed, 3,
                  const Color(0xFF059669)),
              const SizedBox(height: 12),
              _statProgressRow('XP Points', p.totalPoints, 1000,
                  const Color(0xFFFFB300)),
              const SizedBox(height: 12),
              _statProgressRow('Saved Courses', saved, 5, kInterestedAmber),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _badgeTile(_BadgeData b) => GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(b.unlocked
            ? '${b.emoji} ${b.label} — Unlocked!'
            : '${b.emoji} ${b.label} — ${b.description}'),
        backgroundColor: b.unlocked ? kEnrolledGreen : kTextMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ));
    },
    child: Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity, height: 70,
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
            child: Text(b.emoji,
                style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(b.label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: b.unlocked ? kTextDark : kTextMuted)),
    ]),
  );

  Widget _statProgressRow(String label, int value, int max, Color color) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: kTextDark)),
        ),
        Text('$value / $max',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          backgroundColor: const Color(0xFFE8F1FE),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════
  //  TAB 4 — ACCOUNT (dynamic)
  // ═══════════════════════════════════════════

  Widget _buildAccountTab(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      double sw,
      ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          child: Column(children: [
            _cardHeader('Profile Info', Icons.person_rounded,
                onEdit: () => _openEditProfileSheet(context, state, p)),
            const SizedBox(height: 14),
            _tappableRow(Icons.person_rounded, 'Name',
                _apiData?.fullName.isNotEmpty == true
                    ? _apiData!.fullName
                    : (p.name.isNotEmpty ? p.name : '—'),
                false,
                onTap: () => _openEditProfileSheet(context, state, p)),
            _tappableRow(Icons.email_rounded, 'Email',
                _apiData?.email ?? '—', false, onTap: () {}),
            _tappableRow(Icons.school_rounded, 'Grade',
                _apiData != null ? 'Class ${_apiData!.studentClass}' : p.grade,
                false,
                onTap: () => _openEditProfileSheet(context, state, p)),
            _tappableRow(Icons.location_city_rounded, 'School',
                _apiData?.schoolName.isNotEmpty == true
                    ? _apiData!.schoolName
                    : (p.school.isNotEmpty ? p.school : '—'),
                false,
                onTap: () => _openEditProfileSheet(context, state, p)),
            _tappableRow(Icons.flag_rounded, 'Goal',
                _apiData?.goal.isNotEmpty == true ? _apiData!.goal : '—',
                false,
                onTap: () => _openEditProfileSheet(context, state, p)),
            _tappableRow(Icons.emoji_events_rounded, 'Profile Score',
                '${_apiData?.totalScore.toInt() ?? 0} / 100 pts', true,
                onTap: () {}),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Appearance ──
        _sectionCard(
          child: Column(children: [
            _cardHeader('Appearance', Icons.palette_rounded, onEdit: null),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showPhotoPickerSheet(context, state, p),
              child: Row(children: [
                Container(
                  width: sw * 0.15,
                  height: sw * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: kPrimaryBlue.withValues(alpha: 0.30),
                        width: 2),
                  ),
                  child: ClipOval(
                      child: _buildAvatarWidget(sw, p, size: sw * 0.15)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile Picture / Avatar',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: kTextDark)),
                      SizedBox(height: 3),
                      Text('Tap to change photo or choose an emoji avatar',
                          style: TextStyle(fontSize: 11, color: kTextMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: kTextMuted),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Actions ──
        _sectionCard(
          child: Column(children: [
            _actionRow(
              Icons.help_outline_rounded, 'Help & Support',
              kPrimaryBlue, const Color(0xFFE8F1FE), false,
              onTap: () => _showSnack('Opening Help & Support…'),
            ),
            _actionRow(
              Icons.privacy_tip_outlined, 'Privacy Policy',
              kTextMuted, const Color(0xFFF0F4FF), false,
              onTap: () => _showSnack('Opening Privacy Policy…'),
            ),
            _actionRow(
              Icons.logout_rounded, 'Sign Out',
              const Color(0xFFE53935), const Color(0xFFFCE8E6), true,
              onTap: () async {
                await AuthService().clearTokens();
                if (mounted) context.go('/login');
              },
            ),
          ]),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  EDIT PROFILE SHEET
  // ─────────────────────────────────────────

  void _openEditProfileSheet(
      BuildContext context,
      SchoolStateNotifier state,
      StudentProfile p,
      ) {
    final nameCtrl   = TextEditingController(
        text: _apiData?.fullName.isNotEmpty == true ? _apiData!.fullName : p.name);
    final schoolCtrl = TextEditingController(
        text: _apiData?.schoolName.isNotEmpty == true
            ? _apiData!.schoolName
            : p.school);
    final goalCtrl   = TextEditingController(
        text: _apiData?.goal.isNotEmpty == true ? _apiData!.goal : '');
    String grade     = _apiData != null
        ? 'Class ${_apiData!.studentClass}'
        : p.grade;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kPrimaryBlue, kDeepBlue]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: kTextDark)),
                ]),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(children: [
                    _editTextField(nameCtrl, 'Full Name',     Icons.person_rounded),
                    const SizedBox(height: 14),
                    _editTextField(schoolCtrl, 'School Name', Icons.location_city_rounded),
                    const SizedBox(height: 14),
                    _editTextField(goalCtrl, 'Goal (e.g. Software Engineer)',
                        Icons.flag_rounded),
                    const SizedBox(height: 14),
                    // Grade picker
                    GestureDetector(
                      onTap: () async {
                        final picked = await _pickGrade(ctx, grade);
                        if (picked != null) setSheetState(() => grade = picked);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kCardBorder, width: 1.5),
                        ),
                        child: Row(children: [
                          const Icon(Icons.school_rounded,
                              color: kTextMuted, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(grade,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: kTextDark)),
                          ),
                          const Icon(Icons.expand_more_rounded,
                              color: kTextMuted),
                        ]),
                      ),
                    ),
                  ]),
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
                        int.tryParse(grade.replaceAll(
                            RegExp(r'[^0-9]'), '')) ??
                            0;
                    state.updateProfile(p.copyWith(
                      name:   nameCtrl.text.trim().isNotEmpty
                          ? nameCtrl.text.trim() : p.name,
                      school: schoolCtrl.text.trim().isNotEmpty
                          ? schoolCtrl.text.trim() : p.school,
                      grade:  grade,
                    ));
                    Navigator.pop(ctx);
                    await _updateProfile(
                      fullName:    nameCtrl.text.trim().isNotEmpty
                          ? nameCtrl.text.trim()
                          : (_apiData?.fullName ?? p.name),
                      schoolName:  schoolCtrl.text.trim().isNotEmpty
                          ? schoolCtrl.text.trim()
                          : (_apiData?.schoolName ?? p.school),
                      goal:        goalCtrl.text.trim(),
                      studentClass: classNum,
                    );
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
                          end: Alignment.centerRight),
                      color: _isSaving ? kTextMuted : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isSaving
                          ? null
                          : [
                        BoxShadow(
                            color: kPrimaryBlue.withValues(alpha: 0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white)))
                          : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SHARED HELPER WIDGETS
  // ─────────────────────────────────────────

  Widget _sectionCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder)),
    child: child,
  );

  Widget _cardHeader(String title, IconData icon,
      {required VoidCallback? onEdit}) {
    return Row(children: [
      Icon(icon, size: 18, color: kPrimaryBlue),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w800, color: kTextDark)),
      const Spacer(),
      if (onEdit != null)
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFE8F1FE),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.edit_rounded, size: 11, color: kPrimaryBlue),
              SizedBox(width: 5),
              Text('Edit',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: kPrimaryBlue)),
            ]),
          ),
        ),
    ]);
  }

  Widget _infoRow(
      IconData icon, String label, String value, bool isLast) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
              bottom: BorderSide(color: Color(0xFFF0F4FF))),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: kPrimaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: kTextMuted)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: kTextDark)),
        ]),
      );

  Widget _tappableRow(
      IconData icon, String label, String value, bool isLast, {
        required VoidCallback onTap,
      }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                bottom: BorderSide(color: Color(0xFFF0F4FF))),
          ),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 15, color: kPrimaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: kTextMuted)),
            ),
            Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: kTextDark),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 15, color: kTextMuted),
          ]),
        ),
      );

  Widget _actionRow(
      IconData icon, String label, Color iconColor, Color iconBg, bool isLast, {
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
              : const Border(
              bottom: BorderSide(color: Color(0xFFF0F4FF))),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isLast ? const Color(0xFFE53935) : kTextDark)),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 15, color: kTextMuted),
        ]),
      ),
    );
  }

  Widget _miniApiSavedRow(ApiSavedCourse c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: kInterestedAmber.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
              child: Icon(Icons.bookmark_rounded,
                  color: kInterestedAmber, size: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: kTextDark),
                  overflow: TextOverflow.ellipsis),
              if (c.description.isNotEmpty)
                Text(c.description,
                    style: const TextStyle(
                        fontSize: 10, color: kTextMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: kInterestedAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20)),
          child: const Text('Saved',
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800,
                  color: kInterestedAmber)),
        ),
      ]),
    );
  }

  Widget _emptyHint(String emoji, String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 32)),
      const SizedBox(height: 8),
      Text(msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, color: kTextMuted, height: 1.6)),
    ]),
  );

  // ─────────────────────────────────────────
  //  EDIT TEXT FIELD
  // ─────────────────────────────────────────

  Widget _editTextField(
      TextEditingController ctrl, String label, IconData icon) =>
      TextField(
        controller: ctrl,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w600),
          prefixIcon: Icon(icon, color: kTextMuted, size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kCardBorder, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kCardBorder, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                  color: kCardBorder, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 16),
            const Text('Select Grade',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: kTextDark)),
            const SizedBox(height: 8),
            ...kGradeOptions.map((g) => ListTile(
              title: Text(g,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: g == current ? kPrimaryBlue : kTextDark)),
              trailing: g == current
                  ? const Icon(Icons.check_rounded, color: kPrimaryBlue)
                  : null,
              onTap: () => Navigator.pop(ctx, g),
            )),
            const SizedBox(height: 16),
          ]),
        ),
      );

  // ─────────────────────────────────────────
  //  SMALL SHARED WIDGETS
  // ─────────────────────────────────────────

  Widget _hStat(String value, String label, IconData icon) => Column(
    children: [
      Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.80)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65))),
    ],
  );

  Widget _hDiv() => Container(
    width: 1, height: 32,
    color: Colors.white.withValues(alpha: 0.20),
  );

  Widget _profileChip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.75)),
      const SizedBox(width: 5),
      Flexible(
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ),
    ],
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: Colors.white, size: 16),
    ),
  );

  Widget _subTabPill(int count, String label, int index) =>
      _SubTabPill(count: count, label: label, index: index);

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: kPrimaryBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────────────────────
//  SUB TAB PILL  (unchanged from original)
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
    final tc       = DefaultTabController.of(context);
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
              color: selected ? kPrimaryBlue : kCardBorder, width: 1.5),
        ),
        child: Row(children: [
          Text(widget.label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : kTextMuted)),
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
            child: Text('${widget.count}',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : kPrimaryBlue)),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────────

class _BadgeData {
  final String emoji, label, description;
  final bool   unlocked;
  const _BadgeData(this.emoji, this.label, this.description, this.unlocked);
}
