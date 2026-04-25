import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const kInk = Color(0xFF0F172A);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kPrimary = Color(0xFF1D4ED8);
const kAccent = Color(0xFF38BDF8);
const kSelectedBg = Color(0xFFEFF6FF);
const kInputFill = Color(0xFFF8FAFC);

// ─────────────────────────────────────────────
//  ROLE MODEL
// ─────────────────────────────────────────────
class _Role {
  final String value, label, emoji, subtitle, route;
  final Color accent, bg;
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
    value: 'engineering',
    label: 'Engineering / Graduate',
    emoji: '💼',
    subtitle: 'B.E / B.Tech / B.Sc / Degree',
    accent: kPrimary,
    bg: kSelectedBg,
    route: '/engineering',
  ),
  _Role(
    value: 'school',
    label: 'School Student',
    emoji: '🎒',
    subtitle: 'Grade 5 – Grade 12',
    accent: Color(0xFF0D9488),
    bg: Color(0xFFEFFCF9),
    route: '/school/layout',
  ),
  _Role(
    value: 'postgrad',
    label: 'Post Graduation',
    emoji: '📚',
    subtitle: 'M.E / M.Tech / MBA / M.Sc',
    accent: Color(0xFF7C3AED),
    bg: Color(0xFFF5F3FF),
    route: '/engineering',
  ),
];

