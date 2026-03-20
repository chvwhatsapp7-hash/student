import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kSlate      = Color(0xFF334155);
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
  final String route;        // where to go after login

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

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class CommonLoginScreen extends StatefulWidget {
  const CommonLoginScreen({super.key});

  @override
  State<CommonLoginScreen> createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends State<CommonLoginScreen>
    with TickerProviderStateMixin {

  _Role    _selectedRole = _roles[0];
  bool     _showPass     = false;
  bool     _isLoading    = false;
  bool     _btnPressed   = false;
  bool     _dropdownOpen = false;

  // Controllers — shared across all roles
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();

  // Engineering / Postgrad specific
  final _collegeCtrl  = TextEditingController();
  final _branchCtrl   = TextEditingController();
  final _yearCtrl     = TextEditingController();

  // School specific
  final _schoolCtrl   = TextEditingController();
  final _gradeCtrl    = TextEditingController();

  // Animation controllers
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
        .animate(CurvedAnimation(
        parent: _roleSwapAnim, curve: Curves.easeOut));

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _collegeCtrl.dispose();
    _branchCtrl.dispose();
    _yearCtrl.dispose();
    _schoolCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  // ── Role change — animate the extra fields out/in ─────────────────────────

  Future<void> _changeRole(_Role r) async {
    if (r.value == _selectedRole.value) return;
    HapticFeedback.selectionClick();
    await _roleSwapAnim.reverse();
    if (!mounted) return;
    setState(() => _selectedRole = r);
    _roleSwapAnim.forward();
  }

  // ── Login ──────────────────────────────────

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://internship-app.vercel.app/api/auth/login');

    Map<String, dynamic> body = {
      "email": _emailCtrl.text,
      "password": _passCtrl.text,
      "role": _role.value,
    };

    // Role-based fields
    if (_role.value == 'engineering' || _role.value == 'postgrad') {
      body["college"] = _collegeCtrl.text;
      body["branch"]  = _branchCtrl.text;
      body["year"]    = _yearCtrl.text;
    } else if (_role.value == 'school') {
      body["school"] = _schoolCtrl.text;
      body["grade"]  = _gradeCtrl.text;
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("Login Success: $data");

        // Navigate after login
        context.go(_role.route);

      } else {
        print("Error: ${data["message"]}");
      }

    } catch (e) {
      print("Exception: $e");
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
                    // ── TOP BAR ──────────────────────────────
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildTopBar(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── HERO TEXT ─────────────────────────────
                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeroText(),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── ROLE DROPDOWN ─────────────────────────
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

                    // ── FORM CARD ─────────────────────────────
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── SIGN UP LINK ──────────────────────────
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.50),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/signup'),
                              child: const Text(
                                'Create Account',
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
            Text('Welcome back',
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
        const Text('Sign In',
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -0.6,
              height: 1.1,
            )),
        const SizedBox(height: 8),
        Text(
          'Select your role and sign in to continue.',
          style: TextStyle(
              fontSize: 13, height: 1.5,
              color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }

  // ── ROLE SELECTOR ──────────────────────────
  // Custom-built selector — no DropdownButton constraints,
  // full control over spacing, zero overflow risk.

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

        // ── Collapsed "selected" tile — tap to open sheet ──────────────
        GestureDetector(
          onTap: _openRoleSheet,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: _role.accent.withOpacity(0.45), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: kInk.withOpacity(0.18),
                  blurRadius: 24, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emoji tile
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: _role.bg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(_role.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),

                // Label + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _role.label,
                          key: ValueKey(_role.value),
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _role.subtitle,
                          key: ValueKey('sub_${_role.value}'),
                          style: const TextStyle(
                              fontSize: 12, color: kMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Chevron
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _role.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _role.accent, size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom sheet role picker ────────────────

  void _openRoleSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RolePickerSheet(
        roles:        _roles,
        selectedRole: _role,
        onSelect:     (r) {
          Navigator.pop(context);
          _changeRole(r);
        },
      ),
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
          // ── Section label ─────────────────
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _role.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(_role.emoji,
                      style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  key: ValueKey(_role.value),
                  '${_role.label} Login',
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
          _field(
            ctrl: _emailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(
            ctrl: _passCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted, size: 18,
              ),
              onPressed: () =>
                  setState(() => _showPass = !_showPass),
            ),
          ),

          // ── Role-specific extra fields ────
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _roleSwapFade,
            child: SlideTransition(
              position: _roleSwapSlide,
              child: _buildRoleFields(),
            ),
          ),

          // ── Forgot password ───────────────
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: _role.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Submit button ─────────────────
          _buildSubmitBtn(),
        ],
      ),
    );
  }

  // ── ROLE-SPECIFIC FIELDS ──────────────────
  // Animates in/out when role changes

  Widget _buildRoleFields() {
    switch (_role.value) {

    // Engineering & Postgrad show college + branch + year
      case 'engineering':
      case 'postgrad':
        return Column(
          key: ValueKey(_role.value),
          children: [
            _field(
              ctrl: _collegeCtrl,
              label: _role.value == 'postgrad'
                  ? 'University / Institution'
                  : 'College Name',
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              ctrl: _branchCtrl,
              label: _role.value == 'postgrad'
                  ? 'Specialisation / Department'
                  : 'Branch / Department',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              ctrl: _yearCtrl,
              label: _role.value == 'postgrad'
                  ? 'Current Year (PG)'
                  : 'Current Year (e.g. 2nd Year)',
              icon: Icons.calendar_today_outlined,
              type: TextInputType.number,
            ),
          ],
        );

    // School shows school name + grade
      case 'school':
        return Column(
          key: const ValueKey('school'),
          children: [
            _field(
              ctrl: _schoolCtrl,
              label: 'School Name',
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              ctrl: _gradeCtrl,
              label: 'Grade / Class (e.g. Grade 9)',
              icon: Icons.class_outlined,
              type: TextInputType.number,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
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
        _login();
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
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                const Text('Sign In',
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

// ─────────────────────────────────────────────
//  ROLE PICKER BOTTOM SHEET
//  Fully custom — no DropdownButton, no overflow.
//  Each option has generous padding and clear spacing.
// ─────────────────────────────────────────────

class _RolePickerSheet extends StatelessWidget {
  final List<_Role>  roles;
  final _Role        selectedRole;
  final void Function(_Role) onSelect;

  const _RolePickerSheet({
    required this.roles,
    required this.selectedRole,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),

          // ── Sheet title ──────────────────────
          Row(
            children: [
              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your role determines which portal you enter.',
            style: TextStyle(
              fontSize: 13, color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 22),

          // ── Role tiles ───────────────────────
          ...roles.map((r) {
            final isSelected = r.value == selectedRole.value;
            return GestureDetector(
              onTap: () => onSelect(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
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
                    // Emoji tile
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? r.bg
                            : Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(r.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? kInk : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            r.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? kMuted
                                  : Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Check circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? r.accent : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? r.accent
                              : Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
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
