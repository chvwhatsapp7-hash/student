import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kSlate      = Color(0xFF334155);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);
const kBgPage     = Color(0xFFF0F4F8);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kSuccess    = Color(0xFF16A34A);
const kWarning    = Color(0xFFF59E0B);
const kSelectedBg = Color(0xFFEFF6FF);

const List<String> kFilters = [
  'All', 'Full Time', 'Remote', 'Fresher', 'Bengaluru',
];

// ─────────────────────────────────────────────
//  JOB MODEL — untouched
// ─────────────────────────────────────────────

class Job {
  final int          id;
  final String       title;
  final String       company;
  final String       location;
  final String       salary;
  final String       type;
  final int          match;
  final String       logo;
  final List<String> tags;
  final String       exp;
  final String       posted;
  final String       desc;

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

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id:      json['job_id'] ?? 0,
      title:   json['title'] ?? 'No title',
      company: 'Company ${json['company_id'] ?? 0}',
      location: json['location'] ?? 'Remote',
      salary: (json['salary_min'] != null && json['salary_max'] != null)
          ? '₹${json['salary_min']}–${json['salary_max']}'
          : 'Negotiable',
      type:    json['job_type'] ?? 'Full Time',
      match:   80,
      logo:    '💼',
      tags:    ['Tech', 'Developer'],
      exp:     json['experience_level'] ?? 'Fresher',
      posted:  'Recently',
      desc:    json['description'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────
//  PROFESSIONAL JOB ICON SYSTEM — design only
// ─────────────────────────────────────────────

class _JobTheme {
  final IconData icon;
  final Color    grad1;
  final Color    grad2;
  const _JobTheme(this.icon, this.grad1, this.grad2);
}

_JobTheme _resolveJobTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();

  if (t.contains('software engineer') || t.contains('sde') || t.contains('software developer'))
    return const _JobTheme(Icons.code,              Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('frontend') || t.contains('front-end') || t.contains('ui developer'))
    return const _JobTheme(Icons.web,               Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') || t.contains('back-end') || t.contains('server'))
    return const _JobTheme(Icons.dns,               Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const _JobTheme(Icons.layers,            Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('mobile') || t.contains('android') || t.contains('flutter'))
    return const _JobTheme(Icons.phone_android,     Color(0xFF0284C7), Color(0xFF38BDF8));
  if (t.contains('ios') || t.contains('swift'))
    return const _JobTheme(Icons.phone_iphone,      Color(0xFF374151), Color(0xFF6B7280));
  if (t.contains('machine learning') || t.contains(' ml'))
    return const _JobTheme(Icons.psychology,        Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('data scientist') || t.contains('data science'))
    return const _JobTheme(Icons.analytics,         Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('data analyst') || t.contains('data engineer'))
    return const _JobTheme(Icons.bar_chart,         Color(0xFF0369A1), Color(0xFF0284C7));
  if (t.contains('artificial intelligence') || t.contains(' ai') || t.contains('ai '))
    return const _JobTheme(Icons.smart_toy,         Color(0xFF4F46E5), Color(0xFF6366F1));
  if (t.contains('nlp') || t.contains('deep learning') || t.contains('neural'))
    return const _JobTheme(Icons.hub,               Color(0xFF7C3AED), Color(0xFF4F46E5));
  if (t.contains('computer vision'))
    return const _JobTheme(Icons.remove_red_eye,    Color(0xFF6366F1), Color(0xFF3B82F6));
  if (t.contains('cloud') || t.contains('aws') || t.contains('azure') || t.contains('gcp'))
    return const _JobTheme(Icons.cloud,             Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('devops') || t.contains('sre') || t.contains('platform engineer'))
    return const _JobTheme(Icons.sync_alt,          Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('docker') || t.contains('kubernetes'))
    return const _JobTheme(Icons.view_in_ar,        Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('linux') || t.contains('systems'))
    return const _JobTheme(Icons.terminal,          Color(0xFF374151), Color(0xFF4B5563));
  if (t.contains('security') || t.contains('cyber') || t.contains('ethical'))
    return const _JobTheme(Icons.shield,            Color(0xFFB91C1C), Color(0xFFDC2626));
  if (t.contains('ui') || t.contains('ux') || t.contains('design') || t.contains('figma'))
    return const _JobTheme(Icons.brush,             Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('product manager') || t.contains('product management'))
    return const _JobTheme(Icons.inventory_2,       Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('finance') || t.contains('accounting') || t.contains('analyst'))
    return const _JobTheme(Icons.account_balance,   Color(0xFF065F46), Color(0xFF059669));
  if (t.contains('marketing') || t.contains('growth'))
    return const _JobTheme(Icons.trending_up,       Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('sales') || t.contains('business development'))
    return const _JobTheme(Icons.handshake,         Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('hr') || t.contains('human resource') || t.contains('recruiter'))
    return const _JobTheme(Icons.people,            Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('testing') || t.contains('qa') || t.contains('quality'))
    return const _JobTheme(Icons.bug_report,        Color(0xFFB45309), Color(0xFFD97706));
  if (t.contains('blockchain') || t.contains('web3') || t.contains('solidity'))
    return const _JobTheme(Icons.link,              Color(0xFF7C3AED), Color(0xFF6366F1));
  if (c.contains('google'))
    return const _JobTheme(Icons.search,            Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (c.contains('microsoft'))
    return const _JobTheme(Icons.window,            Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (c.contains('amazon') || c.contains('aws'))
    return const _JobTheme(Icons.cloud,             Color(0xFFD97706), Color(0xFFF59E0B));
  if (c.contains('flipkart'))
    return const _JobTheme(Icons.shopping_bag,      Color(0xFFD97706), Color(0xFFF59E0B));
  if (c.contains('razorpay') || c.contains('paytm'))
    return const _JobTheme(Icons.account_balance_wallet, Color(0xFF1D4ED8), Color(0xFF6366F1));
  if (c.contains('infosys') || c.contains('tcs') || c.contains('wipro'))
    return const _JobTheme(Icons.business,          Color(0xFF1D4ED8), Color(0xFF3B82F6));

  return const _JobTheme(Icons.work_outline,        Color(0xFF1D4ED8), Color(0xFF6366F1));
}

// ── Role responsibilities generator ────────────
// Generates context-aware "What you'll do" bullets
// based on the job title — pure UI, no API touch.
List<String> _resolveResponsibilities(String title) {
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
  if (t.contains('full stack') || t.contains('fullstack'))
    return [
      'Develop end-to-end features across frontend and backend',
      'Maintain CI/CD pipelines and deployment workflows',
      'Review pull requests and mentor junior engineers',
      'Collaborate with product managers on feature scoping',
    ];
  if (t.contains('machine learning') || t.contains(' ml') || t.contains('data science'))
    return [
      'Build, train and evaluate machine learning models',
      'Prepare and clean large-scale datasets for training',
      'Deploy models to production via REST or gRPC endpoints',
      'Monitor model performance and retrain as needed',
    ];
  if (t.contains('data analyst') || t.contains('data engineer'))
    return [
      'Build and maintain ETL pipelines for business data',
      'Create dashboards and reports for stakeholders',
      'Identify trends and anomalies in large datasets',
      'Collaborate with engineering teams on data schemas',
    ];
  if (t.contains('devops') || t.contains('sre') || t.contains('cloud'))
    return [
      'Manage and scale cloud infrastructure on AWS / GCP / Azure',
      'Build and maintain CI/CD pipelines using GitHub Actions',
      'Monitor system health with Prometheus, Grafana and PagerDuty',
      'Implement infrastructure-as-code using Terraform',
    ];
  if (t.contains('security') || t.contains('cyber'))
    return [
      'Conduct penetration testing and vulnerability assessments',
      'Implement and review security policies across the stack',
      'Respond to and investigate security incidents',
      'Train teams on security best practices and compliance',
    ];
  if (t.contains('design') || t.contains('ux') || t.contains('ui'))
    return [
      'Create user flows, wireframes and high-fidelity Figma prototypes',
      'Conduct usability testing and synthesise user research',
      'Maintain the design system and component library',
      'Collaborate with engineers during implementation',
    ];
  if (t.contains('product manager') || t.contains('product management'))
    return [
      'Define product roadmap and prioritise the feature backlog',
      'Write clear PRDs and user stories for the engineering team',
      'Analyse user metrics and drive data-informed decisions',
      'Coordinate cross-functional sprints and release cycles',
    ];
  if (t.contains('marketing') || t.contains('growth'))
    return [
      'Plan and execute digital marketing campaigns',
      'Analyse campaign performance and optimise ROAS',
      'Manage SEO, SEM and social media channels',
      'Collaborate with content and design teams',
    ];
  if (t.contains('sales') || t.contains('business development'))
    return [
      'Identify and qualify new business opportunities',
      'Present product demos and close enterprise deals',
      'Maintain CRM records and weekly pipeline reports',
      'Build long-term relationships with key accounts',
    ];
  if (t.contains('hr') || t.contains('human resource'))
    return [
      'Source, screen and onboard top talent',
      'Design and run performance review cycles',
      'Develop HR policies and culture initiatives',
      'Partner with leadership on org-design and headcount planning',
    ];

  // Generic default
  return [
    'Contribute to key product features end-to-end',
    'Collaborate with cross-functional teams in an agile setting',
    'Participate in code reviews, planning and retrospectives',
    'Document your work and support knowledge sharing',
  ];
}

class _JobIconTile extends StatelessWidget {
  final String title;
  final String company;
  final double size;
  const _JobIconTile({
    required this.title,
    required this.company,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _resolveJobTheme(title, company);
    return Container(
      width: size, height: size,
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
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(theme.icon, color: Colors.white, size: size * 0.46),
    );
  }
}

// ─────────────────────────────────────────────
//  JOBS SCREEN
// ─────────────────────────────────────────────

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {

  // state — untouched
  String         _filter  = 'All';
  String         _search  = '';
  final Set<int> _saved   = {};
  final Set<int> _applied = {};
  bool           _loading = true;
  bool           _error   = false;

  late AnimationController            _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};
  List<Job>                           _jobs      = [];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _fetchJobs();
  }

  // API FETCH — untouched
  Future<void> _fetchJobs() async {
    try {
      final res = await http.get(
        Uri.parse('https://studenthub-backend-woad.vercel.app/api/jobs'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List jobsData = data['data'] ?? [];
        _jobs = jobsData.map((j) => Job.fromJson(j)).toList();
        for (int i = 0; i < _jobs.length; i++) {
          final c = AnimationController(
            vsync: this, duration: const Duration(milliseconds: 460),
          );
          _cardAnims[_jobs[i].id] = c;
          Future.delayed(Duration(milliseconds: 150 + i * 80), () {
            if (mounted) c.forward();
          });
        }
        setState(() => _loading = false);
      } else {
        setState(() { _loading = false; _error = true; });
      }
    } catch (_) {
      setState(() { _loading = false; _error = true; });
    }
  }

  // _filtered — untouched
  List<Job> get _filtered => _jobs.where((job) {
    final q           = _search.toLowerCase();
    final matchSearch = q.isEmpty ||
        job.title.toLowerCase().contains(q) ||
        job.company.toLowerCase().contains(q) ||
        job.tags.any((t) => t.toLowerCase().contains(q));
    final matchFilter = _filter == 'All' ||
        job.type == _filter ||
        job.location.contains(_filter) ||
        job.exp == _filter;
    return matchSearch && matchFilter;
  }).toList();

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: kPrimary),
              const SizedBox(height: 16),
              const Text('Finding your perfect jobs…',
                  style: TextStyle(
                      fontSize: 14, color: kMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    if (_error) {
      return Scaffold(
        backgroundColor: kBgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F2), shape: BoxShape.circle),
                child: const Icon(Icons.wifi_off,
                    color: Color(0xFFDC2626), size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Failed to load jobs',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: kSlate)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() { _loading = true; _error = false; });
                  _fetchJobs();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Retry',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(child: _buildJobList()),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jobs',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.4,
                              )),
                          Text('Find your perfect role',
                              style: TextStyle(fontSize: 12, color: kHint)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SavedJobsPage(
                            jobs: _jobs,
                            savedIds: _saved.toList(),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark,
                                color: kAccent, size: 15),
                            const SizedBox(width: 5),
                            Text('${_saved.length} Saved',
                                style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _statPill(Icons.work_outline,  '${_jobs.length}',    'Jobs'),
                    _statPill(Icons.send,           '${_applied.length}', 'Applied'),
                    _statPill(Icons.auto_awesome,   '95%',                'Top Match'),
                    _statPill(Icons.location_city,  '3',                  'Cities'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kAccent),
          const SizedBox(width: 4),
          Text(num,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: kAccent)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search jobs, companies, skills…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search, color: kMuted, size: 22),
          filled: true,
          fillColor: kBgPage,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
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

  // ── FILTER BAR ─────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f        = kFilters[i];
                  final selected = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _filter = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected ? kPrimary : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? kPrimary : kBorder, width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(f,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : kMuted,
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
            ),
            child: Text('${_filtered.length} jobs',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: kPrimary,
                )),
          ),
        ],
      ),
    );
  }

