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

const _skills = [
  {'name': 'React',      'level': 0.85},
  {'name': 'Python',     'level': 0.78},
  {'name': 'TypeScript', 'level': 0.72},
  {'name': 'Node.js',    'level': 0.68},
  {'name': 'SQL',        'level': 0.80},
];

const _certifications = [
  {
    'name':   'AWS Cloud Practitioner',
    'issuer': 'Amazon Web Services',
    'date':   'Mar 2024',
    'icon':   '☁️',
  },
  {
    'name':   'Python for Data Science',
    'issuer': 'Coursera – IBM',
    'date':   'Jan 2024',
    'icon':   '🐍',
  },
  {
    'name':   'Google UX Design Certificate',
    'issuer': 'Google – Coursera',
    'date':   'Nov 2023',
    'icon':   '🎨',
  },
];

const _projects = [
  {
    'title': 'CareerBridge App',
    'desc':  'Full-stack job portal with AI-powered skill matching algorithm.',
    'tech':  ['React', 'Node.js', 'MongoDB'],
    'link':  'github.com/arjun/careerbridge',
  },
  {
    'title': 'ML Price Predictor',
    'desc':  'House price prediction model using regression and ensemble methods.',
    'tech':  ['Python', 'Flask', 'Scikit-learn'],
    'link':  'github.com/arjun/ml-predictor',
  },
  {
    'title': 'DevConnect',
    'desc':  'Real-time developer networking app with live code-sharing rooms.',
    'tech':  ['Next.js', 'Socket.io', 'PostgreSQL'],
    'link':  'github.com/arjun/devconnect',
  },
];

