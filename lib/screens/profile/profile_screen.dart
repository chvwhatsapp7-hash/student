import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════
//  DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════
//  GLOBAL PROFILE STATE
//  ChangeNotifier so any screen can call profileState.addApplication()
//  and the profile page rebuilds automatically.
//  In production: inject via Provider / Riverpod.
// ═══════════════════════════════════════════════════════════════

class ProfileState extends ChangeNotifier {

  // ── Basic info ──────────────────────────────
  String name     = 'Arjun Patel';
  String degree   = 'B.Tech Computer Science  •  3rd Year';
  String college  = 'SRM Institute of Technology';
  String location = 'Chennai, Tamil Nadu';
  String email    = 'arjun.patel@srmist.edu.in';
  String phone    = '+91 98765 43210';
  String linkedin = 'linkedin.com/in/arjunpatel';
  String github   = 'github.com/arjun';
  String about    =
      'Passionate full-stack developer with interest in AI/ML. '
      'Looking for internships to build scalable systems and '
      'contribute to products that impact millions.';

  // ── Resume ──────────────────────────────────
  String resumeName = '';   // empty = not uploaded

  // ── Skills ──────────────────────────────────
  List<Map<String, dynamic>> skills = [
    {'name': 'React',      'level': 0.85},
    {'name': 'Python',     'level': 0.78},
    {'name': 'TypeScript', 'level': 0.72},
    {'name': 'Node.js',    'level': 0.68},
    {'name': 'SQL',        'level': 0.80},
  ];

  // ── Certifications ───────────────────────────
  List<Map<String, String>> certifications = [
    {'name': 'AWS Cloud Practitioner',       'issuer': 'Amazon Web Services', 'date': 'Mar 2024'},
    {'name': 'Python for Data Science',      'issuer': 'Coursera – IBM',      'date': 'Jan 2024'},
    {'name': 'Google UX Design Certificate', 'issuer': 'Google – Coursera',   'date': 'Nov 2023'},
  ];

  // ── Projects ────────────────────────────────
  List<Map<String, dynamic>> projects = [
    {'title': 'CareerBridge App',   'desc': 'Full-stack job portal with AI-powered skill matching.',      'tech': ['React', 'Node.js', 'MongoDB'],        'link': 'github.com/arjun/careerbridge'},
    {'title': 'ML Price Predictor', 'desc': 'House price prediction model using regression & ensembles.', 'tech': ['Python', 'Flask', 'Scikit-learn'],    'link': 'github.com/arjun/ml-predictor'},
    {'title': 'DevConnect',         'desc': 'Real-time dev networking app with live code-sharing rooms.', 'tech': ['Next.js', 'Socket.io', 'PostgreSQL'], 'link': 'github.com/arjun/devconnect'},
  ];

  // ── Applications — fed by Jobs & Internships ─
  List<Map<String, String>> applications = [
    {'role': 'Frontend Developer', 'company': 'Flipkart',          'status': 'Shortlisted', 'date': '2d ago', 'type': 'Job'},
    {'role': 'ML Intern',          'company': 'Microsoft Research', 'status': 'Applied',     'date': '5d ago', 'type': 'Internship'},
    {'role': 'Backend Engineer',   'company': 'Razorpay',          'status': 'Viewed',      'date': '1w ago', 'type': 'Job'},
  ];

  // ── Profile strength ────────────────────────
  double get strength {
    double s = 0.30;
    if (about.length > 30)           s += 0.08;
    if (resumeName.isNotEmpty)       s += 0.15;
    if (skills.length >= 3)          s += 0.10;
    if (skills.length >= 5)          s += 0.05;
    if (certifications.isNotEmpty)   s += 0.10;
    if (projects.isNotEmpty)         s += 0.08;
    if (github.isNotEmpty)           s += 0.07;
    if (linkedin.isNotEmpty)         s += 0.07;
    return s.clamp(0.0, 1.0);
  }