  // ── JOB LIST ───────────────────────────────

  Widget _buildJobList() {
    final list = _filtered;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: kSelectedBg, shape: BoxShape.circle),
              child: const Icon(Icons.search_off,
                  color: kPrimary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No jobs found',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: kSlate)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() { _filter = 'All'; _search = ''; }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Clear filters',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: list.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, i) => _JobCard(
        job:       list[i],
        isSaved:   _saved.contains(list[i].id),
        isApplied: _applied.contains(list[i].id),
        ctrl:      _cardAnims[list[i].id],
        onSave: () {
          HapticFeedback.selectionClick();
          setState(() => _saved.contains(list[i].id)
              ? _saved.remove(list[i].id)
              : _saved.add(list[i].id));
        },
        onApply: () => _showApplyModal(list[i]),
        // Card tap → role detail sheet (NEW)
        onTap: () => _showJobDetailSheet(list[i]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  JOB DETAIL SHEET (NEW)
  //  Shows full role description + responsibilities
  //  BEFORE the user applies. Apply button is inside.
  // ─────────────────────────────────────────────

  void _showJobDetailSheet(Job job) {
    final theme           = _resolveJobTheme(job.title, job.company);
    final responsibilities = _resolveResponsibilities(job.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize:     0.45,
        maxChildSize:     0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [

              // ── Gradient hero header ──────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.10),
                      theme.grad2.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                            color: kBorder,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    // Thin gradient accent line
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [theme.grad1, theme.grad2]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Icon + title + company
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _JobIconTile(
                            title: job.title, company: job.company, size: 58),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.title,
                                  style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w800,
                                    color: kInk, letterSpacing: -0.4,
                                  )),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.apartment_rounded,
                                      size: 13, color: kMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(job.company,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13, color: kMuted,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 13, color: kHint),
                                  const SizedBox(width: 3),
                                  Text(job.location,
                                      style: const TextStyle(
                                          fontSize: 12, color: kMuted)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: kSelectedBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(job.type,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: kPrimary,
                                        )),
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

              // ── Body ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Quick stats row ──────────
                    Container(
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        children: [
                          _statCell(Icons.payments_rounded,
                              job.salary, 'Salary'),
                          _vDivider(),
                          _statCell(Icons.military_tech_rounded,
                              job.exp, 'Experience'),
                          _vDivider(),
                          _statCell(Icons.history_rounded,
                              job.posted, 'Posted'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── AI match ─────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insights_rounded,
                              size: 16, color: kWarning),
                          const SizedBox(width: 8),
                          const Text('AI Match Score',
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: kInk,
                              )),
                          const Spacer(),
                          Text('${job.match}%',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: job.match > 75 ? kSuccess : kWarning,
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: job.match / 100,
                                minHeight: 8,
                                backgroundColor: kBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    job.match > 75 ? kSuccess : kWarning),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── YOUR ROLE SECTION (KEY NEW) ──
                    // Shows exactly what the candidate will do
                    Row(
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.grad1, theme.grad2],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.badge_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text('Your Role at the Company',
                            style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Responsibilities list
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: responsibilities.asMap().entries.map((e) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: e.key < responsibilities.length - 1
                                    ? 12 : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 22, height: 22,
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
                                    child: Text('${e.key + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: theme.grad1,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(e.value,
                                      style: const TextStyle(
                                        fontSize: 13, color: kSlate,
                                        height: 1.5, fontWeight: FontWeight.w500,
                                      )),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Job description ───────────
                    if (job.desc.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.grad1, theme.grad2],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.description_rounded,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text('Job Description',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: kInk,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(job.desc,
                            style: const TextStyle(
                                fontSize: 13, color: kSlate, height: 1.65)),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // ── YOUR ROLE AT THE COMPANY ─────────────
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [theme.grad1, theme.grad2]),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.badge_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text('Your Role at the Company',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Builder(builder: (_) {
                      final resp = _resolveResponsibilities(job.title);
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorder),
                        ),
                        child: Column(
                          children: resp.asMap().entries.map((e) => Padding(
                            padding: EdgeInsets.only(
                                bottom: e.key < resp.length - 1 ? 12 : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    color: theme.grad1.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${e.key + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: theme.grad1,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(e.value,
                                      style: const TextStyle(
                                        fontSize: 13, color: kSlate,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),

                    // ── Required skills ───────────
                    if (job.tags.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.grad1, theme.grad2],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.code_rounded,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text('Skills Required',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: kInk,
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: job.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.grad1.withValues(alpha: 0.10),
                                theme.grad2.withValues(alpha: 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: theme.grad1.withValues(alpha: 0.25)),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: theme.grad1,
                              )),
                        )).toList(),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // ── Apply / Applied CTA ───────
                    _applied.contains(job.id)
                        ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF86EFAC), width: 1.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: kSuccess, size: 20),
                          SizedBox(width: 8),
                          Text('Application Already Submitted',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: kSuccess,
                              )),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                              blurRadius: 12, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Apply for this Role',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                )),
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

  Widget _statCell(IconData icon, String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 18, color: kPrimary),
            const SizedBox(height: 5),
            Text(value,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: kInk)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: kMuted)),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 50, color: kBorder);

  // ── APPLY MODAL — untouched logic ──────────

  void _showApplyModal(Job job) {
    HapticFeedback.mediumImpact();
    final nameCtrl  = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Row(
                children: [
                  _JobIconTile(
                      title: job.title, company: job.company, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Apply for ${job.title}',
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                        Text(job.company,
                            style: const TextStyle(
                                fontSize: 12, color: kMuted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    _applyDetail(Icons.payments,    job.salary,   'Salary'),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 36, color: kBorder),
                    const SizedBox(width: 12),
                    _applyDetail(Icons.location_on,  job.location, 'Location'),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 36, color: kBorder),
                    const SizedBox(width: 12),
                    _applyDetail(Icons.work_outline, job.type,     'Type'),
                  ],
                ),
              ),
              // ── Full Name & Email fields intentionally removed ──
              // Uncomment to re-enable:
              // const SizedBox(height: 16),
              // _modalField(nameCtrl,  'Full Name',     Icons.person),
              // const SizedBox(height: 12),
              // _modalField(emailCtrl, 'Email Address', Icons.email),
              const SizedBox(height: 18),

              // ── YOUR ROLE section (shown before submit) ──────────
              Builder(builder: (ctx) {
                final theme = _resolveJobTheme(job.title, job.company);
                final responsibilities = _resolveResponsibilities(job.title);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [theme.grad1, theme.grad2]),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.badge_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text('Your Role',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Responsibilities
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: responsibilities.asMap().entries.map((e) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: e.key < responsibilities.length - 1
                                    ? 10 : 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      theme.grad1.withValues(alpha: 0.15),
                                      theme.grad2.withValues(alpha: 0.08),
                                    ]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${e.key + 1}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: theme.grad1,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(e.value,
                                      style: const TextStyle(
                                        fontSize: 12, color: kSlate,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // ── Job description ───────────────────────────
                    if (job.desc.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [theme.grad1, theme.grad2]),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.description_rounded,
                                color: Colors.white, size: 15),
                          ),
                          const SizedBox(width: 8),
                          const Text('Job Description',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: kInk,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(job.desc,
                            style: const TextStyle(
                              fontSize: 12, color: kSlate,
                              height: 1.6,
                            )),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _applied.add(job.id));
                  _showAppliedDialog(job);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Submit Application',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            )),
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

  Widget _applyDetail(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: kPrimary),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: kInk)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: kMuted)),
        ],
      ),
    );
  }

