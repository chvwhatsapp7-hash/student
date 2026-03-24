import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../api_services/applications.dart';

// ═══════════════════════════════════════════
//  DESIGN TOKENS
// ═══════════════════════════════════════════
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
const kTabs = ['All', 'Paid', 'Unpaid'];

// ═══════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════
class Internship {
  final int id;
  final String title, company, location, stipend, type, duration, logo, desc;
  final int match;
  final List<String> tags;
  final bool remote;

  Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.stipend,
    required this.type,
    required this.duration,
    required this.match,
    required this.logo,
    required this.tags,
    required this.remote,
    required this.desc,
  });

  factory Internship.fromJson(Map<String, dynamic> json) => Internship(
    id: json['internship_id'] ?? 0,
    title: json['title'] ?? 'No title',
    company: 'Company ${json['company_id'] ?? 0}',
    location: json['location'] ?? 'Remote',
    stipend: json['stipend'] != null ? '${json['stipend']}' : 'Unpaid',
    type: json['internship_type'] ?? 'Paid',
    duration: json['duration'] ?? '1 month',
    match: 0,
    logo: '',
    tags: (json['skills'] as List<dynamic>? ?? [])
        .map<String>((s) => s is Map ? s['name'].toString() : s.toString())
        .toList(),
    remote: json['location']?.toString().toLowerCase() == 'remote',
    desc: json['description'] ?? 'No description',
  );
}

// ═══════════════════════════════════════════
//  ICON SYSTEM
// ═══════════════════════════════════════════
class InternTheme {
  final IconData icon;
  final Color grad1, grad2;
  const InternTheme(this.icon, this.grad1, this.grad2);
}

