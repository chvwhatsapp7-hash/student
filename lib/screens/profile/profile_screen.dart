import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../api_services/authservice.dart';

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
      resumeName = '';

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> skills = [];
  List<Map<String, String>> certifications = [];
  List<Map<String, dynamic>> projects = [];
  List applications = [];

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

  static const _baseUrl = 'https://studenthub-backend-woad.vercel.app';
  final _storage = const FlutterSecureStorage();

  Future<void> fetchProfile() async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) throw Exception('Not logged in');
      final res = await http.get(
        Uri.parse('$_baseUrl/api/profile/getUsers?user_id=$userId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode != 200)
        throw Exception('Server error ${res.statusCode}');
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] != true) throw Exception('API returned failure');
      final data = body['data'] as Map<String, dynamic>;
      _mapUser(data['user'] as Map<String, dynamic>);
      _mapApplications(data['applications'] as List<dynamic>);
      _mapCertificates(data['certificates'] as List<dynamic>);
      _mapProjects(data['projects'] as List<dynamic>);
      _mapSkills(data['skills'] as List<dynamic>);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    try {
      await AuthService().loadTokens();
      final token = AuthService().accessToken;

      if (token == null) {
        throw Exception("Token is null. Please login again.");
      }

      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return false;
      final body = {'user_id': int.parse(userId), ...fields};
      final res = await http.put(
        Uri.parse('$_baseUrl/api/profile/getUsers'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        final resBody = jsonDecode(res.body);
        if (resBody['data']?['user'] != null) {
          _mapUser(resBody['data']['user'] as Map<String, dynamic>);
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

  void _mapUser(Map<String, dynamic> u) {
    name = u['full_name'] ?? '';
    email = u['email'] ?? '';
    phone = u['phone'] ?? '';
    about = u['about_me'] ?? '';
    location = u['address'] ?? '';
    linkedin = u['linkedin_url'] ?? '';
    github = u['github_url'] ?? '';
    resumeName = u['resume_url'] ?? '';
    final deg = u['degree'] ?? '';
    final uni = u['university'] ?? '';
    final year = u['graduation_year']?.toString() ?? '';
    college = uni;
    degree = [deg, uni, year].where((s) => s.isNotEmpty).join('  •  ');
  }

  void _mapApplications(List<dynamic> list) {
    applications = list.map((a) {
      final isJob = a['job_id'] != null;
      return {
        'id': a['id'],
        'job_id': a['job_id'],
        'internship_id': a['internship_id'],
        'role': (isJob ? a['job_title'] : a['internship_title']) ?? '',
        'company':
            (isJob ? a['job_company_name'] : a['internship_company_name']) ??
            '',
        'status': _capitalize(a['status'] ?? 'applied'),
        'date': _timeAgo(a['applied_at']),
        'type': isJob ? 'Job' : 'Internship',
      };
    }).toList();
  }

  void _mapCertificates(List<dynamic> list) {
    certifications = list
        .map(
          (c) => {
            'certificate_id': (c['certificate_id'] ?? '').toString(),
            'name': (c['title'] ?? '') as String,
            'issuer': (c['issuer'] ?? '') as String,
            'date': _formatDate(c['issue_date']),
          },
        )
        .toList();
  }

  void _mapProjects(List<dynamic> list) {
    projects = list
        .map(
          (p) => <String, dynamic>{
            'project_id': p['project_id'],
            'title': (p['title'] ?? '') as String,
            'desc': (p['description'] ?? '') as String,
            'tech': <String>[],
            'link': '',
          },
        )
        .toList();
  }

  void _mapSkills(List<dynamic> list) {
    skills = list
        .map(
          (s) => <String, dynamic>{
            'skill_id': s['skill_id'],
            'name': (s['skill_name'] ?? '') as String,
            'level': ((s['proficiency'] as num) / 100.0).clamp(0.0, 1.0),
          },
        )
        .toList();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
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
    if (iso == null) return '';
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
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  late AnimationController _headerAnim, _xpAnim;
  late Animation<double> _xpVal;
  late List<AnimationController> _skillAnims;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
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
            if (mounted) _skillAnims[i].forward();
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
    for (final c in _skillAnims) c.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  WITHDRAW APPLICATION
  // ─────────────────────────────────────────────
  Future<void> _withdrawApplication(Map app, int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (index < 0 || index >= profileState.applications.length) return;
    try {
      final userId = await const FlutterSecureStorage().read(key: 'user_id');
      final isJob = (app['type'] ?? 'Job') == 'Job';
      final body = <String, dynamic>{
        'user_id': int.tryParse(userId ?? '0') ?? 0,
        if (isJob) 'job_id': app['job_id'],
        if (!isJob) 'internship_id': app['internship_id'],
      };
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/api/applications'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        if (index < profileState.applications.length)
          profileState.set(() => profileState.applications.removeAt(index));
        _showSnack('Application withdrawn', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed');
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  // ─────────────────────────────────────────────
  //  DELETE PROJECT
  // ─────────────────────────────────────────────
  Future<void> _deleteProject(int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

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
        Uri.parse('${ProfileState._baseUrl}/api/projects'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'project_id': projectId}),
      );
      if (res.statusCode == 200) {
        if (index < profileState.projects.length)
          profileState.set(() => profileState.projects.removeAt(index));
        _showSnack('Project deleted', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed');
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  // ─────────────────────────────────────────────
  //  DELETE CERTIFICATE
  // ─────────────────────────────────────────────
  Future<void> _deleteCertificate(int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (index < 0 || index >= profileState.certifications.length) return;
    final cert = profileState.certifications[index];
    final certId = cert['certificate_id'];
    if (certId == null || certId.isEmpty) {
      profileState.set(() => profileState.certifications.removeAt(index));
      _showSnack('Certificate removed', kSuccess);
      return;
    }
    try {
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/api/certificates'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'certificate_id': int.parse(certId)}),
      );
      if (res.statusCode == 200) {
        if (index < profileState.certifications.length)
          profileState.set(() => profileState.certifications.removeAt(index));
        _showSnack('Certificate deleted', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed');
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  // ─────────────────────────────────────────────
  //  DELETE SKILL
  // ─────────────────────────────────────────────
  Future<void> _deleteSkill(int index) async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (index < 0 || index >= profileState.skills.length) return;
    final sk = profileState.skills[index];
    final skillId = sk['skill_id'] as int?;
    if (skillId == null) {
      profileState.set(() => profileState.skills.removeAt(index));
      _showSnack('Skill removed', kSuccess);
      return;
    }
    try {
      final userId = await const FlutterSecureStorage().read(key: 'user_id');
      final res = await http.delete(
        Uri.parse('${ProfileState._baseUrl}/api/user-skills'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({'user_id': int.parse(userId!), 'skill_id': skillId}),
      );
      if (res.statusCode == 200) {
        if (index < profileState.skills.length)
          profileState.set(() => profileState.skills.removeAt(index));
        _showSnack('Skill removed', kSuccess);
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['message'] ?? 'Failed');
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  // ─────────────────────────────────────────────
  //  ADD SKILL DIALOG
  // ─────────────────────────────────────────────
  Future<void> _addSkillDialog() async {
    final sw = MediaQuery.of(context).size.width;
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    final Future<List<Map<String, dynamic>>> skillsFuture = http
        .get(
          Uri.parse('${ProfileState._baseUrl}/api/skills'),
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
            } else if (body['data'] is List) {
              list = body['data'];
            } else if (body['skills'] is List) {
              list = body['skills'];
            }
            return list
                .map(
                  (s) => <String, dynamic>{
                    'skill_id': s['skill_id'] ?? s['id'],
                    'name': (s['name'] ?? s['skill_name'] ?? '').toString(),
                  },
                )
                .where(
                  (s) =>
                      s['skill_id'] != null && (s['name'] as String).isNotEmpty,
                )
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
                                    value: s['skill_id'] as int,
                                    child: Text(s['name'] as String),
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
                                    selectedSkillName =
                                        allSkills.firstWhere(
                                              (s) => s['skill_id'] == val,
                                            )['name']
                                            as String;
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
                            final proficiency = (level * 100).round().clamp(
                              1,
                              100,
                            );
                            final postBody = {
                              'user_id': int.parse(userId!),
                              'skill_name': finalSkillName,
                              'proficiency': proficiency,
                            };
                            debugPrint('POST /api/user-skills body: $postBody');
                            final res = await http.post(
                              Uri.parse(
                                '${ProfileState._baseUrl}/api/user-skills',
                              ),
                              headers: {
                                "Content-Type": "application/json",
                                "Authorization": "Bearer $token",
                              },
                              body: jsonEncode(postBody),
                            );
                            debugPrint(
                              'POST /api/user-skills status: ${res.statusCode}',
                            );
                            debugPrint(
                              'POST /api/user-skills response: ${res.body}',
                            );
                            if (res.statusCode == 200 ||
                                res.statusCode == 201) {
                              final resData = jsonDecode(res.body);
                              final newSkillId = resData['data']?['skill_id'];
                              profileState.set(() {
                                final existingIndex = profileState.skills
                                    .indexWhere(
                                      (s) =>
                                          (s['name'] as String).toLowerCase() ==
                                          finalSkillName.toLowerCase(),
                                    );
                                if (existingIndex != -1) {
                                  profileState.skills[existingIndex]['level'] =
                                      level;
                                } else {
                                  profileState.skills.add({
                                    'skill_id': newSkillId,
                                    'name': finalSkillName,
                                    'level': level,
                                  });
                                }
                              });
                              _showSnack('Skill added! ✅', kSuccess);
                            } else {
                              final data = jsonDecode(res.body);
                              _showSnack(
                                data['message'] ?? 'Failed to save skill',
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

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return ListenableBuilder(
      listenable: profileState,
      builder: (_, __) {
        if (profileState.isLoading)
          return const Scaffold(
            backgroundColor: kBgPage,
            body: Center(child: CircularProgressIndicator(color: kPrimary)),
          );
        if (profileState.errorMessage != null)
          return Scaffold(
            backgroundColor: kBgPage,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: sw * 0.12),
                  SizedBox(height: sw * 0.030),
                  Text(
                    profileState.errorMessage!,
                    style: const TextStyle(color: kSlate),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: sw * 0.040),
                  GestureDetector(
                    onTap: profileState.fetchProfile,
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
          );
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
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
                    _iconBtn(
                      Icons.arrow_back_ios_new,
                      () => Navigator.maybePop(context),
                      sw,
                    ),
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
                    _iconBtn(
                      Icons.edit,
                      _editBasicInfo,
                      sw,
                      bg: kPrimary.withValues(alpha: 0.45),
                      iconColor: kAccent,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.030),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: sw * 0.16,
                    height: sw * 0.16,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: sw * 0.07,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _editBasicInfo,
                    child: Container(
                      width: sw * 0.06,
                      height: sw * 0.06,
                      decoration: BoxDecoration(
                        color: kAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: kInk, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: sw * 0.028,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.020),
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
              Text(
                p.degree,
                style: TextStyle(
                  fontSize: sw * 0.028,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: sw * 0.030),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
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
          color: Colors.white.withValues(alpha: 0.50),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _hDiv() => Container(
    width: 1,
    height: 30,
    color: Colors.white.withValues(alpha: 0.10),
  );

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
          color: bg ?? Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: sw * 0.040),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────────
  Widget _tabBar(double sw) => Container(
    color: kCardBg,
    child: TabBar(
      controller: _tab,
      isScrollable: true,
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
      ],
    ),
  );

  // ─────────────────────────────────────────────
  //  TAB 1 — OVERVIEW
  // ─────────────────────────────────────────────
  Widget _overview(double sw) {
    final p = profileState;
    return ListView(
      padding: EdgeInsets.all(sw * 0.040),
      children: [
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
              _dRow(Icons.school, p.college, 'College', sw),
              _dRow(Icons.location_on, p.location, 'Location', sw),
              _dRow(Icons.email, p.email, 'Email', sw),
              _dRow(Icons.phone, p.phone, 'Phone', sw),
              _dRow(Icons.link, p.linkedin, 'LinkedIn', sw),
              _dRow(Icons.code, p.github, 'GitHub', sw, last: true),
            ],
          ),
        ),
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
                    final pct = ((s['level'] as double) * 100).toInt();
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
                        '${s['name']}  $pct%',
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
      ],
    );
  }

  Widget _resumeCard(double sw) {
    final p = profileState;
    final has = p.resumeName.isNotEmpty;
    return GestureDetector(
      onTap: _uploadResume,
      child: Container(
        padding: EdgeInsets.all(sw * 0.040),
        decoration: BoxDecoration(
          gradient: has
              ? LinearGradient(
                  colors: [
                    kPrimary.withValues(alpha: 0.07),
                    const Color(0xFF4F46E5).withValues(alpha: 0.03),
                  ],
                )
              : null,
          color: has ? null : kCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: has ? kPrimary.withValues(alpha: 0.40) : kBorder,
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
                    color: kPrimary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
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
                    has ? 'Resume Uploaded ✓' : 'Upload Your Resume',
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w800,
                      color: has ? kSuccess : kInk,
                    ),
                  ),
                  SizedBox(height: sw * 0.008),
                  Text(
                    has ? p.resumeName : 'PDF or DOC  •  Max 5MB',
                    style: TextStyle(fontSize: sw * 0.030, color: kMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.025),
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

  // ─────────────────────────────────────────────
  //  TAB 2 — SKILLS
  // ─────────────────────────────────────────────
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
                    final name = sk['name'] as String;
                    final target = sk['level'] as double;
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
                  color: kPrimary.withValues(alpha: 0.35),
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

  // ─────────────────────────────────────────────
  //  TAB 3 — CERTS
  // ─────────────────────────────────────────────
  Widget _certs(double sw) {
    final p = profileState;
    return ListView(
      padding: EdgeInsets.all(sw * 0.040),
      children: [
        ...List.generate(p.certifications.length, (i) {
          final c = p.certifications[i];
          final theme = _certTheme(c['name'] ?? '');
          return Padding(
            padding: EdgeInsets.only(bottom: sw * 0.030),
            child: Container(
              padding: EdgeInsets.all(sw * 0.040),
              decoration: BoxDecoration(
                color: theme.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.g1.withValues(alpha: 0.20),
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
                          c['name'] ?? '',
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        SizedBox(height: sw * 0.008),
                        Text(
                          c['issuer'] ?? '',
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Text(
                          c['date'] ?? '',
                          style: TextStyle(fontSize: sw * 0.025, color: kHint),
                        ),
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
                  color: kPrimary.withValues(alpha: 0.35),
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

  // ─────────────────────────────────────────────
  //  TAB 4 — PROJECTS
  // ─────────────────────────────────────────────
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
                          proj['title'] as String,
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
                    proj['desc'] as String,
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
                  color: kPrimary.withValues(alpha: 0.35),
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

  // ─────────────────────────────────────────────
  //  TAB 5 — APPLICATIONS
  // ─────────────────────────────────────────────
  Widget _applicationsTab(double sw) {
    final p = profileState;
    if (p.applications.isEmpty)
      return Center(
        child: Text(
          'No applications yet.',
          style: TextStyle(color: kMuted, fontSize: sw * 0.035),
        ),
      );
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.040),
      itemCount: p.applications.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.025),
      itemBuilder: (_, i) {
        final app = p.applications[i] as Map;
        final statusColor = app['status'] == 'Applied'
            ? kPrimary
            : app['status'] == 'Accepted'
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
                      app['role'] as String,
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      app['company'] as String,
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
                            color: statusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            app['status'] as String,
                            style: TextStyle(
                              fontSize: sw * 0.025,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          app['date'] as String,
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

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────
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

  void _showSnack(String msg, Color color) {
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

  void _editBasicInfo() {
    final sw = MediaQuery.of(context).size.width;
    final p = profileState;
    final nameCtrl = TextEditingController(text: p.name);
    final degCtrl = TextEditingController(text: p.college);
    final yearCtrl = TextEditingController();
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
        child: Padding(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Basic Info',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.040),
              _field(nameCtrl, 'Full Name', sw),
              SizedBox(height: sw * 0.025),
              _field(degCtrl, 'University', sw),
              SizedBox(height: sw * 0.025),
              _field(
                yearCtrl,
                'Graduation Year',
                sw,
                type: TextInputType.number,
              ),
              SizedBox(height: sw * 0.040),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await profileState.updateProfile({
                    'full_name': nameCtrl.text.trim(),
                    'university': degCtrl.text.trim(),
                    if (yearCtrl.text.trim().isNotEmpty)
                      'graduation_year': int.tryParse(yearCtrl.text.trim()),
                  });
                  _showSnack(
                    ok ? 'Profile updated!' : 'Failed to update',
                    ok ? kSuccess : Colors.red,
                  );
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
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EDIT CONTACT SHEET  ← fully rewritten
  // ─────────────────────────────────────────────
  void _editContactSheet() {
    final sw = MediaQuery.of(context).size.width;
    final p = profileState;

    // All six editable fields
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
              _field(collegeCtrl, 'University / College', sw),
              SizedBox(height: sw * 0.025),
              _field(liCtrl, 'LinkedIn URL', sw),
              SizedBox(height: sw * 0.025),
              _field(ghCtrl, 'GitHub URL', sw),
              SizedBox(height: sw * 0.040),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await profileState.updateProfile({
                    'email': emailCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'address': locCtrl.text.trim(),
                    'university': collegeCtrl.text.trim(),
                    'linkedin_url': liCtrl.text.trim(),
                    'github_url': ghCtrl.text.trim(),
                  });
                  // Mirror changes in local state immediately
                  if (ok) {
                    profileState.set(() {
                      profileState.email = emailCtrl.text.trim();
                      profileState.college = collegeCtrl.text.trim();
                    });
                  }
                  _showSnack(
                    ok ? 'Contact updated!' : 'Failed to update',
                    ok ? kSuccess : Colors.red,
                  );
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
            ],
          ),
        ),
      ),
    );
  }

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
                      onTap: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        profileState.set(
                          () => profileState.certifications.add({
                            'certificate_id': '',
                            'name': nameCtrl.text.trim(),
                            'issuer': issuerCtrl.text.trim(),
                            'date': dateCtrl.text.trim(),
                          }),
                        );
                        _showSnack('Certificate added!', kSuccess);
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
                      onTap: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        Navigator.pop(context);
                        profileState.set(
                          () => profileState.projects.add({
                            'project_id': null,
                            'title': titleCtrl.text.trim(),
                            'desc': descCtrl.text.trim(),
                            'tech': <String>[],
                            'link': '',
                          }),
                        );
                        _showSnack('Project added!', kSuccess);
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

  void _uploadResume() {
    _showSnack('Resume upload coming soon!', kWarning);
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
