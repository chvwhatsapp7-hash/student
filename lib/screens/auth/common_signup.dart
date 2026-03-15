import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
const kSelectedBg = Color(0xFFEFF6FF);
const kInputFill  = Color(0xFFF8FAFC);

// ─────────────────────────────────────────────
//  ROLE MODEL
// ─────────────────────────────────────────────

class _Role {
  final String value;
  final String title;
  final String subtitle;
  final String emoji;
  final Color  accentColor;
  final Color  bgColor;
  final String route;

  const _Role({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
    required this.bgColor,
    required this.route,
  });
}

const _roles = [
  _Role(
    value:       'engineering',
    title:       'Engineering Student',
    subtitle:    'Jobs, internships, companies & hackathons',
    emoji:       '💼',
    accentColor: kPrimary,
    bgColor:     kSelectedBg,
    route:       '/engineering',
  ),
  _Role(
    value:       'school',
    title:       'School Student',
    subtitle:    'Coding, AI, robotics & summer programmes',
    emoji:       '🎒',
    accentColor: Color(0xFF0D9488),
    bgColor:     Color(0xFFEFFCF9),
    route:       '/school',
  ),
  _Role(
    value:       'postgrad',
    title:       'Post Graduation',
    subtitle:    'Research, higher studies & advanced roles',
    emoji:       '📚',
    accentColor: Color(0xFF7C3AED),
    bgColor:     Color(0xFFF5F3FF),
    route:       '/engineering',
  ),
];

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

  String _role = 'engineering';
  bool   _showPass  = false;
  bool   _isLoading = false;
  bool   _btnPressed = false;

  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  late AnimationController _bgAnim;
  late AnimationController _cardAnim;
  late AnimationController _fieldsAnim;
  late AnimationController _btnCtrl;

  late Animation<double> _cardFade;
  late Animation<Offset>  _cardSlide;
  late Animation<double>  _fieldsFade;
  late Animation<Offset>  _fieldsSlide;
  late Animation<double>  _btnScale;

  _Role get _selectedRole =>
      _roles.firstWhere((r) => r.value == _role);

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();

    _cardAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _cardFade  = CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut));

    _fieldsAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _fieldsFade  = CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut);
    _fieldsSlide = Tween<Offset>(
      begin: const Offset(0, 0.10), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardAnim.forward();
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _fieldsAnim.forward();
    });
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _cardAnim.dispose();
    _fieldsAnim.dispose();
    _btnCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(_selectedRole.route);
  }

  void _selectRole(String value) {
    if (_role == value) return;
    HapticFeedback.selectionClick();
    setState(() => _role = value);
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
            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildHeroText(),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _buildRoleSelector(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Already have account
                    Center(
                      child: FadeTransition(
                        opacity: _fieldsFade,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Already have an account? ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.50))),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text('Sign In',
                                  style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w800,
                                    color: kAccent,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
            child: Text('⚡', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NextStep',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
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
          'Pick your role below and get started in under a minute.',
          style: TextStyle(
            fontSize: 13, height: 1.5,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  // ── ROLE SELECTOR ──────────────────────────

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('I am a…',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.45),
              letterSpacing: 0.8,
            )),
        const SizedBox(height: 10),
        ..._roles.map((r) {
          final selected = _role == r.value;
          return GestureDetector(
            onTap: () => _selectRole(r.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? kCardBg
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? r.accentColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.10),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Emoji tile
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selected ? r.bgColor : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(r.emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: selected ? kInk : Colors.white,
                            )),
                        const SizedBox(height: 2),
                        Text(r.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? kMuted
                                  : Colors.white.withOpacity(0.45),
                            )),
                      ],
                    ),
                  ),
                  // Check circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? r.accentColor : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? r.accentColor
                            : Colors.white.withOpacity(0.20),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 13)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
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
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: kPrimary, size: 15),
              ),
              const SizedBox(width: 10),
              const Text('Your Details',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: kInk,
                  )),
            ],
          ),
          const SizedBox(height: 18),
          // Fields
          _field(
            ctrl:  _nameCtrl,
            label: 'Full Name',
            icon:  Icons.person,
            type:  TextInputType.name,
          ),
          const SizedBox(height: 12),
          _field(
            ctrl:  _emailCtrl,
            label: 'Email Address',
            icon:  Icons.email,
            type:  TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(
            ctrl:  _phoneCtrl,
            label: 'Phone Number',
            icon:  Icons.phone,
            type:  TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _field(
            ctrl:    _passCtrl,
            label:   'Create Password',
            icon:    Icons.lock,
            obscure: !_showPass,
            suffix:  IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted, size: 18,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          const SizedBox(height: 20),
          // Terms note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info, size: 14, color: kHint),
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
          // Submit button
          _buildSubmitBtn(),
        ],
      ),
    );
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
          borderSide: const BorderSide(color: kPrimary, width: 2),
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
            color: _selectedRole.accentColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
              BoxShadow(
                color: _selectedRole.accentColor.withOpacity(0.35),
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
                Text(_selectedRole.emoji,
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
