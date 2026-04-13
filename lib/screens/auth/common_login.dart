import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../api_services/authservice.dart';
import '../premium/premium_bottom_sheet.dart'; // ✅ NEW
import '../premium/premium_helper.dart';        // ✅ NEW

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk = Color(0xFF0A0F1E);
const kSlate = Color(0xFF334155);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kPrimary = Color(0xFF1D4ED8);
const kViolet = Color(0xFF4F46E5);
const kAccent = Color(0xFF38BDF8);
const kRose = Color(0xFFF43F5E);
const kSelectedBg = Color(0xFFEFF6FF);
const kInputFill = Color(0xFFF8FAFC);

// ─────────────────────────────────────────────
//  ORB MODEL
// ─────────────────────────────────────────────

class _Orb {
  final double x, y, size, phase, speed;
  final Color color;
  const _Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.phase,
    required this.speed,
  });
}

const _orbs = [
  _Orb(x: 0.85, y: 0.04, size: 200, color: Color(0xFF1D4ED8), phase: 0.0, speed: 0.6),
  _Orb(x: 0.05, y: 0.10, size: 160, color: Color(0xFF7C3AED), phase: 1.2, speed: 0.8),
  _Orb(x: 0.90, y: 0.38, size: 110, color: Color(0xFF38BDF8), phase: 2.4, speed: 0.5),
  _Orb(x: 0.02, y: 0.46, size: 90,  color: Color(0xFFF43F5E), phase: 0.7, speed: 0.7),
];

class _Particle {
  final String emoji;
  final double x, y, size, phase, amplitude;
  const _Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.amplitude,
  });
}

