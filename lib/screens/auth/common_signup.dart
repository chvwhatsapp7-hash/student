import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kSelectedBg = Color(0xFFEFF6FF);
const kInputFill  = Color(0xFFF8FAFC);

// ─────────────────────────────────────────────
//  ROLE MODEL
// ─────────────────────────────────────────────

class _Role {
  final String value;
  final String label;
  final String emoji;
  final String subtitle;
  final Color  accent;
  final Color  bg;
  final String route;

  const _Role({
    required this.value,
    required this.label,
    required this.emoji,
    required this.subtitle,
    required this.accent,
    required this.bg,
    required this.route,
  });
}

const _roles = [
  _Role(
    value:    'engineering',
    label:    'Engineering / Graduate',
    emoji:    '💼',
    subtitle: 'B.E / B.Tech / B.Sc / Degree',
    accent:   kPrimary,
    bg:       kSelectedBg,
    route:    '/engineering',
  ),
  _Role(
    value:    'school',
    label:    'School Student',
    emoji:    '🎒',
    subtitle: 'Grade 5 – Grade 12',
    accent:   Color(0xFF0D9488),
    bg:       Color(0xFFEFFCF9),
    route:    '/school/layout',
  ),
  _Role(
    value:    'postgrad',
    label:    'Post Graduation',
    emoji:    '📚',
    subtitle: 'M.E / M.Tech / MBA / M.Sc',
    accent:   Color(0xFF7C3AED),
    bg:       Color(0xFFF5F3FF),
    route:    '/engineering',
  ),
];

const _grades = [
  'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8',
  'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12',
];

const _engYears  = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
const _pgYears   = ['1st Year', '2nd Year'];

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class CommonSignupScreen extends StatefulWidget {
  const CommonSignupScreen({super.key});

  @override
  State<CommonSignupScreen> createState() => _CommonSignupScreenState();
}

