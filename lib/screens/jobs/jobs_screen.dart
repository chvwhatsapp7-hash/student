import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../notifications/notification_page.dart';

import '../../api_services/applications.dart';
import '../../api_services/authservice.dart';

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
const List<String> kFilters = [
  'All',
  'Full Time',
  'Remote',
  'Fresher',
  'Bengaluru',
];

// ═══════════════════════════════════════════
//  JOB MODEL
// ═══════════════════════════════════════════
class Job {
  final int id;
  final String title, company, location, salary, type, logo, exp, posted, desc;
  final int match;
  final List<String> tags;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.match,
    required this.logo,
    required this.tags,
    required this.exp,
    required this.posted,
    required this.desc,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
    id: json['job_id'] ?? 0,
    title: json['title'] ?? 'No title',
    company: 'Company ${json['company_id'] ?? 0}',
    location: json['location'] ?? 'Remote',
    salary: json['salary_min'] != null && json['salary_max'] != null
        ? '${json['salary_min']}-${json['salary_max']}'
        : 'Negotiable',
    type: json['job_type'] ?? 'Full Time',
    match: 80,
    logo: '',
    // ✅ reads skills array returned by GET /api/jobs
    tags: (json['skills'] as List<dynamic>? ?? [])
        .map<String>((t) => t.toString())
        .toList(),
    exp: json['experience_level'] ?? 'Fresher',
    posted: 'Recently',
    desc: json['description'] ?? '',
  );
}

// ═══════════════════════════════════════════
//  JOB THEME SYSTEM
// ═══════════════════════════════════════════
class JobTheme {
  final IconData icon;
  final Color grad1, grad2;
  const JobTheme(this.icon, this.grad1, this.grad2);
}

