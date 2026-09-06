import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../api_services/applications.dart';
import '../../api_services/authservice.dart';
import '../../widgets/social_post_card.dart';

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

// ═══════════════════════════════════════════
//  JOB MODEL
// ═══════════════════════════════════════════
class Job {
  final int id;
  final String title, company, location, salary, type, logo, exp, posted, desc;
  final int match;
  final List<String> tags;
  final int? salaryMin, salaryMax;
  final String? imageUrl;
  final String? companyLogo;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;

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
    this.salaryMin,
    this.salaryMax,
    this.imageUrl,
    this.companyLogo,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
    id: json['job_id'] ?? 0,
    title: json['title'] ?? 'No title',
    company: json['company_name'] ?? (json['company'] is String ? json['company'] : 'Company ${json['company_id'] ?? 0}'),
    location: json['location'] ?? 'Remote',
    salary: json['salary_min'] != null && json['salary_max'] != null
        ? '₹${json['salary_min']} - ₹${json['salary_max']}'
        : (json['salary_min'] != null ? '₹${json['salary_min']}+' : 'Negotiable'),
    type: json['job_type'] ?? 'Full Time',
    match: 80,
    logo: json['company_logo'] ?? '',
    tags: (json['skills'] as List<dynamic>? ?? [])
        .map<String>((t) => t.toString())
        .toList(),
    exp: json['experience_level'] ?? 'Fresher',
    posted: 'Recently',
    desc: json['description'] ?? '',
    salaryMin: json['salary_min'] != null
        ? int.tryParse(json['salary_min'].toString())
        : null,
    salaryMax: json['salary_max'] != null
        ? int.tryParse(json['salary_max'].toString())
        : null,
    imageUrl: json['image_url'],
    companyLogo: json['company_logo'],
    likesCount: json['likes_count'] is int ? json['likes_count'] : int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
    commentsCount: json['comments_count'] is int ? json['comments_count'] : int.tryParse(json['comments_count']?.toString() ?? '0') ?? 0,
    sharesCount: json['shares_count'] is int ? json['shares_count'] : int.tryParse(json['shares_count']?.toString() ?? '0') ?? 0,
    isLiked: json['is_liked'] == true,
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
    return const JobTheme(
        Icons.code, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('frontend') ||
      t.contains('front-end') ||
      t.contains('ui developer'))
    return const JobTheme(
        Icons.web, Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') ||
      t.contains('back-end') ||
      t.contains('server'))
    return const JobTheme(
        Icons.dns, Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const JobTheme(
        Icons.layers, Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('mobile') ||
      t.contains('android') ||
      t.contains('flutter'))
    return const JobTheme(
        Icons.phone_android, Color(0xFF0284C7), Color(0xFF38BDF8));
  if (t.contains('ios') || t.contains('swift'))
    return const JobTheme(
        Icons.phone_iphone, Color(0xFF374151), Color(0xFF6B7280));
  if (t.contains('machine learning') || t.contains(' ml'))
    return const JobTheme(
        Icons.psychology, Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('data scientist') || t.contains('data science'))
    return const JobTheme(
        Icons.analytics, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('data analyst') || t.contains('data engineer'))
    return const JobTheme(
        Icons.bar_chart, Color(0xFF0369A1), Color(0xFF0284C7));
  if (t.contains('artificial intelligence') ||
      t.contains(' ai') ||
      t.contains('ai '))
    return const JobTheme(
        Icons.smart_toy, Color(0xFF4F46E5), Color(0xFF6366F1));
  if (t.contains('cloud') ||
      t.contains('aws') ||
      t.contains('azure') ||
      t.contains('gcp'))
    return const JobTheme(
        Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('devops') ||
      t.contains('sre') ||
      t.contains('platform engineer'))
    return const JobTheme(
        Icons.sync_alt, Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('security') ||
      t.contains('cyber') ||
      t.contains('ethical'))
    return const JobTheme(
        Icons.shield, Color(0xFFB91C1C), Color(0xFFDC2626));
  if (t.contains('ui') ||
      t.contains('ux') ||
      t.contains('design') ||
      t.contains('figma'))
    return const JobTheme(
        Icons.brush, Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('product manager') ||
      t.contains('product management'))
    return const JobTheme(
        Icons.inventory_2, Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('marketing') || t.contains('growth'))
    return const JobTheme(
        Icons.trending_up, Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('testing') ||
      t.contains('qa') ||
      t.contains('quality'))
    return const JobTheme(
        Icons.bug_report, Color(0xFFB45309), Color(0xFFD97706));
  if (c.contains('google'))
    return const JobTheme(
        Icons.search, Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (c.contains('microsoft'))
    return const JobTheme(
        Icons.window, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (c.contains('amazon') || c.contains('aws'))
    return const JobTheme(
        Icons.cloud, Color(0xFFD97706), Color(0xFFF59E0B));
  return const JobTheme(
      Icons.work_outline, Color(0xFF1D4ED8), Color(0xFF6366F1));
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
//  FILTER STATE
// ═══════════════════════════════════════════
class JobFilterState {
  String? salaryRange;
  String? location;
  String? company;
  String? role;
  String? jobType;
  String? experience;

  JobFilterState({
    this.salaryRange,
    this.location,
    this.company,
    this.role,
    this.jobType,
    this.experience,
  });

  bool get hasAny =>
      salaryRange != null ||
          location != null ||
          company != null ||
          role != null ||
          jobType != null ||
          experience != null;

  int get count =>
      [salaryRange, location, company, role, jobType, experience]
          .where((e) => e != null)
          .length;

  JobFilterState copyWith({
    Object? salaryRange = _sentinel,
    Object? location = _sentinel,
    Object? company = _sentinel,
    Object? role = _sentinel,
    Object? jobType = _sentinel,
    Object? experience = _sentinel,
  }) {
    return JobFilterState(
      salaryRange: salaryRange == _sentinel
          ? this.salaryRange
          : salaryRange as String?,
      location: location == _sentinel
          ? this.location
          : location as String?,
      company: company == _sentinel
          ? this.company
          : company as String?,
      role: role == _sentinel ? this.role : role as String?,
      jobType: jobType == _sentinel
          ? this.jobType
          : jobType as String?,
      experience: experience == _sentinel
          ? this.experience
          : experience as String?,
    );
  }

  static const Object _sentinel = Object();
}

// ═══════════════════════════════════════════
//  JOB ICON TILE
// ═══════════════════════════════════════════
class JobIconTile extends StatelessWidget {
  final String title, company;
  final double size;
  const JobIconTile(
      {required this.title,
        required this.company,
        this.size = 48,
        super.key});

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
              offset: const Offset(0, 3)),
        ],
      ),
      child:
      Icon(theme.icon, color: Colors.white, size: size * 0.46),
    );
  }
}

