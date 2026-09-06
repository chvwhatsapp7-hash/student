import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api_services/authservice.dart';
import '../../services/api_config.dart';

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

// ═══════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════

/// Safely converts any value to String — never throws.
String _str(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

/// Safely converts any value to int — never throws.
int _int(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Safely converts any value to double — never throws.
double _dbl(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

/// Safely converts any value to bool — never throws.
bool _bool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}

// ═══════════════════════════════════════════════════════
//  SCORE CATEGORY MODEL
// ═══════════════════════════════════════════════════════
class ScoreCategory {
  final String label;
  final IconData icon;
  final double earned;
  final double max;
  final Color color;
  final String hint;

  const ScoreCategory({
    required this.label,
    required this.icon,
    required this.earned,
    required this.max,
    required this.color,
    required this.hint,
  });

  bool get complete => earned >= max;
  double get fraction => (earned / max).clamp(0.0, 1.0);
}

// ═══════════════════════════════════════════════════════
//  PROFILE STATE
// ═══════════════════════════════════════════════════════
class ProfileState extends ChangeNotifier {
  String name = '',
      degree = '',
      college = '',
      location = '',
      email = '',
      phone = '',
      linkedin = '',
      github = '',
      about = '',
      resumeName = '',
      profilePhotoUrl = '';

  String goal = '';
  String status = '';
  int age = 0;
  String graduationYear = '';

  String schoolName = '';
  String studentClass = '';
  String roleName = '';
  int roleId = 0;
  bool get isSchoolUser => roleId == 2;

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> certifications = [];
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> applications = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> hackathons = [];

  double get strength {
    double s = 0.30;
    if (about.length > 30) s += 0.08;
    if (resumeName.isNotEmpty) s += 0.15;
    if (skills.length >= 3) s += 0.10;
    if (skills.length >= 5) s += 0.05;
    if (certifications.isNotEmpty) s += 0.10;
    if (projects.isNotEmpty) s += 0.08;
    if (github.isNotEmpty) s += 0.07;
    if (linkedin.isNotEmpty) s += 0.07;
    return s.clamp(0.0, 1.0);
  }

  String get strengthHint {
    if (resumeName.isEmpty) return 'Upload your resume (+15%)';
    if (skills.length < 5) return 'Add ${5 - skills.length} more skills (+5%)';
    if (certifications.isEmpty) return 'Add a certification (+10%)';
    if (github.isEmpty) return 'Link your GitHub (+7%)';
    return '🎉 Profile is looking great!';
  }

  List<ScoreCategory> get scoreCategories => [
    ScoreCategory(
      label: 'Basic Info',
      icon: Icons.person_outline,
      earned:
          (name.isNotEmpty ? 5.0 : 0) +
          (email.isNotEmpty ? 5.0 : 0) +
          (phone.isNotEmpty ? 5.0 : 0),
      max: 15,
      color: const Color(0xFF1D4ED8),
      hint: 'Fill in name, email and phone',
    ),
    ScoreCategory(
      label: 'About Me',
      icon: Icons.notes,
      earned: about.length > 30 ? 8.0 : (about.isNotEmpty ? 4.0 : 0),
      max: 8,
      color: const Color(0xFF0EA5E9),
      hint: 'Write at least 30 characters',
    ),
    ScoreCategory(
      label: 'Resume',
      icon: Icons.description_outlined,
      earned: resumeName.isNotEmpty ? 15.0 : 0,
      max: 15,
      color: const Color(0xFF7C3AED),
      hint: 'Upload your resume (+15 pts)',
    ),
    ScoreCategory(
      label: 'Skills',
      icon: Icons.code,
      earned: skills.isEmpty
          ? 0
          : skills.length >= 5
          ? 15.0
          : skills.length >= 3
          ? 10.0
          : 5.0,
      max: 15,
      color: const Color(0xFF059669),
      hint: 'Add at least 5 skills for full points',
    ),
    ScoreCategory(
      label: 'Certifications',
      icon: Icons.workspace_premium_outlined,
      earned: certifications.isEmpty
          ? 0
          : certifications.length >= 2
          ? 10.0
          : 7.0,
      max: 10,
      color: const Color(0xFFF59E0B),
      hint: 'Add a certification (+10 pts)',
    ),
    ScoreCategory(
      label: 'Projects',
      icon: Icons.folder_outlined,
      earned: projects.isEmpty
          ? 0
          : projects.length >= 2
          ? 8.0
          : 5.0,
      max: 8,
      color: const Color(0xFFEC4899),
      hint: 'Add a project (+8 pts)',
    ),
    ScoreCategory(
      label: 'Social Links',
      icon: Icons.link,
      earned: (github.isNotEmpty ? 7.0 : 0) + (linkedin.isNotEmpty ? 7.0 : 0),
      max: 14,
      color: const Color(0xFF0369A1),
      hint: 'Link GitHub (+7) and LinkedIn (+7)',
    ),
  ];

  double get totalScore =>
      scoreCategories.fold(0.0, (sum, c) => sum + c.earned).clamp(0.0, 100.0);

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
    if (s >= 55) return const Color(0xFF1D4ED8);
    if (s >= 35) return const Color(0xFF059669);
    return const Color(0xFF64748B);
  }

  void set(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void addApplication(String role, String company, {String type = 'Job'}) {
    final already = applications.any(
      (a) => a['role'] == role && a['company'] == company,
    );
    if (!already) {
      applications.insert(0, {
        'role': role,
        'company': company,
        'status': 'Applied',
        'date': 'Just now',
        'type': type,
      });
      notifyListeners();
    }
  }

  static String get _baseUrl => ApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();

  Future<void> fetchProfile() async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) throw Exception("Token is null. Please login again.");

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) throw Exception('Not logged in');

      final res = await AuthService().get(
        '/profile/getUsers',
        queryParameters: {'user_id': userId},
      );

      if (res.statusCode != 200) {
        throw Exception('Server error ${res.statusCode}');
      }

      final data = res.data['data'];
      if (data == null || data is! Map)
        throw Exception('No profile data returned');

      final dataMap = Map<String, dynamic>.from(data as Map);

      final userRaw = dataMap['user'];
      if (userRaw != null && userRaw is Map) {
        _mapUser(Map<String, dynamic>.from(userRaw));
      }

      final appRaw = dataMap['applications'];
      _mapApplications(appRaw is List ? appRaw : []);

      final certRaw = dataMap['certificates'];
      _mapCertificates(certRaw is List ? certRaw : []);

      final projRaw = dataMap['projects'];
      _mapProjects(projRaw is List ? projRaw : []);

      final skillRaw = dataMap['skills'];
      _mapSkills(skillRaw is List ? skillRaw : []);

      final courseRaw = dataMap['courses'];
      _mapCourses(courseRaw is List ? courseRaw : []);

      final hackRaw = dataMap['hackathons'];
      _mapHackathons(hackRaw is List ? hackRaw : []);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return false;

      final res = await AuthService().put('/profile/getUsers', {
        'user_id': userId,
        ...fields,
      });

      if (res.statusCode == 200) {
        final resData = res.data;
        if (resData is Map) {
          final inner = resData['data'];
          if (inner is Map) {
            final userRaw = inner['user'];
            if (userRaw is Map) {
              _mapUser(Map<String, dynamic>.from(userRaw));
            }
          }
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(File file, String fileName) async {
    try {
      await AuthService().loadTokens();
      final token = AuthService().accessToken;
      if (token == null) return false;

      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return false;

      final ext = fileName.split('.').last.toLowerCase();
      final mediaType = MediaType('image', ext == 'jpg' ? 'jpeg' : ext);

      final uri = Uri.parse('$_baseUrl/profile/getUsers');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['user_id'] = userId
        ..fields['upload_type'] = 'profile'
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        );

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map) {
          final inner = body['data'];
          if (inner is Map) {
            final userRaw = inner['user'];
            if (userRaw is Map) {
              _mapUser(Map<String, dynamic>.from(userRaw));
            }
          }
        }
        notifyListeners();
        return true;
      }
      debugPrint('uploadProfilePhoto error body: ${res.body}');
      return false;
    } catch (e) {
      debugPrint('uploadProfilePhoto exception: $e');
      return false;
    }
  }

  Future<bool> uploadResume(File file, String fileName) async {
    try {
      await AuthService().loadTokens();
      final token = AuthService().accessToken;
      if (token == null) return false;

      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return false;

      final ext = fileName.split('.').last.toLowerCase();
      final mediaType = ext == 'pdf'
          ? MediaType('application', 'pdf')
          : MediaType(
              'application',
              'vnd.openxmlformats-officedocument.wordprocessingml.document',
            );

      final uri = Uri.parse('$_baseUrl/profile/getUsers');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['user_id'] = userId
        ..fields['upload_type'] = 'resume'
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: fileName,
            contentType: mediaType,
          ),
        );

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map) {
          final inner = body['data'];
          if (inner is Map) {
            final userRaw = inner['user'];
            if (userRaw is Map) {
              _mapUser(Map<String, dynamic>.from(userRaw));
            }
          }
        }
        notifyListeners();
        return true;
      }
      debugPrint('uploadResume error body: ${res.body}');
      return false;
    } catch (e) {
      debugPrint('uploadResume exception: $e');
      return false;
    }
  }

  // ── FIXED: all fields use safe helpers, no direct `as String` casts ──
  void _mapUser(Map<String, dynamic> u) {
    name = _str(u['full_name']);
    email = _str(u['email']);
    phone = _str(u['phone']);
    about = _str(u['about_me']);
    location = _str(u['address']);
    linkedin = _str(u['linkedin_url']);
    github = _str(u['github_url']);
    resumeName = _str(u['resume_url']);
    profilePhotoUrl = _str(u['profile_image_url']);
    roleId = _int(u['role_id']);
    roleName = _str(u['role_name']);
    goal = _str(u['goal']);
    status = _str(u['status']);
    age = _int(u['age']); // stored in state but NOT displayed in header

    if (isSchoolUser) {
      schoolName = _str(u['school_name']);
      studentClass = _str(u['class']);
      college = schoolName;
      degree = [
        studentClass,
        schoolName,
      ].where((s) => s.isNotEmpty).join('  •  ');
      graduationYear = '';
    } else {
      final deg = _str(u['degree']);
      final uni = _str(u['university']);
      final year = _str(u['graduation_year']);
      college = uni;
      degree = [deg, uni, year].where((s) => s.isNotEmpty).join('  •  ');
      graduationYear = year;
    }
  }

  void _mapApplications(List<dynamic> list) {
    applications = list.map((a) {
      final m = a is Map ? Map<String, dynamic>.from(a) : <String, dynamic>{};
      final isJob = m['job_id'] != null;
      return <String, dynamic>{
        'id': m['id'],
        'job_id': m['job_id'],
        'internship_id': m['internship_id'],
        'role': isJob ? _str(m['job_title']) : _str(m['internship_title']),
        'company': isJob
            ? _str(m['job_company_name'])
            : _str(m['internship_company_name']),
        'status': _capitalize(
          _str(m['status']).isEmpty ? 'applied' : _str(m['status']),
        ),
        'date': _timeAgo(_str(m['applied_at'])),
        'type': isJob ? 'Job' : 'Internship',
      };
    }).toList();
  }

  void _mapCertificates(List<dynamic> list) {
    certifications = list.map((c) {
      final m = c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{};
      return <String, dynamic>{
        'certificate_id': _str(m['certificate_id']),
        'name': _str(m['title']),
        'issuer': _str(m['issuer']),
        'date': _formatDate(_str(m['issue_date'])),
        'file_url': _str(m['file_url']),
      };
    }).toList();
  }

  void _mapProjects(List<dynamic> list) {
    projects = list.map((p) {
      final m = p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{};
      return <String, dynamic>{
        'project_id': m['project_id'],
        'title': _str(m['title']),
        'desc': _str(m['description']),
        'tech': <String>[],
        'link': '',
      };
    }).toList();
  }

  void _mapSkills(List<dynamic> list) {
    skills = list.map((s) {
      final m = s is Map ? Map<String, dynamic>.from(s) : <String, dynamic>{};
      return <String, dynamic>{
        'skill_id': m['skill_id'],
        'name': _str(m['skill_name']),
        'level': _parseProficiency(m['proficiency']),
      };
    }).toList();
  }

  void _mapCourses(List<dynamic> list) {
    courses = list.map((c) {
      final m = c is Map ? Map<String, dynamic>.from(c) : <String, dynamic>{};
      return <String, dynamic>{
        'course_id': m['course_id'],
        'title': _str(m['title']),
        'provider': _str(m['provider']),
        'category': _str(m['category']),
        'level': _str(m['level']),
        'progress': _dbl(m['progress']),
        'completed': _bool(m['completed']),
      };
    }).toList();
  }

  void _mapHackathons(List<dynamic> list) {
    hackathons = list.map((h) {
      final m = h is Map ? Map<String, dynamic>.from(h) : <String, dynamic>{};
      return <String, dynamic>{
        'hackathon_id': m['hackathon_id'],
        'title': _str(m['title']),
        'organizer': _str(m['organizer']),
        'location': _str(m['location']),
        'start_date': _formatDate(_str(m['start_date'])),
        'end_date': _formatDate(_str(m['end_date'])),
        'registration_info': _str(m['registration_info']),
      };
    }).toList();
  }

  double _parseProficiency(dynamic raw) {
    final val = _dbl(raw);
    if (val <= 0) return 0.0;
    // API may send 0-1 or 0-100
    if (val <= 1.0) return val.clamp(0.0, 1.0);
    return (val / 100.0).clamp(0.0, 1.0);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso; // return raw if not parseable
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

final profileState = ProfileState();

// ═══════════════════════════════════════════════════════
//  CERT THEME
// ═══════════════════════════════════════════════════════
class _CertTheme {
  final IconData icon;
  final Color g1, g2, bg;
  const _CertTheme(this.icon, this.g1, this.g2, this.bg);
}

_CertTheme _certTheme(String name) {
  final n = name.toLowerCase();
  if (n.contains('aws') || n.contains('cloud'))
    return const _CertTheme(
      Icons.cloud,
      Color(0xFF0369A1),
      Color(0xFF0EA5E9),
      Color(0xFFF0F9FF),
    );
  if (n.contains('python') || n.contains('data science'))
    return const _CertTheme(
      Icons.code,
      Color(0xFF1D4ED8),
      Color(0xFFF59E0B),
      Color(0xFFFFFBEB),
    );
  if (n.contains('ux') || n.contains('design'))
    return const _CertTheme(
      Icons.brush,
      Color(0xFFEC4899),
      Color(0xFFF43F5E),
      Color(0xFFFFF1F2),
    );
  if (n.contains('machine') || n.contains('ai') || n.contains('ml'))
    return const _CertTheme(
      Icons.psychology,
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFF5F3FF),
    );
  if (n.contains('google'))
    return const _CertTheme(
      Icons.search,
      Color(0xFF1D4ED8),
      Color(0xFF16A34A),
      Color(0xFFF0FDF4),
    );
  if (n.contains('security') || n.contains('cyber'))
    return const _CertTheme(
      Icons.shield,
      Color(0xFFB91C1C),
      Color(0xFFDC2626),
      Color(0xFFFFF1F2),
    );
  if (n.contains('react') || n.contains('frontend'))
    return const _CertTheme(
      Icons.web,
      Color(0xFF0EA5E9),
      Color(0xFF38BDF8),
      Color(0xFFEFF6FF),
    );
  return const _CertTheme(
    Icons.workspace_premium,
    Color(0xFFB45309),
    Color(0xFFD97706),
    Color(0xFFFFFBEB),
  );
}