  // _showAppliedDialog — untouched
  void _showAppliedDialog(Job job) {
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
                blurRadius: 40, offset: const Offset(0, 12),
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          kSuccess.withValues(alpha: 0.15),
                          kSuccess.withValues(alpha: 0.05),
                        ]),
                        border: Border.all(
                            color: kSuccess.withValues(alpha: 0.30), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.check_circle,
                            color: kSuccess, size: 36),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Application Sent! 🎉',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: kInk, letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 4),
                    Text('Your application for ${job.title} has been submitted.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: kMuted, height: 1.5)),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _JobIconTile(
                                  title: job.title,
                                  company: job.company,
                                  size: 42),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: kInk,
                                        )),
                                    Text(job.company,
                                        style: const TextStyle(
                                            fontSize: 12, color: kMuted,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(height: 1, color: kBorder),
                          const SizedBox(height: 14),
                          _dialogDetailRow(Icons.payments,    'Salary',     job.salary),
                          const SizedBox(height: 10),
                          _dialogDetailRow(Icons.location_on, 'Location',   job.location),
                          const SizedBox(height: 10),
                          _dialogDetailRow(Icons.work_outline,'Job Type',   job.type),
                          const SizedBox(height: 10),
                          _dialogDetailRow(Icons.school,       'Experience', job.exp),
                          const SizedBox(height: 10),
                          _dialogDetailRow(Icons.access_time,  'Posted',    job.posted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimary, Color(0xFF4F46E5)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('OK, Got it!',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
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

  Widget _dialogDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: kSelectedBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: kPrimary),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: kInk)),
        ),
      ],
    );
  }

  Widget _modalField(
      TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(
          fontSize: 14, color: kInk, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kMuted, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: kMuted),
        filled: true,
        fillColor: kBgPage,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 13),
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
    );
  }

  // _showAppliedSnack — untouched
  void _showAppliedSnack(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application sent to $company 🎯'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  JOB CARD
// ─────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final Job      job;
  final bool     isSaved;
  final bool     isApplied;
  final AnimationController? ctrl;
  final VoidCallback onSave;
  final VoidCallback onApply;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    required this.onTap,
    this.ctrl,
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

  Widget _buildCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: isApplied
              ? const LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color:        isApplied ? null : kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isApplied
                ? kPrimary.withValues(alpha: 0.40) : kBorder,
            width: isApplied ? 2 : 1.5,
          ),
          boxShadow: isApplied
              ? [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.10),
              blurRadius: 16, offset: const Offset(0, 4),
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
                      colors: [kPrimary, Color(0xFF4F46E5), kAccent]),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TOP ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _JobIconTile(
                          title: job.title, company: job.company),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title,
                                style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800,
                                  color: isApplied ? kPrimary : kInk,
                                )),
                            const SizedBox(height: 2),
                            Text(job.company,
                                style: const TextStyle(
                                    fontSize: 12, color: kMuted,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onSave,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: isSaved
                                ? kAccent.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isSaved ? kAccent : kMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tap hint
                  Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 11,
                          color: kPrimary.withValues(alpha: 0.60)),
                      const SizedBox(width: 4),
                      Text('Tap to see your role & job details',
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: kPrimary.withValues(alpha: 0.60),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // CHIPS — Wrap prevents overflow
                  Wrap(
                    spacing: 7, runSpacing: 7,
                    children: [
                      _chip(Icons.work_outline,  job.type),
                      _chip(Icons.location_on,   job.location),
                      _chip(Icons.school,        job.exp),
                      _chip(Icons.access_time,   job.posted),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // SALARY + APPLIED BADGE
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee,
                          size: 14, color: kInk),
                      const SizedBox(width: 3),
                      Text(job.salary,
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: kInk,
                          )),
                      const Spacer(),
                      if (isApplied)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kSuccess, Color(0xFF15803D)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Applied',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // AI MATCH BAR
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: job.match > 75
                              ? kSuccess.withValues(alpha: 0.12)
                              : kWarning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 12, color: kWarning),
                            const SizedBox(width: 4),
                            Text('${job.match}% Match',
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: job.match > 75 ? kSuccess : kWarning,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 14),

                  // APPLY BUTTON
                  if (!isApplied)
                    GestureDetector(
                      onTap: onApply,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                              blurRadius: 8, offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rocket_launch,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Apply Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  )),
                            ],
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
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: kMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: kMuted)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SAVED JOBS PAGE — untouched logic
// ─────────────────────────────────────────────

class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;
  const SavedJobsPage({
    required this.jobs,
    required this.savedIds,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final savedJobs = jobs.where((j) => savedIds.contains(j.id)).toList();
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kInk,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Saved Jobs',
            style: TextStyle(
                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        centerTitle: false,
      ),
      body: savedJobs.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: kSelectedBg, shape: BoxShape.circle),
              child: const Icon(Icons.bookmark_border,
                  color: kPrimary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No saved jobs yet',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: kSlate)),
            const SizedBox(height: 6),
            const Text(
                'Tap the bookmark icon on any job to save it',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kMuted)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedJobs.length,
        itemBuilder: (_, i) {
          final j = savedJobs[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Row(
              children: [
                _JobIconTile(
                    title: j.title, company: j.company, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(j.title,
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: kInk,
                          )),
                      const SizedBox(height: 2),
                      Text(j.company,
                          style: const TextStyle(
                              fontSize: 12, color: kMuted,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(j.salary,
                        style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kSelectedBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(j.type,
                          style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: kPrimary,
                          )),
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