// ═══════════════════════════════════════════
//  JOBS SCREEN
// ═══════════════════════════════════════════
class JobsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const JobsScreen({super.key, this.onBack});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with TickerProviderStateMixin {
  String search = '';
  final Set<int> saved = {};
  final Set<int> applied = {};
  bool loading = true;
  bool error = false;
  bool appliedLoading = false;
  late AnimationController headerAnim;
  final Map<int, AnimationController> cardAnims = {};
  List<Job> jobs = [];
  JobFilterState _filters = JobFilterState();
  final TextEditingController _searchCtrl = TextEditingController();

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void initState() {
    super.initState();
    headerAnim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600))
      ..forward();
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
    if (jobs.isEmpty) setState(() { loading = true; error = false; });
    try {
      final res = await AuthService().get('/bulk?type=jobs');
      if (res.statusCode == 200) {
        final data = res.data;
        final List jobsData = data['data'] ?? [];
        final newJobs = jobsData.map((j) => Job.fromJson(j)).toList();
        for (final c in cardAnims.values) c.dispose();
        cardAnims.clear();
        for (int i = 0; i < newJobs.length; i++) {
          final c = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 460));
          cardAnims[newJobs[i].id] = c;
          Future.delayed(Duration(milliseconds: 150 + i * 80),
                  () { if (mounted) c.forward(); });
        }
        if (mounted)
          setState(() {
            jobs = newJobs;
            loading = false;
            error = false;
          });
      } else {
        if (mounted) setState(() { loading = false; error = true; });
      }
    } catch (_) {
      if (mounted) setState(() { loading = false; error = true; });
    }
  }

  List<String> get _allLocations => jobs
      .map((j) => j.location)
      .toSet()
      .where((l) => l.isNotEmpty)
      .toList()
    ..sort();
  List<String> get _allCompanies => jobs
      .map((j) => j.company)
      .toSet()
      .where((c) => c.isNotEmpty)
      .toList()
    ..sort();
  List<String> get _allRoles => jobs
      .map((j) => j.title)
      .toSet()
      .where((r) => r.isNotEmpty)
      .toList()
    ..sort();
  List<String> get _allTypes => jobs
      .map((j) => j.type)
      .toSet()
      .where((t) => t.isNotEmpty)
      .toList()
    ..sort();
  List<String> get _allExp => jobs
      .map((j) => j.exp)
      .toSet()
      .where((e) => e.isNotEmpty)
      .toList()
    ..sort();
  static const List<String> _salaryRanges = [
    'Any',
    '0–3 LPA',
    '3–6 LPA',
    '6–10 LPA',
    '10–20 LPA',
    '20+ LPA'
  ];

  List<Job> get filtered => jobs.where((job) {
    final q = search.toLowerCase();
    final matchSearch = q.isEmpty ||
        job.title.toLowerCase().contains(q) ||
        job.company.toLowerCase().contains(q) ||
        job.location.toLowerCase().contains(q) ||
        job.type.toLowerCase().contains(q) ||
        job.exp.toLowerCase().contains(q) ||
        job.tags.any((t) => t.toLowerCase().contains(q));

    bool matchSalary = true;
    if (_filters.salaryRange != null &&
        _filters.salaryRange != 'Any') {
      final sMin = job.salaryMin ?? 0;
      final range = _filters.salaryRange!;
      if (range == '0–3 LPA')
        matchSalary = sMin < 300000;
      else if (range == '3–6 LPA')
        matchSalary = sMin >= 300000 && sMin < 600000;
      else if (range == '6–10 LPA')
        matchSalary = sMin >= 600000 && sMin < 1000000;
      else if (range == '10–20 LPA')
        matchSalary = sMin >= 1000000 && sMin < 2000000;
      else if (range == '20+ LPA')
        matchSalary = sMin >= 2000000;
    }

    final matchLocation =
        _filters.location == null ||
            job.location == _filters.location;
    final matchCompany =
        _filters.company == null ||
            job.company == _filters.company;
    final matchRole =
        _filters.role == null || job.title == _filters.role;
    final matchType =
        _filters.jobType == null ||
            job.type == _filters.jobType;
    final matchExp =
        _filters.experience == null ||
            job.exp == _filters.experience;

    return matchSearch &&
        matchSalary &&
        matchLocation &&
        matchCompany &&
        matchRole &&
        matchType &&
        matchExp;
  }).toList();

  @override
  void dispose() {
    headerAnim.dispose();
    _searchCtrl.dispose();
    for (final c in cardAnims.values) c.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    HapticFeedback.mediumImpact();
    JobFilterState tempFilters = JobFilterState(
      salaryRange: _filters.salaryRange,
      location: _filters.location,
      company: _filters.company,
      role: _filters.role,
      jobType: _filters.jobType,
      experience: _filters.experience,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          final sw = MediaQuery.of(context).size.width;
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(sw * 0.05,
                        sw * 0.030, sw * 0.05, 0),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: sw * 0.10,
                            height: 4,
                            decoration: BoxDecoration(
                                color: kBorder,
                                borderRadius:
                                BorderRadius.circular(4)),
                          ),
                        ),
                        SizedBox(height: sw * 0.030),
                        Row(
                          children: [
                            Container(
                              width: sw * 0.10,
                              height: sw * 0.10,
                              decoration: BoxDecoration(
                                gradient:
                                const LinearGradient(colors: [
                                  kPrimary,
                                  Color(0xFF4F46E5)
                                ]),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.tune_rounded,
                                  color: Colors.white,
                                  size: sw * 0.050),
                            ),
                            SizedBox(width: sw * 0.030),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('Filter Jobs',
                                      style: TextStyle(
                                          fontSize: sw * 0.042,
                                          fontWeight:
                                          FontWeight.w800,
                                          color: kInk)),
                                  Text(
                                      'Narrow down to your perfect role',
                                      style: TextStyle(
                                          fontSize: sw * 0.028,
                                          color: kMuted)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pop(context),
                              child: Container(
                                width: sw * 0.09,
                                height: sw * 0.09,
                                decoration: BoxDecoration(
                                  color: kBgPage,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  border: Border.all(
                                      color: kBorder, width: 1.5),
                                ),
                                child: Icon(Icons.close_rounded,
                                    color: kMuted,
                                    size: sw * 0.040),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sw * 0.025),
                        Container(height: 1, color: kBorder),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: EdgeInsets.fromLTRB(sw * 0.05,
                          sw * 0.030, sw * 0.05, sw * 0.04),
                      children: [
                        _filterSection(
                          icon: Icons.payments_rounded,
                          title: 'Salary Range',
                          color: kSuccess,
                          sw: sw,
                          options: _salaryRanges,
                          selected: tempFilters.salaryRange,
                          onSelect: (v) => setModal(() =>
                          tempFilters = tempFilters.copyWith(
                              salaryRange: v ==
                                  tempFilters.salaryRange
                                  ? null
                                  : v)),
                        ),
                        SizedBox(height: sw * 0.04),
                        _filterSection(
                          icon: Icons.work_outline_rounded,
                          title: 'Job Type',
                          color: kPrimary,
                          sw: sw,
                          options: _allTypes,
                          selected: tempFilters.jobType,
                          onSelect: (v) => setModal(() =>
                          tempFilters = tempFilters.copyWith(
                              jobType:
                              v == tempFilters.jobType
                                  ? null
                                  : v)),
                        ),
                        SizedBox(height: sw * 0.04),
                        _filterSection(
                          icon: Icons.location_on_rounded,
                          title: 'City / Location',
                          color: const Color(0xFF0EA5E9),
                          sw: sw,
                          options: _allLocations,
                          selected: tempFilters.location,
                          onSelect: (v) => setModal(() =>
                          tempFilters = tempFilters.copyWith(
                              location:
                              v == tempFilters.location
                                  ? null
                                  : v)),
                        ),
                        SizedBox(height: sw * 0.04),
                        _filterSection(
                          icon: Icons.apartment_rounded,
                          title: 'Company',
                          color: const Color(0xFF7C3AED),
                          sw: sw,
                          options: _allCompanies,
                          selected: tempFilters.company,
                          onSelect: (v) => setModal(() =>
                          tempFilters = tempFilters.copyWith(
                              company:
                              v == tempFilters.company
                                  ? null
                                  : v)),
                        ),
                        SizedBox(height: sw * 0.04),
                        _filterSection(
                          icon: Icons.badge_rounded,
                          title: 'Role / Title',
                          color: const Color(0xFFEC4899),
                          sw: sw,
                          options: _allRoles,
                          selected: tempFilters.role,
                          onSelect: (v) => setModal(() =>
                          tempFilters = tempFilters.copyWith(
                              role: v == tempFilters.role
                                  ? null
                                  : v)),
                        ),
                        SizedBox(height: sw * 0.04),
                        _filterSection(
                          icon: Icons.military_tech_rounded,
                          title: 'Experience Level',
                          color: kWarning,
                          sw: sw,
                          options: _allExp,
                          selected: tempFilters.experience,
                          onSelect: (v) => setModal(() =>
                          tempFilters = tempFilters.copyWith(
                              experience:
                              v == tempFilters.experience
                                  ? null
                                  : v)),
                        ),
                        SizedBox(height: sw * 0.04),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(sw * 0.05, 0,
                        sw * 0.05, sw * 0.06),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _filters = tempFilters);
                        Navigator.pop(context);
                        HapticFeedback.selectionClick();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: sw * 0.038),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [
                                kPrimary,
                                Color(0xFF4F46E5)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                          borderRadius:
                          BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: kPrimary.withValues(
                                    alpha: 0.30),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white,
                                  size: sw * 0.045),
                              SizedBox(width: sw * 0.020),
                              Text('Apply Filters',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: sw * 0.038)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterSection({
    required IconData icon,
    required String title,
    required Color color,
    required double sw,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: sw * 0.075,
              height: sw * 0.075,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon,
                  size: sw * 0.038, color: color),
            ),
            SizedBox(width: sw * 0.025),
            Text(title,
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kInk)),
            if (selected != null) ...[
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.020,
                    vertical: sw * 0.008),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                    BorderRadius.circular(20)),
                child: Text('1 selected',
                    style: TextStyle(
                        fontSize: sw * 0.025,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ],
        ),
        SizedBox(height: sw * 0.020),
        Wrap(
          spacing: sw * 0.020,
          runSpacing: sw * 0.020,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.030,
                    vertical: sw * 0.018),
                decoration: BoxDecoration(
                  color: isSelected ? color : kBgPage,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: isSelected ? color : kBorder,
                      width: isSelected ? 2 : 1.5),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                        color:
                        color.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                      : null,
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: sw * 0.030,
                    fontWeight: FontWeight.w700,
                    color:
                    isSelected ? Colors.white : kSlate,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
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
              Text('Finding your perfect jobs...',
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      color: kMuted,
                      fontWeight: FontWeight.w600)),
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
                    shape: BoxShape.circle),
                child: Icon(Icons.wifi_off,
                    color: const Color(0xFFDC2626),
                    size: sw * 0.08),
              ),
              SizedBox(height: sw * 0.04),
              Text('Failed to load jobs',
                  style: TextStyle(
                      fontSize: sw * 0.040,
                      fontWeight: FontWeight.w700,
                      color: kSlate)),
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
                      vertical: sw * 0.030),
                  decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius:
                      BorderRadius.circular(20)),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh,
                            color: Colors.white,
                            size: sw * 0.040),
                        SizedBox(width: sw * 0.015),
                        Text('Retry',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: sw * 0.035)),
                      ]),
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
          _buildSearchAndFilter(sw),
          _buildActiveFiltersBar(sw),
          Expanded(child: _buildJobList(sw)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER — back button wrapped in context.canPop()
  // ─────────────────────────────────────────────
  Widget _buildHeader(double sw) {
    return AnimatedBuilder(
      animation: headerAnim,
      builder: (_, child) =>
          Opacity(opacity: headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Row(
              children: [
                // ✅ Back button only shown when there is a route to pop to
                if (context.canPop() || widget.onBack != null) ...[
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Jobs',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3)),
                        Text('Find your perfect role',
                            style: TextStyle(
                                fontSize: 9.5,
                                color: kHint)),
                      ]),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SavedJobsPage(
                              jobs: jobs,
                              savedIds: saved.toList()))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark,
                            color: kAccent,
                            size: 12),
                        const SizedBox(width: 3),
                        Text('${saved.length} Saved',
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(double sw) {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => search = v),
                style: TextStyle(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w600,
                    color: kInk),
                decoration: InputDecoration(
                  hintText: 'Search jobs, cities, skills...',
                  hintStyle: TextStyle(
                      fontSize: sw * 0.031, color: kHint),
                  prefixIcon: Icon(Icons.search,
                      color: kMuted, size: sw * 0.048),
                  suffixIcon: search.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => search = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: kMuted, size: sw * 0.042),
                  )
                      : null,
                  filled: true,
                  fillColor: kBgPage,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: 0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: kBorder, width: 1.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: kBorder, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: kPrimary, width: 2)),
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.025),
          GestureDetector(
            onTap: _showFilterModal,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sw * 0.115,
              height: sw * 0.115,
              decoration: BoxDecoration(
                gradient: _filters.hasAny
                    ? const LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                    : null,
                color: _filters.hasAny ? null : kBgPage,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _filters.hasAny ? kPrimary : kBorder,
                    width: _filters.hasAny ? 2 : 1.5),
                boxShadow: _filters.hasAny
                    ? [
                  BoxShadow(
                      color:
                      kPrimary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                      child: Icon(Icons.tune_rounded,
                          color: _filters.hasAny
                              ? Colors.white
                              : kMuted,
                          size: sw * 0.048)),
                  if (_filters.count > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: sw * 0.048,
                        height: sw * 0.048,
                        decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text('${_filters.count}',
                              style: TextStyle(
                                  fontSize: sw * 0.022,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersBar(double sw) {
    final chips = <_ActiveChip>[];
    if (_filters.salaryRange != null)
      chips.add(_ActiveChip('💰 ${_filters.salaryRange!}',
              () => setState(() => _filters = _filters.copyWith(salaryRange: null))));
    if (_filters.location != null)
      chips.add(_ActiveChip('📍 ${_filters.location!}',
              () => setState(() => _filters = _filters.copyWith(location: null))));
    if (_filters.company != null)
      chips.add(_ActiveChip('🏢 ${_filters.company!}',
              () => setState(() => _filters = _filters.copyWith(company: null))));
    if (_filters.role != null)
      chips.add(_ActiveChip('👤 ${_filters.role!}',
              () => setState(() => _filters = _filters.copyWith(role: null))));
    if (_filters.jobType != null)
      chips.add(_ActiveChip('💼 ${_filters.jobType!}',
              () => setState(() => _filters = _filters.copyWith(jobType: null))));
    if (_filters.experience != null)
      chips.add(_ActiveChip('🎯 ${_filters.experience!}',
              () => setState(() => _filters = _filters.copyWith(experience: null))));

    return Container(
      color: kCardBg,
      padding: EdgeInsets.only(bottom: sw * 0.020),
      child: Column(
        children: [
          if (chips.isNotEmpty)
            SizedBox(
              height: sw * 0.085,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04),
                children: [
                  ...chips.map((c) => Padding(
                    padding:
                    EdgeInsets.only(right: sw * 0.020),
                    child: GestureDetector(
                      onTap: c.onRemove,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.030,
                            vertical: sw * 0.015),
                        decoration: BoxDecoration(
                          color: kSelectedBg,
                          borderRadius:
                          BorderRadius.circular(30),
                          border: Border.all(
                              color: kPrimary.withValues(
                                  alpha: 0.40),
                              width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.label,
                                style: TextStyle(
                                    fontSize: sw * 0.028,
                                    fontWeight:
                                    FontWeight.w700,
                                    color: kPrimary)),
                            SizedBox(width: sw * 0.015),
                            Icon(Icons.close_rounded,
                                size: sw * 0.030,
                                color: kPrimary),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: sw * 0.04),
            child: Row(
              children: [
                Text(
                  '${filtered.length} of ${jobs.length} jobs',
                  style: TextStyle(
                      fontSize: sw * 0.030,
                      fontWeight: FontWeight.w700,
                      color: kMuted),
                ),
                const Spacer(),
                if (_filters.hasAny || search.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filters = JobFilterState();
                        search = '';
                        _searchCtrl.clear();
                      });
                    },
                    child: Text('Clear all',
                        style: TextStyle(
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w700,
                            color:
                            const Color(0xFFDC2626))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(double sw) {
    final list = filtered;
    if (list.isEmpty)
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: sw * 0.18,
            height: sw * 0.18,
            decoration: const BoxDecoration(
                color: kSelectedBg, shape: BoxShape.circle),
            child: Icon(Icons.search_off,
                color: kPrimary, size: sw * 0.08),
          ),
          SizedBox(height: sw * 0.04),
          Text('No jobs found',
              style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w700,
                  color: kSlate)),
          SizedBox(height: sw * 0.015),
          GestureDetector(
            onTap: () => setState(() {
              _filters = JobFilterState();
              search = '';
              _searchCtrl.clear();
            }),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05, vertical: sw * 0.025),
              decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Clear filters',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: sw * 0.033)),
            ),
          ),
        ]),
      );

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: () async =>
      await Future.wait([fetchJobs(), loadAppliedJobs()]),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
            sw * 0.04, sw * 0.035, sw * 0.04, sw * 0.06),
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
            setState(() => saved.contains(list[i].id)
                ? saved.remove(list[i].id)
                : saved.add(list[i].id));
          },
          onApply: () => _showApplyModal(list[i]),
          onTap: () => _showJobDetailSheet(list[i]),
        ),
      ),
    );
  }

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
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28))),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    theme.grad1.withValues(alpha: 0.10),
                    theme.grad2.withValues(alpha: 0.04)
                  ]),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(sw * 0.05, 0,
                    sw * 0.05, sw * 0.05),
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: sw * 0.030),
                              width: sw * 0.10,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: kBorder,
                                  borderRadius:
                                  BorderRadius.circular(
                                      4)))),
                      Container(
                          height: 3,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                theme.grad1,
                                theme.grad2
                              ]),
                              borderRadius:
                              BorderRadius.circular(4))),
                      SizedBox(height: sw * 0.045),
                      Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            JobIconTile(
                                title: job.title,
                                company: job.company,
                                size: sw * 0.145),
                            SizedBox(width: sw * 0.035),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(job.title,
                                          style: TextStyle(
                                              fontSize: sw * 0.048,
                                              fontWeight:
                                              FontWeight.w800,
                                              color: kInk,
                                              letterSpacing: -0.4)),
                                      SizedBox(height: sw * 0.010),
                                      Row(children: [
                                        Icon(
                                            Icons.apartment_rounded,
                                            size: sw * 0.033,
                                            color: kMuted),
                                        SizedBox(width: sw * 0.010),
                                        Expanded(
                                            child: Text(
                                                job.company,
                                                overflow: TextOverflow
                                                    .ellipsis,
                                                style: TextStyle(
                                                    fontSize:
                                                    sw * 0.033,
                                                    color: kMuted,
                                                    fontWeight:
                                                    FontWeight
                                                        .w600)))
                                      ]),
                                      SizedBox(height: sw * 0.015),
                                      Row(children: [
                                        Icon(
                                            Icons.location_on_rounded,
                                            size: sw * 0.033,
                                            color: kHint),
                                        SizedBox(width: sw * 0.008),
                                        Text(job.location,
                                            style: TextStyle(
                                                fontSize: sw * 0.030,
                                                color: kMuted)),
                                        SizedBox(width: sw * 0.020),
                                        Container(
                                            padding: EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                sw * 0.020,
                                                vertical:
                                                sw * 0.008),
                                            decoration: BoxDecoration(
                                                color: kSelectedBg,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    20)),
                                            child: Text(job.type,
                                                style: TextStyle(
                                                    fontSize:
                                                    sw * 0.025,
                                                    fontWeight:
                                                    FontWeight
                                                        .w700,
                                                    color:
                                                    kPrimary))),
                                      ]),
                                    ])),
                          ]),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(sw * 0.05,
                    sw * 0.045, sw * 0.05, sw * 0.08),
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: kBgPage,
                            borderRadius:
                            BorderRadius.circular(16),
                            border:
                            Border.all(color: kBorder)),
                        child: Row(children: [
                          _statCell(Icons.payments_rounded,
                              job.salary, 'Salary', sw),
                          _vDivider(),
                          _statCell(
                              Icons.military_tech_rounded,
                              job.exp,
                              'Experience',
                              sw),
                          _vDivider(),
                          _statCell(Icons.history_rounded,
                              job.posted, 'Posted', sw),
                        ]),
                      ),
                      SizedBox(height: sw * 0.05),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.035,
                            vertical: sw * 0.030),
                        decoration: BoxDecoration(
                            color: kBgPage,
                            borderRadius:
                            BorderRadius.circular(14),
                            border:
                            Border.all(color: kBorder)),
                        child: Row(children: [
                          Icon(Icons.insights_rounded,
                              size: sw * 0.040,
                              color: kWarning),
                          SizedBox(width: sw * 0.020),
                          Text('AI Match Score',
                              style: TextStyle(
                                  fontSize: sw * 0.033,
                                  fontWeight: FontWeight.w700,
                                  color: kInk)),
                          const Spacer(),
                          Text('${job.match}%',
                              style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.w800,
                                  color: job.match > 75
                                      ? kSuccess
                                      : kWarning)),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                              child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  child:
                                  LinearProgressIndicator(
                                      value:
                                      job.match / 100,
                                      minHeight: 8,
                                      backgroundColor:
                                      kBorder,
                                      valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                          job.match > 75
                                              ? kSuccess
                                              : kWarning)))),
                        ]),
                      ),
                      SizedBox(height: sw * 0.055),
                      _sectionHeader(Icons.badge_rounded,
                          'Your Role at the Company', theme, sw),
                      SizedBox(height: sw * 0.030),
                      _responsibilitiesBox(
                          responsibilities, theme, sw),
                      if (job.desc.isNotEmpty) ...[
                        SizedBox(height: sw * 0.055),
                        _sectionHeader(
                            Icons.description_rounded,
                            'Job Description',
                            theme,
                            sw),
                        SizedBox(height: sw * 0.030),
                        Container(
                            width: double.infinity,
                            padding:
                            EdgeInsets.all(sw * 0.040),
                            decoration: BoxDecoration(
                                color: kBgPage,
                                borderRadius:
                                BorderRadius.circular(16),
                                border: Border.all(
                                    color: kBorder)),
                            child: Text(job.desc,
                                style: TextStyle(
                                    fontSize: sw * 0.033,
                                    color: kSlate,
                                    height: 1.65))),
                      ],
                      if (job.tags.isNotEmpty) ...[
                        SizedBox(height: sw * 0.055),
                        _sectionHeader(Icons.code_rounded,
                            'Skills Required', theme, sw),
                        SizedBox(height: sw * 0.030),
                        Wrap(
                            spacing: sw * 0.020,
                            runSpacing: sw * 0.020,
                            children: job.tags
                                .map((tag) => Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.030,
                                  vertical: sw * 0.015),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        theme.grad1
                                            .withValues(
                                            alpha: 0.10),
                                        theme.grad2
                                            .withValues(
                                            alpha: 0.06)
                                      ]),
                                  borderRadius:
                                  BorderRadius.circular(
                                      20),
                                  border: Border.all(
                                      color: theme.grad1
                                          .withValues(
                                          alpha: 0.25))),
                              child: Text(tag,
                                  style: TextStyle(
                                      fontSize: sw * 0.030,
                                      fontWeight:
                                      FontWeight.w700,
                                      color: theme.grad1)),
                            ))
                                .toList()),
                      ],
                      SizedBox(height: sw * 0.055),
                      applied.contains(job.id)
                          ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: sw * 0.038),
                          decoration: BoxDecoration(
                              color:
                              const Color(0xFFF0FDF4),
                              borderRadius:
                              BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(
                                      0xFF86EFAC),
                                  width: 1.5)),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: kSuccess,
                                    size: sw * 0.050),
                                SizedBox(width: sw * 0.020),
                                Text(
                                    'Application Already Submitted',
                                    style: TextStyle(
                                        fontSize: sw * 0.038,
                                        fontWeight:
                                        FontWeight.w800,
                                        color: kSuccess))
                              ]))
                          : GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showApplyModal(job);
                          },
                          child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: sw * 0.038),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        theme.grad1,
                                        theme.grad2
                                      ],
                                      begin: Alignment
                                          .centerLeft,
                                      end: Alignment
                                          .centerRight),
                                  borderRadius:
                                  BorderRadius.circular(
                                      16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: theme.grad1
                                            .withValues(
                                            alpha: 0.30),
                                        blurRadius: 12,
                                        offset: const Offset(
                                            0, 4))
                                  ]),
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                                  children: [
                                    Icon(
                                        Icons
                                            .rocket_launch_rounded,
                                        color: Colors.white,
                                        size: sw * 0.045),
                                    SizedBox(
                                        width: sw * 0.020),
                                    Text('Apply for this Role',
                                        style: TextStyle(
                                            color:
                                            Colors.white,
                                            fontWeight:
                                            FontWeight
                                                .w800,
                                            fontSize:
                                            sw * 0.038))
                                  ]))),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
      IconData icon, String title, JobTheme theme, double sw) {
    return Row(children: [
      Container(
          width: sw * 0.085,
          height: sw * 0.085,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [theme.grad1, theme.grad2]),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon,
              color: Colors.white, size: sw * 0.045)),
      SizedBox(width: sw * 0.025),
      Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w800,
                  color: kInk))),
    ]);
  }

  Widget _responsibilitiesBox(
      List<String> items, JobTheme theme, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.040),
      decoration: BoxDecoration(
          color: kBgPage,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder)),
      child: Column(
          children: items.asMap().entries
              .map((e) => Padding(
            padding: EdgeInsets.only(
                bottom: e.key < items.length - 1
                    ? sw * 0.030
                    : 0),
            child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(
                          top: sw * 0.005),
                      width: sw * 0.055,
                      height: sw * 0.055,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            theme.grad1
                                .withValues(alpha: 0.15),
                            theme.grad2
                                .withValues(alpha: 0.08)
                          ]),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: TextStyle(
                                  fontSize: sw * 0.025,
                                  fontWeight:
                                  FontWeight.w800,
                                  color: theme.grad1)))),
                  SizedBox(width: sw * 0.025),
                  Expanded(
                      child: Text(e.value,
                          style: TextStyle(
                              fontSize: sw * 0.033,
                              color: kSlate,
                              height: 1.5,
                              fontWeight:
                              FontWeight.w500))),
                ]),
          ))
              .toList()),
    );
  }

  Widget _statCell(
      IconData icon, String value, String label, double sw) {
    return Expanded(
        child: Padding(
          padding:
          EdgeInsets.symmetric(vertical: sw * 0.035),
          child: Column(children: [
            Icon(icon, size: sw * 0.045, color: kPrimary),
            SizedBox(height: sw * 0.012),
            Text(value,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    fontSize: sw * 0.030,
                    fontWeight: FontWeight.w800,
                    color: kInk)),
            Text(label,
                style: TextStyle(
                    fontSize: sw * 0.025, color: kMuted)),
          ]),
        ));
  }

  Widget _vDivider() =>
      Container(width: 1, height: 50, color: kBorder);

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
            bottom:
            MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28))),
          padding: EdgeInsets.fromLTRB(
              sw * 0.06, 0, sw * 0.06, sw * 0.08),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: sw * 0.030),
                        width: sw * 0.10,
                        height: 4,
                        decoration: BoxDecoration(
                            color: kBorder,
                            borderRadius:
                            BorderRadius.circular(4)))),
                Row(children: [
                  JobIconTile(
                      title: job.title,
                      company: job.company,
                      size: sw * 0.12),
                  SizedBox(width: sw * 0.030),
                  Expanded(
                      child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text('Apply for ${job.title}',
                                style: TextStyle(
                                    fontSize: sw * 0.040,
                                    fontWeight: FontWeight.w800,
                                    color: kInk)),
                            Text(job.company,
                                style: TextStyle(
                                    fontSize: sw * 0.030,
                                    color: kMuted,
                                    fontWeight: FontWeight.w600)),
                          ])),
                ]),
                SizedBox(height: sw * 0.040),
                Container(
                  padding: EdgeInsets.all(sw * 0.035),
                  decoration: BoxDecoration(
                      color: kBgPage,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(color: kBorder)),
                  child: Row(children: [
                    _applyDetail(Icons.payments, job.salary,
                        'Salary', sw),
                    SizedBox(width: sw * 0.030),
                    Container(
                        width: 1,
                        height: sw * 0.09,
                        color: kBorder),
                    SizedBox(width: sw * 0.030),
                    _applyDetail(Icons.location_on,
                        job.location, 'Location', sw),
                    SizedBox(width: sw * 0.030),
                    Container(
                        width: 1,
                        height: sw * 0.09,
                        color: kBorder),
                    SizedBox(width: sw * 0.030),
                    _applyDetail(Icons.work_outline, job.type,
                        'Type', sw),
                  ]),
                ),
                SizedBox(height: sw * 0.045),
                _sectionHeader(
                    Icons.badge_rounded, 'Your Role', theme, sw),
                SizedBox(height: sw * 0.025),
                _responsibilitiesBox(responsibilities, theme, sw),
                SizedBox(height: sw * 0.05),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await ApplicationsService
                        .apply(jobId: job.id);
                    if (result == 'Applied successfully') {
                      setState(() => applied.add(job.id));
                      _showAppliedDialog(job);
                      loadAppliedJobs();
                    } else {
                      debugPrint("❌ Apply failed: $result");
                      if (mounted)
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                            content: Text(result),
                            duration: const Duration(
                                seconds: 2)));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: sw * 0.038),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [kPrimary, Color(0xFF4F46E5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius:
                      BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimary.withValues(
                                alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Center(
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send,
                                  color: Colors.white,
                                  size: sw * 0.040),
                              SizedBox(width: sw * 0.020),
                              Text('Submit Application',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: sw * 0.038)),
                            ])),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _applyDetail(
      IconData icon, String value, String label, double sw) {
    return Expanded(
        child: Column(children: [
          Icon(icon, size: sw * 0.040, color: kPrimary),
          SizedBox(height: sw * 0.010),
          Text(value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w800,
                  color: kInk)),
          Text(label,
              style:
              TextStyle(fontSize: sw * 0.025, color: kMuted)),
        ]));
  }

  void _showAppliedDialog(Job job) {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
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
                    offset: const Offset(0, 12))
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                height: 6,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      kPrimary,
                      Color(0xFF4F46E5),
                      kAccent
                    ]),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24)))),
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.06, sw * 0.05,
                  sw * 0.06, sw * 0.06),
              child: Column(children: [
                Container(
                    width: sw * 0.175,
                    height: sw * 0.175,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          kSuccess.withValues(alpha: 0.15),
                          kSuccess.withValues(alpha: 0.05)
                        ]),
                        border: Border.all(
                            color: kSuccess.withValues(alpha: 0.30),
                            width: 2)),
                    child: Center(
                        child: Icon(Icons.check_circle,
                            color: kSuccess, size: sw * 0.09))),
                SizedBox(height: sw * 0.035),
                Text('Application Sent! 🎉',
                    style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                        letterSpacing: -0.3)),
                SizedBox(height: sw * 0.010),
                Text(
                    'Your application for ${job.title} has been submitted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: sw * 0.033,
                        color: kMuted,
                        height: 1.5)),
                SizedBox(height: sw * 0.05),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: sw * 0.035),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [
                                kPrimary,
                                Color(0xFF4F46E5)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                          borderRadius:
                          BorderRadius.circular(14)),
                      child: Center(
                          child: Text('OK, Got it!',
                              style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)))),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Helper data class for active filter chips
