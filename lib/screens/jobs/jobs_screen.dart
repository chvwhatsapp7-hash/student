import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

const List<String> kFilters = [
  'All',
  'Full Time',
  'Remote',
  'Fresher',
  'Bengaluru',
];

// ─────────────────────────────────────────────
//  JOB MODEL
// ─────────────────────────────────────────────

class Job {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final int match;
  final String logo;
  final List<String> tags;
  final String exp;
  final String posted;
  final String desc;

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
      id: json['job_id'] ?? 0,
      title: json['title'] ?? 'No title',
      company: 'Company ${json['company_id'] ?? 0}',
      location: json['location'] ?? 'Remote',
      salary: (json['salary_min'] != null && json['salary_max'] != null)
          ? '₹${json['salary_min']}–${json['salary_max']}'
          : 'Negotiable',
      type: json['job_type'] ?? 'Full Time',
      match: 80,
      logo: '💼',
      tags: ['Tech', 'Developer'],
      exp: json['experience_level'] ?? 'Fresher',
      posted: 'Recently',
      desc: json['description'] ?? '',
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
  String _filter = 'All';
  String _search = '';
  final Set<int> _saved = {};
  final Set<int> _applied = {};
  bool _loading = true;
  bool _error = false;

  late AnimationController _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};

  List<Job> _jobs = [];

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fetchJobs();
  }

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
            vsync: this,
            duration: const Duration(milliseconds: 460),
          );
          _cardAnims[_jobs[i].id] = c;
          Future.delayed(Duration(milliseconds: 150 + i * 80), () {
            if (mounted) c.forward();
          });
        }

        setState(() {
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    } catch (_) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  List<Job> get _filtered => _jobs.where((job) {
    final q = _search.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        job.title.toLowerCase().contains(q) ||
        job.company.toLowerCase().contains(q) ||
        job.tags.any((t) => t.toLowerCase().contains(q));

    final matchFilter =
        _filter == 'All' ||
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

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error)
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load jobs.',
            style: TextStyle(color: kMuted, fontSize: 16),
          ),
        ),
      );

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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jobs',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Find your perfect role',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Saved jobs button
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
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bookmark,
                              color: kAccent,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_saved.length} Saved',
                              style: const TextStyle(
                                fontSize: 12,
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
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _statPill('${_jobs.length}', 'Jobs'),
                    const SizedBox(width: 10),
                    _statPill('${_applied.length}', 'Applied'),
                    const SizedBox(width: 10),
                    _statPill('95%', 'Top Match'),
                    const SizedBox(width: 10),
                    _statPill('3', 'Cities'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            num,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kAccent,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: kInk,
        ),
        decoration: InputDecoration(
          hintText: 'Search jobs, companies, skills…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search, color: kMuted, size: 20),
          filled: true,
          fillColor: kBgPage,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
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
                  final f = kFilters[i];
                  final selected = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _filter = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
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
                            fontSize: 12,
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
          const SizedBox(width: 10),
          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              '${_filtered.length} jobs',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
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
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kSlate,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() {
                _filter = 'All';
                _search = '';
              }),
              child: const Text(
                'Clear filters',
                style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700),
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
        job: list[i],
        isSaved: _saved.contains(list[i].id),
        isApplied: _applied.contains(list[i].id),
        ctrl: _cardAnims[list[i].id],
        onSave: () {
          HapticFeedback.selectionClick();
          setState(
            () => _saved.contains(list[i].id)
                ? _saved.remove(list[i].id)
                : _saved.add(list[i].id),
          );
        },
        onApply: () => _showApplyModal(list[i]),
      ),
    );
  }

  // ── APPLY MODAL ────────────────────────────
  void _showApplyModal(Job job) {
    HapticFeedback.mediumImpact();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Title row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kBgPage,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: kBorder),
                    ),
                    child: Center(
                      child: Text(
                        job.logo,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply for ${job.title}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                        Text(
                          job.company,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _modalField(nameCtrl, 'Full Name', Icons.person),
              const SizedBox(height: 12),
              _modalField(emailCtrl, 'Email Address', Icons.email),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _applied.add(job.id));
                  _showAppliedSnack(job.company);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Submit Application',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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

  void _showAppliedSnack(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application sent to $company 🎯'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _modalField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, color: kInk),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kMuted, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: kMuted),
        filled: true,
        fillColor: kBgPage,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
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
    );
  }
}

// ── JOB CARD ─────────────────────────────────
class _JobCard extends StatelessWidget {
  final Job job;
  final bool isSaved;
  final bool isApplied;
  final AnimationController? ctrl;
  final VoidCallback onSave;
  final VoidCallback onApply;

  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.isApplied,
    this.ctrl,
    required this.onSave,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return ctrl == null
        ? _buildCard()
        : AnimatedBuilder(
            animation: ctrl!,
            builder: (_, child) => Opacity(
              opacity: ctrl!.value,
              child: Transform.translate(
                offset: Offset(0, 50 * (1 - ctrl!.value)),
                child: child,
              ),
            ),
            child: _buildCard(),
          );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job header row
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: kBorder),
                ),
                child: Center(
                  child: Text(job.logo, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    Text(
                      job.company,
                      style: const TextStyle(
                        color: kMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onSave,
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: isSaved ? kAccent : kMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chips row
          Row(
            children: [
              _chip(job.type),
              const SizedBox(width: 8),
              _chip(job.location),
              const SizedBox(width: 8),
              _chip(job.exp),
            ],
          ),
          const SizedBox(height: 12),

          // ─── AI MATCH INDICATOR ──────────────────────────────
          Row(
            children: [
              // AI Match pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: job.match > 75
                      ? kSuccess.withOpacity(0.15)
                      : job.match > 50
                      ? kWarning.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${job.match}% AI Match',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: job.match > 75
                        ? kSuccess
                        : job.match > 50
                        ? kWarning
                        : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Optional: Gradient mini progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: job.match / 100,
                    minHeight: 6,
                    backgroundColor: kBgPage,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      job.match > 75
                          ? kSuccess
                          : job.match > 50
                          ? kWarning
                          : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Apply button row
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: isApplied ? null : onApply,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isApplied ? kSuccess.withOpacity(0.3) : kPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: kSelectedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kPrimary,
        ),
      ),
    );
  }
}

// ── SAVED JOBS PAGE ─────────────────────────
class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;
  const SavedJobsPage({required this.jobs, required this.savedIds});

  @override
  Widget build(BuildContext context) {
    final savedJobs = jobs.where((j) => savedIds.contains(j.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: savedJobs.isEmpty
          ? const Center(child: Text('No saved jobs'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedJobs.length,
              itemBuilder: (_, i) {
                final j = savedJobs[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(
                    j.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              },
            ),
    );
  }
}