  String get strengthHint {
    if (resumeName.isEmpty)          return 'Upload your resume (+15%)';
    if (skills.length < 5)           return 'Add ${5 - skills.length} more skills (+5%)';
    if (certifications.isEmpty)      return 'Add a certification (+10%)';
    if (github.isEmpty)              return 'Link your GitHub (+7%)';
    return '🎉 Profile is looking great!';
  }

  // ── Mutators — call these from other screens ─
  void set(VoidCallback fn) { fn(); notifyListeners(); }

  /// Called by Jobs & Internships screens after applying
  void addApplication(String role, String company, {String type = 'Job'}) {
    final already = applications.any(
            (a) => a['role'] == role && a['company'] == company);
    if (!already) {
      applications.insert(0, {
        'role':    role,
        'company': company,
        'status':  'Applied',
        'date':    'Just now',
        'type':    type,
      });
      notifyListeners();
    }
  }
}

/// Singleton — import and use anywhere in the app
final profileState = ProfileState();

// ═══════════════════════════════════════════════════════════════
//  CERT ICON RESOLVER — design only
// ═══════════════════════════════════════════════════════════════

class _CertTheme {
  final IconData icon;
  final Color    g1, g2, bg;
  const _CertTheme(this.icon, this.g1, this.g2, this.bg);
}

_CertTheme _certTheme(String name) {
  final n = name.toLowerCase();
  if (n.contains('aws') || n.contains('cloud'))
    return const _CertTheme(Icons.cloud,            Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFFF0F9FF));
  if (n.contains('python') || n.contains('data science'))
    return const _CertTheme(Icons.code,             Color(0xFF1D4ED8), Color(0xFFF59E0B), Color(0xFFFFFBEB));
  if (n.contains('ux') || n.contains('design'))
    return const _CertTheme(Icons.brush,            Color(0xFFEC4899), Color(0xFFF43F5E), Color(0xFFFFF1F2));
  if (n.contains('machine') || n.contains('ai') || n.contains('ml'))
    return const _CertTheme(Icons.psychology,       Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFF5F3FF));
  if (n.contains('google'))
    return const _CertTheme(Icons.search,           Color(0xFF1D4ED8), Color(0xFF16A34A), Color(0xFFF0FDF4));
  if (n.contains('security') || n.contains('cyber'))
    return const _CertTheme(Icons.shield,           Color(0xFFB91C1C), Color(0xFFDC2626), Color(0xFFFFF1F2));
  if (n.contains('react') || n.contains('frontend'))
    return const _CertTheme(Icons.web,              Color(0xFF0EA5E9), Color(0xFF38BDF8), Color(0xFFEFF6FF));
  return const _CertTheme(Icons.workspace_premium,  Color(0xFFB45309), Color(0xFFD97706), Color(0xFFFFFBEB));
}