// ─────────────────────────────────────────────
class _ActiveChip {
  final String label;
  final VoidCallback onRemove;
  _ActiveChip(this.label, this.onRemove);
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
    final card = SocialPostCard(
      postType: 'job',
      id: job.id,
      title: job.title,
      company: job.company,
      location: job.location,
      type: job.type,
      primaryBadge: job.salary,
      secondaryBadge: job.exp,
      imageUrl: job.imageUrl,
      companyLogo: job.companyLogo,
      description: job.desc,
      tags: job.tags,
      isSaved: isSaved,
      isApplied: isApplied,
      initialLikesCount: job.likesCount,
      initialCommentsCount: job.commentsCount,
      initialSharesCount: job.sharesCount,
      initialIsLiked: job.isLiked,
      onSave: onSave,
      onApply: onApply,
      onTap: onTap,
    );

    if (ctrl == null) return card;
    return AnimatedBuilder(
      animation: ctrl!,
      builder: (_, child) => Opacity(
          opacity: ctrl!.value,
          child: Transform.translate(
              offset: Offset(0, 50 * (1 - ctrl!.value)),
              child: child)),
      child: card,
    );
  }
}

// ═══════════════════════════════════════════
//  SAVED JOBS PAGE
// ═══════════════════════════════════════════
class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;
  const SavedJobsPage(
      {required this.jobs, required this.savedIds, super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final savedJobs =
    jobs.where((j) => savedIds.contains(j.id)).toList();
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kInk,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Saved Jobs',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3)),
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
                        shape: BoxShape.circle),
                    child: Icon(Icons.bookmark_border,
                        color: kPrimary, size: sw * 0.08)),
                SizedBox(height: sw * 0.040),
                Text('No saved jobs yet',
                    style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w700,
                        color: kSlate)),
                SizedBox(height: sw * 0.015),
                Text(
                    'Tap the bookmark icon on any job to save it',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: sw * 0.033, color: kMuted)),
              ]))
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
                border: Border.all(
                    color: kBorder, width: 1.5)),
            child: Row(children: [
              JobIconTile(
                  title: j.title,
                  company: j.company,
                  size: sw * 0.11),
              SizedBox(width: sw * 0.030),
              Expanded(
                  child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(j.title,
                            style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w800,
                                color: kInk)),
                        SizedBox(height: sw * 0.005),
                        Text(j.company,
                            style: TextStyle(
                                fontSize: sw * 0.030,
                                color: kMuted,
                                fontWeight: FontWeight.w600)),
                      ])),
              Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(j.salary,
                        style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: FontWeight.w800,
                            color: kInk)),
                    SizedBox(height: sw * 0.010),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.020,
                            vertical: sw * 0.008),
                        decoration: BoxDecoration(
                            color: kSelectedBg,
                            borderRadius:
                            BorderRadius.circular(8)),
                        child: Text(j.type,
                            style: TextStyle(
                                fontSize: sw * 0.025,
                                fontWeight: FontWeight.w700,
                                color: kPrimary))),
                  ]),
            ]),
          );
        },
      ),
    );
  }
}
