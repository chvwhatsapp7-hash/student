import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk = Color(0xFF0F172A);
const kSlate = Color(0xFF334155);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kPrimary = Color(0xFF1D4ED8);
const kAccent = Color(0xFF38BDF8);
const kSelectedBg = Color(0xFFEFF6FF);
const kInputFill = Color(0xFFF8FAFC);

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

  late AnimationController _headerAnim;
  late AnimationController _fieldsAnim;
  late AnimationController _btnCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _fieldsFade;
  late Animation<Offset> _fieldsSlide;
  late Animation<double> _btnScale;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _fieldsAnim.forward();
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _fieldsAnim.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── VALIDATION HELPERS ─────────────────────

  void _showErrorSnack(String message) {
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

  void _showNoAccountDialog() {
    // 👇 Responsive values inside dialog too
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
                      'We couldn\'t find an account with these credentials.\nPlease create an account first to sign in.',
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
                            colors: [kPrimary, Color(0xFF4F46E5)],
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

  // ── SIGN IN — API completely untouched ──────

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
    final body = {
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        print("📦 Full API Response: ${data}");
        print("📦 data['data'] keys: ${data['data']?.keys}");
        final userId = data["data"]["user_id"];
        final roleId = data["data"]["role_id"];
        final userName = data["data"]["full_name"];

        await _storage.write(key: 'full_name', value: userName ?? '');
        await _storage.write(key: "user_id", value: userId.toString());
        await _storage.write(key: "role_id", value: roleId.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Text(
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
          context.go('/engineering');
        } else if (roleId == 2) {
          context.go('/school/layout');
        } else {
          context.go('/');
        }

        print("✅ User ID: $userId, Role ID: $roleId,User Name: $userName");
      } else {
        _showNoAccountDialog();
        print("❌ ${data["message"]}");
      }
    } catch (e) {
      _showErrorSnack('Something went wrong. Please try again.');
      print("❌ Sign In Error: $e");
    }

    setState(() => _isLoading = false);
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width; // 👈 responsive base
    final sh = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kInk,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background blobs — responsive positions
            Positioned(
              top: -sh * 0.10,
              right: -sw * 0.15,
              child: Container(
                width: sw * 0.60,
                height: sw * 0.60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -sh * 0.10,
              left: -sw * 0.15,
              child: Container(
                width: sw * 0.65,
                height: sw * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withValues(alpha: 0.06),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05, // ~20px on 400px screen
                  vertical: sh * 0.02,
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
                    SizedBox(height: sh * 0.03),

                    FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeroText(sw),
                      ),
                    ),
                    SizedBox(height: sh * 0.035),

                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(sw),
                      ),
                    ),
                    SizedBox(height: sh * 0.025),

                    FadeTransition(
                      opacity: _fieldsFade,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                color: Colors.white.withValues(alpha: 0.50),
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
                      ),
                    ),
                    SizedBox(height: sh * 0.035),
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
            width: sw * 0.09,
            height: sw * 0.09,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: sw * 0.04,
            ),
          ),
        ),
        SizedBox(width: sw * 0.035),
        Container(
          width: sw * 0.085,
          height: sw * 0.085,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('⚡', style: TextStyle(fontSize: sw * 0.04)),
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
              'Welcome back',
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
          'Sign In',
          style: TextStyle(
            fontSize: sw * 0.07, // ~28px on 400px screen
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        SizedBox(height: sw * 0.02),
        Text(
          'Enter your credentials to continue.',
          style: TextStyle(
            fontSize: sw * 0.033,
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  // ── FORM CARD ──────────────────────────────

  Widget _buildFormCard(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.055), // ~22px on 400px screen
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kInk.withValues(alpha: 0.20),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                width: sw * 0.09,
                height: sw * 0.09,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: sw * 0.045,
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                // 👈 prevents overflow in narrow screens
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    Text(
                      'Your portal is auto-detected after sign in',
                      style: TextStyle(fontSize: sw * 0.028, color: kMuted),
                      overflow: TextOverflow.ellipsis,
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
          SizedBox(height: sw * 0.03),

          _field(
            ctrl: _passCtrl,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: !_showPass,
            sw: sw,
            suffix: IconButton(
              icon: Icon(
                _showPass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
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
              onTap: () {
                context.push('/update-password');
              },
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
        ],
      ),
    );
  }

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
          horizontal: sw * 0.04,
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
          borderSide: const BorderSide(color: kPrimary, width: 2),
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
          padding: EdgeInsets.symmetric(vertical: sw * 0.038),
          decoration: BoxDecoration(
            gradient: _btnPressed
                ? null
                : const LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: _btnPressed ? kPrimary : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.35),
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
                      Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: sw * 0.045,
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Sign In',
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
}