// ═══════════════════════════════════════════════════════════════
//  PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  late TabController             _tab;
  late AnimationController       _headerAnim;
  late AnimationController       _xpAnim;
  late Animation<double>         _xpVal;
  late List<AnimationController> _skillAnims;

  @override
  void initState() {
    super.initState();
    _tab        = TabController(length: 5, vsync: this);
    _headerAnim = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700))..forward();
    _xpAnim = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800));
    _xpVal  = _buildXpTween();

    _skillAnims = List.generate(profileState.skills.length, (_) =>
        AnimationController(vsync: this,
            duration: const Duration(milliseconds: 900)));

    Future.delayed(const Duration(milliseconds: 350),
            () { if (mounted) _xpAnim.forward(); });

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
  }

  Animation<double> _buildXpTween() =>
      Tween<double>(begin: 0, end: profileState.strength)
          .animate(CurvedAnimation(parent: _xpAnim, curve: Curves.easeOut));

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {
      _xpAnim.reset();
      _xpVal = _buildXpTween();
      _xpAnim.forward();
      // Sync skill animators count
      while (_skillAnims.length < profileState.skills.length) {
        final c = AnimationController(vsync: this,
            duration: const Duration(milliseconds: 900))..forward();
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

  // ────────────────────────────────────────────
  //  ROOT BUILD
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profileState,
      builder: (_, __) => Scaffold(
        backgroundColor: kBgPage,
        body: Column(
          children: [
            _header(),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _overview(),
                  _skills(),
                  _certs(),
                  _projectsTab(),
                  _applicationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════

  Widget _header() {
    final p = profileState;
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1E), Color(0xFF0F172A), Color(0xFF1A2035)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [

              // ── Top bar ────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    _iconBtn(Icons.arrow_back_ios_new,
                            () => Navigator.maybePop(context)),
                    const Spacer(),
                    const Text('My Profile',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800, color: Colors.white)),
                    const Spacer(),
                    _iconBtn(Icons.edit, _editBasicInfo,
                        bg: kPrimary.withOpacity(0.45),
                        iconColor: kAccent),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Avatar ─────────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 86, height: 86,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25), width: 3),
                      boxShadow: [
                        BoxShadow(color: kPrimary.withOpacity(0.45),
                            blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : 'A',
                        style: const TextStyle(fontSize: 36,
                            fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _editBasicInfo,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: kAccent, shape: BoxShape.circle,
                        border: Border.all(color: kInk, width: 2.5),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Name ───────────────────────
              Text(p.name,
                  style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w900, color: Colors.white,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(p.degree,
                  style: TextStyle(fontSize: 12,
                      color: Colors.white.withOpacity(0.65))),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 11,
                      color: Colors.white.withOpacity(0.40)),
                  const SizedBox(width: 4),
                  Text(p.college,
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.40))),
                ],
              ),
              const SizedBox(height: 20),

              // ── Stats card ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.10), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _hStat('${p.applications.length}', 'Applied',   Icons.send),
                      _hDiv(),
                      _hStat('${p.skills.length}',       'Skills',    Icons.code),
                      _hDiv(),
                      _hStat('${p.certifications.length}', 'Certs',   Icons.workspace_premium),
                      _hDiv(),
                      _hStat('${p.projects.length}',     'Projects',  Icons.folder),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Strength bar ───────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, size: 13, color: kAccent),
                        const SizedBox(width: 5),
                        const Text('Profile Strength',
                            style: TextStyle(fontSize: 12,
                                color: kHint, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _xpVal,
                          builder: (_, __) => Text(
                            '${(_xpVal.value * 100).toInt()}%',
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w900, color: kAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedBuilder(
                        animation: _xpVal,
                        builder: (_, __) => LinearProgressIndicator(
                          value: _xpVal.value,
                          minHeight: 7,
                          backgroundColor: Colors.white.withOpacity(0.10),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(kAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(p.strengthHint,
                        style: TextStyle(fontSize: 11,
                            color: Colors.white.withOpacity(0.40),
                            fontStyle: FontStyle.italic)),
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

  Widget _hStat(String v, String l, IconData ic) => Column(
    children: [
      Icon(ic, size: 14, color: kAccent),
      const SizedBox(height: 5),
      Text(v, style: const TextStyle(fontSize: 18,
          fontWeight: FontWeight.w900, color: Colors.white)),
      const SizedBox(height: 2),
      Text(l, style: TextStyle(fontSize: 9,
          color: Colors.white.withOpacity(0.50), fontWeight: FontWeight.w600)),
    ],
  );

  Widget _hDiv() => Container(width: 1, height: 36,
      color: Colors.white.withOpacity(0.10));

  Widget _iconBtn(IconData icon, VoidCallback onTap,
      {Color? bg, Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: bg ?? Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  TAB BAR
  // ════════════════════════════════════════════

  Widget _tabBar() => Container(
    color: kCardBg,
    child: TabBar(
      controller: _tab,
      isScrollable: true,
      labelColor: kPrimary,
      unselectedLabelColor: kMuted,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

  // ════════════════════════════════════════════
  //  TAB 1 — OVERVIEW
  // ════════════════════════════════════════════

  Widget _overview() {
    final p = profileState;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // About Me
        _card(
          title: 'About Me', icon: Icons.person,
          onEdit: () => _textDialog('About Me', p.about, 5,
                  (v) => profileState.set(() => p.about = v)),
          child: Text(p.about,
              style: const TextStyle(fontSize: 13, color: kSlate, height: 1.6)),
        ),
        const SizedBox(height: 14),

        // Resume upload
        _resumeCard(),
        const SizedBox(height: 14),

        // Contact
        _card(
          title: 'Contact & Links', icon: Icons.contact_page,
          onEdit: _editContactSheet,
          child: Column(children: [
            _dRow(Icons.school,    p.college,  'College'),
            _dRow(Icons.location_on, p.location, 'Location'),
            _dRow(Icons.email,     p.email,    'Email'),
            _dRow(Icons.phone,     p.phone,    'Phone'),
            _dRow(Icons.link,      p.linkedin, 'LinkedIn'),
            _dRow(Icons.code,      p.github,   'GitHub', last: true),
          ]),
        ),
        const SizedBox(height: 14),

        // Top skills preview
        _card(
          title: 'Top Skills', icon: Icons.auto_awesome,
          onEdit: () => _tab.animateTo(1),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: p.skills.map((s) {
              final pct = ((s['level'] as double) * 100).toInt();
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${s['name']}  $pct%',
                    style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w800, color: Colors.white)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Resume card
  Widget _resumeCard() {
    final p = profileState;
    final has = p.resumeName.isNotEmpty;
    return GestureDetector(
      onTap: _uploadResume,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: has
              ? LinearGradient(colors: [
            kPrimary.withOpacity(0.07),
            const Color(0xFF4F46E5).withOpacity(0.03),
          ])
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
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, Color(0xFF4F46E5)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: kPrimary.withOpacity(0.30),
                      blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.description,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    has ? 'Resume Uploaded ✓' : 'Upload Your Resume',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: has ? kSuccess : kInk),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    has ? p.resumeName : 'PDF or DOC  •  Max 5MB',
                    style: const TextStyle(fontSize: 12, color: kMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: has ? const Color(0xFFF0FDF4) : kPrimary,
                borderRadius: BorderRadius.circular(20),
                border: has ? Border.all(
                    color: const Color(0xFF86EFAC), width: 1.5) : null,
              ),
              child: Text(has ? 'Replace' : 'Upload',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: has ? kSuccess : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dRow(IconData icon, String val, String lbl,
      {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(width: 28, height: 28,
              decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: kPrimary)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lbl, style: const TextStyle(
                  fontSize: 10, color: kHint, fontWeight: FontWeight.w600)),
              Text(val, style: const TextStyle(
                  fontSize: 13, color: kSlate, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  TAB 2 — SKILLS
  // ════════════════════════════════════════════

  Widget _skills() {
    final p = profileState;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(
          title: 'Technical Skills', icon: Icons.code, onEdit: null,
          child: Column(
            children: List.generate(p.skills.length, (i) {
              if (i >= _skillAnims.length) return const SizedBox();
              final sk     = p.skills[i];
              final name   = sk['name'] as String;
              final target = sk['level'] as double;
              final pct    = (target * 100).toInt();
              // colour by level
              final barCol = target >= 0.80 ? kSuccess
                  : target >= 0.60 ? kPrimary : kWarning;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800,
                                color: kInk)),
                      ),
                      AnimatedBuilder(
                        animation: _skillAnims[i],
                        builder: (_, __) => Text(
                          '${(_skillAnims[i].value * pct).toInt()}%',
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w800, color: barCol),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            profileState.set(() => p.skills.removeAt(i)),
                        child: const Icon(Icons.remove_circle_outline,
                            size: 16, color: kHint),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedBuilder(
                        animation: _skillAnims[i],
                        builder: (_, __) => LinearProgressIndicator(
                          value: _skillAnims[i].value * target,
                          minHeight: 9,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(barCol),
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
        _addCta(Icons.add_circle, 'Add a Skill', _addSkillDialog),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  TAB 3 — CERTS
  // ════════════════════════════════════════════

  Widget _certs() {
    final p = profileState;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...p.certifications.asMap().entries.map((e) {
          final i  = e.key;
          final c  = e.value;
          final ct = _certTheme(c['name']!);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [ct.g1, ct.g2]),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ct.g1, ct.g2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                          color: ct.g1.withOpacity(0.28),
                          blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Icon(ct.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name']!,
                              style: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w800, color: kInk)),
                          const SizedBox(height: 3),
                          Text(c['issuer']!,
                              style: const TextStyle(fontSize: 12,
                                  color: kMuted, fontWeight: FontWeight.w600)),
                        ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: ct.bg, borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: ct.g1.withOpacity(0.30)),
                          ),
                          child: Text(c['date']!,
                              style: TextStyle(fontSize: 10,
                                  fontWeight: FontWeight.w700, color: ct.g1)),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => profileState.set(
                                  () => p.certifications.removeAt(i)),
                          child: const Icon(Icons.delete_outline,
                              size: 15, color: kHint),
                        ),
                      ]),
                ]),
              ),
            ]),
          );
        }),
        const SizedBox(height: 4),
        _addCta(Icons.upload_file, 'Add / Upload Certificate', _addCertDialog),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  TAB 4 — PROJECTS
  // ════════════════════════════════════════════

  Widget _projectsTab() {
    final p = profileState;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...p.projects.asMap().entries.map((e) {
          final i = e.key;
          final proj = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(children: [
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [kPrimary, Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            kPrimary.withOpacity(0.14),
                            const Color(0xFF4F46E5).withOpacity(0.07),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: kPrimary.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.folder,
                            color: kPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(proj['title'] as String,
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w800, color: kInk)),
                      ),
                      GestureDetector(
                        onTap: () => _editProjectDialog(i),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: kSelectedBg,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.edit,
                              size: 14, color: kPrimary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => profileState.set(
                                () => p.projects.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete_outline,
                              size: 14, color: Color(0xFFDC2626)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(proj['desc'] as String,
                        style: const TextStyle(fontSize: 12,
                            color: kMuted, height: 1.5)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.link, size: 12, color: kHint),
                      const SizedBox(width: 4),
                      Text(proj['link'] as String,
                          style: const TextStyle(fontSize: 11,
                              color: kPrimary, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7, runSpacing: 6,
                      children: (proj['tech'] as List<String>)
                          .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSelectedBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(t,
                            style: const TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kPrimary)),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ]),
          );
        }),
        _addCta(Icons.add_circle, 'Add a Project', _addProjectDialog),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  TAB 5 — APPLICATIONS (live cross-page sync)
  // ════════════════════════════════════════════

  Widget _applicationsTab() {
    final apps = profileState.applications;

    if (apps.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(
                color: kSelectedBg, shape: BoxShape.circle),
            child: const Icon(Icons.work_off_outlined,
                color: kPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('No applications yet',
              style: TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: kSlate)),
          const SizedBox(height: 6),
          const Text('Apply to jobs & internships\nto see them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kMuted)),
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live sync banner
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              kPrimary.withOpacity(0.08),
              const Color(0xFF4F46E5).withOpacity(0.04),
            ]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimary.withOpacity(0.20)),
          ),
          child: Row(children: [
            const Icon(Icons.sync, size: 14, color: kPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live sync from Jobs & Internships  •  ${apps.length} applications',
                style: const TextStyle(fontSize: 11,
                    color: kPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ),

        ...apps.map((app) {
          final status = app['status']!;
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

          final isJob = (app['type'] ?? 'Job') == 'Job';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Column(children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: statusFg.withOpacity(0.50),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        statusFg.withOpacity(0.15),
                        statusFg.withOpacity(0.05),
                      ]),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: statusFg.withOpacity(0.25)),
                    ),
                    child: Icon(
                      isJob ? Icons.work_outline : Icons.school_outlined,
                      color: statusFg, size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app['role']!,
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w800, color: kInk)),
                        const SizedBox(height: 2),
                        Text(app['company']!,
                            style: const TextStyle(fontSize: 12,
                                color: kMuted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isJob ? kSelectedBg
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isJob ? 'Job' : 'Internship',
                              style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w800,
                                color: isJob ? kPrimary : kSuccess,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(app['date']!,
                              style: const TextStyle(
                                  fontSize: 11, color: kHint)),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(statusIcon, size: 12, color: statusFg),
                      const SizedBox(width: 5),
                      Text(status,
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusFg)),
                    ]),
                  ),
                ]),
              ),
            ]),
          );
        }),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  SHARED WIDGETS
  // ════════════════════════════════════════════

  Widget _card({
    required String   title,
    required IconData icon,
    required Widget   child,
    VoidCallback?     onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [kPrimary, Color(0xFF4F46E5)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w800, color: kInk)),
          const Spacer(),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit, size: 12, color: kPrimary),
                  SizedBox(width: 4),
                  Text('Edit', style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: kPrimary)),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _addCta(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            kPrimary.withOpacity(0.07),
            const Color(0xFF4F46E5).withOpacity(0.03),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: kPrimary.withOpacity(0.35), width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: kPrimary, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w800, color: kPrimary)),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  EDIT FLOWS
  // ════════════════════════════════════════════

  // Generic bottom sheet editor
  void _sheet({
    required String             title,
    required IconData           icon,
    required List<_FieldCfg>    fields,
    required VoidCallback       onSave,
  }) {
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w800, color: kInk)),
            ]),
            const SizedBox(height: 18),
            ...fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: f.ctrl,
                maxLines: f.maxLines,
                style: const TextStyle(fontSize: 13, color: kInk),
                decoration: InputDecoration(
                  labelText: f.label,
                  labelStyle: const TextStyle(color: kMuted, fontSize: 13),
                  prefixIcon: Icon(f.icon, color: kMuted, size: 18),
                  filled: true, fillColor: kBgPage,
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
            )),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () { onSave(); Navigator.pop(context); },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: kPrimary.withOpacity(0.28),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Center(
                  child: Text('Save Changes',
                      style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Simple text dialog
  void _textDialog(String title, String initial, int maxLines,
      Function(String) onSave) {
    final ctrl = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Edit $title',
                style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 13, color: kInk),
              decoration: InputDecoration(
                filled: true, fillColor: kBgPage,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Cancel',
                        style: TextStyle(color: kMuted,
                            fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onSave(ctrl.text.trim());
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Save',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w800))),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _editBasicInfo() {
    final p   = profileState;
    final n   = TextEditingController(text: p.name);
    final dg  = TextEditingController(text: p.degree);
    final co  = TextEditingController(text: p.college);
    _sheet(
      title: 'Edit Profile', icon: Icons.person,
      fields: [
        _FieldCfg(n,  'Full Name',    Icons.badge),
        _FieldCfg(dg, 'Degree & Year', Icons.school),
        _FieldCfg(co, 'College',      Icons.account_balance),
      ],
      onSave: () => profileState.set(() {
        p.name    = n.text.trim();
        p.degree  = dg.text.trim();
        p.college = co.text.trim();
      }),
    );
  }

  void _editContactSheet() {
    final p  = profileState;
    final em = TextEditingController(text: p.email);
    final ph = TextEditingController(text: p.phone);
    final lo = TextEditingController(text: p.location);
    final li = TextEditingController(text: p.linkedin);
    final gh = TextEditingController(text: p.github);
    _sheet(
      title: 'Contact & Links', icon: Icons.contact_page,
      fields: [
        _FieldCfg(em, 'Email',    Icons.email),
        _FieldCfg(ph, 'Phone',    Icons.phone),
        _FieldCfg(lo, 'Location', Icons.location_on),
        _FieldCfg(li, 'LinkedIn', Icons.link),
        _FieldCfg(gh, 'GitHub',   Icons.code),
      ],
      onSave: () => profileState.set(() {
        p.email    = em.text.trim();
        p.phone    = ph.text.trim();
        p.location = lo.text.trim();
        p.linkedin = li.text.trim();
        p.github   = gh.text.trim();
      }),
    );
  }

  void _addSkillDialog() {
    final nameCtrl = TextEditingController();
    double level   = 0.70;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, sst) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Add Skill',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 13, color: kInk),
                decoration: InputDecoration(
                  hintText: 'e.g. Flutter, Figma, AWS',
                  hintStyle: const TextStyle(color: kHint),
                  filled: true, fillColor: kBgPage,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: kPrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Proficiency',
                    style: TextStyle(fontSize: 12, color: kMuted,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${(level * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13,
                        color: kPrimary, fontWeight: FontWeight.w900)),
              ]),
              Slider(
                value: level,
                onChanged: (v) => sst(() => level = v),
                activeColor: kPrimary,
                inactiveColor: kBorder,
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: kBgPage,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Cancel',
                          style: TextStyle(color: kMuted,
                              fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (nameCtrl.text.trim().isNotEmpty) {
                        profileState.set(() {
                          profileState.skills.add({
                            'name': nameCtrl.text.trim(),
                            'level': level,
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: kPrimary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Add',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800))),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _addCertDialog() {
    final nm = TextEditingController();
    final is_ = TextEditingController();
    final dt = TextEditingController();
    _sheet(
      title: 'Add Certification', icon: Icons.workspace_premium,
      fields: [
        _FieldCfg(nm,  'Certificate Name',      Icons.workspace_premium),
        _FieldCfg(is_, 'Issuer',                Icons.business),
        _FieldCfg(dt,  'Date  (e.g. Mar 2024)', Icons.calendar_today),
      ],
      onSave: () {
        if (nm.text.trim().isNotEmpty) {
          profileState.set(() => profileState.certifications.add({
            'name':   nm.text.trim(),
            'issuer': is_.text.trim(),
            'date':   dt.text.trim(),
          }));
        }
      },
    );
  }

  void _addProjectDialog() {
    final ti = TextEditingController();
    final de = TextEditingController();
    final li = TextEditingController();
    final te = TextEditingController();
    _sheet(
      title: 'Add Project', icon: Icons.folder,
      fields: [
        _FieldCfg(ti, 'Project Title',             Icons.title),
        _FieldCfg(de, 'Description',               Icons.description, maxLines: 3),
        _FieldCfg(li, 'GitHub / Live Link',         Icons.link),
        _FieldCfg(te, 'Tech Stack  (comma-sep)',    Icons.code),
      ],
      onSave: () {
        if (ti.text.trim().isNotEmpty) {
          profileState.set(() => profileState.projects.add({
            'title': ti.text.trim(),
            'desc':  de.text.trim(),
            'link':  li.text.trim(),
            'tech':  te.text.split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          }));
        }
      },
    );
  }

  void _editProjectDialog(int idx) {
    final proj = profileState.projects[idx];
    final ti   = TextEditingController(text: proj['title'] as String);
    final de   = TextEditingController(text: proj['desc']  as String);
    final li   = TextEditingController(text: proj['link']  as String);
    final te   = TextEditingController(
        text: (proj['tech'] as List<String>).join(', '));
    _sheet(
      title: 'Edit Project', icon: Icons.folder,
      fields: [
        _FieldCfg(ti, 'Project Title',           Icons.title),
        _FieldCfg(de, 'Description',             Icons.description, maxLines: 3),
        _FieldCfg(li, 'GitHub / Live Link',       Icons.link),
        _FieldCfg(te, 'Tech Stack (comma-sep)',  Icons.code),
      ],
      onSave: () => profileState.set(() {
        profileState.projects[idx] = {
          'title': ti.text.trim(),
          'desc':  de.text.trim(),
          'link':  li.text.trim(),
          'tech':  te.text.split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        };
      }),
    );
  }

  void _uploadResume() {
    profileState.set(
            () => profileState.resumeName = 'Arjun_Patel_Resume_2025.pdf');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Resume uploaded! Profile strength updated.',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  FIELD CONFIG HELPER
// ═══════════════════════════════════════════════════════════════

class _FieldCfg {
  final TextEditingController ctrl;
  final String   label;
  final IconData icon;
  final int      maxLines;
  const _FieldCfg(this.ctrl, this.label, this.icon, {this.maxLines = 1});
}