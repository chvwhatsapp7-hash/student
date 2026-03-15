import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — Engineering Theme
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

// ─────────────────────────────────────────────
//  MODEL
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

  const Job({
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
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

final List<Job> kJobs = [
  const Job(
    id: 1, logo: '🔵', title: 'Software Engineer',
    company: 'Google', location: 'Bengaluru',
    salary: '₹20–30 LPA', type: 'Full Time',
    match: 95, tags: ['Python', 'Cloud', 'Golang'],
    exp: 'Fresher', posted: '2d ago',
    desc: 'Build and scale next-generation distributed systems that power Google products used by billions worldwide.',
  ),
  const Job(
    id: 2, logo: '🟡', title: 'Frontend Developer',
    company: 'Flipkart', location: 'Bengaluru',
    salary: '₹12–18 LPA', type: 'Full Time',
    match: 90, tags: ['React', 'TypeScript', 'CSS'],
    exp: 'Fresher', posted: '1d ago',
    desc: 'Craft exceptional user interfaces for India\'s largest e-commerce platform serving 400M+ customers.',
  ),
  const Job(
    id: 3, logo: '🔷', title: 'Data Analyst',
    company: 'Paytm', location: 'Noida',
    salary: '₹8–12 LPA', type: 'Full Time',
    match: 82, tags: ['SQL', 'Python', 'Tableau'],
    exp: '0–1 yr', posted: '3d ago',
    desc: 'Analyse financial data to drive product decisions at India\'s leading digital payments platform.',
  ),
  const Job(
    id: 4, logo: '🟢', title: 'Backend Engineer',
    company: 'Razorpay', location: 'Bengaluru',
    salary: '₹15–22 LPA', type: 'Remote',
    match: 88, tags: ['Go', 'Microservices', 'AWS'],
    exp: 'Fresher', posted: '5h ago',
    desc: 'Design and build robust payment APIs powering 8M+ businesses across India and Southeast Asia.',
  ),
  const Job(
    id: 5, logo: '🔴', title: 'ML Engineer',
    company: 'Ola', location: 'Bengaluru',
    salary: '₹18–26 LPA', type: 'Full Time',
    match: 79, tags: ['Python', 'TensorFlow', 'Spark'],
    exp: '0–1 yr', posted: '1d ago',
    desc: 'Build ML models that power route optimisation, demand forecasting, and driver-rider matching at scale.',
  ),
];

const List<String> kFilters = [
  'All', 'Full Time', 'Remote', 'Fresher', 'Bengaluru',
];

// ─────────────────────────────────────────────
//  JOBS SCREEN
// ─────────────────────────────────────────────

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with TickerProviderStateMixin {

  String     _filter = 'All';
  String     _search = '';
  final Set<int> _saved   = {2};
  final Set<int> _applied = {};

  late AnimationController _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};

  List<Job> get _filtered => kJobs.where((job) {
    final q = _search.toLowerCase();
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
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();

    for (int i = 0; i < kJobs.length; i++) {
      final c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 460),
      );
      _cardAnims[kJobs[i].id] = c;
      Future.delayed(Duration(milliseconds: 150 + i * 80), () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
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
                          color: Colors.white.withOpacity(0.10),
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
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    // Saved jobs button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SavedJobsPage(
                            jobs: kJobs,
                            savedIds: _saved.toList(),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark,
                                color: kAccent, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              '${_saved.length} Saved',
                              style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
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
                    _statPill('${kJobs.length}', 'Jobs'),
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
          Text(num,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  color: kAccent)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF94A3B8),
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
          prefixIcon: const Icon(Icons.search, color: kMuted, size: 20),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      decoration: BoxDecoration(
                        color: selected ? kPrimary : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? kPrimary : kBorder,
                          width: 1.5,
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
          // Results count
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              '${_filtered.length} jobs',
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
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
            const Text('No jobs found',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: kSlate)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() {
                _filter = 'All';
                _search = '';
              }),
              child: const Text('Clear filters',
                  style: TextStyle(
                      color: kPrimary, fontWeight: FontWeight.w700)),
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
      ),
    );
  }

  // ── APPLY MODAL ────────────────────────────

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
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40, height: 4,
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
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: kBgPage,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: kBorder),
                    ),
                    child: Center(
                      child: Text(job.logo,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
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
              const SizedBox(height: 20),
              _modalField(nameCtrl,  'Full Name',     Icons.person),
              const SizedBox(height: 12),
              _modalField(emailCtrl, 'Email Address', Icons.email),
              const SizedBox(height: 20),
              // Submit
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
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: Colors.white,
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

  Widget _modalField(
      TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: kMuted),
        prefixIcon: Icon(icon, color: kMuted, size: 18),
        filled: true,
        fillColor: kBgPage,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
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

  void _showAppliedSnack(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('Application sent to $company!',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  JOB CARD WIDGET
// ─────────────────────────────────────────────

class _JobCard extends StatefulWidget {
  final Job                 job;
  final bool                isSaved;
  final bool                isApplied;
  final AnimationController? ctrl;
  final VoidCallback        onSave;
  final VoidCallback        onApply;

  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    this.ctrl,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard>
    with SingleTickerProviderStateMixin {

  bool _btnPressed = false;
  late AnimationController _btnCtrl;
  late Animation<double>   _btnScale;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 140),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final ctrl = widget.ctrl;

    final fade  = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    // Match colour
    final matchColor = job.match >= 90
        ? kSuccess
        : job.match >= 80
        ? kWarning
        : kMuted;
    final matchBg = job.match >= 90
        ? const Color(0xFFF0FDF4)
        : job.match >= 80
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF1F5F9);

    final isRemote = job.type == 'Remote';

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TOP ROW ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo tile
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Center(
                        child: Text(job.logo,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.title,
                              style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: kInk,
                              )),
                          const SizedBox(height: 2),
                          Text(job.company,
                              style: const TextStyle(
                                  fontSize: 12, color: kMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: kHint),
                              const SizedBox(width: 3),
                              Text(job.location,
                                  style: const TextStyle(
                                      fontSize: 12, color: kMuted)),
                              const SizedBox(width: 8),
                              // Type pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isRemote
                                      ? const Color(0xFFF0FDF4)
                                      : kSelectedBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(job.type,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isRemote ? kSuccess : kPrimary,
                                    )),
                              ),
                              const SizedBox(width: 6),
                              // Posted
                              Text(job.posted,
                                  style: const TextStyle(
                                      fontSize: 10, color: kHint)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bookmark
                    GestureDetector(
                      onTap: widget.onSave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 34, height: 34,
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
                          size: 17,
                          color: widget.isSaved ? kPrimary : kHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── META CHIPS ───────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _chip(Icons.work_outline, job.exp),
                    const SizedBox(width: 7),
                    _chip(Icons.currency_rupee, job.salary,
                        iconColor: const Color(0xFF16A34A)),
                  ],
                ),
              ),

              // ── DESCRIPTION ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(job.desc,
                    style: const TextStyle(
                        fontSize: 12, color: kHint, height: 1.5)),
              ),

              // ── AI MATCH BAR ─────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 13, color: kWarning),
                        const SizedBox(width: 5),
                        const Text('AI Match',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: kMuted)),
                        const Spacer(),
                        Text('${job.match}%',
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: matchColor,
                            )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: job.match / 100,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                      ),
                    ),
                  ],
                ),
              ),

              // ── DIVIDER ──────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                height: 1, color: const Color(0xFFF1F5F9),
              ),

              // ── TAGS + APPLY ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6, runSpacing: 6,
                        children: job.tags
                            .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kSlate,
                              )),
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply button
                    GestureDetector(
                      onTapDown: widget.isApplied
                          ? null
                          : (_) {
                        _btnCtrl.forward();
                        setState(() => _btnPressed = true);
                      },
                      onTapUp: widget.isApplied
                          ? null
                          : (_) {
                        _btnCtrl.reverse();
                        setState(() => _btnPressed = false);
                        widget.onApply();
                      },
                      onTapCancel: () {
                        _btnCtrl.reverse();
                        setState(() => _btnPressed = false);
                      },
                      child: ScaleTransition(
                        scale: _btnScale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: widget.isApplied
                                ? const Color(0xFFF0FDF4)
                                : kPrimary,
                            borderRadius: BorderRadius.circular(30),
                            border: widget.isApplied
                                ? Border.all(
                                color: const Color(0xFF86EFAC),
                                width: 1.5)
                                : null,
                            boxShadow: widget.isApplied || _btnPressed
                                ? null
                                : [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.isApplied)
                                const Icon(Icons.check,
                                    size: 13, color: kSuccess),
                              if (widget.isApplied)
                                const SizedBox(width: 4),
                              Text(
                                widget.isApplied ? 'Applied!' : 'Apply Now',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800,
                                  color: widget.isApplied
                                      ? kSuccess
                                      : Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color iconColor = kHint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: kMuted)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SAVED JOBS PAGE
// ─────────────────────────────────────────────

class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;

  const SavedJobsPage({
    super.key,
    required this.jobs,
    required this.savedIds,
  });

  @override
  Widget build(BuildContext context) {
    final saved = jobs.where((j) => savedIds.contains(j.id)).toList();

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          // Header
          Container(
            color: kInk,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('Saved Jobs',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${saved.length} jobs',
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: kAccent,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: saved.isEmpty
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔖', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 12),
                  Text('No saved jobs yet',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: kSlate)),
                  SizedBox(height: 6),
                  Text('Bookmark jobs to view them here',
                      style: TextStyle(
                          fontSize: 13, color: kMuted)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: saved.length,
              itemBuilder: (_, i) {
                final job = saved[i];
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
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: kBgPage,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: kBorder),
                        ),
                        child: Center(
                          child: Text(job.logo,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
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
                            const SizedBox(height: 2),
                            Text(job.company,
                                style: const TextStyle(
                                    fontSize: 12, color: kMuted,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(job.salary,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kSuccess,
                                )),
                          ],
                        ),
                      ),
                      const Icon(Icons.bookmark,
                          color: kPrimary, size: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