// These constants are kept for when role-specific fields are re-enabled
// const _grades = [
//   'Grade 5',
//   'Grade 6',
//   'Grade 7',
//   'Grade 8',
//   'Grade 9',
//   'Grade 10',
//   'Grade 11',
//   'Grade 12',
// ];
// const _engYears = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
// const _pgYears = ['1st Year', '2nd Year'];

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
  _Role _selectedRole = _roles[0];
  bool _showPass = false,
      _showConfirm = false,
      _isLoading = false,
      _btnPressed = false;

  // ── Common fields ──────────────────────────
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ── Engineering / Postgrad fields (hidden for now, kept for future use) ─
  // final _collegeCtrl = TextEditingController();
  // final _branchCtrl = TextEditingController();
  // final _rollCtrl = TextEditingController();
  // String? _selectedYear;

  // ── School fields (hidden for now, kept for future use) ─────────────────
  // final _schoolCtrl = TextEditingController();
  // final _parentCtrl = TextEditingController();
  // final _parentPhoneCtrl = TextEditingController();
  // String? _selectedGrade;

  // ── Animations ─────────────────────────────
  late AnimationController _headerAnim,
      _dropAnim,
      _fieldsAnim,
      _btnCtrl,
      _roleSwapAnim;
  late Animation<double> _headerFade, _fieldsFade, _btnScale, _roleSwapFade;
  late Animation<Offset> _headerSlide, _fieldsSlide, _roleSwapSlide;

  _Role get _role => _selectedRole;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _dropAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fieldsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fieldsFade = CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut);
    _fieldsSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _roleSwapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _roleSwapFade = CurvedAnimation(
      parent: _roleSwapAnim,
      curve: Curves.easeOut,
    );
    _roleSwapSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _roleSwapAnim, curve: Curves.easeOut));

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
    // _collegeCtrl.dispose();
    // _branchCtrl.dispose();
    // _rollCtrl.dispose();
    // _schoolCtrl.dispose();
    // _parentCtrl.dispose();
    // _parentPhoneCtrl.dispose();
    super.dispose();
  }

  // ── Role change — animates the selector tile ──
  Future<void> _changeRole(_Role r) async {
    if (r.value == _selectedRole.value) return;
    HapticFeedback.selectionClick();
    await _roleSwapAnim.reverse();
    if (!mounted) return;
    setState(() {
      _selectedRole = r;
      // _selectedYear = null;
      // _selectedGrade = null;
    });
    _roleSwapAnim.forward();
  }

  // ── Open bottom sheet role picker ─────────────
  void _openRoleSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RolePickerSheet(
        roles: _roles,
        selectedRole: _role,
        onSelect: (r) {
          Navigator.pop(context);
          _changeRole(r);
        },
      ),
    );
  }

  // ── SIGNUP ─────────────────────────────────
  Future<void> _signup() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://studenthub-backend-woad.vercel.app/api/auth/register',
    );

    int roleId;
    switch (_role.value) {
      case 'engineering':
        roleId = 3;
        break;
      case 'school':
        roleId = 2;
        break;
      case 'postgrad':
        roleId = 4;
        break;
      default:
        roleId = 3;
    }

    final body = {
      "full_name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "role_id": roleId,
      // // Optional fields for students
      // if (_role.value == 'engineering' || _role.value == 'postgrad') ...{
      //   "university": _collegeCtrl.text.trim(),
      //   "degree": _branchCtrl.text.trim(),
      //   "graduation_year": _selectedYear ?? "",
      //   "roll_number": _rollCtrl.text.trim(),
      // },
      // if (_role.value == 'school') ...{
      //   "school": _schoolCtrl.text.trim(),
      //   "grade": _selectedGrade ?? "",
      //   "parent_name": _parentCtrl.text.trim(),
      //   "parent_phone": _parentPhoneCtrl.text.trim(),
      // },
      // // Optional social/resume fields (can later be added in UI)
      // "resume_url": "https://example.com/resume.pdf",
      // "linkedin_url": "https://linkedin.com/in/username",
      // "github_url": "https://github.com/username",
      "age": 20,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Signup Successful")));
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
      debugPrint("❌ Exception: $e");
    }
    setState(() => _isLoading = false);
  }

  // ── GOOGLE SIGN UP ─────────────────────────
  // TODO: replace body with your Google OAuth / firebase_auth call
  Future<void> _signUpWithGoogle() async {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Google sign-up coming soon")));
  }

  // ── LINKEDIN SIGN UP ───────────────────────
  // TODO: replace body with your LinkedIn OAuth call
  Future<void> _signUpWithLinkedIn() async {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("LinkedIn sign-up coming soon")),
    );
  }

  // ── build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kInk,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background blobs
            Positioned(
              top: -sw * 0.20,
              right: -sw * 0.15,
              child: Container(
                width: sw * 0.60,
                height: sw * 0.60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -sw * 0.20,
              left: -sw * 0.15,
              child: Container(
                width: sw * 0.65,
                height: sw * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.06),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.050,
                  vertical: sw * 0.040,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildTopBar(sw),
                      ),
                    ),
                    SizedBox(height: sw * 0.060),
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeroText(sw),
                      ),
                    ),
                    SizedBox(height: sw * 0.055),

                    // ── Role selector tile ────────────────────────────────
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _dropAnim,
                        curve: Curves.easeOut,
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _dropAnim,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: _buildRoleSelector(sw),
                      ),
                    ),
                    SizedBox(height: sw * 0.040),

                    // Form card
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(sw),
                      ),
                    ),
                    SizedBox(height: sw * 0.040),

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
                                fontSize: sw * 0.033,
                                color: Colors.white.withOpacity(0.50),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: sw * 0.033,
                                  fontWeight: FontWeight.w800,
                                  color: kAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.070),

                    // ── Divider ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.030,
                            ),
                            child: Text(
                              'or sign up with',
                              style: TextStyle(
                                fontSize: sw * 0.028,
                                color: Colors.white.withOpacity(0.40),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.035),

                    // ── Social buttons ────────────────────────────────────
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: Row(
                        children: [
                          Expanded(
                            child: _socialBtn(
                              label: 'Google',
                              onTap: _signUpWithGoogle,
                              sw: sw,
                              iconWidget: _GoogleIcon(size: sw * 0.048),
                              borderColor: const Color(
                                0xFF4285F4,
                              ).withOpacity(0.45),
                            ),
                          ),
                          SizedBox(width: sw * 0.025),
                          Expanded(
                            child: _socialBtn(
                              label: 'LinkedIn',
                              onTap: _signUpWithLinkedIn,
                              sw: sw,
                              iconWidget: _LinkedInIcon(size: sw * 0.048),
                              borderColor: const Color(
                                0xFF0A66C2,
                              ).withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.050),
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
  Widget _buildTopBar(double sw) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: sw * 0.090,
            height: sw * 0.090,
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
        Container(
          width: sw * 0.085,
          height: sw * 0.085,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('⚡', style: TextStyle(fontSize: sw * 0.040)),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NextStep',
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Create your account',
              style: TextStyle(
                fontSize: sw * 0.025,
                color: kHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── HERO TEXT ──────────────────────────────
  Widget _buildHeroText(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join NextStep',
          style: TextStyle(
            fontSize: sw * 0.070,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        SizedBox(height: sw * 0.020),
        Text(
          'Select your role and get started in under a minute.',
          style: TextStyle(
            fontSize: sw * 0.033,
            height: 1.5,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  // ── ROLE SELECTOR TILE ────────────────────
  Widget _buildRoleSelector(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR ROLE',
          style: TextStyle(
            fontSize: sw * 0.028,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.45),
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: sw * 0.025),
        GestureDetector(
          onTap: _openRoleSheet,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.040,
              vertical: sw * 0.035,
            ),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _role.accent.withOpacity(0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: kInk.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: sw * 0.115,
                  height: sw * 0.115,
                  decoration: BoxDecoration(
                    color: _role.bg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      _role.emoji,
                      style: TextStyle(fontSize: sw * 0.055),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _role.label,
                          key: ValueKey(_role.value),
                          style: TextStyle(
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ),
                      SizedBox(height: sw * 0.005),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _role.subtitle,
                          key: ValueKey('sub_${_role.value}'),
                          style: TextStyle(fontSize: sw * 0.030, color: kMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: sw * 0.025),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.all(sw * 0.015),
                  decoration: BoxDecoration(
                    color: _role.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _role.accent,
                    size: sw * 0.050,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── FORM CARD ─────────────────────────────
  Widget _buildFormCard(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.055),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.20),
            blurRadius: 36,
            offset: const Offset(0, 14),
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
                width: sw * 0.070,
                height: sw * 0.070,
                decoration: BoxDecoration(
                  color: _role.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _role.emoji,
                    style: TextStyle(fontSize: sw * 0.035),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.025),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '${_role.label} Sign Up',
                  key: ValueKey(_role.value),
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.045),

          _field(
            ctrl: _nameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline,
            sw: sw,
          ),
          SizedBox(height: sw * 0.030),
          _field(
            ctrl: _emailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            sw: sw,
            type: TextInputType.emailAddress,
          ),
          SizedBox(height: sw * 0.030),
          _field(
            ctrl: _phoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            sw: sw,
            type: TextInputType.phone,
          ),
          SizedBox(height: sw * 0.030),
          _field(
            ctrl: _passCtrl,
            label: 'Create Password',
            icon: Icons.lock_outline,
            sw: sw,
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted,
                size: sw * 0.045,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          SizedBox(height: sw * 0.030),
          _field(
            ctrl: _confirmCtrl,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            sw: sw,
            obscure: !_showConfirm,
            suffix: IconButton(
              icon: Icon(
                _showConfirm ? Icons.visibility_off : Icons.visibility,
                color: kMuted,
                size: sw * 0.045,
              ),
              onPressed: () => setState(() => _showConfirm = !_showConfirm),
            ),
          ),
          SizedBox(height: sw * 0.050),

          // ── Role-specific fields — hidden for now, kept for future ────
          // To re-enable: uncomment the block below + uncomment the
          // controllers/constants at the top of this class.
          //
          // const SizedBox(height: 4),
          // Row( ... role divider ... ),
          // FadeTransition(
          //   opacity: _roleSwapFade,
          //   child: SlideTransition(
          //     position: _roleSwapSlide,
          //     child: AnimatedSwitcher(
          //       duration: const Duration(milliseconds: 300),
          //       child: _buildRoleFields(),
          //     ),
          //   ),
          // ),

          // Terms
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: sw * 0.033, color: kHint),
              SizedBox(width: sw * 0.020),
              Expanded(
                child: Text(
                  'By signing up you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    color: kHint,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.045),
          _buildSubmitBtn(sw),
        ],
      ),
    );
  }

  // ── ROLE-SPECIFIC FIELDS ──────────────────
  // Kept intact for future use — currently not shown in the form.
  // To re-enable, uncomment the _buildRoleFields() call in _buildFormCard().

  // Widget _buildRoleFields() { ... }

  // ── DROPDOWN FIELD ────────────────────────
  // Kept for role-specific fields when they are re-enabled.

  // Widget _dropdownField({ ... }) { ... }

  // ── TEXT FIELD ─────────────────────────────
  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required double sw,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: TextStyle(
        fontSize: sw * 0.035,
        fontWeight: FontWeight.w600,
        color: kInk,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: sw * 0.033,
          color: kMuted,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: kMuted, size: sw * 0.045),
        suffixIcon: suffix,
        filled: true,
        fillColor: kInputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.040,
          vertical: sw * 0.038,
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
          borderSide: BorderSide(color: _role.accent, width: 2),
        ),
      ),
    );
  }

  // ── SUBMIT BUTTON ──────────────────────────
  Widget _buildSubmitBtn(double sw) {
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
          padding: EdgeInsets.symmetric(vertical: sw * 0.038),
          decoration: BoxDecoration(
            color: _role.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
                    BoxShadow(
                      color: _role.accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: sw * 0.055,
                    height: sw * 0.055,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_role.emoji, style: TextStyle(fontSize: sw * 0.040)),
                      SizedBox(width: sw * 0.020),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── SOCIAL BUTTON ──────────────────────────
  Widget _socialBtn({
    required String label,
    required VoidCallback onTap,
    required double sw,
    required Widget iconWidget,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sw * 0.038),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(width: sw * 0.020),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.034,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GOOGLE ICON  (pure CustomPainter — no assets needed)
// ─────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double cx = s / 2, cy = s / 2, r = s / 2;

    // White circle background
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.76);

    // Four colour arcs
    canvas.drawArc(
      rect,
      3.38,
      1.75,
      true,
      Paint()..color = const Color(0xFFEA4335),
    );
    canvas.drawArc(
      rect,
      5.13,
      1.57,
      true,
      Paint()..color = const Color(0xFF4285F4),
    );
    canvas.drawArc(
      rect,
      0.52,
      1.48,
      true,
      Paint()..color = const Color(0xFF34A853),
    );
    canvas.drawArc(
      rect,
      1.96,
      1.42,
      true,
      Paint()..color = const Color(0xFFFBBC05),
    );

    // Inner white donut
    canvas.drawCircle(Offset(cx, cy), r * 0.46, Paint()..color = Colors.white);

    // Blue right-side tab (the horizontal bar in the "G")
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.20, r * 0.76, r * 0.40),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────
//  LINKEDIN ICON  (pure CustomPainter — no assets needed)
// ─────────────────────────────────────────────
class _LinkedInIcon extends StatelessWidget {
  final double size;
  const _LinkedInIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LinkedInPainter()),
    );
  }
}

class _LinkedInPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint bg = Paint()..color = const Color(0xFF0A66C2);
    final Paint white = Paint()..color = Colors.white;

    // Rounded square background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(s * 0.22),
      ),
      bg,
    );

    final double pad = s * 0.18;
    final double dotR = s * 0.09;

    // Top-left dot
    canvas.drawCircle(Offset(pad + dotR, pad + dotR), dotR, white);

    // Left vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pad, pad + dotR * 2 + s * 0.04, dotR * 2, s * 0.38),
        Radius.circular(dotR),
      ),
      white,
    );

    // Right vertical bar
    final double rx = s - pad - dotR * 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rx, pad + dotR * 2 + s * 0.10, dotR * 2, s * 0.32),
        Radius.circular(dotR),
      ),
      white,
    );

    // Arch connector (top of right bar)
    canvas.drawArc(
      Rect.fromLTWH(
        pad + dotR * 2,
        pad + dotR * 2 + s * 0.04,
        (rx - pad - dotR * 2) * 2,
        s * 0.28,
      ),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = dotR * 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────
//  ROLE PICKER BOTTOM SHEET
// ─────────────────────────────────────────────
class _RolePickerSheet extends StatelessWidget {
  final List<_Role> roles;
  final _Role selectedRole;
  final void Function(_Role) onSelect;

  const _RolePickerSheet({
    required this.roles,
    required this.selectedRole,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        sw * 0.050,
        sw * 0.030,
        sw * 0.050,
        sw * 0.080,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: sw * 0.10,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: sw * 0.050),

          // Title row
          Row(
            children: [
              Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: sw * 0.080,
                  height: sw * 0.080,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: sw * 0.040,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.015),
          Text(
            'Your role determines which portal you enter.',
            style: TextStyle(
              fontSize: sw * 0.033,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          SizedBox(height: sw * 0.055),

          // Role tiles
          ...roles.map((r) {
            final isSelected = r.value == selectedRole.value;
            return GestureDetector(
              onTap: () => onSelect(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.only(bottom: sw * 0.030),
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.045,
                  vertical: sw * 0.040,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? r.accent.withOpacity(0.55)
                        : Colors.white.withOpacity(0.12),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: sw * 0.130,
                      height: sw * 0.130,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? r.bg
                            : Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          r.emoji,
                          style: TextStyle(fontSize: sw * 0.060),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.040),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.label,
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? kInk : Colors.white,
                            ),
                          ),
                          SizedBox(height: sw * 0.008),
                          Text(
                            r.subtitle,
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: isSelected
                                  ? kMuted
                                  : Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: sw * 0.030),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: sw * 0.065,
                      height: sw * 0.065,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? r.accent : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? r.accent
                              : Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: sw * 0.035,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