class _CommonSignupScreenState extends State<CommonSignupScreen>
    with TickerProviderStateMixin {

  _Role  _selectedRole = _roles[0];
  bool   _showPass     = false;
  bool   _showConfirm  = false;
  bool   _isLoading    = false;
  bool   _btnPressed   = false;

  // ── Common fields ──────────────────────────
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ── Engineering / Postgrad ─────────────────
  final _collegeCtrl    = TextEditingController();
  final _branchCtrl     = TextEditingController();
  final _rollCtrl       = TextEditingController();
  String? _selectedYear;

  // ── School ─────────────────────────────────
  final _schoolCtrl     = TextEditingController();
  final _parentCtrl     = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  String? _selectedGrade;

  // ── Animations ─────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _dropAnim;
  late AnimationController _fieldsAnim;
  late AnimationController _btnCtrl;
  late AnimationController _roleSwapAnim;

  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double>  _fieldsFade;
  late Animation<Offset>  _fieldsSlide;
  late Animation<double>  _btnScale;
  late Animation<double>  _roleSwapFade;
  late Animation<Offset>  _roleSwapSlide;

  _Role get _role => _selectedRole;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
        begin: const Offset(0, -0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _dropAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _fieldsAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fieldsFade  = CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut);
    _fieldsSlide = Tween<Offset>(
        begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut));

    _btnCtrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _roleSwapAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _roleSwapFade  = CurvedAnimation(
        parent: _roleSwapAnim, curve: Curves.easeOut);
    _roleSwapSlide = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _roleSwapAnim, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _dropAnim.forward();
    });
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) {
        _fieldsAnim.forward();
        _roleSwapAnim.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _dropAnim.dispose();
    _fieldsAnim.dispose();
    _btnCtrl.dispose();
    _roleSwapAnim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _collegeCtrl.dispose();
    _branchCtrl.dispose();
    _rollCtrl.dispose();
    _schoolCtrl.dispose();
    _parentCtrl.dispose();
    _parentPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _changeRole(_Role r) async {
    if (r.value == _selectedRole.value) return;
    HapticFeedback.selectionClick();
    await _roleSwapAnim.reverse();
    if (!mounted) return;
    setState(() {
      _selectedRole  = r;
      _selectedYear  = null;
      _selectedGrade = null;
    });
    _roleSwapAnim.forward();
  }

  Future<void> _signup() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://studenthub-backend-woad.vercel.app/api/auth/register',
    );

    final body = {
      "full_name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Signup Success");

        context.go('/login');
      } else {
        print("❌ Error: ${data["message"]}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }

    setState(() => _isLoading = false);
  }
  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kInk,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background blobs
            Positioned(
              top: -80, right: -60,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -80, left: -60,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.06),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildTopBar(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeroText(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Role dropdown
                    FadeTransition(
                      opacity: CurvedAnimation(
                          parent: _dropAnim, curve: Curves.easeOut),
                      child: SlideTransition(
                        position: Tween<Offset>(
                            begin: const Offset(0, 0.12), end: Offset.zero)
                            .animate(CurvedAnimation(
                            parent: _dropAnim, curve: Curves.easeOut)),
                        child: _buildRoleDropdown(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Form card
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign in link
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.50),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: kAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/'),
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
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NextStep',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: Colors.white)),
            Text('Create your account',
                style: TextStyle(
                    fontSize: 10, color: kHint,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ── HERO TEXT ──────────────────────────────

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Join NextStep',
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -0.6,
              height: 1.1,
            )),
        const SizedBox(height: 8),
        Text(
          'Select your role and get started in under a minute.',
          style: TextStyle(
              fontSize: 13, height: 1.5,
              color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }

  // ── ROLE DROPDOWN ──────────────────────────

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR ROLE',
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.45),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: _role.accent.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: kInk.withOpacity(0.18),
                blurRadius: 24, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(canvasColor: kCardBg),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  value: _role.value,
                  isExpanded: true,
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _role.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: _role.accent, size: 20),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      _changeRole(
                          _roles.firstWhere((r) => r.value == val));
                    }
                  },
                  selectedItemBuilder: (context) => _roles.map((r) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: r.bg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text(r.emoji,
                                style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(r.label,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: kInk)),
                                Text(r.subtitle,
                                    style: const TextStyle(
                                        fontSize: 11, color: kMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  items: _roles.map((r) {
                    final isSel = r.value == _role.value;
                    return DropdownMenuItem<String>(
                      value: r.value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? r.bg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: r.bg,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(child: Text(r.emoji,
                                  style: const TextStyle(fontSize: 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.label,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isSel ? r.accent : kInk)),
                                  Text(r.subtitle,
                                      style: const TextStyle(
                                          fontSize: 11, color: kMuted)),
                                ],
                              ),
                            ),
                            if (isSel)
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: r.accent),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 12),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── FORM CARD ──────────────────────────────

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.20),
            blurRadius: 36, offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28, height: 28,
                decoration: BoxDecoration(
                    color: _role.bg,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(_role.emoji,
                    style: const TextStyle(fontSize: 14))),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  key: ValueKey(_role.value),
                  '${_role.label} Sign Up',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Common fields ─────────────────
          _field(ctrl: _nameCtrl,  label: 'Full Name',
              icon: Icons.person_outline),
          const SizedBox(height: 12),
          _field(ctrl: _emailCtrl, label: 'Email Address',
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(ctrl: _phoneCtrl, label: 'Phone Number',
              icon: Icons.phone_outlined,
              type: TextInputType.phone),
          const SizedBox(height: 12),
          _field(ctrl: _passCtrl,  label: 'Create Password',
              icon: Icons.lock_outline, obscure: !_showPass,
              suffix: IconButton(
                icon: Icon(_showPass
                    ? Icons.visibility_off : Icons.visibility,
                    color: kMuted, size: 18),
                onPressed: () =>
                    setState(() => _showPass = !_showPass),
              )),
          const SizedBox(height: 12),
          _field(ctrl: _confirmCtrl, label: 'Confirm Password',
              icon: Icons.lock_outline, obscure: !_showConfirm,
              suffix: IconButton(
                icon: Icon(_showConfirm
                    ? Icons.visibility_off : Icons.visibility,
                    color: kMuted, size: 18),
                onPressed: () =>
                    setState(() => _showConfirm = !_showConfirm),
              )),
          const SizedBox(height: 16),

          // ── Divider with role label ────────
          Row(
            children: [
              Expanded(child: Divider(color: kBorder, thickness: 1.5)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _role.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_role.emoji}  ${_role.label} Details',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _role.accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Divider(color: kBorder, thickness: 1.5)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Role-specific fields ──────────
          FadeTransition(
            opacity: _roleSwapFade,
            child: SlideTransition(
              position: _roleSwapSlide,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: _buildRoleFields(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Terms
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 13, color: kHint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'By signing up you agree to our Terms of Service and Privacy Policy.',
                  style: const TextStyle(
                      fontSize: 11, color: kHint, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSubmitBtn(),
        ],
      ),
    );
  }

  // ── ROLE-SPECIFIC FIELDS ───────────────────

  Widget _buildRoleFields() {
    switch (_role.value) {

      case 'engineering':
        return Column(
          key: const ValueKey('engineering'),
          children: [
            _field(ctrl: _collegeCtrl, label: 'College Name',
                icon: Icons.account_balance_outlined),
            const SizedBox(height: 12),
            _field(ctrl: _branchCtrl,
                label: 'Branch / Department (e.g. CSE)',
                icon: Icons.school_outlined),
            const SizedBox(height: 12),
            _dropdownField(
              label: 'Current Year',
              icon: Icons.calendar_today_outlined,
              value: _selectedYear,
              items: _engYears,
              onChanged: (v) => setState(() => _selectedYear = v),
            ),
            const SizedBox(height: 12),
            _field(ctrl: _rollCtrl,
                label: 'Roll Number / Register No.',
                icon: Icons.badge_outlined),
          ],
        );

      case 'postgrad':
        return Column(
          key: const ValueKey('postgrad'),
          children: [
            _field(ctrl: _collegeCtrl,
                label: 'University / Institution',
                icon: Icons.account_balance_outlined),
            const SizedBox(height: 12),
            _field(ctrl: _branchCtrl,
                label: 'Specialisation / Department',
                icon: Icons.school_outlined),
            const SizedBox(height: 12),
            _dropdownField(
              label: 'Current Year (PG)',
              icon: Icons.calendar_today_outlined,
              value: _selectedYear,
              items: _pgYears,
              onChanged: (v) => setState(() => _selectedYear = v),
            ),
            const SizedBox(height: 12),
            _field(ctrl: _rollCtrl,
                label: 'Register / Enrolment No.',
                icon: Icons.badge_outlined),
          ],
        );

      case 'school':
        return Column(
          key: const ValueKey('school'),
          children: [
            _field(ctrl: _schoolCtrl, label: 'School Name',
                icon: Icons.location_city_outlined),
            const SizedBox(height: 12),
            _dropdownField(
              label: 'Grade / Class',
              icon: Icons.class_outlined,
              value: _selectedGrade,
              items: _grades,
              onChanged: (v) => setState(() => _selectedGrade = v),
            ),
            const SizedBox(height: 12),
            _field(ctrl: _parentCtrl,
                label: "Parent's Full Name",
                icon: Icons.supervisor_account_outlined),
            const SizedBox(height: 12),
            _field(ctrl: _parentPhoneCtrl,
                label: "Parent's Phone Number",
                icon: Icons.phone_outlined,
                type: TextInputType.phone),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFFFEE58), width: 1.5),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👨‍👩‍👧',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Parent details are used only for class reminders.\nSunday is a holiday — no classes!',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF795548),
                          height: 1.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  // ── TEXT FIELD ─────────────────────────────

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13, color: kMuted, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: kMuted, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: kInputFill,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 15),
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
          borderSide: BorderSide(color: _role.accent, width: 2),
        ),
      ),
    );
  }

  // ── DROPDOWN FIELD ─────────────────────────

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13, color: kMuted, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: kMuted, size: 18),
        filled: true,
        fillColor: kInputFill,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 15),
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
          borderSide: BorderSide(color: _role.accent, width: 2),
        ),
      ),
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
      dropdownColor: kCardBg,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: _role.accent, size: 20),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ── SUBMIT BUTTON ──────────────────────────

  Widget _buildSubmitBtn() {
    return GestureDetector(
      onTapDown: (_) {
        _btnCtrl.forward();
        setState(() => _btnPressed = true);
      },
      onTapUp: (_) {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
        _signup();
      },
      onTapCancel: () {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
      },
      child: ScaleTransition(
        scale: _btnScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _role.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
              BoxShadow(
                color: _role.accent.withOpacity(0.35),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_role.emoji,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Text('Create Account',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 0.2,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
