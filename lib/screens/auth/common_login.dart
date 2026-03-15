import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — shared with Signup
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

  const _Role({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
    required this.bgColor,
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
  ),
  _Role(
    value:       'school',
    title:       'School Student',
    subtitle:    'Coding, AI, robotics & summer programmes',
    emoji:       '🎒',
    accentColor: Color(0xFF0D9488),
    bgColor:     Color(0xFFEFFCF9),
  ),
  _Role(
    value:       'postgrad',
    title:       'Post Graduation',
    subtitle:    'Research, higher studies & advanced roles',
    emoji:       '📚',
    accentColor: Color(0xFF7C3AED),
    bgColor:     Color(0xFFF5F3FF),
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

  String _role       = 'engineering';
  bool   _showPass   = false;
  bool   _isLoading  = false;
  bool   _btnPressed = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

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
    _cardAnim.dispose();
    _fieldsAnim.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Login — routes based on selected role ──────────────────────────────────
  //   school             → /school/login  (school portal own login)
  //   engineering / PG   → /engineering   (main dashboard)

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_role == 'school') {
      context.go('/school/login');
    } else {
      // covers both 'engineering' and 'postgrad'
      context.go('/engineering');
    }
  }

  void _selectRole(String value) {
    if (_role == value) return;
    HapticFeedback.selectionClick();
    setState(() => _role = value);
  }

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
                    Center(
                      child: FadeTransition(
                        opacity: _fieldsFade,
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
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white, size: 16,
            ),
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
            Text(
              'NextStep',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 10, color: kHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your role and sign in to continue.',
          style: TextStyle(
            fontSize: 13, height: 1.5,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a…',
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.45),
            letterSpacing: 0.8,
          ),
        ),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? r.bgColor
                          : Colors.white.withOpacity(0.08),
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
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: selected ? kInk : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? kMuted
                                : Colors.white.withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock, color: kPrimary, size: 15),
              ),
              const SizedBox(width: 10),
              const Text(
                'Your Credentials',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _field(
            ctrl:  _emailCtrl,
            label: 'Email Address',
            icon:  Icons.email_outlined,
            type:  TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(
            ctrl:    _passCtrl,
            label:   'Password',
            icon:    Icons.lock_outline,
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted, size: 18,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: wire up forgot-password route when ready
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildSubmitBtn(),
        ],
      ),
    );
  }

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
                Text(
                  _selectedRole.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