// ═══════════════════════════════════════════════════════
//  PROFILE SCREEN
// ═══════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ProfileScreen({super.key, this.onBack});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  late AnimationController _headerAnim, _xpAnim;
  late Animation<double> _xpVal;
  late List<AnimationController> _skillAnims;

  File? _localProfilePhoto;
  bool _isUploadingPhoto = false;
  bool _isUploadingResume = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 7, vsync: this);
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _xpAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _xpVal = _buildXpTween();
    _skillAnims = List.generate(
      profileState.skills.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _xpAnim.forward();
    });
    _tab.addListener(() {
      if (_tab.index == 1) {
        for (int i = 0; i < _skillAnims.length; i++) {
          Future.delayed(Duration(milliseconds: i * 90), () {
            if (mounted && i < _skillAnims.length) _skillAnims[i].forward();
          });
        }
      }
    });
    profileState.addListener(_onStateChanged);
    profileState.fetchProfile();
  }

  Animation<double> _buildXpTween() => Tween<double>(
    begin: 0,
    end: profileState.strength,
  ).animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {
      _xpAnim.reset();
      _xpVal = _buildXpTween();
      _xpAnim.forward();
      while (_skillAnims.length < profileState.skills.length) {
        final c = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
        )..forward();
        _skillAnims.add(c);
      }
    });
  }

  @override
  void dispose() {
    profileState.removeListener(_onStateChanged);
    _tab.dispose();
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _skillAnims) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/engineering');
    }
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      XFile? picked;

      if (Platform.isAndroid || Platform.isIOS) {
        final source = await _showImageSourceSheet();
        if (source == null) return;
        picked = await picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
      } else {
        picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
      }

      if (picked == null) return;

      final file = File(picked.path);
      if (!await file.exists()) {
        if (mounted) _showSnack('Could not read selected photo.', Colors.red);
        return;
      }

      final fileName = picked.name.isNotEmpty
          ? picked.name
          : 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() {
        _localProfilePhoto = file;
        _isUploadingPhoto = true;
      });

      final ok = await profileState.uploadProfilePhoto(file, fileName);

      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        if (ok) {
          setState(() => _localProfilePhoto = null);
          _showSnack('Profile photo updated! ✅', kSuccess);
        } else {
          _showSnack('Upload failed — showing local preview.', kWarning);
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          _localProfilePhoto = null;
        });
        if (e.code == 'photo_access_denied' ||
            e.code == 'camera_access_denied') {
          _showPermissionDeniedDialog(
            title: 'Photo Access Denied',
            message:
                'Please allow photo access in your device Settings → Privacy → Photos.',
          );
        } else {
          _showSnack('Could not open gallery: ${e.message}', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          _localProfilePhoto = null;
        });
        _showSnack('Error: $e', Colors.red);
      }
    }
  }

  Future<ImageSource?> _showImageSourceSheet() async {
    final sw = MediaQuery.of(context).size.width;
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: kCardBg,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: sw * 0.04),
              Text(
                'Select Photo',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.04),
              _sourceOption(
                ctx,
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: kPrimary,
                source: ImageSource.gallery,
                sw: sw,
              ),
              SizedBox(height: sw * 0.03),
              _sourceOption(
                ctx,
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                color: const Color(0xFF0EA5E9),
                source: ImageSource.camera,
                sw: sw,
              ),
              SizedBox(height: sw * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
    required double sw,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, source),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.115,
              height: sw * 0.115,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: sw * 0.055),
            ),
            SizedBox(width: sw * 0.035),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: kHint, size: sw * 0.05),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return;
      final picked = result.files.first;

      if (picked.path == null) {
        if (mounted) {
          _showSnack(
            'Cannot access this file. Please pick a file from local storage.',
            kWarning,
          );
        }
        return;
      }

      final file = File(picked.path!);
      if (!await file.exists()) {
        if (mounted)
          _showSnack('File not found. Please try again.', Colors.red);
        return;
      }

      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        if (mounted) _showSnack('File too large. Max 5 MB.', kWarning);
        return;
      }

      final fileName = picked.name;
      final ext = fileName.split('.').last.toLowerCase();
      if (!['pdf', 'doc', 'docx'].contains(ext)) {
        if (mounted) {
          _showSnack('Only PDF, DOC, DOCX files are allowed.', kWarning);
        }
        return;
      }

      setState(() => _isUploadingResume = true);
      if (mounted) _showSnack('Uploading resume…', kPrimary);

      final ok = await profileState.uploadResume(file, fileName);

      if (mounted) {
        setState(() => _isUploadingResume = false);
        _showSnack(
          ok ? 'Resume uploaded! ✅' : 'Upload failed. Please try again.',
          ok ? kSuccess : Colors.red,
        );
        if (ok && profileState.resumeName.isEmpty) {
          profileState.set(() => profileState.resumeName = fileName);
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => _isUploadingResume = false);
        if (e.code == 'read_external_storage_denied') {
          _showPermissionDeniedDialog(
            title: 'Storage Access Denied',
            message:
                'Please allow storage access in your device Settings → Privacy → Files.',
          );
        } else {
          _showSnack('Could not open file picker: ${e.message}', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingResume = false);
        _showSnack('Error: $e', Colors.red);
      }
    }
  }

  void _showPermissionDeniedDialog({
    required String title,
    required String message,
  }) {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kCardBg,
        child: Padding(
          padding: EdgeInsets.all(sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.18,
                height: sw * 0.18,
                decoration: BoxDecoration(
                  color: kWarning.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.no_photography_rounded,
                  color: kWarning,
                  size: sw * 0.09,
                ),
              ),
              SizedBox(height: sw * 0.04),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.025),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: kMuted,
                  height: 1.55,
                ),
              ),
              SizedBox(height: sw * 0.05),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.033),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: kMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        try {
                          await const MethodChannel(
                            'flutter/platform',
                          ).invokeMethod('openAppSettings');
                        } catch (_) {}
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.033),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [kPrimary, kPrimary.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Open Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
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

  Future<void> _handleSignOut() async {
    final sw = MediaQuery.of(context).size.width;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: kCardBg,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.06,
            vertical: sw * 0.07,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.18,
                height: sw * 0.18,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: sw * 0.09,
                ),
              ),
              SizedBox(height: sw * 0.05),
              Text(
                'Sign Out?',
                style: TextStyle(
                  fontSize: sw * 0.048,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: sw * 0.025),
              Text(
                'You will be logged out of your account.\nAre you sure you want to continue?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: kMuted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sw * 0.06),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogCtx).pop(false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w700,
                              color: kMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogCtx).pop(true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

    if (confirmed != true) return;

    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    AuthService().clearTokens();

    if (!mounted) return;
    context.go('/login');
  }

  // ── FIXED: safe userId parsing, safe map access ──
  Future<void> _withdrawApplication(Map<String, dynamic> app, int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;
    if (index < 0 || index >= profileState.applications.length) return;

    try {
      final userId = await const FlutterSecureStorage().read(key: 'user_id');
      final userIdInt = _int(userId);
      final isJob = (app['type'] ?? 'Job') == 'Job';
      final body = <String, dynamic>{
        'user_id': userIdInt,
        if (isJob) 'job_id': app['job_id'],
        if (!isJob) 'internship_id': app['internship_id'],
      };
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/applications'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        if (index < profileState.applications.length) {
          profileState.set(() => profileState.applications.removeAt(index));
        }
        _showSnack('Application withdrawn', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(
          _str(data['message']).isEmpty ? 'Failed' : _str(data['message']),
        );
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _deleteProject(int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;
    if (index < 0 || index >= profileState.projects.length) return;

    final proj = profileState.projects[index];
    final projectId = proj['project_id'];
    if (projectId == null) {
      profileState.set(() => profileState.projects.removeAt(index));
      _showSnack('Project removed', kSuccess);
      return;
    }

    try {
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/projects'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'project_id': projectId}),
      );
      if (res.statusCode == 200) {
        if (index < profileState.projects.length) {
          profileState.set(() => profileState.projects.removeAt(index));
        }
        _showSnack('Project deleted', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(
          _str(data['message']).isEmpty ? 'Failed' : _str(data['message']),
        );
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _deleteCertificate(int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;
    if (index < 0 || index >= profileState.certifications.length) return;

    final cert = profileState.certifications[index];
    final certIdStr = _str(cert['certificate_id']);
    if (certIdStr.isEmpty) {
      profileState.set(() => profileState.certifications.removeAt(index));
      _showSnack('Certificate removed', kSuccess);
      return;
    }

    final certIdInt = _int(certIdStr);
    try {
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/certificates'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'certificate_id': certIdInt}),
      );
      if (res.statusCode == 200) {
        if (index < profileState.certifications.length) {
          profileState.set(() => profileState.certifications.removeAt(index));
        }
        _showSnack('Certificate deleted', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(
          _str(data['message']).isEmpty ? 'Failed' : _str(data['message']),
        );
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _deleteSkill(int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;
    if (index < 0 || index >= profileState.skills.length) return;

    final sk = profileState.skills[index];
    final skillId = sk['skill_id'];
    if (skillId == null) {
      profileState.set(() => profileState.skills.removeAt(index));
      _showSnack('Skill removed', kSuccess);
      return;
    }

    try {
      final userId = await const FlutterSecureStorage().read(key: 'user_id');
      final userIdInt = _int(userId);
      final skillIdInt = _int(skillId);
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/user-skills'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'user_id': userIdInt, 'skill_id': skillIdInt}),
      );
      if (res.statusCode == 200) {
        if (index < profileState.skills.length) {
          profileState.set(() => profileState.skills.removeAt(index));
        }
        _showSnack('Skill removed', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(
          _str(data['message']).isEmpty ? 'Failed' : _str(data['message']),
        );
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _addSkillDialog() async {
    final sw = MediaQuery.of(context).size.width;
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;

    final Future<List<Map<String, dynamic>>> skillsFuture = http
        .get(
          Uri.parse('${ProfileState._baseUrl}/skills'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .then((res) {
          if (res.statusCode == 200) {
            final body = jsonDecode(res.body);
            List<dynamic> list = [];
            if (body is List) {
              list = body;
            } else if (body is Map && body['data'] is List) {
              list = body['data'] as List;
            } else if (body is Map && body['skills'] is List) {
              list = body['skills'] as List;
            }
            return list
                .map((s) {
                  if (s is! Map) return null;
                  final m = Map<String, dynamic>.from(s);
                  final id = m['skill_id'] ?? m['id'];
                  final name = _str(m['name'] ?? m['skill_name']);
                  if (id == null || name.isEmpty) return null;
                  return <String, dynamic>{'skill_id': id, 'name': name};
                })
                .whereType<Map<String, dynamic>>()
                .toList();
          }
          return <Map<String, dynamic>>[];
        })
        .catchError((e) {
          debugPrint('Skills fetch error: $e');
          return <Map<String, dynamic>>[];
        });

    double level = 0.70;
    int? selectedSkillId;
    String? selectedSkillName;
    bool isOther = false;
    final otherCtrl = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, sst) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(sw * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Add Skill',
                    style: TextStyle(
                      fontSize: sw * 0.040,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                    ),
                  ),
                ),
                SizedBox(height: sw * 0.040),
                Text(
                  'Select Skill',
                  style: TextStyle(
                    fontSize: sw * 0.030,
                    color: kMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: sw * 0.015),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: skillsFuture,
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      );
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(sw * 0.030),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          'Failed to load skills.',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: sw * 0.030,
                          ),
                        ),
                      );
                    }

                    final allSkills = snapshot.data!;
                    const int otherSentinel = -1;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.030),
                          decoration: BoxDecoration(
                            color: kBgPage,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              hint: Text(
                                'Choose a skill...',
                                style: TextStyle(
                                  color: kHint,
                                  fontSize: sw * 0.033,
                                ),
                              ),
                              value: isOther ? otherSentinel : selectedSkillId,
                              dropdownColor: kCardBg,
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                color: kInk,
                              ),
                              items: [
                                ...allSkills.map(
                                  (s) => DropdownMenuItem<int>(
                                    value: _int(s['skill_id']),
                                    child: Text(_str(s['name'])),
                                  ),
                                ),
                                DropdownMenuItem<int>(
                                  value: otherSentinel,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: sw * 0.040,
                                        color: kPrimary,
                                      ),
                                      SizedBox(width: sw * 0.020),
                                      Text(
                                        'Other (type your own)',
                                        style: TextStyle(
                                          color: kPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: sw * 0.033,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                sst(() {
                                  if (val == otherSentinel) {
                                    isOther = true;
                                    selectedSkillId = null;
                                    selectedSkillName = null;
                                  } else {
                                    isOther = false;
                                    selectedSkillId = val;
                                    final match = allSkills.firstWhere(
                                      (s) => _int(s['skill_id']) == val,
                                      orElse: () => <String, dynamic>{},
                                    );
                                    selectedSkillName = match.isNotEmpty
                                        ? _str(match['name'])
                                        : null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        if (isOther) ...[
                          SizedBox(height: sw * 0.025),
                          TextField(
                            controller: otherCtrl,
                            autofocus: true,
                            style: TextStyle(fontSize: sw * 0.033, color: kInk),
                            decoration: InputDecoration(
                              hintText: 'Type skill name...',
                              hintStyle: TextStyle(
                                color: kHint,
                                fontSize: sw * 0.033,
                              ),
                              filled: true,
                              fillColor: kBgPage,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: kPrimary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.edit,
                                color: kPrimary,
                                size: sw * 0.040,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: sw * 0.040,
                                vertical: sw * 0.030,
                              ),
                            ),
                            onChanged: (v) => sst(() {}),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                SizedBox(height: sw * 0.040),
                Row(
                  children: [
                    Text(
                      'Proficiency',
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        color: kMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(level * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        color: kPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: level,
                  onChanged: (v) => sst(() => level = v),
                  activeColor: kPrimary,
                  inactiveColor: kBorder,
                ),
                SizedBox(height: sw * 0.020),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                          decoration: BoxDecoration(
                            color: kBgPage,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: kMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: sw * 0.033,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.030),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final String? finalSkillName = isOther
                              ? (otherCtrl.text.trim().isEmpty
                                    ? null
                                    : otherCtrl.text.trim())
                              : selectedSkillName;

                          if (finalSkillName == null ||
                              finalSkillName.isEmpty) {
                            _showSnack(
                              isOther
                                  ? 'Please type a skill name'
                                  : 'Please select a skill',
                              kWarning,
                            );
                            return;
                          }

                          Navigator.pop(context);
                          try {
                            final userId = await const FlutterSecureStorage()
                                .read(key: 'user_id');
                            final userIdInt = _int(userId);
                            final proficiency = (level * 100).round().clamp(
                              1,
                              100,
                            );
                            final postBody = {
                              'user_id': userIdInt,
                              'skill_name': finalSkillName,
                              'proficiency': proficiency,
                            };
                            final res = await http.post(
                              Uri.parse(
                                '${ProfileState._baseUrl}/user-skills',
                              ),
                              headers: {
                                "Content-Type": "application/json",
                                "Authorization": "Bearer $token",
                              },
                              body: jsonEncode(postBody),
                            );
                            if (res.statusCode == 200 ||
                                res.statusCode == 201) {
                              final resData = jsonDecode(res.body);
                              final newSkillId =
                                  (resData is Map && resData['data'] != null)
                                  ? resData['data']['skill_id']
                                  : null;
                              profileState.set(() {
                                final existingIndex = profileState.skills
                                    .indexWhere(
                                      (s) =>
                                          _str(s['name']).toLowerCase() ==
                                          finalSkillName.toLowerCase(),
                                    );
                                if (existingIndex != -1) {
                                  // profileState.skills[existingIndex]['level'] =
                                  //     level;
                                } else {
                                  // profileState.skills.add({
                                  //   'skill_id': newSkillId,
                                  //   'name': finalSkillName,
                                  //   'level': level,
                                  // });
                                }
                              });
                              _showSnack('Skill added! ✅', kSuccess);
                            } else {
                              final data = jsonDecode(res.body);
                              _showSnack(
                                data is Map
                                    ? (_str(data['message']).isEmpty
                                          ? 'Failed to save skill'
                                          : _str(data['message']))
                                    : 'Failed to save skill',
                                Colors.red,
                              );
                            }
                          } catch (e) {
                            _showSnack('Error: $e', Colors.red);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: sw * 0.033,
                              ),
                            ),
                          ),
                        ),
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

  // ══════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return ListenableBuilder(
      listenable: profileState,
      builder: (_, __) {
        if (profileState.isLoading) {
          return const Scaffold(
            backgroundColor: kBgPage,
            body: Center(child: CircularProgressIndicator(color: kPrimary)),
          );
        }
        if (profileState.errorMessage != null) {
          return Scaffold(
            backgroundColor: kBgPage,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: sw * 0.12,
                    ),
                    SizedBox(height: sw * 0.030),
                    Text(
                      profileState.errorMessage!,
                      style: const TextStyle(color: kSlate),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: sw * 0.040),
                    GestureDetector(
                      onTap: () {
                        profileState.set(
                          () => profileState.errorMessage = null,
                        );
                        profileState.fetchProfile();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.06,
                          vertical: sw * 0.030,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: sw * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: kBgPage,
          body: Column(
            children: [
              _header(sw),
              _tabBar(sw),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _overview(sw),
                    _skills(sw),
                    _certs(sw),
                    _projectsTab(sw),
                    _applicationsTab(sw),
                    _coursesTab(sw),
                    _hackathonsTab(sw),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════
  Widget _header(double sw) {
    final p = profileState;
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF0F172A), Color(0xFF1A2035)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.05,
                  sw * 0.025,
                  sw * 0.05,
                  0,
                ),
                child: Row(
                  children: [
                    if (context.canPop() || widget.onBack != null)
                      _iconBtn(Icons.arrow_back_ios_new, _handleBack, sw),
                    if (context.canPop() || widget.onBack != null)
                      SizedBox(width: sw * 0.025),
                    const Spacer(),
                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: sw * 0.040,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // _iconBtn(
                    //   Icons.notifications_outlined,
                    //       () => Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (_) => const NotificationPage())),
                    //   sw,
                    //   bg: Colors.white.withOpacity(0.10),
                    //   iconColor: kAccent,
                    // ),
                    SizedBox(width: sw * 0.025),
                    _iconBtn(
                      Icons.logout,
                      _handleSignOut,
                      sw,
                      bg: Colors.red.withOpacity(0.25),
                      iconColor: Colors.redAccent,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.030),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _editBasicInfo,
                    child: Container(
                      width: sw * 0.22,
                      height: sw * 0.22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(child: _avatarContent(sw, p)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickProfilePhoto,
                    child: Container(
                      width: sw * 0.08,
                      height: sw * 0.08,
                      decoration: BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: kInk, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withOpacity(0.40),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _isUploadingPhoto
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.add_a_photo_rounded,
                              color: Colors.white,
                              size: sw * 0.038,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.020),
              // ── Name ──
              Text(
                p.name,
                style: TextStyle(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: sw * 0.008),
              // ── Degree / education subtitle ──
              if (p.degree.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                  child: Text(
                    p.degree,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ),
              // ── Goal / Status badges (age is intentionally NOT shown here) ──
              if (p.goal.isNotEmpty || p.status.isNotEmpty) ...[
                SizedBox(height: sw * 0.010),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (p.goal.isNotEmpty) _headerBadge(p.goal, kAccent, sw),
                    if (p.goal.isNotEmpty && p.status.isNotEmpty)
                      SizedBox(width: sw * 0.015),
                    if (p.status.isNotEmpty)
                      _headerBadge(
                        p.status,
                        p.status.toLowerCase() == 'active'
                            ? kSuccess
                            : kWarning,
                        sw,
                      ),
                  ],
                ),
              ],
              // ── NOTE: age is stored in profileState.age but is NOT rendered
              //         anywhere in the header. If the API returns age as part
              //         of a different field (e.g. inside degree/degree_year),
              //         check _mapUser() above. ──
              SizedBox(height: sw * 0.030),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _hStat(
                        '${p.applications.length}',
                        'Applied',
                        Icons.send,
                        sw,
                      ),
                      _hDiv(),
                      _hStat('${p.skills.length}', 'Skills', Icons.code, sw),
                      _hDiv(),
                      _hStat(
                        '${p.certifications.length}',
                        'Certs',
                        Icons.workspace_premium,
                        sw,
                      ),
                      _hDiv(),
                      _hStat(
                        '${p.projects.length}',
                        'Projects',
                        Icons.folder,
                        sw,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sw * 0.030),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBadge(String label, Color color, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.030,
        vertical: sw * 0.008,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sw * 0.026,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _avatarContent(double sw, ProfileState p) {
    if (_localProfilePhoto != null) {
      return Image.file(
        _localProfilePhoto!,
        fit: BoxFit.cover,
        width: sw * 0.22,
        height: sw * 0.22,
        errorBuilder: (_, __, ___) => _initialsAvatar(sw, p),
      );
    }
    if (p.profilePhotoUrl.isNotEmpty) {
      return Image.network(
        p.profilePhotoUrl,
        fit: BoxFit.cover,
        width: sw * 0.22,
        height: sw * 0.22,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: kPrimary,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _initialsAvatar(sw, p),
      );
    }
    return _initialsAvatar(sw, p);
  }

  Widget _initialsAvatar(double sw, ProfileState p) {
    return Container(
      color: kPrimary,
      child: Center(
        child: Text(
          p.name.isNotEmpty ? p.name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: sw * 0.09,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _hStat(String v, String l, IconData ic, double sw) => Column(
    children: [
      Icon(ic, size: sw * 0.033, color: kAccent),
      SizedBox(height: sw * 0.010),
      Text(
        v,
        style: TextStyle(
          fontSize: sw * 0.040,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      SizedBox(height: sw * 0.005),
      Text(
        l,
        style: TextStyle(
          fontSize: sw * 0.023,
          color: Colors.white.withOpacity(0.50),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _hDiv() =>
      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.10));

  Widget _iconBtn(
    IconData icon,
    VoidCallback onTap,
    double sw, {
    Color? bg,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sw * 0.09,
        height: sw * 0.09,
        decoration: BoxDecoration(
          color: bg ?? Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: sw * 0.040),
      ),
    );
  }

  // ── FIX: TabBar is now centered using tabAlignment: TabAlignment.center
  //        so Overview/Skills/Certs... are centred when they fit the screen,
  //        and still scroll when they overflow. ──
  Widget _tabBar(double sw) => Container(
    color: kCardBg,
    child: TabBar(
      controller: _tab,
      isScrollable: true,
      // CENTER the tabs — requires Flutter 3.10+
      tabAlignment: TabAlignment.center,
      labelColor: kPrimary,
      unselectedLabelColor: kMuted,
      labelStyle: TextStyle(fontSize: sw * 0.026, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(
        fontSize: sw * 0.026,
        fontWeight: FontWeight.w600,
      ),
      indicatorColor: kPrimary,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.tab,
      padding: EdgeInsets.zero,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Skills'),
        Tab(text: 'Certs'),
        Tab(text: 'Projects'),
        Tab(text: 'Applications'),
        Tab(text: 'Courses'),
        Tab(text: 'Hackathons'),
      ],
    ),
  );

  // ══════════════════════════════════════════════════════
  //  OVERVIEW TAB
  // ══════════════════════════════════════════════════════
  Widget _overview(double sw) {
    final p = profileState;
    return ListView(
      padding: EdgeInsets.all(sw * 0.040),
      children: [
        // Profile strength card
        Container(
          padding: EdgeInsets.all(sw * 0.040),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: sw * 0.075,
                    height: sw * 0.075,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: sw * 0.038,
                    ),
                  ),
                  SizedBox(width: sw * 0.025),
                  Text(
                    'Profile Strength',
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _xpVal,
                    builder: (_, __) => Text(
                      '${(_xpVal.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: sw * 0.040,
                        fontWeight: FontWeight.w900,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.030),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _xpVal,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _xpVal.value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.020),
              Row(
                children: [
                  Icon(Icons.tips_and_updates, size: sw * 0.030, color: kHint),
                  SizedBox(width: sw * 0.015),
                  Flexible(
                    child: Text(
                      p.strengthHint,
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        color: kMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: sw * 0.035),
        _card(
          title: 'About Me',
          icon: Icons.person,
          sw: sw,
          onEdit: () => _textDialog('About Me', p.about, 5, (v) async {
            final ok = await profileState.updateProfile({'about_me': v});
            if (!ok) profileState.set(() => p.about = v);
            _showSnack(
              ok ? 'About Me updated!' : 'Saved locally',
              ok ? kSuccess : kWarning,
            );
          }),
          child: Text(
            p.about.isNotEmpty ? p.about : 'No bio added yet.',
            style: TextStyle(fontSize: sw * 0.033, color: kSlate, height: 1.6),
          ),
        ),
        SizedBox(height: sw * 0.035),
        _resumeCard(sw),
        SizedBox(height: sw * 0.035),
        _card(
          title: 'Contact and Profile',
          icon: Icons.contact_page,
          sw: sw,
          onEdit: _editContactSheet,
          child: Column(
            children: [
              if (profileState.isSchoolUser) ...[
                _dRow(Icons.school, p.schoolName, 'School', sw),
                _dRow(Icons.class_, p.studentClass, 'Class', sw),
              ] else ...[
                _dRow(Icons.school, p.college, 'University', sw),
              ],
              _dRow(Icons.location_on, p.location, 'Location', sw),
              _dRow(Icons.email, p.email, 'Email', sw),
              _dRow(Icons.phone, p.phone, 'Phone', sw),
              _dRow(Icons.link, p.linkedin, 'LinkedIn', sw),
              _dRow(Icons.code, p.github, 'GitHub', sw, last: true),
            ],
          ),
        ),
        if (p.goal.isNotEmpty || p.status.isNotEmpty) ...[
          SizedBox(height: sw * 0.035),
          _card(
            title: 'Goal & Status',
            icon: Icons.flag_outlined,
            sw: sw,
            onEdit: _editGoalStatusSheet,
            child: Column(
              children: [
                if (p.goal.isNotEmpty)
                  _dRow(
                    Icons.flag_outlined,
                    p.goal,
                    'Goal',
                    sw,
                    last: p.status.isEmpty,
                  ),
                if (p.status.isNotEmpty)
                  _dRow(
                    Icons.circle_outlined,
                    p.status,
                    'Status',
                    sw,
                    last: true,
                  ),
              ],
            ),
          ),
        ],
        SizedBox(height: sw * 0.035),
        _card(
          title: 'Top Skills',
          icon: Icons.auto_awesome,
          sw: sw,
          onEdit: () => _tab.animateTo(1),
          child: p.skills.isEmpty
              ? Text(
                  'No skills added yet.',
                  style: TextStyle(fontSize: sw * 0.033, color: kMuted),
                )
              : Wrap(
                  spacing: sw * 0.020,
                  runSpacing: sw * 0.020,
                  children: p.skills.map((s) {
                    final pct = ((_dbl(s['level'])) * 100).toInt();
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.030,
                        vertical: sw * 0.015,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary, Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_str(s['name'])}  $pct%',
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        SizedBox(height: sw * 0.020),
      ],
    );
  }

  Widget _resumeCard(double sw) {
    final p = profileState;
    final has = p.resumeName.isNotEmpty;

    String displayName = '';
    if (has) {
      final uri = Uri.tryParse(p.resumeName);
      displayName = uri?.pathSegments.lastOrNull ?? p.resumeName;
      try {
        displayName = Uri.decodeComponent(displayName);
      } catch (_) {}
      if (displayName.length > 40) {
        displayName = '…${displayName.substring(displayName.length - 37)}';
      }
    }

    return GestureDetector(
      onTap: _isUploadingResume ? null : _uploadResume,
      child: Container(
        padding: EdgeInsets.all(sw * 0.040),
        decoration: BoxDecoration(
          gradient: has
              ? LinearGradient(
                  colors: [
                    kPrimary.withOpacity(0.07),
                    const Color(0xFF4F46E5).withOpacity(0.03),
                  ],
                )
              : null,
          color: has ? null : kCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: has ? kPrimary.withOpacity(0.40) : kBorder,
            width: has ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.125,
              height: sw * 0.125,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isUploadingResume
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.description,
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
                    _isUploadingResume
                        ? 'Uploading…'
                        : has
                        ? 'Resume Uploaded ✓'
                        : 'Upload Your Resume',
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w800,
                      color: _isUploadingResume
                          ? kPrimary
                          : has
                          ? kSuccess
                          : kInk,
                    ),
                  ),
                  SizedBox(height: sw * 0.008),
                  Text(
                    has ? displayName : 'PDF or DOC  •  Max 5 MB',
                    style: TextStyle(fontSize: sw * 0.030, color: kMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (has) ...[
                    SizedBox(height: sw * 0.008),
                    // GestureDetector(
                    //   onTap: () => _openUrl(p.resumeName),
                    //   child: Text('Open Resume →',
                    //       style: TextStyle(
                    //           fontSize: sw * 0.026,
                    //           color: kPrimary,
                    //           fontWeight: FontWeight.w700)),
                    // ),
                  ],
                ],
              ),
            ),
            SizedBox(width: sw * 0.025),
            if (!_isUploadingResume)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.035,
                  vertical: sw * 0.020,
                ),
                decoration: BoxDecoration(
                  color: has ? const Color(0xFFF0FDF4) : kPrimary,
                  borderRadius: BorderRadius.circular(20),
                  border: has
                      ? Border.all(color: const Color(0xFF86EFAC), width: 1.5)
                      : null,
                ),
                child: Text(
                  has ? 'Replace' : 'Upload',
                  style: TextStyle(
                    fontSize: sw * 0.030,
                    fontWeight: FontWeight.w800,
                    color: has ? kSuccess : Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dRow(
    IconData icon,
    String val,
    String lbl,
    double sw, {
    bool last = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.025),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
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
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lbl,
                  style: TextStyle(
                    fontSize: sw * 0.025,
                    color: kHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  val.isNotEmpty ? val : '—',
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    color: kSlate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  SKILLS TAB
  // ══════════════════════════════════════════════════════
  Widget _skills(double sw) {
    final p = profileState;
    return ListView(
      padding: EdgeInsets.all(sw * 0.040),
      children: [
        _card(
          title: 'Technical Skills',
          icon: Icons.code,
          sw: sw,
          onEdit: null,
          child: p.skills.isEmpty
              ? Text(
                  'No skills added yet.',
                  style: TextStyle(fontSize: sw * 0.033, color: kMuted),
                )
              : Column(
                  children: List.generate(p.skills.length, (i) {
                    if (i >= _skillAnims.length) return const SizedBox();
                    final sk = p.skills[i];
                    final name = _str(sk['name']);
                    final target = _dbl(sk['level']);
                    final pct = (target * 100).toInt();
                    final barCol = target >= 0.80
                        ? kSuccess
                        : target >= 0.60
                        ? kPrimary
                        : kWarning;
                    return Padding(
                      padding: EdgeInsets.only(bottom: sw * 0.050),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: sw * 0.033,
                                    fontWeight: FontWeight.w800,
                                    color: kInk,
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _skillAnims[i],
                                builder: (_, __) => Text(
                                  '${(_skillAnims[i].value * pct).toInt()}%',
                                  style: TextStyle(
                                    fontSize: sw * 0.030,
                                    fontWeight: FontWeight.w700,
                                    color: barCol,
                                  ),
                                ),
                              ),
                              SizedBox(width: sw * 0.020),
                              GestureDetector(
                                onTap: () => _deleteSkill(i),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: sw * 0.045,
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sw * 0.020),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AnimatedBuilder(
                              animation: _skillAnims[i],
                              builder: (_, __) => LinearProgressIndicator(
                                value: _skillAnims[i].value * target,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  barCol,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
        ),
        SizedBox(height: sw * 0.030),
        GestureDetector(
          onTap: _addSkillDialog,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: sw * 0.040),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: sw * 0.050,
                ),
                SizedBox(width: sw * 0.020),
                Text(
                  'Add New Skill',
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  CERTS TAB
  // ══════════════════════════════════════════════════════
  Widget _certs(double sw) {
    final p = profileState;
    return ListView(
      padding: EdgeInsets.all(sw * 0.040),
      children: [
        ...List.generate(p.certifications.length, (i) {
          final c = p.certifications[i];
          final theme = _certTheme(_str(c['name']));
          final fileUrl = _str(c['file_url']);
          return Padding(
            padding: EdgeInsets.only(bottom: sw * 0.030),
            child: Container(
              padding: EdgeInsets.all(sw * 0.040),
              decoration: BoxDecoration(
                color: theme.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.g1.withOpacity(0.20),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: sw * 0.115,
                    height: sw * 0.115,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [theme.g1, theme.g2]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      theme.icon,
                      color: Colors.white,
                      size: sw * 0.055,
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _str(c['name']),
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        SizedBox(height: sw * 0.008),
                        Text(
                          _str(c['issuer']),
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Text(
                          _str(c['date']),
                          style: TextStyle(fontSize: sw * 0.025, color: kHint),
                        ),
                        if (fileUrl.isNotEmpty) ...[
                          SizedBox(height: sw * 0.012),
                          GestureDetector(
                            onTap: () => _openUrl(fileUrl),
                            child: Text(
                              'View Certificate →',
                              style: TextStyle(
                                fontSize: sw * 0.025,
                                color: theme.g1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _deleteCertificate(i),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade300,
                      size: sw * 0.050,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: sw * 0.010),
        GestureDetector(
          onTap: _addCertDialog,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: sw * 0.040),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: sw * 0.050,
                ),
                SizedBox(width: sw * 0.020),
                Text(
                  'Add Certificate',
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  PROJECTS TAB
  // ══════════════════════════════════════════════════════
  Widget _projectsTab(double sw) {
    final p = profileState;
    return ListView(
      padding: EdgeInsets.all(sw * 0.040),
      children: [
        ...List.generate(p.projects.length, (i) {
          final proj = p.projects[i];
          return Padding(
            padding: EdgeInsets.only(bottom: sw * 0.030),
            child: Container(
              padding: EdgeInsets.all(sw * 0.040),
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
                      Expanded(
                        child: Text(
                          _str(proj['title']),
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _deleteProject(i),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade300,
                          size: sw * 0.050,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.015),
                  Text(
                    _str(proj['desc']),
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      color: kMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: sw * 0.010),
        GestureDetector(
          onTap: _addProjectDialog,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: sw * 0.040),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: sw * 0.050,
                ),
                SizedBox(width: sw * 0.020),
                Text(
                  'Add Project',
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  APPLICATIONS TAB
  // ══════════════════════════════════════════════════════
  Widget _applicationsTab(double sw) {
    final p = profileState;
    if (p.applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_outlined, size: sw * 0.15, color: kHint),
            SizedBox(height: sw * 0.025),
            Text(
              'No applications yet.',
              style: TextStyle(color: kMuted, fontSize: sw * 0.035),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.040),
      itemCount: p.applications.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.025),
      itemBuilder: (_, i) {
        final app = p.applications[i];
        final statusStr = _str(app['status']);
        final statusColor = statusStr == 'Applied'
            ? kPrimary
            : statusStr == 'Accepted'
            ? kSuccess
            : kWarning;
        return Container(
          padding: EdgeInsets.all(sw * 0.040),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: sw * 0.115,
                height: sw * 0.115,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  app['type'] == 'Internship' ? Icons.school : Icons.work,
                  color: kPrimary,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(width: sw * 0.030),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _str(app['role']),
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      _str(app['company']),
                      style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                    ),
                    SizedBox(height: sw * 0.010),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.020,
                            vertical: sw * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusStr,
                            style: TextStyle(
                              fontSize: sw * 0.025,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          _str(app['date']),
                          style: TextStyle(fontSize: sw * 0.025, color: kHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _withdrawApplication(app, i),
                child: Icon(
                  Icons.cancel_outlined,
                  color: Colors.red.shade300,
                  size: sw * 0.055,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  //  COURSES TAB
  // ══════════════════════════════════════════════════════
  Widget _coursesTab(double sw) {
    final p = profileState;
    if (p.courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: sw * 0.15, color: kHint),
            SizedBox(height: sw * 0.025),
            Text(
              'No courses yet.',
              style: TextStyle(color: kMuted, fontSize: sw * 0.035),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.040),
      itemCount: p.courses.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.025),
      itemBuilder: (_, i) {
        final c = p.courses[i];
        final progress = _dbl(c['progress']).clamp(0.0, 100.0);
        final completed = _bool(c['completed']);
        final category = _str(c['category']);
        final level = _str(c['level']);
        return Container(
          padding: EdgeInsets.all(sw * 0.040),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: sw * 0.11,
                    height: sw * 0.11,
                    decoration: BoxDecoration(
                      color: kSelectedBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      color: kPrimary,
                      size: sw * 0.055,
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _str(c['title']),
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Text(
                          _str(c['provider']),
                          style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                        ),
                        SizedBox(height: sw * 0.005),
                        Row(
                          children: [
                            if (category.isNotEmpty)
                              _chip(category, kSelectedBg, kPrimary, sw),
                            if (category.isNotEmpty && level.isNotEmpty)
                              SizedBox(width: sw * 0.015),
                            if (level.isNotEmpty)
                              _chip(level, kSelectedBg, kSlate, sw),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (completed)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.020,
                        vertical: sw * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: kSuccess.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontSize: sw * 0.025,
                          color: kSuccess,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (!completed) ...[
                SizedBox(height: sw * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            kPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.020),
                    Text(
                      '${progress.toInt()}%',
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        color: kPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  //  HACKATHONS TAB
  // ══════════════════════════════════════════════════════
  Widget _hackathonsTab(double sw) {
    final p = profileState;
    if (p.hackathons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: sw * 0.15, color: kHint),
            SizedBox(height: sw * 0.025),
            Text(
              'No hackathons yet.',
              style: TextStyle(color: kMuted, fontSize: sw * 0.035),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.040),
      itemCount: p.hackathons.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.025),
      itemBuilder: (_, i) {
        final h = p.hackathons[i];
        final organizer = _str(h['organizer']);
        final location = _str(h['location']);
        final startDate = _str(h['start_date']);
        final endDate = _str(h['end_date']);
        final regInfo = _str(h['registration_info']);
        return Container(
          padding: EdgeInsets.all(sw * 0.040),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sw * 0.11,
                height: sw * 0.11,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(width: sw * 0.030),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _str(h['title']),
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    if (organizer.isNotEmpty) ...[
                      SizedBox(height: sw * 0.008),
                      Text(
                        organizer,
                        style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      SizedBox(height: sw * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: sw * 0.030,
                            color: kHint,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: sw * 0.027,
                                color: kHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (startDate.isNotEmpty || endDate.isNotEmpty) ...[
                      SizedBox(height: sw * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: sw * 0.028,
                            color: kHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            [
                              startDate,
                              endDate,
                            ].where((s) => s.isNotEmpty).join(' – '),
                            style: TextStyle(
                              fontSize: sw * 0.027,
                              color: kHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (regInfo.isNotEmpty) ...[
                      SizedBox(height: sw * 0.010),
                      Text(
                        regInfo,
                        style: TextStyle(
                          fontSize: sw * 0.027,
                          color: kSlate,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, Color bg, Color fg, double sw) => Container(
    padding: EdgeInsets.symmetric(horizontal: sw * 0.018, vertical: sw * 0.007),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: sw * 0.024,
        color: fg,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _card({
    required String title,
    required IconData icon,
    required double sw,
    required Widget child,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: EdgeInsets.all(sw * 0.040),
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
              Icon(icon, size: sw * 0.040, color: kPrimary),
              SizedBox(width: sw * 0.020),
              Text(
                title,
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.025,
                      vertical: sw * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: kSelectedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        color: kPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: sw * 0.030),
          child,
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) _showSnack('Cannot open URL', kWarning);
      }
    } catch (e) {
      if (mounted) _showSnack('Error opening URL: $e', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _textDialog(
    String title,
    String initial,
    int maxLines,
    Future<void> Function(String) onSave,
  ) {
    final ctrl = TextEditingController(text: initial);
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.040),
              TextField(
                controller: ctrl,
                maxLines: maxLines,
                style: TextStyle(fontSize: sw * 0.033, color: kInk),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kBgPage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary, width: 2),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.040),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: kMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onSave(ctrl.text.trim());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
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

  // ══════════════════════════════════════════════════════
  //  EDIT SHEETS
  // ══════════════════════════════════════════════════════
  void _editBasicInfo() {
    final sw = MediaQuery.of(context).size.width;
    final p = profileState;
    final nameCtrl = TextEditingController(text: p.name);
    final degCtrl = TextEditingController(
      text: p.isSchoolUser ? p.schoolName : p.college,
    );
    final classOrYearCtrl = TextEditingController(
      text: p.isSchoolUser ? p.studentClass : p.graduationYear,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: sw * 0.04),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.035),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(
                    const Duration(milliseconds: 250),
                    _pickProfilePhoto,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(sw * 0.035),
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kPrimary.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: sw * 0.13,
                        height: sw * 0.13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kPrimary.withOpacity(0.35),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(child: _avatarContent(sw, p)),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Change Profile Photo',
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w700,
                                color: kInk,
                              ),
                            ),
                            SizedBox(height: sw * 0.008),
                            Text(
                              'Tap to pick from gallery or take a photo',
                              style: TextStyle(
                                fontSize: sw * 0.028,
                                color: kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.photo_library_outlined,
                        color: kPrimary,
                        size: sw * 0.055,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sw * 0.030),
              _field(nameCtrl, 'Full Name', sw),
              SizedBox(height: sw * 0.025),
              _field(
                degCtrl,
                p.isSchoolUser ? 'School Name' : 'University',
                sw,
              ),
              SizedBox(height: sw * 0.025),
              _field(
                classOrYearCtrl,
                p.isSchoolUser ? 'Class / Grade' : 'Graduation Year',
                sw,
                type: p.isSchoolUser
                    ? TextInputType.text
                    : TextInputType.number,
              ),
              SizedBox(height: sw * 0.040),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final fields = <String, dynamic>{
                    'full_name': nameCtrl.text.trim(),
                  };
                  if (p.isSchoolUser) {
                    fields['school_name'] = degCtrl.text.trim();
                    fields['class'] = classOrYearCtrl.text.trim();
                  } else {
                    fields['university'] = degCtrl.text.trim();
                    final yr = classOrYearCtrl.text.trim();
                    if (yr.isNotEmpty) {
                      fields['graduation_year'] = int.tryParse(yr) ?? yr;
                    }
                  }
                  final ok = await profileState.updateProfile(fields);
                  if (mounted) {
                    _showSnack(
                      ok ? 'Profile updated!' : 'Failed to update',
                      ok ? kSuccess : Colors.red,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: sw * 0.035,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _editContactSheet() {
    final sw = MediaQuery.of(context).size.width;
    final p = profileState;

    final emailCtrl = TextEditingController(text: p.email);
    final phoneCtrl = TextEditingController(text: p.phone);
    final locCtrl = TextEditingController(text: p.location);
    final collegeCtrl = TextEditingController(text: p.college);
    final liCtrl = TextEditingController(text: p.linkedin);
    final ghCtrl = TextEditingController(text: p.github);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: sw * 0.04),
              Text(
                'Contact and Profile',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.040),
              _field(emailCtrl, 'Email', sw, type: TextInputType.emailAddress),
              SizedBox(height: sw * 0.025),
              _field(phoneCtrl, 'Phone', sw, type: TextInputType.phone),
              SizedBox(height: sw * 0.025),
              _field(locCtrl, 'Address / Location', sw),
              SizedBox(height: sw * 0.025),
              _field(
                collegeCtrl,
                p.isSchoolUser ? 'School Name' : 'University / College',
                sw,
              ),
              SizedBox(height: sw * 0.025),
              _field(liCtrl, 'LinkedIn URL', sw),
              SizedBox(height: sw * 0.025),
              _field(ghCtrl, 'GitHub URL', sw),
              SizedBox(height: sw * 0.040),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final fields = <String, dynamic>{
                    'email': emailCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'address': locCtrl.text.trim(),
                    'linkedin_url': liCtrl.text.trim(),
                    'github_url': ghCtrl.text.trim(),
                  };
                  if (p.isSchoolUser) {
                    fields['school_name'] = collegeCtrl.text.trim();
                  } else {
                    fields['university'] = collegeCtrl.text.trim();
                  }
                  final ok = await profileState.updateProfile(fields);
                  if (mounted) {
                    _showSnack(
                      ok ? 'Contact updated!' : 'Failed to update',
                      ok ? kSuccess : Colors.red,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: sw * 0.035,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _editGoalStatusSheet() {
    final sw = MediaQuery.of(context).size.width;
    final p = profileState;
    final goalCtrl = TextEditingController(text: p.goal);
    final statusCtrl = TextEditingController(text: p.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: sw * 0.04),
              Text(
                'Goal & Status',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.040),
              _field(
                goalCtrl,
                'Your Goal (e.g. Get placed at FAANG)',
                sw,
                maxLines: 2,
              ),
              SizedBox(height: sw * 0.025),
              _field(statusCtrl, 'Status (e.g. Active, Placed, Looking)', sw),
              SizedBox(height: sw * 0.040),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await profileState.updateProfile({
                    'goal': goalCtrl.text.trim(),
                    'status': statusCtrl.text.trim(),
                  });
                  if (mounted) {
                    _showSnack(
                      ok ? 'Updated!' : 'Failed to update',
                      ok ? kSuccess : Colors.red,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: sw * 0.035,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  ADD CERT / PROJECT
  // ══════════════════════════════════════════════════════
  void _addCertDialog() {
    final sw = MediaQuery.of(context).size.width;
    final nameCtrl = TextEditingController();
    final issuerCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Certificate',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.040),
              _field(nameCtrl, 'Certificate Name', sw),
              SizedBox(height: sw * 0.025),
              _field(issuerCtrl, 'Issuer', sw),
              SizedBox(height: sw * 0.025),
              _field(dateCtrl, 'Date (e.g. Jan 2024)', sw),
              SizedBox(height: sw * 0.040),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: kMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        await _saveCertToBackend(
                          name: nameCtrl.text.trim(),
                          issuer: issuerCtrl.text.trim(),
                          date: dateCtrl.text.trim(),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
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

  Future<void> _saveCertToBackend({
    required String name,
    required String issuer,
    required String date,
  }) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;
    final userId = await const FlutterSecureStorage().read(key: 'user_id');
    if (userId == null) return;
    try {
      final res = await http.post(
        Uri.parse('${ProfileState._baseUrl}/certificates'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'user_id': _int(userId),
          'title': name,
          'issuer': issuer,
          'issue_date': date,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final certId = body is Map ? _str(body['data']?['certificate_id']) : '';
        profileState.set(
          () => profileState.certifications.add({
            'certificate_id': certId,
            'name': name,
            'issuer': issuer,
            'date': date,
            'file_url': '',
          }),
        );
        if (mounted) _showSnack('Certificate added! ✅', kSuccess);
      } else {
        final body = jsonDecode(res.body);
        if (mounted) {
          _showSnack(
            body is Map
                ? (_str(body['message']).isEmpty
                      ? 'Failed to save certificate'
                      : _str(body['message']))
                : 'Failed to save certificate',
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', Colors.red);
    }
  }

  void _addProjectDialog() {
    final sw = MediaQuery.of(context).size.width;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Project',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.040),
              _field(titleCtrl, 'Project Title', sw),
              SizedBox(height: sw * 0.025),
              _field(descCtrl, 'Description', sw, maxLines: 3),
              SizedBox(height: sw * 0.040),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: kMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (titleCtrl.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        await _saveProjectToBackend(
                          title: titleCtrl.text.trim(),
                          desc: descCtrl.text.trim(),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: sw * 0.033,
                            ),
                          ),
                        ),
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

  Future<void> _saveProjectToBackend({
    required String title,
    required String desc,
  }) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;
    if (token == null) return;
    final userId = await const FlutterSecureStorage().read(key: 'user_id');
    if (userId == null) return;
    try {
      final res = await http.post(
        Uri.parse('${ProfileState._baseUrl}/projects'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'user_id': _int(userId),
          'title': title,
          'description': desc,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final projectId = (body is Map && body['data'] != null)
            ? body['data']['project_id']
            : null;
        profileState.set(
          () => profileState.projects.add({
            'project_id': projectId,
            'title': title,
            'desc': desc,
            'tech': <String>[],
            'link': '',
          }),
        );
        if (mounted) _showSnack('Project added! ✅', kSuccess);
      } else {
        final body = jsonDecode(res.body);
        if (mounted) {
          _showSnack(
            body is Map
                ? (_str(body['message']).isEmpty
                      ? 'Failed to save project'
                      : _str(body['message']))
                : 'Failed to save project',
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', Colors.red);
    }
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    double sw, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: TextStyle(fontSize: sw * 0.033, color: kInk),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kHint, fontSize: sw * 0.033),
        filled: true,
        fillColor: kBgPage,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.040,
          vertical: sw * 0.030,
        ),
      ),
    );
  }
}
