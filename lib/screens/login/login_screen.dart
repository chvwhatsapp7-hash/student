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
//  LOGIN SCREEN
// ─────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  bool   _showPass   = false;
  bool   _isLoading  = false;
  bool   _btnPressed = false;

  // 0 = Engineering, 1 = School
  int _portalIndex = 0;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  late AnimationController _bgAnim;
  late AnimationController _cardAnim;
  late AnimationController _btnCtrl;

  late Animation<double> _cardFade;
  late Animation<Offset>  _cardSlide;
  late Animation<double>  _btnScale;

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();

    _cardAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650),
    );
    _cardFade  = CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.16), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _cardAnim.forward();
    });
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _cardAnim.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (_portalIndex == 0) {
      context.go('/dashboard');
    } else {
      context.go('/school/dashboard');
    }
  }

  void _switchPortal(int index) {
    if (index == _portalIndex) return;
    HapticFeedback.selectionClick();
    _cardAnim.reset();
    setState(() => _portalIndex = index);
    _cardAnim.forward();
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
            // Background decorative blobs
            Positioned(
              top: -80, left: -60,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -100, right: -70,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.07),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 28),
                    _buildPortalSwitcher(),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: _portalIndex == 0
                            ? _buildEngCard()
                            : _buildSchoolCard(),
                      ),
                    ),
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
            Text('Sign in to continue',
                style: TextStyle(
                    fontSize: 10, color: kHint,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ── PORTAL SWITCHER ────────────────────────

  Widget _buildPortalSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.10), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(child: _switchTab(0, '💼', 'Engineering')),
          Expanded(child: _switchTab(1, '🎒', 'School')),
        ],
      ),
    );
  }

  Widget _switchTab(int index, String emoji, String label) {
    final active = _portalIndex == index;
    return GestureDetector(
      onTap: () => _switchPortal(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? kCardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: active ? kInk : Colors.white.withOpacity(0.50),
                )),
          ],
        ),
      ),
    );
  }

  // ── ENGINEERING CARD ───────────────────────

  Widget _buildEngCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.22),
            blurRadius: 40, offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon tile
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: kSelectedBg,
              shape: BoxShape.circle,
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: const Center(
              child: Text('💼', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Welcome back',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: kInk, letterSpacing: -0.4,
              )),
          const SizedBox(height: 5),
          const Text('Sign in to your engineering portal',
              style: TextStyle(fontSize: 13, color: kMuted)),
          const SizedBox(height: 24),
          // Email field
          _field(
            controller: _emailCtrl,
            label: 'Work / College Email',
            icon: Icons.email,
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          // Password field
          _field(
            controller: _passCtrl,
            label: 'Password',
            icon: Icons.lock,
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted, size: 18,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          const SizedBox(height: 8),
          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Text('Forgot Password?',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: kPrimary,
                  )),
            ),
          ),
          const SizedBox(height: 22),
          _buildLoginBtn(label: "Sign In  →"),
          const SizedBox(height: 18),
          // Sign up row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('New to NextStep? ',
                  style: TextStyle(fontSize: 13, color: kMuted)),
              GestureDetector(
                onTap: () => context.go('/signup'),
                child: const Text('Create Account',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: kPrimary,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SCHOOL CARD ────────────────────────────

  Widget _buildSchoolCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.22),
            blurRadius: 40, offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon tile
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFCF9),
              shape: BoxShape.circle,
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: const Center(
              child: Text('🎒', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Hello Explorer!',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: kInk, letterSpacing: -0.4,
              )),
          const SizedBox(height: 5),
          const Text('Sign in to start your tech adventure 🚀',
              style: TextStyle(fontSize: 13, color: kMuted),
              textAlign: TextAlign.center),
          // Stars
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Icon(Icons.star, color: Color(0xFFFFB300), size: 18),
            )),
          ),
          const SizedBox(height: 22),
          // Email
          _field(
            controller: _emailCtrl,
            label: 'Your Email',
            icon: Icons.email,
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          // Password
          _field(
            controller: _passCtrl,
            label: 'Password',
            icon: Icons.lock,
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted, size: 18,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          const SizedBox(height: 22),
          _buildLoginBtn(label: "Let's Go! →"),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('New here? ',
                  style: TextStyle(fontSize: 13, color: kMuted)),
              GestureDetector(
                onTap: () => context.go('/school/signup'),
                child: const Text('Join the Fun! 🎉',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: kPrimary,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Parents note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFFFEE58), width: 1.5),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👨‍👩‍👧', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Parents: Please help your child register.\nSunday is a holiday — no classes!',
                    style: TextStyle(
                      fontSize: 12, color: Color(0xFF795548),
                      height: 1.5, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED FIELD ───────────────────────────

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
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

  // ── LOGIN BUTTON ───────────────────────────

  Widget _buildLoginBtn({required String label}) {
    return GestureDetector(
      onTapDown: (_) {
        _btnCtrl.forward();
        setState(() => _btnPressed = true);
      },
      onTapUp: (_) {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
        _handleLogin();
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
            color: kPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
              BoxShadow(
                color: kPrimary.withOpacity(0.35),
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
                : Text(label,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 0.2,
                )),
          ),
        ),
      ),
    );
  }
}
