import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/school_api_service.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue = Color(0xFF1A73E8);
const kDeepBlue    = Color(0xFF0D47A1);
const kSkyBlue     = Color(0xFF00B0FF);
const kCardBg      = Color(0xFFFFFFFF);
const kCardBorder  = Color(0xFFE0E8FB);
const kTextDark    = Color(0xFF1A2A5E);
const kTextMuted   = Color(0xFF6B80B3);
const kSelectedBg  = Color(0xFFE8F1FE);
const kInputFill   = Color(0xFFF0F6FF);

// ─────────────────────────────────────────────
//  FLOATING ITEM MODEL
// ─────────────────────────────────────────────

class _FloatItem {
  final String  emoji;
  final double  left;
  final double  top;
  final double  size;
  final double  phaseOffset;
  final double  amplitude;
  const _FloatItem({
    required this.emoji,
    required this.left,
    required this.top,
    required this.size,
    required this.phaseOffset,
    required this.amplitude,
  });
}

const _floatItems = [
  _FloatItem(emoji: '🚀', left: 22,  top: 90,  size: 32, phaseOffset: 0.0,  amplitude: 18),
  _FloatItem(emoji: '🤖', left: 80,  top: 55,  size: 28, phaseOffset: 0.8,  amplitude: 14),
  _FloatItem(emoji: '💻', left: 145, top: 110, size: 26, phaseOffset: 1.6,  amplitude: 20),
  _FloatItem(emoji: '🎮', left: 210, top: 65,  size: 30, phaseOffset: 2.4,  amplitude: 16),
  _FloatItem(emoji: '⭐', left: 290, top: 95,  size: 24, phaseOffset: 3.2,  amplitude: 22),
  _FloatItem(emoji: '🌈', left: 340, top: 50,  size: 28, phaseOffset: 0.4,  amplitude: 15),
  _FloatItem(emoji: '🔬', left: 50,  top: 680, size: 26, phaseOffset: 1.2,  amplitude: 18),
  _FloatItem(emoji: '🎯', left: 300, top: 700, size: 30, phaseOffset: 2.0,  amplitude: 14),
  _FloatItem(emoji: '🟣', left: 15,  top: 400, size: 18, phaseOffset: 0.6,  amplitude: 12),
  _FloatItem(emoji: '🔵', left: 355, top: 350, size: 16, phaseOffset: 1.4,  amplitude: 10),
  _FloatItem(emoji: '🟡', left: 30,  top: 550, size: 14, phaseOffset: 2.2,  amplitude: 16),
  _FloatItem(emoji: '🟢', left: 340, top: 560, size: 16, phaseOffset: 3.0,  amplitude: 12),
];

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────

class SchoolLoginScreen extends StatefulWidget {
  const SchoolLoginScreen({super.key});

  @override
  State<SchoolLoginScreen> createState() => _SchoolLoginScreenState();
}

class _SchoolLoginScreenState extends State<SchoolLoginScreen>
    with TickerProviderStateMixin {

  late AnimationController _floatCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _btnCtrl;

  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _btnScale;

  bool   _showPass   = false;
  bool   _isLoading  = false;
  bool   _btnPressed = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.18), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _cardCtrl.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── KEY FIX: go to /school/layout (the nav shell), NOT /school/dashboard ──

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final success = await SchoolApiService.instance.login(
      _emailCtrl.text.trim(), 
      _passCtrl.text,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/school/layout');   // ← enters the bottom-nav shell
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryBlue, kDeepBlue, Color(0xFF002171)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative blobs
          Positioned(
            top: -80, left: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100, right: -70,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSkyBlue.withOpacity(0.08),
              ),
            ),
          ),

          // Floating emojis
          ..._floatItems.map(_buildFloatItem),

          // Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40),
              child: FadeTransition(
                opacity: _cardFade,
                child: SlideTransition(
                  position: _cardSlide,
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatItem(_FloatItem item) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, __) {
        final offset =
            sin(_floatCtrl.value * 2 * pi + item.phaseOffset) * item.amplitude;
        return Positioned(
          left: item.left,
          top:  item.top + offset,
          child: Opacity(
            opacity: 0.55,
            child: Text(item.emoji, style: TextStyle(fontSize: item.size)),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: kCardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kDeepBlue.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: kSelectedBg,
              shape: BoxShape.circle,
              border: Border.all(color: kCardBorder, width: 1.5),
            ),
            child: const Center(
              child: Text('🎒', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Hello Explorer!',
            style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800,
              color: kTextDark, letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to start your tech adventure 🚀',
            style: TextStyle(fontSize: 13, color: kTextMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Star row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (_) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Icon(Icons.star_rounded,
                  color: Color(0xFFFFB300), size: 20),
            )),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _emailCtrl,
            label: 'Your Email',
            prefixEmoji: '📧',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _passCtrl,
            label: 'Password',
            prefixEmoji: '🔒',
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: kTextMuted, size: 20,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: kPrimaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          _buildLoginButton(),
          const SizedBox(height: 18),

          // Sign up row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New here? ',
                style: TextStyle(fontSize: 13, color: kTextMuted),
              ),
              GestureDetector(
                onTap: () => context.go('/school/signup'),  // ← go_router
                child: const Text(
                  'Join the Fun! 🎉',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: kPrimaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Parents note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFFEE58), width: 1.5),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👨‍👩‍👧', style: TextStyle(fontSize: 20)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String prefixEmoji,
    bool obscure                  = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
      decoration: InputDecoration(
        labelText: '$prefixEmoji  $label',
        labelStyle: const TextStyle(
            fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: kInputFill,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCardBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCardBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _btnPressed
                ? []
                : [
              BoxShadow(
                color: kPrimaryBlue.withOpacity(0.35),
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Let's Go!",
                  style: TextStyle(
                    color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.w800, letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}