const _particles = [
  _Particle(emoji: '💻', x: 0.05, y: 0.20, size: 18, phase: 0.0, amplitude: 12),
  _Particle(emoji: '🤖', x: 0.88, y: 0.14, size: 20, phase: 1.1, amplitude: 16),
  _Particle(emoji: '⭐', x: 0.84, y: 0.40, size: 15, phase: 0.5, amplitude: 14),
  _Particle(emoji: '🎮', x: 0.06, y: 0.48, size: 17, phase: 2.2, amplitude: 10),
  _Particle(emoji: '🌟', x: 0.48, y: 0.04, size: 14, phase: 0.8, amplitude: 18),
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
  bool _showPass = false;
  bool _isLoading = false;
  bool _btnPressed = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late AnimationController _orbCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _btnCtrl;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _badgeFade;
  late Animation<double> _pulse;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _badgeFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _heroCtrl.forward();
    });
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    _heroCtrl.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── VALIDATION HELPERS ──────────────────────

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showNoAccountDialog() {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kInk.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFEF4444), kAccent],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(sw * 0.06, 22, sw * 0.06, 24),
                child: Column(
                  children: [
                    Container(
                      width: sw * 0.17,
                      height: sw * 0.17,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFF1F2),
                        border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_off_rounded,
                          color: const Color(0xFFDC2626),
                          size: sw * 0.08,
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.04),
                    Text(
                      'Account Not Found',
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: sw * 0.02),
                    Text(
                      'We couldn\'t find an account with these credentials.\nPlease create an account first to sign in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: sw * 0.033, color: kMuted, height: 1.6),
                    ),
                    SizedBox(height: sw * 0.055),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/signup');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimary, kViolet],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_rounded, color: Colors.white, size: sw * 0.045),
                              SizedBox(width: sw * 0.02),
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: sw * 0.038,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sw * 0.025),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.033),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              fontWeight: FontWeight.w700,
                              color: kMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SIGN IN ─────────────────────────────────

  Future<void> _signIn() async {
    if (_emailCtrl.text.trim().isEmpty && _passCtrl.text.trim().isEmpty) {
      _showErrorSnack('Please enter your email and password to sign in.');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      _showErrorSnack('Email address is required.');
      return;
    }
    if (_passCtrl.text.trim().isEmpty) {
      _showErrorSnack('Password is required.');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://studenthub-backend-woad.vercel.app/api/auth/login',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailCtrl.text.trim(),
          "password": _passCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final String accessToken = data["data"]["accessToken"];
        final String refreshToken = data["data"]["refreshToken"];

        final Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
        debugPrint("📦 JWT Payload: $payload");

        // ✅ Declare ALL variables FIRST before using them
        final String userId = payload['user_id'].toString();
        final int roleId = payload['role_id'] is int
            ? payload['role_id']
            : int.tryParse(payload['role_id'].toString()) ?? 0;
        final String userName = payload['full_name'] ?? '';

        // ✅ Now safe to print
        debugPrint("🎯 roleId = $roleId (type: ${roleId.runtimeType})");
        debugPrint("✅ User ID: $userId, Role: $roleId, Name: $userName");

        await AuthService().saveTokens(
          access: accessToken,
          refresh: refreshToken,
          user_id: userId,
          role_id: roleId.toString(),
          full_name: userName,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Signed in successfully!',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        // ✅ Premium check wrapped in try/catch so it never blocks navigation
        if ((roleId == 3 || roleId == 4) && mounted) {
          try {
            final show = await PremiumHelper.shouldShow(onLogin: true);
            if (show && mounted) {
              await showPremiumSheet(context);
            }
          } catch (e) {
            debugPrint("⚠️ PremiumHelper error (non-fatal): $e");
          }
        }

        if (!mounted) return;

        // ✅ Fixed fallback — '/' has no route so use '/engineering' instead
        if (roleId == 3 || roleId == 4) {
          context.go('/engineering');
        } else if (roleId == 2) {
          context.go('/school/layout');
        } else {
          debugPrint("⚠️ Unknown roleId: $roleId — check JWT payload above");
          context.go('/engineering');
        }
      } else {
        _showNoAccountDialog();
        debugPrint("❌ Login failed: ${data["message"]}");
      }
    } catch (e) {
      _showErrorSnack('Something went wrong. Please try again.');
      debugPrint("❌ Sign In Error: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kInk,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── Animated orbs ─────────────────
            ..._orbs.map((orb) => _buildOrb(orb, sw, sh)),
            // ── Floating particles ────────────
            ..._particles.map((p) => _buildParticle(p, sw, sh)),
            // ── Bottom fade overlay ───────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: sh * 0.22,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [kInk, kInk.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ),
            ),
            // ── Main scrollable content ───────
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sh * 0.018,
                ),
                child: FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNavBar(sw),
                        SizedBox(height: sh * 0.028),
                        _buildHero(sw, sh),
                        SizedBox(height: sh * 0.030),
                        _buildFormCard(sw),
                        SizedBox(height: sh * 0.022),
                        _buildSignupRow(sw),
                        SizedBox(height: sh * 0.030),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Orb & particle helpers ─────────────────

  Widget _buildOrb(_Orb orb, double sw, double sh) {
    return AnimatedBuilder(
      animation: _orbCtrl,
      builder: (_, __) {
        final dy = sin(_orbCtrl.value * 2 * pi + orb.phase) * 26 * orb.speed;
        final dx = cos(_orbCtrl.value * 2 * pi * 0.4 + orb.phase) * 12;
        return Positioned(
          left: sw * orb.x + dx - orb.size / 2,
          top: sh * orb.y + dy - orb.size / 2,
          child: Container(
            width: orb.size,
            height: orb.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: orb.color.withValues(alpha: 0.16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(_Particle p, double sw, double sh) {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        final dy = sin(_particleCtrl.value * 2 * pi + p.phase) * p.amplitude;
        return Positioned(
          left: sw * p.x,
          top: sh * p.y + dy,
          child: Opacity(
            opacity: 0.40,
            child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
          ),
        );
      },
    );
  }

  // ── Nav bar ────────────────────────────────

  Widget _buildNavBar(double sw) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: sw * 0.10,
            height: sw * 0.10,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: sw * 0.040,
            ),
          ),
        ),
        SizedBox(width: sw * 0.030),
        Container(
          width: sw * 0.095,
          height: sw * 0.095,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Center(
            child: Text('⚡', style: TextStyle(fontSize: sw * 0.042)),
          ),
        ),
        SizedBox(width: sw * 0.028),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NextStep',
              style: TextStyle(
                fontSize: sw * 0.040,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: sw * 0.025,
                color: kAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Hero text + badge ──────────────────────

  Widget _buildHero(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _badgeFade,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.032,
              vertical: sw * 0.016,
            ),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kAccent.withValues(alpha: 0.40), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    width: sw * 0.018,
                    height: sw * 0.018,
                    decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
                  ),
                ),
                SizedBox(width: sw * 0.020),
                Text(
                  'India\'s #1 Campus-to-Career Platform',
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w700,
                    color: kAccent,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sh * 0.022),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: sw * 0.080,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
            children: [
              const TextSpan(text: 'Sign In to\n'),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [kAccent, kViolet, kRose],
                  ).createShader(bounds),
                  child: Text(
                    'Your Portal',
                    style: TextStyle(
                      fontSize: sw * 0.080,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sw * 0.022),
        Text(
          'Your dashboard is auto-detected after sign in.',
          style: TextStyle(
            fontSize: sw * 0.033,
            height: 1.55,
            color: Colors.white.withValues(alpha: 0.52),
          ),
        ),
      ],
    );
  }

  // ── Form card ─────────────────────────────

  Widget _buildFormCard(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.055),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kInk.withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.11,
                height: sw * 0.11,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kViolet],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.shield_rounded, color: Colors.white, size: sw * 0.055),
              ),
              SizedBox(width: sw * 0.030),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Sign In',
                      style: TextStyle(
                        fontSize: sw * 0.040,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    Text(
                      '256-bit encrypted connection',
                      style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.05),

          _field(
            ctrl: _emailCtrl,
            label: 'Email Address',
            icon: Icons.alternate_email_rounded,
            type: TextInputType.emailAddress,
            sw: sw,
          ),
          SizedBox(height: sw * 0.030),
          _field(
            ctrl: _passCtrl,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: !_showPass,
            sw: sw,
            suffix: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: kMuted,
                size: sw * 0.045,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
          SizedBox(height: sw * 0.025),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.push('/update-password'),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: sw * 0.030,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: sw * 0.045),

          _buildSubmitBtn(sw),

          SizedBox(height: sw * 0.045),

          Row(
            children: [
              Expanded(child: Container(height: 1, color: kBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
                child: Text(
                  'or continue with',
                  style: TextStyle(fontSize: sw * 0.028, color: kHint),
                ),
              ),
              Expanded(child: Container(height: 1, color: kBorder)),
            ],
          ),
          SizedBox(height: sw * 0.035),

          Row(
            children: [
              Expanded(child: _socialBtn('Google', '🅖', sw, isGoogle: true)),
              SizedBox(width: sw * 0.025),
              Expanded(child: _socialBtn('LinkedIn', '🔗', sw)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(String label, String icon, double sw, {bool isGoogle = false}) {
    return Container(
      height: sw * 0.115,
      decoration: BoxDecoration(
        color: kInputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isGoogle ? 'G' : 'in',
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w800,
                color: isGoogle ? const Color(0xFF4285F4) : const Color(0xFF0A66C2),
              ),
            ),
            SizedBox(width: sw * 0.018),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.033,
                fontWeight: FontWeight.w700,
                color: kSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          horizontal: sw * 0.04,
          vertical: sw * 0.040,
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
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitBtn(double sw) {
    return GestureDetector(
      onTapDown: (_) {
        _btnCtrl.forward();
        setState(() => _btnPressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
        _signIn();
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
          padding: EdgeInsets.symmetric(vertical: sw * 0.040),
          decoration: BoxDecoration(
            gradient: _btnPressed
                ? null
                : const LinearGradient(
              colors: [kPrimary, kViolet],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: _btnPressed ? kPrimary : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
              BoxShadow(
                color: kPrimary.withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: kViolet.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
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
                Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: sw * 0.048,
                ),
                SizedBox(width: sw * 0.022),
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: sw * 0.040,
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

  Widget _buildSignupRow(double sw) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontSize: sw * 0.033,
              color: Colors.white.withValues(alpha: 0.48),
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/signup'),
            child: Text(
              'Create Account',
              style: TextStyle(
                fontSize: sw * 0.033,
                fontWeight: FontWeight.w800,
                color: kAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
