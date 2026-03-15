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
//  DATA
// ─────────────────────────────────────────────

const _recommended = [
  {
    'title':    'Frontend Developer',
    'company':  'TechNova India',
    'location': 'Bengaluru',
    'salary':   '₹8–12 LPA',
    'match':    '92',
    'logo':     '🔷',
    'type':     'Full Time',
    'tags':     ['React', 'TypeScript'],
  },
  {
    'title':    'ML Engineer Intern',
    'company':  'DataMind Labs',
    'location': 'Hyderabad',
    'salary':   '₹25K/month',
    'match':    '87',
    'logo':     '🟠',
    'type':     'Internship',
    'tags':     ['Python', 'TensorFlow'],
  },
  {
    'title':    'Backend Developer',
    'company':  'CloudSoft Systems',
    'location': 'Pune',
    'salary':   '₹6–9 LPA',
    'match':    '78',
    'logo':     '🟢',
    'type':     'Full Time',
    'tags':     ['Node.js', 'AWS'],
  },
];

const _nearby = [
  {'name': 'Infosys',  'city': 'Bengaluru', 'distance': '2.3 km', 'openings': '12', 'logo': '🔵'},
  {'name': 'Wipro',    'city': 'Hyderabad',  'distance': '5.1 km', 'openings': '8',  'logo': '🟡'},
  {'name': 'TCS',      'city': 'Chennai',    'distance': '7.8 km', 'openings': '20', 'logo': '🔴'},
];

