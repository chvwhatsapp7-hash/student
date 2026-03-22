import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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
//  SCREEN
// ─────────────────────────────────────────────

class CommonLoginScreen extends StatefulWidget {
  const CommonLoginScreen({super.key});

  @override
  State<CommonLoginScreen> createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends State<CommonLoginScreen>
    with TickerProviderStateMixin {

  bool _showPass   = false;
  bool _isLoading  = false;
  bool _btnPressed = false;

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // Animation controllers
  late AnimationController _headerAnim;
  late AnimationController _fieldsAnim;
  late AnimationController _btnCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double>  _fieldsFade;
  late Animation<Offset>  _fieldsSlide;
  late Animation<double>  _btnScale;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));

    _fieldsAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _fieldsFade  = CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut);
    _fieldsSlide = Tween<Offset>(
      begin: const Offset(0, 0.10), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fieldsAnim, curve: Curves.easeOut));

    _btnCtrl  = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );

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

  // Shows a styled snackbar for field errors
  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13,
                  )),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Shows "Account not found — please create account" dialog
  void _showNoAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kInk.withValues(alpha: 0.15),
                blurRadius: 40, offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient top band
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFEF4444),
                      kAccent],
                  ),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFF1F2),
                        border: Border.all(
                            color: const Color(0xFFFCA5A5), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_off_rounded,
                            color: Color(0xFFDC2626), size: 32),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Account Not Found',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: kInk, letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 8),
                    const Text(
                      'We couldn\'t find an account with these credentials.\nPlease create an account first to sign in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: kMuted, height: 1.6),
                    ),
                    const SizedBox(height: 22),

                    // Create account button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/signup');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Create Account',
                                  style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Try again button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('Try Again',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: kMuted,
                              )),
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
    // ── Validation: empty field checks ─────────
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

    // ── API call — completely untouched ─────────
    final url = Uri.parse(
      'https://studenthub-backend-woad.vercel.app/api/auth/login',
    );

    final body = {
      "email":    _emailCtrl.text.trim(),
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
        final userId = data["data"]["user_id"];
        final roleId = data["data"]["role_id"];

        await _storage.write(key: "user_id", value: userId.toString());
        await _storage.write(key: "role_id", value: roleId.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                const Text('Signed in successfully!',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate based on role returned by API — untouched
        if (roleId == 3 || roleId == 4) {
          context.go('/engineering');
        } else if (roleId == 2) {
          context.go('/school/layout');
        } else {
          context.go('/');
        }

        print("✅ User ID: $userId, Role ID: $roleId");
      } else {
        // Account not found or wrong credentials → show dialog
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
                  color: kPrimary.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -80, left: -60,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withValues(alpha: 0.06),
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
                    const SizedBox(height: 28),

                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign up link
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
                                color: Colors.white.withValues(alpha: 0.50),
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
              color: Colors.white.withValues(alpha: 0.10),
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
            color: Colors.white.withValues(alpha: 0.10),
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
                  color: Colors.white,
                )),
            Text('Welcome back',
                style: TextStyle(
                  fontSize: 10, color: kHint,
                  fontWeight: FontWeight.w600,
                )),
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
          'Enter your credentials to continue.',
          style: TextStyle(
            fontSize: 13, height: 1.5,
            color: Colors.white.withValues(alpha: 0.55),
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
            color: kInk.withValues(alpha: 0.20),
            blurRadius: 36, offset: const Offset(0, 14),
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
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: kInk,
                      )),
                  Text('Your portal is auto-detected after sign in',
                      style: TextStyle(
                          fontSize: 11, color: kMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Email
          _field(
            ctrl:  _emailCtrl,
            label: 'Email Address',
            icon:  Icons.alternate_email_rounded,
            type:  TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Password
          _field(
            ctrl:    _passCtrl,
            label:   'Password',
            icon:    Icons.lock_outline_rounded,
            obscure: !_showPass,
            suffix: IconButton(
              icon: Icon(
                _showPass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: kMuted, size: 18,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),

          // Forgot password
          const SizedBox(height: 10),
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
          const SizedBox(height: 18),

          // Info note
          // Container(
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: kSelectedBg,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: kBorder),
          //   ),
          //   child: const Row(
          //     children: [
          //       Icon(Icons.info_outline_rounded,
          //           size: 16, color: kPrimary),
          //       SizedBox(width: 10),
          //       Expanded(
          //         child: Text(
          //           'Your portal is automatically assigned based on the role you selected during sign up.',
          //           style: TextStyle(
          //             fontSize: 11, color: kPrimary,
          //             height: 1.5, fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 18),

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
    TextInputType type  = TextInputType.text,
    bool obscure        = false,
    Widget? suffix,
  }) {
    return TextField(
      controller:   ctrl,
      obscureText:  obscure,
      keyboardType: type,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: const TextStyle(
            fontSize: 13, color: kMuted, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: kMuted, size: 18),
        suffixIcon: suffix,
        filled:    true,
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
        _signIn();   // ← calls _signIn not _login
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
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Sign In',
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