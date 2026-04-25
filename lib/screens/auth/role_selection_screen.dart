import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../api_services/authservice.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (same as signup screen)
// ─────────────────────────────────────────────
const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);
const _kHint = Color(0xFF94A3B8);
const _kCardBg = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF1D4ED8);
const _kAccent = Color(0xFF38BDF8);
const _kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  ROLE MODEL
// ─────────────────────────────────────────────
class _Role {
  final String value, label, emoji, subtitle, route;
  final Color accent, bg;
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
    value: 'engineering',
    label: 'Engineering / Graduate',
    emoji: '💼',
    subtitle: 'B.E / B.Tech / B.Sc / Degree',
    accent: _kPrimary,
    bg: _kSelectedBg,
    route: '/engineering',
  ),
  _Role(
    value: 'school',
    label: 'School Student',
    emoji: '🎒',
    subtitle: 'Grade 5 – Grade 12',
    accent: Color(0xFF0D9488),
    bg: Color(0xFFEFFCF9),
    route: '/school/layout',
  ),
  _Role(
    value: 'postgrad',
    label: 'Post Graduation',
    emoji: '📚',
    subtitle: 'M.E / M.Tech / MBA / M.Sc',
    accent: Color(0xFF7C3AED),
    bg: Color(0xFFF5F3FF),
    route: '/engineering', // update when postgrad portal is ready
  ),
];

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

/// Shown after OAuth sign-in when role_id == 0 (brand-new Google account).
/// Saves the chosen role via API → updates secure storage → navigates to portal.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  _Role? _selected;
  bool _isLoading = false;
  bool _btnPressed = false;

  late AnimationController _headerAnim, _cardsAnim, _btnCtrl;
  late Animation<double> _headerFade, _cardsFade;
  late Animation<Offset> _headerSlide, _cardsSlide;
  late Animation<double> _btnScale;

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

    _cardsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardsFade = CurvedAnimation(parent: _cardsAnim, curve: Curves.easeOut);
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardsAnim, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardsAnim.forward();
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _cardsAnim.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  int _toRoleId(String value) {
    switch (value) {
      case 'engineering':
        return 3;
      case 'school':
        return 2;
      case 'postgrad':
        return 4;
      default:
        return 3;
    }
  }

  // ── Save role to backend + secure storage, then navigate ──
  Future<void> _confirm() async {
    if (_selected == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final roleId = _toRoleId(_selected!.value);

    try {
      final userId = AuthService().userId; // ✅ correct

      if (userId == null) {
        _showError('User not found. Please login again.');
        return;
      }

      final response = await AuthService().put('/profile/getUsers', {
        'user_id': userId, // ✅ required by backend
        'role_id': roleId, // ✅ role update
      });

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('DATA: ${response.data}');

      if (response.statusCode == 200) {
        await AuthService().updateRoleId(roleId.toString());

        debugPrint('✅ Role updated to $roleId');

        if (!mounted) return;
        context.go(_selected!.route);
      } else {
        _showError(response.data['message'] ?? 'Failed to save role');
      }
    } catch (e) {
      debugPrint('❌ FULL ERROR: $e');
      _showError('Something went wrong. Please try again.');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kInk,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              top: -sw * 0.20,
              right: -sw * 0.15,
              child: Container(
                width: sw * 0.60,
                height: sw * 0.60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kPrimary.withOpacity(0.10),
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
                  color: _kAccent.withOpacity(0.06),
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
                      opacity: _cardsFade,
                      child: SlideTransition(
                        position: _cardsSlide,
                        child: _buildRoleList(sw),
                      ),
                    ),
                    SizedBox(height: sw * 0.055),
                    FadeTransition(
                      opacity: _cardsFade,
                      child: _buildContinueBtn(sw),
                    ),
                    SizedBox(height: sw * 0.060),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double sw) {
    return Row(
      children: [
        Container(
          width: sw * 0.085,
          height: sw * 0.085,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('⚡', style: TextStyle(fontSize: sw * 0.040)),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Students Hub',
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              'Almost there!',
              style: TextStyle(
                fontSize: sw * 0.025,
                color: _kHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroText(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'One last step',
          style: TextStyle(
            fontSize: sw * 0.070,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        SizedBox(height: sw * 0.018),
        Text(
          'Tell us who you are so we can take you\nto the right portal.',
          style: TextStyle(
            fontSize: sw * 0.033,
            height: 1.5,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleList(double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR ROLE',
          style: TextStyle(
            fontSize: sw * 0.028,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.45),
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: sw * 0.025),
        ..._roles.map(
          (r) => Padding(
            padding: EdgeInsets.only(bottom: sw * 0.028),
            child: _buildRoleTile(r, sw),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTile(_Role r, double sw) {
    final isSelected = _selected?.value == r.value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selected = r);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.040,
          vertical: sw * 0.035,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _kCardBg : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? r.accent.withOpacity(0.55)
                : Colors.white.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kInk.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: sw * 0.130,
              height: sw * 0.130,
              decoration: BoxDecoration(
                color: isSelected ? r.bg : Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(r.emoji, style: TextStyle(fontSize: sw * 0.060)),
              ),
            ),
            SizedBox(width: sw * 0.040),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.label,
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? _kInk : Colors.white,
                    ),
                  ),
                  SizedBox(height: sw * 0.008),
                  Text(
                    r.subtitle,
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      color: isSelected
                          ? _kMuted
                          : Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.030),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: sw * 0.065,
              height: sw * 0.065,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? r.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? r.accent : Colors.white.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: sw * 0.035,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueBtn(double sw) {
    final accent = _selected?.accent ?? _kPrimary;
    final emoji = _selected?.emoji ?? '🚀';
    final enabled = _selected != null && !_isLoading;

    return GestureDetector(
      onTapDown: enabled
          ? (_) {
              _btnCtrl.forward();
              setState(() => _btnPressed = true);
            }
          : null,
      onTapUp: enabled
          ? (_) {
              _btnCtrl.reverse();
              setState(() => _btnPressed = false);
              _confirm();
            }
          : null,
      onTapCancel: () {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
      },
      child: ScaleTransition(
        scale: _btnScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: sw * 0.038),
          decoration: BoxDecoration(
            color: enabled ? accent : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            boxShadow: (enabled && !_btnPressed)
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
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
                      Text(emoji, style: TextStyle(fontSize: sw * 0.040)),
                      SizedBox(width: sw * 0.020),
                      Text(
                        _selected == null
                            ? 'Pick a role to continue'
                            : 'Continue to Portal',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w800,
                          color: enabled
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
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