const _stats = [
  {'icon': Icons.send_rounded,          'value': '14', 'label': 'Applied',       'color': Color(0xFF1D4ED8)},
  {'icon': Icons.star_rounded,          'value': '5',  'label': 'Shortlisted',   'color': Color(0xFFF59E0B)},
  {'icon': Icons.person_rounded,        'value': '72%','label': 'Profile Score', 'color': Color(0xFF16A34A)},
  {'icon': Icons.bookmark_rounded,      'value': '9',  'label': 'Saved Jobs',    'color': Color(0xFF7C3AED)},
];

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController _headerAnim;
  late AnimationController _xpAnim;
  late Animation<double>   _xpValue;

  late List<AnimationController> _sectionAnims;
  late List<Animation<double>>   _sectionFade;
  late List<Animation<Offset>>   _sectionSlide;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650),
    )..forward();

    _xpAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    );
    _xpValue = Tween<double>(begin: 0, end: 0.72).animate(
      CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut),
    );

    _sectionAnims = List.generate(6, (_) => AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480),
    ));
    _sectionFade  = _sectionAnims.map((c) =>
        CurvedAnimation(parent: c, curve: Curves.easeOut),
    ).toList();
    _sectionSlide = _sectionAnims.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        ),
    ).toList();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _xpAnim.forward();
    });
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 90), () {
        if (mounted) _sectionAnims[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _sectionAnims) c.dispose();
    super.dispose();
  }

  Widget _fs(int i, Widget child) => FadeTransition(
    opacity: _sectionFade[i],
    child: SlideTransition(position: _sectionSlide[i], child: child),
  );

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              children: [
                _fs(0, _buildStatsRow()),
                const SizedBox(height: 16),
                _fs(1, _buildProfileStrength()),
                const SizedBox(height: 22),
                _fs(2, _sectionLabel('Recommended for You')),
                const SizedBox(height: 10),
                _fs(2, _buildRecommended()),
                const SizedBox(height: 22),
                _fs(3, _sectionLabel('Companies Near You')),
                const SizedBox(height: 10),
                _fs(3, _buildNearby()),
                const SizedBox(height: 22),
                _fs(4, _buildCoursesCTA()),
              ],
            ),
          ),
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.22), width: 2),
                  ),
                  child: const Center(
                    child: Text('👨‍💻', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hey Arjun 👋',
                          style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: -0.3,
                          )),
                      Text(
                        'You have 3 new job matches today!',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.65)),
                      ),
                    ],
                  ),
                ),
                // Notification
                Stack(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white, size: 20),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: kAccent, shape: BoxShape.circle,
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

  // ── SEARCH BAR ─────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search jobs, companies, skills…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search_rounded,
              color: kMuted, size: 20),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded,
                color: kPrimary, size: 18),
          ),
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

  // ── STATS ROW ──────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: List.generate(_stats.length, (i) {
        final s = _stats[i];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: (s['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s['icon'] as IconData,
                      size: 16, color: s['color'] as Color),
                ),
                const SizedBox(height: 8),
                Text(s['value'] as String,
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: kInk,
                    )),
                Text(s['label'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: kMuted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── PROFILE STRENGTH ───────────────────────

  Widget _buildProfileStrength() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kInk,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile Strength',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    SizedBox(height: 3),
                    Text('Add certifications to reach 90%',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _xpValue,
                builder: (_, __) => Text(
                  '${(_xpValue.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: kAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedBuilder(
              animation: _xpValue,
              builder: (_, __) => LinearProgressIndicator(
                value: _xpValue.value,
                minHeight: 8,
                color: kAccent,
                backgroundColor: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Incomplete items
          Row(
            children: [
              _profileChip(Icons.workspace_premium_rounded,
                  'Add Certifications', false),
              const SizedBox(width: 8),
              _profileChip(Icons.link_rounded, 'Link GitHub', false),
              const SizedBox(width: 8),
              _profileChip(Icons.check_rounded, 'Skills Added', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileChip(IconData icon, String label, bool done) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFF16A34A).withOpacity(0.15)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: done
                ? const Color(0xFF16A34A).withOpacity(0.4)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12,
                color: done ? kSuccess : const Color(0xFF94A3B8)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: done
                        ? kSuccess
                        : const Color(0xFF94A3B8),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION LABEL ──────────────────────────

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800, color: kInk,
      ));

  // ── RECOMMENDED JOBS ───────────────────────

  Widget _buildRecommended() {
    return Column(
      children: List.generate(_recommended.length, (i) {
        final job = _recommended[i];
        return _JobCard(job: job, index: i);
      }),
    );
  }

  // ── NEARBY COMPANIES ───────────────────────

  Widget _buildNearby() {
    return Column(
      children: _nearby.map((c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Center(
                  child: Text(c['logo']!,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name']!,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: kHint),
                        const SizedBox(width: 3),
                        Text(c['city']!,
                            style: const TextStyle(
                                fontSize: 12, color: kMuted)),
                        const SizedBox(width: 8),
                        const Icon(Icons.near_me_rounded,
                            size: 11, color: kHint),
                        const SizedBox(width: 3),
                        Text(c['distance']!,
                            style: const TextStyle(
                                fontSize: 12, color: kMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline_rounded,
                        size: 12, color: kPrimary),
                    const SizedBox(width: 5),
                    Text(
                      '${c['openings']} open',
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── COURSES CTA ────────────────────────────

  Widget _buildCoursesCTA() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kInk,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Boost your profile',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                const SizedBox(height: 4),
                Text(
                  'Get certified and stand out to recruiters.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ctaTag('🤖 AI/ML'),
                    const SizedBox(width: 6),
                    _ctaTag('🌐 Web Dev'),
                    const SizedBox(width: 6),
                    _ctaTag('☁️ Cloud'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.school_rounded,
                      color: Colors.white, size: 22),
                  SizedBox(height: 5),
                  Text('Explore',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label,
        style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: Colors.white70,
        )),
  );
}

// ─────────────────────────────────────────────
//  JOB CARD WIDGET
// ─────────────────────────────────────────────

class _JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final int index;
  const _JobCard({required this.job, required this.index});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 + widget.index * 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final job     = widget.job;
    final match   = int.tryParse(job['match'] as String) ?? 0;
    final isIntern = (job['type'] as String) == 'Internship';
    final tags    = job['tags'] as List<String>;

    // Match colour
    final matchColor = match >= 90
        ? kSuccess
        : match >= 80
        ? kWarning
        : kMuted;
    final matchBg = match >= 90
        ? const Color(0xFFF0FDF4)
        : match >= 80
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF1F5F9);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: kBgPage,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder),
                    ),
                    child: Center(
                      child: Text(job['logo']!,
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['title']!,
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                        const SizedBox(height: 2),
                        Text(job['company']!,
                            style: const TextStyle(
                                fontSize: 12, color: kMuted,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: kHint),
                            const SizedBox(width: 3),
                            Text(job['location']!,
                                style: const TextStyle(
                                    fontSize: 12, color: kMuted)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isIntern
                                    ? const Color(0xFFFFFBEB)
                                    : kSelectedBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(job['type']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isIntern
                                        ? kWarning
                                        : kPrimary,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _saved = !_saved);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: _saved ? kSelectedBg : kBgPage,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _saved ? kPrimary : kBorder,
                        ),
                      ),
                      child: Icon(
                        _saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 17,
                        color: _saved ? kPrimary : kHint,
                      ),
                    ),
                  ),
                ],
              ),
              // Divider
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 1, color: const Color(0xFFF1F5F9),
              ),
              // Bottom row
              Row(
                children: [
                  // Tags
                  ...tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder),
                    ),
                    child: Text(t,
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: kSlate,
                        )),
                  )),
                  const Spacer(),
                  // Salary
                  Text(job['salary']!,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: kInk,
                      )),
                  const SizedBox(width: 10),
                  // Match badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: matchBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${job['match']}% match',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: matchColor,
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
}