JobTheme resolveJobTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();
  if (t.contains('software engineer') ||
      t.contains('sde') ||
      t.contains('software developer'))
    return const JobTheme(Icons.code, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('frontend') ||
      t.contains('front-end') ||
      t.contains('ui developer'))
    return const JobTheme(Icons.web, Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') || t.contains('back-end') || t.contains('server'))
    return const JobTheme(Icons.dns, Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const JobTheme(Icons.layers, Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('mobile') || t.contains('android') || t.contains('flutter'))
    return const JobTheme(
      Icons.phone_android,
      Color(0xFF0284C7),
      Color(0xFF38BDF8),
    );
  if (t.contains('ios') || t.contains('swift'))
    return const JobTheme(
      Icons.phone_iphone,
      Color(0xFF374151),
      Color(0xFF6B7280),
    );
  if (t.contains('machine learning') || t.contains(' ml'))
    return const JobTheme(
      Icons.psychology,
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
    );
  if (t.contains('data scientist') || t.contains('data science'))
    return const JobTheme(
      Icons.analytics,
      Color(0xFF7C3AED),
      Color(0xFF6366F1),
    );
  if (t.contains('data analyst') || t.contains('data engineer'))
    return const JobTheme(
      Icons.bar_chart,
      Color(0xFF0369A1),
      Color(0xFF0284C7),
    );
  if (t.contains('artificial intelligence') ||
      t.contains(' ai') ||
      t.contains('ai '))
    return const JobTheme(
      Icons.smart_toy,
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
    );
  if (t.contains('cloud') ||
      t.contains('aws') ||
      t.contains('azure') ||
      t.contains('gcp'))
    return const JobTheme(Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('devops') ||
      t.contains('sre') ||
      t.contains('platform engineer'))
    return const JobTheme(Icons.sync_alt, Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('security') || t.contains('cyber') || t.contains('ethical'))
    return const JobTheme(Icons.shield, Color(0xFFB91C1C), Color(0xFFDC2626));
  if (t.contains('ui') ||
      t.contains('ux') ||
      t.contains('design') ||
      t.contains('figma'))
    return const JobTheme(Icons.brush, Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('product manager') || t.contains('product management'))
    return const JobTheme(
      Icons.inventory_2,
      Color(0xFFD97706),
      Color(0xFFF59E0B),
    );
  if (t.contains('marketing') || t.contains('growth'))
    return const JobTheme(
      Icons.trending_up,
      Color(0xFFD97706),
      Color(0xFFF59E0B),
    );
  if (t.contains('testing') || t.contains('qa') || t.contains('quality'))
    return const JobTheme(
      Icons.bug_report,
      Color(0xFFB45309),
      Color(0xFFD97706),
    );
  if (c.contains('google'))
    return const JobTheme(Icons.search, Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (c.contains('microsoft'))
    return const JobTheme(Icons.window, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (c.contains('amazon') || c.contains('aws'))
    return const JobTheme(Icons.cloud, Color(0xFFD97706), Color(0xFFF59E0B));
  return const JobTheme(
    Icons.work_outline,
    Color(0xFF1D4ED8),
    Color(0xFF6366F1),
  );
}

List<String> resolveResponsibilities(String title) {
  final t = title.toLowerCase();
  if (t.contains('frontend') || t.contains('ui developer'))
    return [
      'Build responsive, accessible UI components using React / Flutter',
      'Collaborate with designers to translate Figma designs into code',
      'Optimise web performance and Core Web Vitals scores',
      'Write unit and integration tests for all UI components',
    ];
  if (t.contains('backend') || t.contains('server'))
    return [
      'Design and develop RESTful APIs and microservices',
      'Optimise database queries and manage schema migrations',
      'Implement authentication, authorisation and security layers',
      'Write technical documentation and ensure 99.9% uptime',
    ];
  if (t.contains('machine learning') ||
      t.contains(' ml') ||
      t.contains('data science'))
    return [
      'Build, train and evaluate machine learning models',
      'Prepare and clean large-scale datasets for training',
      'Deploy models to production via REST or gRPC endpoints',
      'Monitor model performance and retrain as needed',
    ];
  return [
    'Contribute to key product features end-to-end',
    'Collaborate with cross-functional teams in an agile setting',
    'Participate in code reviews, planning and retrospectives',
    'Document your work and support knowledge sharing',
  ];
}

// ═══════════════════════════════════════════
//  JOB ICON TILE
// ═══════════════════════════════════════════
class JobIconTile extends StatelessWidget {
  final String title, company;
  final double size;
  const JobIconTile({
    required this.title,
    required this.company,
    this.size = 48,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = resolveJobTheme(title, company);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.grad1, theme.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [
          BoxShadow(
            color: theme.grad1.withValues(alpha: 0.28),
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
//  JOBS SCREEN
// ═══════════════════════════════════════════
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  String filter = 'All';
  String search = '';
  final Set<int> saved = {};
  final Set<int> applied = {};
  bool loading = true;
  bool error = false;
  bool appliedLoading = false;
  late AnimationController headerAnim;
  final Map<int, AnimationController> cardAnims = {};
  List<Job> jobs = [];

  @override
  void initState() {
    super.initState();
    headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    fetchJobs();
    loadAppliedJobs();
  }

  Future<void> loadAppliedJobs() async {
    setState(() => appliedLoading = true);
    try {
      final appsData = await ApplicationsService.getApplications();
      if (appsData != null && appsData['data'] != null) {
        final data = appsData['data'] as List;
        final jobIds = ApplicationsService.extractJobIds(data);
        if (mounted) {
          setState(() {
            applied.clear();
            applied.addAll(jobIds);
          });
        }
      }
    } finally {
      if (mounted) setState(() => appliedLoading = false);
    }
  }

  Future<void> fetchJobs() async {
    await AuthService().loadTokens();
    final token = AuthService().accessToken;

    if (token == null) {
      throw Exception("Token is null. Please login again.");
    }

    if (jobs.isEmpty)
      setState(() {
        loading = true;
        error = false;
      });
    try {
      final res = await http.get(
        Uri.parse('https://studenthub-backend-woad.vercel.app/api/jobs'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List jobsData = data['data'] ?? [];
        final newJobs = jobsData.map((j) => Job.fromJson(j)).toList();
        for (final c in cardAnims.values) c.dispose();
        cardAnims.clear();
        for (int i = 0; i < newJobs.length; i++) {
          final c = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 460),
          );
          cardAnims[newJobs[i].id] = c;
          Future.delayed(Duration(milliseconds: 150 + i * 80), () {
            if (mounted) c.forward();
          });
        }
        if (mounted)
          setState(() {
            jobs = newJobs;
            loading = false;
            error = false;
          });
      } else {
        if (mounted)
          setState(() {
            loading = false;
            error = true;
          });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          loading = false;
          error = true;
        });
    }
  }

  List<Job> get filtered => jobs.where((job) {
    final q = search.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        job.title.toLowerCase().contains(q) ||
        job.company.toLowerCase().contains(q) ||
        job.tags.any((t) => t.toLowerCase().contains(q));
    final matchFilter =
        filter == 'All' ||
        job.type == filter ||
        job.location.contains(filter) ||
        job.exp == filter;
    return matchSearch && matchFilter;
  }).toList();

  @override
  void dispose() {
    headerAnim.dispose();
    for (final c in cardAnims.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    if (loading)
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: kPrimary),
              SizedBox(height: sw * 0.04),
              Text(
                'Finding your perfect jobs...',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  color: kMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );

    if (error)
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.18,
                height: sw * 0.18,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off,
                  color: const Color(0xFFDC2626),
                  size: sw * 0.08,
                ),
              ),
              SizedBox(height: sw * 0.04),
              Text(
                'Failed to load jobs',
                style: TextStyle(
                  fontSize: sw * 0.040,
                  fontWeight: FontWeight.w700,
                  color: kSlate,
                ),
              ),
              SizedBox(height: sw * 0.02),
              GestureDetector(
                onTap: () => setState(() {
                  loading = true;
                  error = false;
                  fetchJobs();
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.06,
                    vertical: sw * 0.030,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: sw * 0.040,
                      ),
                      SizedBox(width: sw * 0.015),
                      Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: sw * 0.035,
                        ),
                      ),
                    ],
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
          _buildHeader(sw),
          _buildSearchBar(sw),
          _buildFilterBar(sw),
          Expanded(child: _buildJobList(sw)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader(double sw) {
    return AnimatedBuilder(
      animation: headerAnim,
      builder: (_, child) => Opacity(opacity: headerAnim.value, child: child),
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
                          color: Colors.white.withValues(alpha: 0.10),
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
                            'Jobs',
                            style: TextStyle(
                              fontSize: sw * 0.050,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Find your perfect role',
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: kHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SavedJobsPage(
                            jobs: jobs,
                            savedIds: saved.toList(),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.030,
                          vertical: sw * 0.018,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bookmark,
                              color: kAccent,
                              size: sw * 0.038,
                            ),
                            SizedBox(width: sw * 0.012),
                            Text(
                              '${saved.length} Saved',
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.04),
                Wrap(
                  spacing: sw * 0.02,
                  runSpacing: sw * 0.02,
                  children: [
                    _statPill(Icons.work_outline, '${jobs.length}', 'Jobs', sw),
                    _statPill(Icons.send, '${applied.length}', 'Applied', sw),
                    _statPill(Icons.auto_awesome, '95%', 'Top Match', sw),
                    _statPill(Icons.location_city, '3', 'Cities', sw),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String num, String label, double sw) =>
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025,
          vertical: sw * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
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
            SizedBox(width: sw * 0.010),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.028,
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  // ─────────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────────
  Widget _buildSearchBar(double sw) => Container(
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
        hintText: 'Search jobs, companies, skills...',
        hintStyle: TextStyle(fontSize: sw * 0.033, color: kHint),
        prefixIcon: Icon(Icons.search, color: kMuted, size: sw * 0.055),
        filled: true,
        fillColor: kBgPage,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
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

  // ─────────────────────────────────────────────
  //  FILTER BAR
  // ─────────────────────────────────────────────
  Widget _buildFilterBar(double sw) => Container(
    color: kCardBg,
    padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.025, sw * 0.04, sw * 0.030),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: sw * 0.085,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFilters.length,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.02),
              itemBuilder: (_, i) {
                final f = kFilters[i];
                final selected = f == filter;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => filter = f);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.035),
                    decoration: BoxDecoration(
                      color: selected ? kPrimary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected ? kPrimary : kBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: sw * 0.030,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : kMuted,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.028,
            vertical: sw * 0.018,
          ),
          decoration: BoxDecoration(
            color: kSelectedBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: Text(
            '${filtered.length} jobs',
            style: TextStyle(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  //  JOB LIST
  // ─────────────────────────────────────────────
  Widget _buildJobList(double sw) {
    final list = filtered;
    if (list.isEmpty)
      return Center(
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
              child: Icon(Icons.search_off, color: kPrimary, size: sw * 0.08),
            ),
            SizedBox(height: sw * 0.04),
            Text(
              'No jobs found',
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w700,
                color: kSlate,
              ),
            ),
            SizedBox(height: sw * 0.015),
            GestureDetector(
              onTap: () => setState(() {
                filter = 'All';
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
      );

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: () async =>
          await Future.wait([fetchJobs(), loadAppliedJobs()]),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          sw * 0.04,
          sw * 0.035,
          sw * 0.04,
          sw * 0.06,
        ),
        itemCount: list.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, i) => JobCard(
          job: list[i],
          sw: sw,
          isSaved: saved.contains(list[i].id),
          isApplied: applied.contains(list[i].id),
          ctrl: cardAnims[list[i].id],
          onSave: () {
            HapticFeedback.selectionClick();
            setState(
              () => saved.contains(list[i].id)
                  ? saved.remove(list[i].id)
                  : saved.add(list[i].id),
            );
          },
          onApply: () => _showApplyModal(list[i]),
          onTap: () => _showJobDetailSheet(list[i]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  JOB DETAIL SHEET
  // ─────────────────────────────────────────────
  void _showJobDetailSheet(Job job) {
    final sw = MediaQuery.of(context).size.width;
    final theme = resolveJobTheme(job.title, job.company);
    final responsibilities = resolveResponsibilities(job.title);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [
              // Gradient header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.10),
                      theme.grad2.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  sw * 0.05,
                  0,
                  sw * 0.05,
                  sw * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.grad1, theme.grad2],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: sw * 0.045),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        JobIconTile(
                          title: job.title,
                          company: job.company,
                          size: sw * 0.145,
                        ),
                        SizedBox(width: sw * 0.035),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: sw * 0.048,
                                  fontWeight: FontWeight.w800,
                                  color: kInk,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              SizedBox(height: sw * 0.010),
                              Row(
                                children: [
                                  Icon(
                                    Icons.apartment_rounded,
                                    size: sw * 0.033,
                                    color: kMuted,
                                  ),
                                  SizedBox(width: sw * 0.010),
                                  Expanded(
                                    child: Text(
                                      job.company,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: sw * 0.033,
                                        color: kMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: sw * 0.015),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: sw * 0.033,
                                    color: kHint,
                                  ),
                                  SizedBox(width: sw * 0.008),
                                  Text(
                                    job.location,
                                    style: TextStyle(
                                      fontSize: sw * 0.030,
                                      color: kMuted,
                                    ),
                                  ),
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
                                      job.type,
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
                  ],
                ),
              ),
              // Sheet body
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.05,
                  sw * 0.045,
                  sw * 0.05,
                  sw * 0.08,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat row
                    Container(
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        children: [
                          _statCell(
                            Icons.payments_rounded,
                            job.salary,
                            'Salary',
                            sw,
                          ),
                          _vDivider(),
                          _statCell(
                            Icons.military_tech_rounded,
                            job.exp,
                            'Experience',
                            sw,
                          ),
                          _vDivider(),
                          _statCell(
                            Icons.history_rounded,
                            job.posted,
                            'Posted',
                            sw,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.05),
                    // Match score
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.035,
                        vertical: sw * 0.030,
                      ),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            size: sw * 0.040,
                            color: kWarning,
                          ),
                          SizedBox(width: sw * 0.020),
                          Text(
                            'AI Match Score',
                            style: TextStyle(
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w700,
                              color: kInk,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${job.match}%',
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: FontWeight.w800,
                              color: job.match > 75 ? kSuccess : kWarning,
                            ),
                          ),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: job.match / 100,
                                minHeight: 8,
                                backgroundColor: kBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  job.match > 75 ? kSuccess : kWarning,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.055),
                    _sectionHeader(
                      Icons.badge_rounded,
                      'Your Role at the Company',
                      theme,
                      sw,
                    ),
                    SizedBox(height: sw * 0.030),
                    _responsibilitiesBox(responsibilities, theme, sw),
                    if (job.desc.isNotEmpty) ...[
                      SizedBox(height: sw * 0.055),
                      _sectionHeader(
                        Icons.description_rounded,
                        'Job Description',
                        theme,
                        sw,
                      ),
                      SizedBox(height: sw * 0.030),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(sw * 0.040),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(
                          job.desc,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            color: kSlate,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                    // ✅ Skills Required from tags[]
                    if (job.tags.isNotEmpty) ...[
                      SizedBox(height: sw * 0.055),
                      _sectionHeader(
                        Icons.code_rounded,
                        'Skills Required',
                        theme,
                        sw,
                      ),
                      SizedBox(height: sw * 0.030),
                      Wrap(
                        spacing: sw * 0.020,
                        runSpacing: sw * 0.020,
                        children: job.tags
                            .map(
                              (tag) => Container(
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
                                  tag,
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
                    SizedBox(height: sw * 0.055),
                    applied.contains(job.id)
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: sw * 0.038),
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
                                  Icons.verified_rounded,
                                  color: kSuccess,
                                  size: sw * 0.050,
                                ),
                                SizedBox(width: sw * 0.020),
                                Text(
                                  'Application Already Submitted',
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
                            onTap: () {
                              Navigator.pop(context);
                              _showApplyModal(job);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: sw * 0.038,
                              ),
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
                                  Icon(
                                    Icons.rocket_launch_rounded,
                                    color: Colors.white,
                                    size: sw * 0.045,
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  REUSABLE SECTION HELPERS
  // ─────────────────────────────────────────────
  Widget _sectionHeader(
    IconData icon,
    String title,
    JobTheme theme,
    double sw,
  ) {
    return Row(
      children: [
        Container(
          width: sw * 0.085,
          height: sw * 0.085,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.grad1, theme.grad2]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: sw * 0.045),
        ),
        SizedBox(width: sw * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w800,
            color: kInk,
          ),
        ),
      ],
    );
  }

  Widget _responsibilitiesBox(List<String> items, JobTheme theme, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.040),
      decoration: BoxDecoration(
        color: kBgPage,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: EdgeInsets.only(
                  bottom: e.key < items.length - 1 ? sw * 0.030 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: sw * 0.005),
                      width: sw * 0.055,
                      height: sw * 0.055,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.grad1.withValues(alpha: 0.15),
                            theme.grad2.withValues(alpha: 0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            fontSize: sw * 0.025,
                            fontWeight: FontWeight.w800,
                            color: theme.grad1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: sw * 0.033,
                          color: kSlate,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _statCell(IconData icon, String value, String label, double sw) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
        child: Column(
          children: [
            Icon(icon, size: sw * 0.045, color: kPrimary),
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
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 50, color: kBorder);

  // ─────────────────────────────────────────────
  //  APPLY MODAL
  // ─────────────────────────────────────────────
  void _showApplyModal(Job job) {
    final sw = MediaQuery.of(context).size.width;
    final theme = resolveJobTheme(job.title, job.company);
    final responsibilities = resolveResponsibilities(job.title);
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, sw * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                children: [
                  JobIconTile(
                    title: job.title,
                    company: job.company,
                    size: sw * 0.12,
                  ),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply for ${job.title}',
                          style: TextStyle(
                            fontSize: sw * 0.040,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        Text(
                          job.company,
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
              SizedBox(height: sw * 0.040),
              Container(
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    _applyDetail(Icons.payments, job.salary, 'Salary', sw),
                    SizedBox(width: sw * 0.030),
                    Container(width: 1, height: sw * 0.09, color: kBorder),
                    SizedBox(width: sw * 0.030),
                    _applyDetail(
                      Icons.location_on,
                      job.location,
                      'Location',
                      sw,
                    ),
                    SizedBox(width: sw * 0.030),
                    Container(width: 1, height: sw * 0.09, color: kBorder),
                    SizedBox(width: sw * 0.030),
                    _applyDetail(Icons.work_outline, job.type, 'Type', sw),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.045),
              _sectionHeader(Icons.badge_rounded, 'Your Role', theme, sw),
              SizedBox(height: sw * 0.025),
              _responsibilitiesBox(responsibilities, theme, sw),
              if (job.desc.isNotEmpty) ...[
                SizedBox(height: sw * 0.035),
                _sectionHeader(
                  Icons.description_rounded,
                  'Job Description',
                  theme,
                  sw,
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
                    job.desc,
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      color: kSlate,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
              SizedBox(height: sw * 0.05),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  final result = await ApplicationsService.apply(jobId: job.id);
                  if (result == 'Applied successfully') {
                    setState(() => applied.add(job.id));
                    _showAppliedDialog(job);
                    loadAppliedJobs();
                  } else {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: sw * 0.038),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFF4F46E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: sw * 0.040),
                        SizedBox(width: sw * 0.020),
                        Text(
                          'Submit Application',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _applyDetail(IconData icon, String value, String label, double sw) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: sw * 0.040, color: kPrimary),
          SizedBox(height: sw * 0.010),
          Text(
            value,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
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
  }

  // ─────────────────────────────────────────────
  //  APPLIED DIALOG
  // ─────────────────────────────────────────────
  void _showAppliedDialog(Job job) {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.15),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5), kAccent],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    SizedBox(height: sw * 0.035),
                    Text(
                      'Application Sent! 🎉',
                      style: TextStyle(
                        fontSize: sw * 0.045,
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
                        fontSize: sw * 0.033,
                        color: kMuted,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sw * 0.05),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.040),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              JobIconTile(
                                title: job.title,
                                company: job.company,
                                size: sw * 0.105,
                              ),
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
                                        color: kInk,
                                      ),
                                    ),
                                    Text(
                                      job.company,
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
                          SizedBox(height: sw * 0.035),
                          Container(height: 1, color: kBorder),
                          SizedBox(height: sw * 0.035),
                          _dialogDetailRow(
                            Icons.payments,
                            'Salary',
                            job.salary,
                            sw,
                          ),
                          SizedBox(height: sw * 0.025),
                          _dialogDetailRow(
                            Icons.location_on,
                            'Location',
                            job.location,
                            sw,
                          ),
                          SizedBox(height: sw * 0.025),
                          _dialogDetailRow(
                            Icons.work_outline,
                            'Job Type',
                            job.type,
                            sw,
                          ),
                          SizedBox(height: sw * 0.025),
                          _dialogDetailRow(
                            Icons.school,
                            'Experience',
                            job.exp,
                            sw,
                          ),
                          SizedBox(height: sw * 0.025),
                          _dialogDetailRow(
                            Icons.access_time,
                            'Posted',
                            job.posted,
                            sw,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.05),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimary, Color(0xFF4F46E5)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'OK, Got it!',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogDetailRow(
    IconData icon,
    String label,
    String value,
    double sw,
  ) {
    return Row(
      children: [
        Container(
          width: sw * 0.075,
          height: sw * 0.075,
          decoration: BoxDecoration(
            color: kSelectedBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: sw * 0.038, color: kPrimary),
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
    );
  }
}

// ═══════════════════════════════════════════
//  JOB CARD
// ═══════════════════════════════════════════
class JobCard extends StatelessWidget {
  final Job job;
  final double sw;
  final bool isSaved, isApplied;
  final AnimationController? ctrl;
  final VoidCallback onSave, onApply, onTap;

  const JobCard({
    required this.job,
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
  Widget build(BuildContext context) {
    final card = _buildCard();
    if (ctrl == null) return card;
    return AnimatedBuilder(
      animation: ctrl!,
      builder: (_, child) => Opacity(
        opacity: ctrl!.value,
        child: Transform.translate(
          offset: Offset(0, 50 * (1 - ctrl!.value)),
          child: child,
        ),
      ),
      child: card,
    );
  }

  Widget _buildCard() => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: sw * 0.040),
      decoration: BoxDecoration(
        gradient: isApplied
            ? const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
         )
            : null,
        color: isApplied ? null : kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApplied ? kPrimary.withValues(alpha: 0.40) : kBorder,
          width: isApplied ? 2 : 1.5,
        ),
        boxShadow: isApplied
            ? [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isApplied)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, Color(0xFF4F46E5), kAccent],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(sw * 0.040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    JobIconTile(
                      title: job.title,
                      company: job.company,
                      size: sw * 0.12,
                    ),
                    SizedBox(width: sw * 0.030),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: FontWeight.w800,
                              color: isApplied ? kPrimary : kInk,
                            ),
                          ),
                          SizedBox(height: sw * 0.005),
                          Text(
                            job.company,
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onSave,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: sw * 0.085,
                        height: sw * 0.085,
                        decoration: BoxDecoration(
                          color: isSaved
                              ? kAccent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? kAccent : kMuted,
                          size: sw * 0.050,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.025),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: sw * 0.028,
                      color: kPrimary.withValues(alpha: 0.60),
                    ),
                    SizedBox(width: sw * 0.010),
                    Text(
                      'Tap to see your role & job details',
                      style: TextStyle(
                        fontSize: sw * 0.025,
                        fontWeight: FontWeight.w600,
                        color: kPrimary.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.025),
                // Chips
                Wrap(
                  spacing: sw * 0.018,
                  runSpacing: sw * 0.018,
                  children: [
                    _chip(Icons.work_outline, job.type, sw),
                    _chip(Icons.location_on, job.location, sw),
                    _chip(Icons.school, job.exp, sw),
                    _chip(Icons.access_time, job.posted, sw),
                  ],
                ),
                SizedBox(height: sw * 0.030),
                // Salary + applied badge
                Row(
                  children: [
                    Icon(Icons.currency_rupee, size: sw * 0.035, color: kInk),
                    SizedBox(width: sw * 0.008),
                    Text(
                      job.salary,
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    const Spacer(),
                    if (isApplied)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.025,
                          vertical: sw * 0.010,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kSuccess, Color(0xFF15803D)],
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
                            SizedBox(width: sw * 0.010),
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
                      ),
                  ],
                ),
                SizedBox(height: sw * 0.030),
                // Match bar
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.025,
                        vertical: sw * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: job.match > 75
                            ? kSuccess.withValues(alpha: 0.12)
                            : kWarning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: sw * 0.030,
                            color: kWarning,
                          ),
                          SizedBox(width: sw * 0.010),
                          Text(
                            '${job.match}% Match',
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w700,
                              color: job.match > 75 ? kSuccess : kWarning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: job.match / 100,
                          minHeight: 6,
                          backgroundColor: kBgPage,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            job.match > 75 ? kSuccess : kWarning,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.030),
                // ✅ Skills tags displayed on card
                if (job.tags.isNotEmpty)
                  Wrap(
                    spacing: sw * 0.015,
                    runSpacing: sw * 0.015,
                    children: job.tags
                        .take(4) // show max 4 tags on card
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.022,
                              vertical: sw * 0.010,
                            ),
                            decoration: BoxDecoration(
                              color: kSelectedBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kBorder),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: sw * 0.025,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                // Apply button
                if (!isApplied) ...[
                  SizedBox(height: sw * 0.030),
                  GestureDetector(
                    onTap: onApply,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: sw * 0.030),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary, Color(0xFF4F46E5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              color: Colors.white,
                              size: sw * 0.040,
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              'Apply Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: sw * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _chip(IconData icon, String label, double sw) => Container(
    padding: EdgeInsets.symmetric(horizontal: sw * 0.023, vertical: sw * 0.012),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: sw * 0.028, color: kMuted),
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
}

// ═══════════════════════════════════════════
//  SAVED JOBS PAGE
// ═══════════════════════════════════════════
class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;
  const SavedJobsPage({required this.jobs, required this.savedIds, super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final savedJobs = jobs.where((j) => savedIds.contains(j.id)).toList();
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kInk,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Saved Jobs',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        centerTitle: false,
      ),
      body: savedJobs.isEmpty
          ? Center(
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
                      Icons.bookmark_border,
                      color: kPrimary,
                      size: sw * 0.08,
                    ),
                  ),
                  SizedBox(height: sw * 0.040),
                  Text(
                    'No saved jobs yet',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w700,
                      color: kSlate,
                    ),
                  ),
                  SizedBox(height: sw * 0.015),
                  Text(
                    'Tap the bookmark icon on any job to save it',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: sw * 0.033, color: kMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(sw * 0.040),
              itemCount: savedJobs.length,
              itemBuilder: (_, i) {
                final j = savedJobs[i];
                return Container(
                  margin: EdgeInsets.only(bottom: sw * 0.030),
                  padding: EdgeInsets.all(sw * 0.040),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kBorder, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      JobIconTile(
                        title: j.title,
                        company: j.company,
                        size: sw * 0.11,
                      ),
                      SizedBox(width: sw * 0.030),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j.title,
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w800,
                                color: kInk,
                              ),
                            ),
                            SizedBox(height: sw * 0.005),
                            Text(
                              j.company,
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                color: kMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            j.salary,
                            style: TextStyle(
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w800,
                              color: kInk,
                            ),
                          ),
                          SizedBox(height: sw * 0.010),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.020,
                              vertical: sw * 0.008,
                            ),
                            decoration: BoxDecoration(
                              color: kSelectedBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              j.type,
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
                );
              },
            ),
    );
  }
}
