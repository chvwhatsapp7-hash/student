import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  DESIGN TOKENS (same as signup screen)
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
//  UPDATE PASSWORD SCREEN
// ─────────────────────────────────────────────
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _emailCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // State
  bool _showNewPass = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  bool _btnPressed = false;

  // Animations (reuse pattern from signup)
  late AnimationController _headerAnim, _fieldsAnim, _btnCtrl;
  late Animation<double> _headerFade, _fieldsFade, _btnScale;
  late Animation<Offset> _headerSlide, _fieldsSlide;

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

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fieldsAnim.forward();
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _fieldsAnim.dispose();
    _btnCtrl.dispose();
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── UPDATE PASSWORD API ─────────────────────
  Future<void> _updatePassword() async {
    if (_newPassCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (_emailCtrl.text.trim().isEmpty || _newPassCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Change this URL to your actual update-password endpoint
    final url = Uri.parse(
      'https://studenthub-backend-woad.vercel.app/api/auth/update-password',
    );

    final body = {
      'email': _emailCtrl.text.trim(),
      'password': _newPassCtrl.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        context.go('/login');
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Password update failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            // Background blobs (same style as signup)
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
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: _buildFormCard(sw),
                      ),
                    ),
                    SizedBox(height: sw * 0.040),
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
          onTap: () => context.go('/login'),
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
            child: Text('🔒', style: TextStyle(fontSize: sw * 0.040)),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Secure your account',
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
          'Update your password',
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
          'Enter your email and choose a new password.',
          style: TextStyle(
            fontSize: sw * 0.033,
            height: 1.5,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  // ── FORM CARD ──────────────────────────────
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
              Container(
                width: sw * 0.070,
                height: sw * 0.070,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('🔐', style: TextStyle(fontSize: sw * 0.035)),
                ),
              ),
              SizedBox(width: sw * 0.025),
              Text(
                'Update Password',
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.045),

          _field(
            ctrl: _emailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            sw: sw,
            type: TextInputType.emailAddress,
          ),
          SizedBox(height: sw * 0.030),

          _field(
            ctrl: _newPassCtrl,
            label: 'New Password',
            icon: Icons.lock_outline,
            sw: sw,
            obscure: !_showNewPass,
            suffix: IconButton(
              icon: Icon(
                _showNewPass ? Icons.visibility_off : Icons.visibility,
                color: kMuted,
                size: sw * 0.045,
              ),
              onPressed: () => setState(() => _showNewPass = !_showNewPass),
            ),
          ),
          SizedBox(height: sw * 0.030),

          _field(
            ctrl: _confirmCtrl,
            label: 'Re-type Password',
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
          SizedBox(height: sw * 0.040),

          Text(
            'Make sure your new password is strong and unique.',
            style: TextStyle(fontSize: sw * 0.028, color: kHint, height: 1.5),
          ),
          SizedBox(height: sw * 0.045),

          _buildSubmitBtn(sw),
        ],
      ),
    );
  }

  // ── TEXT FIELD WIDGET (same style as signup) ─
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
          borderSide: const BorderSide(color: kAccent, width: 2),
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
        _updatePassword();
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
            color: kAccent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _btnPressed
                ? null
                : [
                    BoxShadow(
                      color: kAccent.withOpacity(0.35),
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
                      Text('🔑', style: TextStyle(fontSize: sw * 0.040)),
                      SizedBox(width: sw * 0.020),
                      Text(
                        'Update Password',
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
