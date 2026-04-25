import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internship_app/services/fcm_token_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../api_services/authservice.dart';
import '../premium/premium_bottom_sheet.dart';
import '../premium/premium_helper.dart';

// ── DESIGN TOKENS ────────────────────────────────────────────────────────────
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

// ── ORB MODEL ────────────────────────────────────────────────────────────────
class Orb {
  final double x, y, size, phase, speed;
  final Color color;
  const Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.phase,
    required this.speed,
  });
}

const orbs = [
  Orb(
    x: 0.85,
    y: 0.04,
    size: 200,
    color: Color(0xFF1D4ED8),
    phase: 0.0,
    speed: 0.6,
  ),
  Orb(
    x: 0.05,
    y: 0.10,
    size: 160,
    color: Color(0xFF7C3AED),
    phase: 1.2,
    speed: 0.8,
  ),
  Orb(
    x: 0.90,
    y: 0.38,
    size: 110,
    color: Color(0xFF38BDF8),
    phase: 2.4,
    speed: 0.5,
  ),
  Orb(
    x: 0.02,
    y: 0.46,
    size: 90,
    color: Color(0xFFF43F5E),
    phase: 0.7,
    speed: 0.7,
  ),
];

class Particle {
  final String emoji;
  final double x, y, size, phase, amplitude;
  const Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.amplitude,
  });
}

const particles = [
  Particle(emoji: '🎓', x: 0.05, y: 0.20, size: 18, phase: 0.0, amplitude: 12),
  Particle(emoji: '💼', x: 0.88, y: 0.14, size: 20, phase: 1.1, amplitude: 16),
  Particle(emoji: '🚀', x: 0.84, y: 0.40, size: 15, phase: 0.5, amplitude: 14),
  Particle(emoji: '⭐', x: 0.06, y: 0.48, size: 17, phase: 2.2, amplitude: 10),
  Particle(emoji: '💡', x: 0.48, y: 0.04, size: 14, phase: 0.8, amplitude: 18),
];

// ── SCREEN ───────────────────────────────────────────────────────────────────
class CommonLoginScreen extends StatefulWidget {
  const CommonLoginScreen({super.key});