const _applications = [
  {
    'role':    'Frontend Developer',
    'company': 'Flipkart',
    'status':  'Shortlisted',
    'logo':    '🟡',
    'date':    '2d ago',
  },
  {
    'role':    'ML Intern',
    'company': 'Microsoft Research',
    'status':  'Applied',
    'logo':    '🔵',
    'date':    '5d ago',
  },
  {
    'role':    'Backend Engineer',
    'company': 'Razorpay',
    'status':  'Viewed',
    'logo':    '💙',
    'date':    '1w ago',
  },
];

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  late TabController _tabCtrl;
  late AnimationController _headerAnim;
  late AnimationController _xpAnim;
  late Animation<double>   _xpValue;

  // Per-skill bar animation
  late List<AnimationController> _skillAnims;

  @override
  void initState() {
    super.initState();

    _tabCtrl = TabController(length: 5, vsync: this);

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650),
    )..forward();

    _xpAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    );
    _xpValue = Tween<double>(begin: 0, end: 0.72).animate(
      CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut),
    );

    _skillAnims = List.generate(_skills.length, (i) =>
        AnimationController(
          vsync: this, duration: const Duration(milliseconds: 900),
        ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _xpAnim.forward();
    });

    // Trigger skill bars when Skills tab is tapped
    _tabCtrl.addListener(() {
      if (_tabCtrl.index == 1) {
        for (int i = 0; i < _skillAnims.length; i++) {
          Future.delayed(Duration(milliseconds: i * 100), () {
            if (mounted) _skillAnims[i].forward();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _headerAnim.dispose();
    _xpAnim.dispose();
    for (final c in _skillAnims) c.dispose();
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
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildOverview(),
                _buildSkills(),
                _buildCertifications(),
                _buildProjects(),
                _buildApplications(),
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
          child: Column(
            children: [
              // Top row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
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
                    const Spacer(),
                    const Text('My Profile',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                    const Spacer(),
                    // Edit button
                    GestureDetector(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit,
                            color: kAccent, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Avatar + name
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 3),
                ),
                child: const Center(
                  child: Text('A',
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Arjun Patel',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -0.3,
                  )),
              const SizedBox(height: 4),
              Text(
                'B.Tech Computer Science  •  3rd Year',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65)),
              ),
              const SizedBox(height: 2),
              Text('SRM Institute of Technology',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.50))),
              const SizedBox(height: 20),
              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _headerStat('3', 'Applications'),
                    _vDivider(),
                    _headerStat('5', 'Skills'),
                    _vDivider(),
                    _headerStat('3', 'Certifications'),
                    _vDivider(),
                    _headerStat('3', 'Projects'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Profile strength bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Profile Strength',
                            style: TextStyle(
                                fontSize: 12, color: kHint,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _xpValue,
                          builder: (_, __) => Text(
                            '${(_xpValue.value * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              color: kAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedBuilder(
                        animation: _xpValue,
                        builder: (_, __) => LinearProgressIndicator(
                          value: _xpValue.value,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(kAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add GitHub profile & 2 more skills to reach 90%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: Colors.white.withOpacity(0.50),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _vDivider() => Container(
    width: 1, height: 30,
    color: Colors.white.withOpacity(0.12),
  );

  // ── TAB BAR ────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: kCardBg,
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        labelColor: kPrimary,
        unselectedLabelColor: kMuted,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
        indicatorColor: kPrimary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Skills'),
          Tab(text: 'Certs'),
          Tab(text: 'Projects'),
          Tab(text: 'Applications'),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TAB 1 — OVERVIEW
  // ─────────────────────────────────────────

  Widget _buildOverview() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // About card
        _sectionCard(
          title: 'About Me',
          icon: Icons.person,
          child: const Text(
            'Passionate full-stack developer with interest in AI/ML. '
                'Looking for internships to build scalable systems and '
                'contribute to products that impact millions.',
            style: TextStyle(
                fontSize: 13, color: kSlate, height: 1.6),
          ),
        ),
        const SizedBox(height: 14),
        // Details card
        _sectionCard(
          title: 'Details',
          icon: Icons.info,
          child: Column(
            children: [
              _detailRow(Icons.school,    'SRM Institute of Technology'),
              _detailRow(Icons.location_on, 'Chennai, Tamil Nadu'),
              _detailRow(Icons.email,     'arjun.patel@srmist.edu.in'),
              _detailRow(Icons.phone,     '+91 98765 43210'),
              _detailRow(Icons.link,      'linkedin.com/in/arjunpatel'),
              _detailRow(Icons.code,      'github.com/arjun',
                  isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Quick skills preview
        _sectionCard(
          title: 'Top Skills',
          icon: Icons.auto_awesome,
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: _skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kSelectedBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Text(s['name'] as String,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: kPrimary,
                  )),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String value,
      {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: kPrimary),
          const SizedBox(width: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: kSlate,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TAB 2 — SKILLS
  // ─────────────────────────────────────────

  Widget _buildSkills() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          title: 'Technical Skills',
          icon: Icons.code,
          child: Column(
            children: List.generate(_skills.length, (i) {
              final skill  = _skills[i];
              final name   = skill['name'] as String;
              final target = skill['level'] as double;
              final pct    = (target * 100).toInt();

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _skillAnims[i],
                          builder: (_, __) => Text(
                            '${(_skillAnims[i].value * pct).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedBuilder(
                        animation: _skillAnims[i],
                        builder: (_, __) => LinearProgressIndicator(
                          value: _skillAnims[i].value * target,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(kPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        // Add skill CTA
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: kPrimary.withOpacity(0.4),
                  width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: kPrimary, size: 18),
                SizedBox(width: 8),
                Text('Add a skill',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: kPrimary,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  TAB 3 — CERTIFICATIONS
  // ─────────────────────────────────────────

  Widget _buildCertifications() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._certifications.map((cert) => Container(
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
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: const Color(0xFFFDE68A), width: 1.5),
                ),
                child: Center(
                  child: Text(cert['icon']!,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert['name']!,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                    const SizedBox(height: 3),
                    Text(cert['issuer']!,
                        style: const TextStyle(
                            fontSize: 12, color: kMuted,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFFDE68A), width: 1),
                ),
                child: Text(cert['date']!,
                    style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    )),
              ),
            ],
          ),
        )),
        const SizedBox(height: 4),
        // Upload CTA
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: kPrimary.withOpacity(0.4), width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: kPrimary, size: 18),
                SizedBox(width: 8),
                Text('Upload certificate',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: kPrimary,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  TAB 4 — PROJECTS
  // ─────────────────────────────────────────

  Widget _buildProjects() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._projects.map((project) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
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
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: kSelectedBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.folder,
                        color: kPrimary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(project['title'] as String,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                  ),
                  const Icon(Icons.open_in_new,
                      size: 16, color: kHint),
                ],
              ),
              const SizedBox(height: 10),
              Text(project['desc'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: kMuted, height: 1.5)),
              const SizedBox(height: 10),
              // GitHub link
              Row(
                children: [
                  const Icon(Icons.link, size: 12, color: kHint),
                  const SizedBox(width: 4),
                  Text(project['link'] as String,
                      style: const TextStyle(
                        fontSize: 11, color: kPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
              const SizedBox(height: 10),
              // Tech tags
              Wrap(
                spacing: 7, runSpacing: 6,
                children: (project['tech'] as List<String>)
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
            ],
          ),
        )),
        // Add project CTA
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: kPrimary.withOpacity(0.4), width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: kPrimary, size: 18),
                SizedBox(width: 8),
                Text('Add a project',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: kPrimary,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  TAB 5 — APPLICATIONS
  // ─────────────────────────────────────────

  Widget _buildApplications() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _applications.map((app) {
        final status = app['status'] as String;

        // Status style
        Color statusBg, statusFg;
        IconData statusIcon;
        switch (status) {
          case 'Shortlisted':
            statusBg = const Color(0xFFF0FDF4);
            statusFg = kSuccess;
            statusIcon = Icons.check_circle;
            break;
          case 'Viewed':
            statusBg = const Color(0xFFFFFBEB);
            statusFg = kWarning;
            statusIcon = Icons.visibility;
            break;
          default:
            statusBg = kSelectedBg;
            statusFg = kPrimary;
            statusIcon = Icons.send;
        }

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
              // Logo
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: kBorder),
                ),
                child: Center(
                  child: Text(app['logo'] as String,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app['role'] as String,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                    const SizedBox(height: 2),
                    Text(app['company'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: kMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(app['date'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: kHint)),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusFg),
                    const SizedBox(width: 5),
                    Text(status,
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: statusFg,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: kPrimary, size: 15),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: kInk,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