InternTheme resolveInternTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();
  if (t.contains('software engineer') || t.contains('sde'))
    return const InternTheme(Icons.code, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('frontend') ||
      t.contains('front-end') ||
      t.contains('ui developer'))
    return const InternTheme(Icons.web, Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') || t.contains('back-end') || t.contains('server'))
    return const InternTheme(Icons.dns, Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const InternTheme(
      Icons.layers,
      Color(0xFF1D4ED8),
      Color(0xFF7C3AED),
    );
  if (t.contains('mobile') || t.contains('android') || t.contains('flutter'))
    return const InternTheme(
      Icons.phone_android,
      Color(0xFF0284C7),
      Color(0xFF38BDF8),
    );
  if (t.contains('machine learning') || t.contains(' ml'))
    return const InternTheme(
      Icons.psychology,
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
    );
  if (t.contains('data science') || t.contains('data analyst'))
    return const InternTheme(
      Icons.analytics,
      Color(0xFF7C3AED),
      Color(0xFF6366F1),
    );
  if (t.contains('artificial intelligence') ||
      t.contains(' ai') ||
      t.contains('ai '))
    return const InternTheme(
      Icons.smart_toy,
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
    );
  if (t.contains('cloud') ||
      t.contains('aws') ||
      t.contains('azure') ||
      t.contains('gcp'))
    return const InternTheme(Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('devops') || t.contains('sre'))
    return const InternTheme(
      Icons.sync_alt,
      Color(0xFF059669),
      Color(0xFF10B981),
    );
  if (t.contains('security') || t.contains('cyber') || t.contains('ethical'))
    return const InternTheme(
      Icons.shield,
      Color(0xFFB91C1C),
      Color(0xFFDC2626),
    );
  if (t.contains('ui') ||
      t.contains('ux') ||
      t.contains('design') ||
      t.contains('figma'))
    return const InternTheme(Icons.brush, Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('marketing') || t.contains('growth') || t.contains('seo'))
    return const InternTheme(
      Icons.trending_up,
      Color(0xFFD97706),
      Color(0xFFF59E0B),
    );
  if (t.contains('testing') || t.contains('qa') || t.contains('quality'))
    return const InternTheme(
      Icons.bug_report,
      Color(0xFFB45309),
      Color(0xFFD97706),
    );
  if (c.contains('google'))
    return const InternTheme(
      Icons.search,
      Color(0xFF1D4ED8),
      Color(0xFF0EA5E9),
    );
  if (c.contains('microsoft'))
    return const InternTheme(
      Icons.window,
      Color(0xFF1D4ED8),
      Color(0xFF3B82F6),
    );
  if (c.contains('amazon') || c.contains('aws'))
    return const InternTheme(Icons.cloud, Color(0xFFD97706), Color(0xFFF59E0B));
  return const InternTheme(
    Icons.work_outline,
    Color(0xFF1D4ED8),
    Color(0xFF6366F1),
  );
}

// ═══════════════════════════════════════════
//  ICON TILE
// ═══════════════════════════════════════════
class InternIconTile extends StatelessWidget {
  final String title, company;
  final double size;
  const InternIconTile({
    required this.title,
    required this.company,
    this.size = 50,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = resolveInternTheme(title, company);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.grad1, theme.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: theme.grad1.withOpacity(0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(theme.icon, color: Colors.white, size: size * 0.46),
    );
  }
}

// ═══════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════
class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});
  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen>
    with TickerProviderStateMixin {
  List<Internship> internships = [];
  final Set<int> saved = {};
  final Set<int> applied = {};
  final Map<int, AnimationController> cardAnims = {};
  String tab = 'All';
  String search = '';
  late AnimationController headerAnim;

  @override
  void initState() {
    super.initState();
    headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    loadAppliedInternships();
    fetchInternships();
  }

  Future<void> loadAppliedInternships() async {
    final appsData = await ApplicationsService.getApplications();
    if (appsData != null && appsData['success'] == true) {
      final dataList = appsData['data'] as List;
      if (mounted) {
        setState(() {
          applied.clear();
          applied.addAll(
            dataList
                .where((app) => app['internship_id'] != null)
                .map<int>((app) => app['internship_id'] as int),
          );
        });
      }
    }
  }

  Future<void> handleApply(int internshipId, String company) async {
    if (applied.contains(internshipId)) return;
    HapticFeedback.lightImpact();
    final result = await ApplicationsService.apply(internshipId: internshipId);
    if (result == 'Applied successfully') {
      if (mounted) setState(() => applied.add(internshipId));
      _showAppliedSnack(company);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: kWarning),
        );
    }
  }

  Future<void> fetchInternships() async {
    if (mounted) setState(() => internships = []);
    try {
      final response = await http.get(
        Uri.parse('https://studenthub-backend-woad.vercel.app/api/internships'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> dataList = jsonData['data'];
          for (final c in cardAnims.values) c.dispose();
          cardAnims.clear();
          final newList = dataList.map((e) => Internship.fromJson(e)).toList();
          for (int i = 0; i < newList.length; i++) {
            final ctrl = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 460),
            );
            cardAnims[newList[i].id] = ctrl;
            Future.delayed(Duration(milliseconds: 60 + i * 60), () {
              if (mounted) ctrl.forward();
            });
          }
          if (mounted) setState(() => internships = newList);
        } else {
          throw Exception('API returned success:false');
        }
      } else {
        throw Exception('Failed to load internships: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching internships: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to load internships: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
    }
  }

  List<Internship> get filtered {
    var list = tab == 'All'
        ? internships
        : internships.where((i) => i.type == tab).toList();
    if (search.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.title.toLowerCase().contains(search.toLowerCase()) ||
                i.company.toLowerCase().contains(search.toLowerCase()) ||
                i.tags.any(
                  (t) => t.toLowerCase().contains(search.toLowerCase()),
                ),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    headerAnim.dispose();
    for (final c in cardAnims.values) c.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  DETAIL SHEET
  // ─────────────────────────────────────────────
  void _showDetailSheet(Internship intern) {
    final sw = MediaQuery.of(context).size.width;
    final theme = resolveInternTheme(intern.title, intern.company);
    final isPaid = intern.type == 'Paid';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
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
                  InternIconTile(
                    title: intern.title,
                    company: intern.company,
                    size: sw * 0.14,
                  ),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          intern.title,
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: sw * 0.008),
                        Text(
                          intern.company,
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
                              intern.location,
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                color: kMuted,
                              ),
                            ),
                            if (intern.remote) ...[
                              SizedBox(width: sw * 0.020),
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
                                  'Remote',
                                  style: TextStyle(
                                    fontSize: sw * 0.025,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimary,
                                  ),
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
              SizedBox(height: sw * 0.05),
              Container(
                padding: EdgeInsets.all(sw * 0.040),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withOpacity(0.08),
                      theme.grad2.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.grad1.withOpacity(0.20),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    _statItem(
                      isPaid ? Icons.monetization_on : Icons.favorite,
                      intern.stipend,
                      'Stipend',
                      sw,
                      iconColor: isPaid ? kSuccess : const Color(0xFF7C3AED),
                    ),
                    _vDivider(),
                    _statItem(Icons.schedule, intern.duration, 'Duration', sw),
                    _vDivider(),
                    _statItem(Icons.work_outline, intern.type, 'Type', sw),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.05),
              Text(
                'Internship Details',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.030),
              Container(
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _detailRow(
                      Icons.location_on,
                      'Location',
                      intern.location,
                      sw,
                    ),
                    _dividerLine(),
                    _detailRow(Icons.schedule, 'Duration', intern.duration, sw),
                    _dividerLine(),
                    _detailRow(
                      Icons.currency_rupee,
                      'Stipend',
                      intern.stipend,
                      sw,
                    ),
                    _dividerLine(),
                    _detailRow(Icons.work_outline, 'Type', intern.type, sw),
                    if (intern.remote) ...[
                      _dividerLine(),
                      _detailRow(
                        Icons.wifi,
                        'Mode',
                        'Remote — work from anywhere',
                        sw,
                      ),
                    ],
                  ],
                ),
              ),
              if (intern.tags.isNotEmpty) ...[
                SizedBox(height: sw * 0.05),
                Text(
                  'Skills Required',
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
                  children: intern.tags
                      .map(
                        (t) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.030,
                            vertical: sw * 0.015,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.grad1.withOpacity(0.10),
                                theme.grad2.withOpacity(0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.grad1.withOpacity(0.25),
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
              ],
              SizedBox(height: sw * 0.05),
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
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Text(
                  intern.desc,
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    color: kSlate,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: sw * 0.05),
              Text(
                'About the Company',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              SizedBox(height: sw * 0.025),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InternIconTile(
                      title: intern.title,
                      company: intern.company,
                      size: sw * 0.10,
                    ),
                    SizedBox(width: sw * 0.030),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            intern.company,
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w800,
                              color: kInk,
                            ),
                          ),
                          SizedBox(height: sw * 0.010),
                          Text(
                            'This internship is offered by ${intern.company}. '
                            'Location: ${intern.location}. '
                            '${intern.remote ? 'This is a fully remote opportunity.' : ''}',
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: kMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.06),
              applied.contains(intern.id)
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF86EFAC),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: kSuccess,
                            size: sw * 0.045,
                          ),
                          SizedBox(width: sw * 0.020),
                          Text(
                            'Application Submitted',
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: FontWeight.w800,
                              color: kSuccess,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await handleApply(intern.id, intern.company);
                        _showApplyDialog(intern);
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
                              color: theme.grad1.withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color: Colors.white,
                              size: sw * 0.040,
                            ),
                            SizedBox(width: sw * 0.020),
                            Text(
                              'Apply for this Internship',
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

  // ─────────────────────────────────────────────
  //  SHEET HELPERS
  // ─────────────────────────────────────────────
  Widget _statItem(
    IconData icon,
    String value,
    String label,
    double sw, {
    Color iconColor = kPrimary,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: sw * 0.040, color: iconColor),
          SizedBox(height: sw * 0.012),
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

  Widget _vDivider() => Container(width: 1, height: 36, color: kBorder);

  Widget _detailRow(IconData icon, String label, String value, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.035,
        vertical: sw * 0.028,
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
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.030,
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
                fontSize: sw * 0.033,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
    height: 1,
    color: const Color(0xFFF1F5F9),
    margin: const EdgeInsets.symmetric(horizontal: 14),
  );

  // ─────────────────────────────────────────────
  //  APPLY DIALOG
  // ─────────────────────────────────────────────
  void _showApplyDialog(Internship intern) {
    final sw = MediaQuery.of(context).size.width;
    final theme = resolveInternTheme(intern.title, intern.company);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: sw * 0.13,
                    height: sw * 0.13,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.grad1, theme.grad2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.grad1.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
                            fontSize: sw * 0.040,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Text(
                          intern.company,
                          style: TextStyle(
                            fontSize: sw * 0.030,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.05),
              _dialogRow(Icons.location_on, 'Location', intern.location, sw),
              _dialogRow(Icons.schedule, 'Duration', intern.duration, sw),
              _dialogRow(Icons.currency_rupee, 'Stipend', intern.stipend, sw),
              _dialogRow(Icons.work_outline, 'Type', intern.type, sw),
              if (intern.remote)
                _dialogRow(
                  Icons.wifi,
                  'Mode',
                  'Remote — work from anywhere',
                  sw,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About the Role',
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: sw * 0.015),
                    Text(
                      intern.desc,
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        color: kSlate,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.035),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.030),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF86EFAC),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: kSuccess, size: sw * 0.045),
                    SizedBox(width: sw * 0.025),
                    Flexible(
                      child: Text(
                        'Application submitted successfully!',
                        style: TextStyle(
                          fontSize: sw * 0.033,
                          fontWeight: FontWeight.w700,
                          color: kSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.045),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.grad1.withOpacity(0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Got it!',
                      style: TextStyle(
                        fontSize: sw * 0.038,
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
      ),
    );
  }

  Widget _dialogRow(IconData icon, String label, String value, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.025),
      child: Row(
        children: [
          Container(
            width: sw * 0.075,
            height: sw * 0.075,
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kPrimary, size: sw * 0.038),
          ),
          SizedBox(width: sw * 0.025),
          Text(
            '$label  ',
            style: TextStyle(
              fontSize: sw * 0.030,
              color: kMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sw * 0.030,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppliedSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final paidCount = internships.where((i) => i.type == 'Paid').length;
    final unpaidCount = internships.where((i) => i.type == 'Unpaid').length;

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          // ── HEADER ──
          AnimatedBuilder(
            animation: headerAnim,
            builder: (_, child) =>
                Opacity(opacity: headerAnim.value, child: child),
            child: Container(
              color: kInk,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Container(
                              width: sw * 0.09,
                              height: sw * 0.09,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: sw * 0.040,
                              ),
                            ),
                          ),
                          SizedBox(width: sw * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Internships',
                                  style: TextStyle(
                                    fontSize: sw * 0.050,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Real experience, real growth',
                                  style: TextStyle(
                                    fontSize: sw * 0.030,
                                    color: Colors.white.withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (saved.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.030,
                                vertical: sw * 0.015,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    color: kAccent,
                                    size: sw * 0.033,
                                  ),
                                  SizedBox(width: sw * 0.010),
                                  Text(
                                    '${saved.length} Saved',
                                    style: TextStyle(
                                      fontSize: sw * 0.030,
                                      fontWeight: FontWeight.w700,
                                      color: kAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: sw * 0.04),
                      Wrap(
                        spacing: sw * 0.025,
                        runSpacing: sw * 0.015,
                        children: [
                          _statPill(
                            Icons.work_outline,
                            '${internships.length}',
                            'Total',
                            sw,
                          ),
                          _statPill(
                            Icons.currency_rupee,
                            '$paidCount',
                            'Paid',
                            sw,
                          ),
                          _statPill(
                            Icons.volunteer_activism,
                            '$unpaidCount',
                            'Unpaid',
                            sw,
                          ),
                          _statPill(
                            Icons.trending_up,
                            internships.isEmpty
                                ? '0'
                                : '${internships.map((e) => int.tryParse(e.stipend.replaceAll(',', '')) ?? 0).reduce((a, b) => a > b ? a : b)}',
                            'Max',
                            sw,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── SEARCH ──
          Container(
            color: kCardBg,
            padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.030, sw * 0.04, 0),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
              decoration: InputDecoration(
                hintText: 'Search by role, company or skill...',
                hintStyle: TextStyle(fontSize: sw * 0.033, color: kHint),
                prefixIcon: Icon(Icons.search, color: kMuted, size: sw * 0.050),
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
          ),

          // ── TAB SWITCHER ──
          Container(
            color: kCardBg,
            padding: EdgeInsets.fromLTRB(
              sw * 0.04,
              sw * 0.030,
              sw * 0.04,
              sw * 0.030,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.010),
                  decoration: BoxDecoration(
                    color: kBgPage,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: kTabs.map((t) {
                      final active = tab == t;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => tab = t);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.045,
                            vertical: sw * 0.020,
                          ),
                          decoration: BoxDecoration(
                            color: active ? kPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : kMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.030,
                    vertical: sw * 0.018,
                  ),
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(
                    '${filtered.length} results',
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── LIST ──
          Expanded(
            child: RefreshIndicator(
              color: kPrimary,
              onRefresh: () async {
                await fetchInternships();
                await loadAppliedInternships();
              },
              child: filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: sw * 0.18,
                                height: sw * 0.18,
                                decoration: const BoxDecoration(
                                  color: kSelectedBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  color: kPrimary,
                                  size: sw * 0.08,
                                ),
                              ),
                              SizedBox(height: sw * 0.04),
                              Text(
                                'No internships found',
                                style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.w700,
                                  color: kSlate,
                                ),
                              ),
                              SizedBox(height: sw * 0.015),
                              Text(
                                'Pull down to refresh or clear filters',
                                style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: kMuted,
                                ),
                              ),
                              SizedBox(height: sw * 0.04),
                              GestureDetector(
                                onTap: () => setState(() {
                                  tab = 'All';
                                  search = '';
                                }),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.05,
                                    vertical: sw * 0.025,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Clear filters',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: sw * 0.033,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        sw * 0.04,
                        sw * 0.035,
                        sw * 0.04,
                        sw * 0.06,
                      ),
                      itemCount: filtered.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (_, i) => InternshipCard(
                        internship: filtered[i],
                        sw: sw,
                        isSaved: saved.contains(filtered[i].id),
                        isApplied: applied.contains(filtered[i].id),
                        ctrl: cardAnims[filtered[i].id],
                        onTap: () => _showDetailSheet(filtered[i]),
                        onSave: () {
                          HapticFeedback.selectionClick();
                          setState(
                            () => saved.contains(filtered[i].id)
                                ? saved.remove(filtered[i].id)
                                : saved.add(filtered[i].id),
                          );
                        },
                        onApply: () =>
                            handleApply(filtered[i].id, filtered[i].company),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String num, String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.025,
        vertical: sw * 0.013,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.030, color: kAccent),
          SizedBox(width: sw * 0.010),
          Text(
            num,
            style: TextStyle(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w800,
              color: kAccent,
            ),
          ),
          SizedBox(width: sw * 0.008),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  INTERNSHIP CARD
// ═══════════════════════════════════════════
class InternshipCard extends StatefulWidget {
  final Internship internship;
  final double sw;
  final bool isSaved, isApplied;
  final AnimationController? ctrl;
  final VoidCallback onSave, onApply, onTap;

  const InternshipCard({
    required this.internship,
    required this.sw,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    required this.onTap,
    this.ctrl,
    super.key,
  });

  @override
  State<InternshipCard> createState() => _InternshipCardState();
}

class _InternshipCardState extends State<InternshipCard>
    with SingleTickerProviderStateMixin {
  bool btnPressed = false;
  late AnimationController btnCtrl;
  late Animation<double> btnScale;

  @override
  void initState() {
    super.initState();
    btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    btnScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intern = widget.internship;
    final sw = widget.sw;
    final ctrl = widget.ctrl;
    final theme = resolveInternTheme(intern.title, intern.company);
    final isPaid = intern.type == 'Paid';

    final fade = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: EdgeInsets.only(bottom: sw * 0.035),
            decoration: BoxDecoration(
              gradient: widget.isApplied
                  ? LinearGradient(
                      colors: [
                        theme.grad1.withOpacity(0.09),
                        theme.grad2.withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isApplied ? null : kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isApplied
                    ? theme.grad1.withOpacity(0.50)
                    : kBorder,
                width: widget.isApplied ? 2 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isApplied)
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
                  padding: EdgeInsets.fromLTRB(
                    sw * 0.04,
                    sw * 0.040,
                    sw * 0.04,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title Row ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InternIconTile(
                            title: intern.title,
                            company: intern.company,
                            size: sw * 0.125,
                          ),
                          SizedBox(width: sw * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  intern.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: sw * 0.035,
                                    color: kInk,
                                  ),
                                ),
                                SizedBox(height: sw * 0.008),
                                Text(
                                  intern.company,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: kMuted,
                                    fontSize: sw * 0.030,
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
                                      intern.location,
                                      style: TextStyle(
                                        fontSize: sw * 0.030,
                                        color: kMuted,
                                      ),
                                    ),
                                    if (intern.remote) ...[
                                      SizedBox(width: sw * 0.020),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: sw * 0.018,
                                          vertical: sw * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kSelectedBg,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'Remote',
                                          style: TextStyle(
                                            fontSize: sw * 0.025,
                                            fontWeight: FontWeight.w700,
                                            color: kPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onSave,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: sw * 0.085,
                              height: sw * 0.085,
                              decoration: BoxDecoration(
                                color: widget.isSaved ? kSelectedBg : kBgPage,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.isSaved ? kPrimary : kBorder,
                                ),
                              ),
                              child: Icon(
                                widget.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: sw * 0.043,
                                color: widget.isSaved ? kPrimary : kHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.030),

                      // ── Description ──
                      Text(
                        intern.desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: sw * 0.030,
                          color: kHint,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: sw * 0.015),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: sw * 0.028,
                            color: kHint,
                          ),
                          SizedBox(width: sw * 0.010),
                          Text(
                            'Tap card to view full details',
                            style: TextStyle(
                              fontSize: sw * 0.025,
                              color: kHint.withOpacity(0.70),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.030),

                      // ── Chips: Duration + Stipend ──
                      Wrap(
                        spacing: sw * 0.018,
                        runSpacing: sw * 0.015,
                        children: [
                          _chip(Icons.schedule, intern.duration, sw),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.023,
                              vertical: sw * 0.013,
                            ),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPaid
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFDDD6FE),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPaid
                                      ? Icons.monetization_on
                                      : Icons.favorite,
                                  size: sw * 0.030,
                                  color: isPaid
                                      ? kSuccess
                                      : const Color(0xFF7C3AED),
                                ),
                                SizedBox(width: sw * 0.010),
                                Text(
                                  intern.stipend,
                                  style: TextStyle(
                                    fontSize: sw * 0.028,
                                    fontWeight: FontWeight.w800,
                                    color: isPaid
                                        ? kSuccess
                                        : const Color(0xFF7C3AED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ✅ Skills on new line
                      if (intern.tags.isNotEmpty) ...[
                        SizedBox(height: sw * 0.015),
                        Wrap(
                          spacing: sw * 0.015,
                          runSpacing: sw * 0.015,
                          children: intern.tags
                              .map(
                                (t) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.023,
                                    vertical: sw * 0.013,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: kBorder),
                                  ),
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: sw * 0.028,
                                      fontWeight: FontWeight.w700,
                                      color: kSlate,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      // ── Divider ──
                      Container(
                        margin: EdgeInsets.symmetric(vertical: sw * 0.030),
                        height: 1,
                        color: const Color(0xFFF1F5F9),
                      ),

                      // ── Bottom Row ──
                      Row(
                        children: [
                          if (widget.isApplied)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.025,
                                vertical: sw * 0.013,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.grad1, theme.grad2],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: sw * 0.030,
                                  ),
                                  SizedBox(width: sw * 0.013),
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
                            )
                          else if (intern.match > 0)
                            _matchBadge(intern.match, sw),
                          const Spacer(),
                          GestureDetector(
                            onTapDown: widget.isApplied
                                ? null
                                : (_) {
                                    btnCtrl.forward();
                                    setState(() => btnPressed = true);
                                  },
                            onTapUp: widget.isApplied
                                ? null
                                : (_) {
                                    btnCtrl.reverse();
                                    setState(() => btnPressed = false);
                                    widget.onApply();
                                  },
                            onTapCancel: () {
                              btnCtrl.reverse();
                              setState(() => btnPressed = false);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: ScaleTransition(
                              scale: btnScale,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.055,
                                  vertical: sw * 0.025,
                                ),
                                decoration: BoxDecoration(
                                  gradient: widget.isApplied
                                      ? null
                                      : LinearGradient(
                                          colors: [theme.grad1, theme.grad2],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                  color: widget.isApplied
                                      ? const Color(0xFFF0FDF4)
                                      : null,
                                  borderRadius: BorderRadius.circular(30),
                                  border: widget.isApplied
                                      ? Border.all(
                                          color: const Color(0xFF86EFAC),
                                          width: 1.5,
                                        )
                                      : null,
                                  boxShadow: widget.isApplied || btnPressed
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: theme.grad1.withOpacity(
                                              0.28,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Text(
                                  widget.isApplied ? 'Applied' : 'Apply Now',
                                  style: TextStyle(
                                    color: widget.isApplied
                                        ? kSuccess
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: sw * 0.033,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.04),
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

  Widget _chip(IconData icon, String label, double sw) => Container(
    padding: EdgeInsets.symmetric(horizontal: sw * 0.020, vertical: sw * 0.013),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: sw * 0.030, color: kHint),
        SizedBox(width: sw * 0.010),
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.028,
            fontWeight: FontWeight.w700,
            color: kMuted,
          ),
        ),
      ],
    ),
  );

  Widget _matchBadge(int match, double sw) {
    final color = match >= 90
        ? kSuccess
        : match >= 80
        ? kWarning
        : kMuted;
    final bg = match >= 90
        ? const Color(0xFFF0FDF4)
        : match >= 80
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF1F5F9);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.025,
        vertical: sw * 0.013,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$match% Match',
        style: TextStyle(
          fontSize: sw * 0.028,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