  @override
  State<CommonLoginScreen> createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends State<CommonLoginScreen>
    with TickerProviderStateMixin {
  bool showPass = false;
  bool isLoading = false;
  bool isGoogleLoading = false;
  bool btnPressed = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // ✅ CHANGE 1: class-level instance — NOT inside the method
  final _googleSignIn = GoogleSignIn(scopes: ['email']);

  late AnimationController orbCtrl, particleCtrl, pulseCtrl, heroCtrl, btnCtrl;
  late Animation<double> heroFade, badgeFade, pulse, btnScale;
  late Animation<Offset> heroSlide;

  @override
  void initState() {
    super.initState();
    orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    pulse = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut));
    heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    heroFade = CurvedAnimation(parent: heroCtrl, curve: Curves.easeOut);
    heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: heroCtrl, curve: Curves.easeOut));
    badgeFade = CurvedAnimation(
      parent: heroCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: btnCtrl, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) heroCtrl.forward();
    });
  }

  @override
  void dispose() {
    orbCtrl.dispose();
    particleCtrl.dispose();
    pulseCtrl.dispose();
    heroCtrl.dispose();
    btnCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // ── VALIDATION HELPERS ───────────────────────────────────────────────────
  void showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
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

  void showNoAccountDialog() {
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
                        border: Border.all(
                          color: const Color(0xFFFCA5A5),
                          width: 2,
                        ),
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
                      'We couldn\'t find an account with these credentials. Create an account first to sign in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        color: kMuted,
                        height: 1.6,
                      ),
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
                              Icon(
                                Icons.person_add_rounded,
                                color: Colors.white,
                                size: sw * 0.045,
                              ),
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

  // ── SIGN IN ──────────────────────────────────────────────────────────────
  Future<void> signIn() async {
    if (emailCtrl.text.trim().isEmpty && passCtrl.text.trim().isEmpty) {
      showErrorSnack('Please enter your email and password to sign in.');
      return;
    }
    if (emailCtrl.text.trim().isEmpty) {
      showErrorSnack('Email address is required.');
      return;
    }
    if (passCtrl.text.trim().isEmpty) {
      showErrorSnack('Password is required.');
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
      'https://studenthub-backend-woad.vercel.app/api/auth/login',
    );
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': emailCtrl.text.trim(),
              'password': passCtrl.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final String accessToken = data['data']['accessToken'];
        final String refreshToken = data['data']['refreshToken'];
        final Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
        debugPrint('JWT Payload: $payload');

        // ✅ FIX 1: was 'userid', correct key is 'user_id'
        final String userId = payload['user_id'].toString();
        final int roleId = payload['role_id'] is int
            ? payload['role_id']
            : int.tryParse(payload['role_id'].toString()) ?? 0;
        final String userName = payload['full_name'] ?? '';

        debugPrint('roleId: $roleId');
        debugPrint('User ID: $userId, Role: $roleId, Name: $userName');

        // ✅ FIX 2: param names match — user_id, role_id, full_name
        await AuthService().saveTokens(
          access: accessToken,
          refresh: refreshToken,
          user_id: userId,
          role_id: roleId.toString(),
          full_name: userName,
        );

        try {
          await FcmTokenService.sendTokenToBackend(accessToken);
          FcmTokenService.listenToTokenRefresh(accessToken);
          debugPrint('FCM token sent successfully.');
        } catch (e) {
          debugPrint('FCM token upload failed (non-fatal): $e');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        if (roleId == 3 || roleId == 4) {
          if (mounted) {
            try {
              final show = await PremiumHelper.shouldShow(onLogin: true);
              if (show && mounted) await showPremiumSheet(context);
            } catch (e) {
              debugPrint('PremiumHelper error (non-fatal): $e');
            }
          }
        }

        if (!mounted) return;

        if (roleId == 3 || roleId == 4) {
          context.go('/engineering');
        } else if (roleId == 2) {
          context.go('/school/layout');
        } else {
          context.go('/engineering');
        }
      } else {
        showNoAccountDialog();
        debugPrint('Login failed: ${data['message']}');
      }
    } catch (e) {
      showErrorSnack('Something went wrong. Please try again.');
      debugPrint('Sign In Error: $e');
    }

    if (mounted) setState(() => isLoading = false);
  }

  // ── GOOGLE SIGN IN ───────────────────────────────────────────────────────
  Future<void> handleGoogleSignIn() async {
    try {
      setState(() => isGoogleLoading = true);

      // ✅ FIX: always show account picker — removed signInSilently()
      await _googleSignIn
          .signOut(); // clears cached account so picker always appears
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        showErrorSnack('Could not get ID token. Try again.');
        if (mounted) setState(() => isGoogleLoading = false);
        return;
      }

      debugPrint('Got idToken: ${idToken.substring(0, 20)}...');

      final url = Uri.parse(
        'https://studenthub-backend-woad.vercel.app/api/auth/google-login',
      );
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      debugPrint('Google Login Response: $data');

      if (response.statusCode == 200) {
        final String accessToken = data['data']['accessToken'];
        final String refreshToken = data['data']['refreshToken'];
        final user = data['user'];

        await AuthService().saveTokens(
          access: accessToken,
          refresh: refreshToken,
          user_id: user['user_id'].toString(),
          role_id: user['role_id'].toString(),
          full_name: user['full_name'] ?? '',
        );

        try {
          await FcmTokenService.sendTokenToBackend(accessToken);
          FcmTokenService.listenToTokenRefresh(accessToken);
          debugPrint('FCM token sent successfully.');
        } catch (e) {
          debugPrint('FCM token upload failed (non-fatal): $e');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Google Sign-In Successful!',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        // ✅ FIX: was user['roleid'] — correct key is role_id
        final int roleId = int.tryParse(user['role_id'].toString()) ?? 0;
        if (!mounted) return;

        if (roleId == 3 || roleId == 4) {
          try {
            final show = await PremiumHelper.shouldShow(onLogin: true);
            if (show && mounted) await showPremiumSheet(context);
          } catch (e) {
            debugPrint('PremiumHelper error (non-fatal): $e');
          }
        }

        if (!mounted) return;

        if (roleId == 0) {
          context.go('/select-role');
        }
        // ✅ SCHOOL
        else if (roleId == 2) {
          context.go('/school/layout');
        }
        // ✅ ENGINEERING
        else if (roleId == 3 || roleId == 4) {
          context.go('/engineering');
        }
      } else {
        showErrorSnack(data['message'] ?? 'Google login failed');
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      showErrorSnack('Google Sign-In failed. Please try again.');
    }

    if (mounted) setState(() => isGoogleLoading = false);
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
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
            ...orbs.map((orb) => _buildOrb(orb, sw, sh)),
            ...particles.map((p) => _buildParticle(p, sw, sh)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sh * 0.018,
                ),
                child: FadeTransition(
                  opacity: heroFade,
                  child: SlideTransition(
                    position: heroSlide,
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

  Widget _buildOrb(Orb orb, double sw, double sh) {
    return AnimatedBuilder(
      animation: orbCtrl,
      builder: (_, __) {
        final dy = sin(orbCtrl.value * 2 * pi * orb.phase) * 26 * orb.speed;
        final dx = cos(orbCtrl.value * 2 * pi * 0.4 * orb.phase) * 12;
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

  Widget _buildParticle(Particle p, double sw, double sh) {
    return AnimatedBuilder(
      animation: particleCtrl,
      builder: (_, __) {
        final dy = sin(particleCtrl.value * 2 * pi * p.phase) * p.amplitude;
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
            child: Text('🎓', style: TextStyle(fontSize: sw * 0.042)),
          ),
        ),
        SizedBox(width: sw * 0.028),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Students Hub',
              style: TextStyle(
                fontSize: sw * 0.040,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            // Text(
            //   'Welcome back',
            //   style: TextStyle(
            //     fontSize: sw * 0.025,
            //     color: kAccent,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildHero(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: badgeFade,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.032,
              vertical: sw * 0.016,
            ),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: kAccent.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: pulse,
                  child: Container(
                    width: sw * 0.018,
                    height: sw * 0.018,
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
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
        // Text(
        //   'Your dashboard is auto-detected after sign in.',
        //   style: TextStyle(
        //     fontSize: sw * 0.033,
        //     height: 1.55,
        //     color: Colors.white.withValues(alpha: 0.52),
        //   ),
        // ),
      ],
    );
  }

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
                child: Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: sw * 0.055,
                ),
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
                    // Text(
                    //   '256-bit encrypted connection',
                    //   style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.05),
          _field(
            ctrl: emailCtrl,
            label: 'Email Address',
            icon: Icons.alternate_email_rounded,
            type: TextInputType.emailAddress,
            sw: sw,
          ),
          SizedBox(height: sw * 0.030),
          _field(
            ctrl: passCtrl,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: !showPass,
            sw: sw,
            suffix: IconButton(
              icon: Icon(
                showPass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: kMuted,
                size: sw * 0.045,
              ),
              onPressed: () => setState(() => showPass = !showPass),
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
              const Expanded(child: Divider(color: kBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
                child: Text(
                  'or continue with',
                  style: TextStyle(fontSize: sw * 0.028, color: kHint),
                ),
              ),
              const Expanded(child: Divider(color: kBorder)),
            ],
          ),
          SizedBox(height: sw * 0.035),
          // ── ONLY CHANGE: was Row{ Google half + LinkedIn half }
          //                 now full-width Google button with real "G" logo ──
          _buildGoogleBtn(sw),
        ],
      ),
    );
  }

  // ── NEW: full-width Google button, official branding, same onTap ─────────
  Widget _buildGoogleBtn(double sw) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isLoading || isGoogleLoading ? null : handleGoogleSignIn,
      child: Container(
        width: double.infinity,
        height: sw * 0.135,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDADCE0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGoogleLoading
            ? Center(
                child: SizedBox(
                  width: sw * 0.052,
                  height: sw * 0.052,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4285F4),
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Four-colour Google "G" — drawn with canvas, no assets needed
                  CustomPaint(
                    size: Size(sw * 0.058, sw * 0.058),
                    painter: _GoogleGPainter(),
                  ),
                  SizedBox(width: sw * 0.030),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3C4043),
                      letterSpacing: 0.1,
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
        btnCtrl.forward();
        setState(() => btnPressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        btnCtrl.reverse();
        setState(() => btnPressed = false);
        signIn();
      },
      onTapCancel: () {
        btnCtrl.reverse();
        setState(() => btnPressed = false);
      },
      child: ScaleTransition(
        scale: btnScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: sw * 0.040),
          decoration: BoxDecoration(
            gradient: btnPressed
                ? null
                : const LinearGradient(
                    colors: [kPrimary, kViolet],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: btnPressed ? kPrimary : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: btnPressed
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
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
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
            'Don\'t have an account? ',
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

// ── GOOGLE "G" PAINTER ───────────────────────────────────────────────────────
/// Paints the official four-colour Google "G" mark using canvas arcs.
/// No image assets or external packages required.
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final sw = size.width * 0.22;
    final ir = r - sw / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: ir);

    double rad(double deg) => deg * pi / 180;

    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    // Red  – top-left  (~246° to 306°)
    p.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, rad(246), rad(60), false, p);

    // Blue – right     (~306° to 108°, sweep 162°)
    p.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, rad(306), rad(162), false, p);

    // Green – bottom-right (~108° to 180°)
    p.color = const Color(0xFF34A853);
    canvas.drawArc(rect, rad(108), rad(72), false, p);

    // Yellow – bottom-left (~180° to 246°)
    p.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, rad(180), rad(66), false, p);

    // White blocker — cuts the right side open for the "G" shape
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - sw * 0.55, cx + r + 2, cy + sw * 0.55),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Blue crossbar — the horizontal bar of the "G"
    final barH = sw * 0.95;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(
          cx - sw * 0.05,
          cy - barH / 2,
          cx + ir + sw * 0.5,
          cy + barH / 2,
        ),
        topRight: Radius.circular(barH / 2),
        bottomRight: Radius.circular(barH / 2),
      ),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
