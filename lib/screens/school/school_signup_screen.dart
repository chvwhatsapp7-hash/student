import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/school_api_service.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue = Color(0xFF1A73E8);
const kDeepBlue = Color(0xFF0D47A1);
const kSkyBlue = Color(0xFF00B0FF);
const kCardBg = Color(0xFFFFFFFF);
const kCardBorder = Color(0xFFE0E8FB);
const kTextDark = Color(0xFF1A2A5E);
const kTextMuted = Color(0xFF6B80B3);
const kSelectedBg = Color(0xFFE8F1FE);
const kInputFill = Color(0xFFF0F6FF);

// ─────────────────────────────────────────────
//  RESPONSIVE HELPER
// ─────────────────────────────────────────────

class _R {
  final BuildContext ctx;
  const _R(this.ctx);

  double get w => MediaQuery.sizeOf(ctx).width;
  double get h => MediaQuery.sizeOf(ctx).height;
  double get ts => MediaQuery.textScalerOf(ctx).scale(1.0).clamp(1.0, 1.3);

  bool get isTablet => w >= 600;
  bool get isLarge => w >= 900;

  /// Fluid font — scales up on wider screens but clamps textScaler
  double fs(double mobile, {double? tablet, double? large}) {
    double base = mobile;
    if (isLarge && large != null) base = large;
    if (isTablet && tablet != null) base = tablet;
    return base / ts;
  }

  /// Card width: fixed 360 on phones, wider on tablets, capped on large
  double get cardWidth {
    if (isLarge) return (w * 0.44).clamp(480.0, 600.0);
    if (isTablet) return (w * 0.62).clamp(400.0, 520.0);
    return (w - 40).clamp(300.0, 360.0);
  }

  /// Card horizontal padding
  double get cardPad => isTablet ? 32.0 : 26.0;

  /// Outer horizontal padding for the scroll view
  double get scrollHPad => isLarge ? w * 0.06 : 20.0;
}

// ─────────────────────────────────────────────
//  FLOATING ITEM MODEL
// ─────────────────────────────────────────────

class _FloatItem {
  final String emoji;
  final double leftFrac; // fraction of screen width (0–1)
  final double top;
  final double size;
  final double phase;
  final double amp;
  const _FloatItem({
    required this.emoji,
    required this.leftFrac,
    required this.top,
    required this.size,
    required this.phase,
    required this.amp,
  });
}

// left values converted to fractions of a 390-wide reference screen
const _floatItems = [
  _FloatItem(
    emoji: '🌟',
    leftFrac: 0.046,
    top: 85,
    size: 28,
    phase: 0.0,
    amp: 16,
  ),
  _FloatItem(
    emoji: '🚀',
    leftFrac: 0.192,
    top: 52,
    size: 26,
    phase: 0.9,
    amp: 20,
  ),
  _FloatItem(
    emoji: '🤖',
    leftFrac: 0.380,
    top: 96,
    size: 30,
    phase: 1.8,
    amp: 14,
  ),
  _FloatItem(
    emoji: '💡',
    leftFrac: 0.559,
    top: 60,
    size: 24,
    phase: 2.7,
    amp: 18,
  ),
  _FloatItem(
    emoji: '🎨',
    leftFrac: 0.759,
    top: 88,
    size: 26,
    phase: 0.5,
    amp: 22,
  ),
  _FloatItem(
    emoji: '🔬',
    leftFrac: 0.892,
    top: 48,
    size: 24,
    phase: 1.3,
    amp: 16,
  ),
  _FloatItem(
    emoji: '🟣',
    leftFrac: 0.030,
    top: 420,
    size: 16,
    phase: 2.1,
    amp: 12,
  ),
  _FloatItem(
    emoji: '🔵',
    leftFrac: 0.910,
    top: 360,
    size: 15,
    phase: 0.7,
    amp: 10,
  ),
  _FloatItem(
    emoji: '🟡',
    leftFrac: 0.056,
    top: 600,
    size: 14,
    phase: 1.5,
    amp: 14,
  ),
  _FloatItem(
    emoji: '🟢',
    leftFrac: 0.877,
    top: 580,
    size: 16,
    phase: 2.9,
    amp: 12,
  ),
  _FloatItem(
    emoji: '🔴',
    leftFrac: 0.461,
    top: 700,
    size: 14,
    phase: 0.3,
    amp: 16,
  ),
  _FloatItem(
    emoji: '🟠',
    leftFrac: 0.794,
    top: 680,
    size: 18,
    phase: 1.1,
    amp: 10,
  ),
];

// ─────────────────────────────────────────────
//  STEP META
// ─────────────────────────────────────────────

const _stepEmojis = ['🎒', '👨‍👩‍👧', '🎯'];
const _stepTitles = [
  "Tell us about you!",
  "Parent's Info",
  "Pick your interests!",
];
const _stepSubtitles = [
  "Let's get to know you first 👋",
  "Your parent's contact details",
  "What do you want to learn? 🚀",
];

const _interests = [
  '🐍 Python',
  '🤖 AI / ML',
  '🎮 Game Dev',
  '📱 App Dev',
  '🌐 Web Design',
  '🔬 Robotics',
  '🎨 UI Design',
  '📊 Data Science',
];

const _grades = [
  'Grade 5',
  'Grade 6',
  'Grade 7',
  'Grade 8',
  'Grade 9',
  'Grade 10',
  'Grade 11',
  'Grade 12',
];

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────

class SchoolSignupScreen extends StatefulWidget {
  const SchoolSignupScreen({super.key});

  @override
  State<SchoolSignupScreen> createState() => _SchoolSignupScreenState();
}

class _SchoolSignupScreenState extends State<SchoolSignupScreen>
    with TickerProviderStateMixin {
  int _step = 0;

  final Map<String, dynamic> _form = {
    'name': '',
    'age': '',
    'school': '',
    'grade': '',
    'studentEmail': '',
    'password': '',
    'parentName': '',
    'parentPhone': '',
    'parentEmail': '',
    'interests': <String>[],
  };

  late AnimationController _floatCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _stepCtrl;
  late AnimationController _btnCtrl;

  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _stepFade;
  late Animation<Offset> _stepSlide;
  late Animation<double> _btnScale;

  bool _btnPressed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..value = 1.0;
    _stepFade = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);
    _stepSlide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _cardCtrl.dispose();
    _stepCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _animateStep(VoidCallback change) async {
    await _stepCtrl.reverse();
    if (mounted) {
      setState(change);
      _stepCtrl.forward();
    }
  }

  void _nextStep() async {
    if (_step < 2) {
      _animateStep(() => _step++);
    } else {
      setState(() => _isLoading = true);
      final success = await SchoolApiService.instance.register(
        fullName: _form['name'],
        email: _form['studentEmail'].toString().trim(),
        password: _form['password'],
        phone: _form['parentPhone'],
        schoolName: _form['school'],
        grade: _form['grade'],
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          context.go('/school/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
            ),
          );
        }
      }
    }
  }

  void _back() {
    if (_step > 0) {
      _animateStep(() => _step--);
    } else {
      context.go('/school/login');
    }
  }

  void _toggleInterest(String item) {
    setState(() {
      final List<String> list = List<String>.from(_form['interests']);
      list.contains(item) ? list.remove(item) : list.add(item);
      _form['interests'] = list;
    });
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background gradient
          const SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryBlue, kDeepBlue, Color(0xFF002171)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Decorative circles — scale with screen
          Positioned(
            top: -r.h * 0.10,
            right: -r.w * 0.15,
            child: Container(
              width: r.isTablet ? 300 : 220,
              height: r.isTablet ? 300 : 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSkyBlue.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -r.h * 0.10,
            left: -r.w * 0.12,
            child: Container(
              width: r.isTablet ? 340 : 260,
              height: r.isTablet ? 340 : 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Floating emoji items — left computed from fraction
          ..._floatItems.map((item) => _buildFloatItem(item, r)),
          // Scrollable card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: r.scrollHPad,
                  vertical: 40,
                ),
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: Center(child: _buildCard(r)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatItem(_FloatItem item, _R r) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, __) {
        final dy = sin(_floatCtrl.value * 2 * pi + item.phase) * item.amp;
        // Scale emoji size slightly on tablet
        final size = r.isTablet ? item.size * 1.2 : item.size;
        return Positioned(
          left: item.leftFrac * r.w,
          top: item.top + dy,
          child: Opacity(
            opacity: 0.52,
            child: Text(item.emoji, style: TextStyle(fontSize: size)),
          ),
        );
      },
    );
  }

  Widget _buildCard(_R r) {
    return Container(
      width: r.cardWidth,
      padding: EdgeInsets.all(r.cardPad),
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
          _buildCardHeader(r),
          const SizedBox(height: 18),
          _buildProgressBar(),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: _stepFade,
            child: SlideTransition(
              position: _stepSlide,
              child: _buildStepContent(r),
            ),
          ),
          const SizedBox(height: 22),
          _buildNextButton(r),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  CARD HEADER
  // ─────────────────────────────────────────

  Widget _buildCardHeader(_R r) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _back,
              child: Container(
                width: r.isTablet ? 42 : 36,
                height: r.isTablet ? 42 : 36,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kCardBorder),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kPrimaryBlue,
                  size: r.isTablet ? 18 : 16,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.isTablet ? 16 : 12,
                vertical: r.isTablet ? 7 : 5,
              ),
              decoration: BoxDecoration(
                color: kSelectedBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kCardBorder),
              ),
              child: Text(
                'Step ${_step + 1} of 3',
                style: TextStyle(
                  fontSize: r.fs(12, tablet: 13),
                  fontWeight: FontWeight.w800,
                  color: kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: r.isTablet ? 80 : 68,
          height: r.isTablet ? 80 : 68,
          decoration: BoxDecoration(
            color: kSelectedBg,
            shape: BoxShape.circle,
            border: Border.all(color: kCardBorder, width: 1.5),
          ),
          child: Center(
            child: Text(
              _stepEmojis[_step],
              style: TextStyle(fontSize: r.fs(32, tablet: 38)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _stepTitles[_step],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: r.fs(22, tablet: 24),
            fontWeight: FontWeight.w800,
            color: kTextDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _stepSubtitles[_step],
          style: TextStyle(fontSize: r.fs(13, tablet: 14), color: kTextMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  PROGRESS BAR
  // ─────────────────────────────────────────

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(3, (i) {
        final isDone = i < _step;
        final isActive = i == _step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: 5,
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: isDone
                  ? kSkyBlue
                  : isActive
                  ? kPrimaryBlue
                  : const Color(0xFFDCE8FF),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────
  //  STEP CONTENT
  // ─────────────────────────────────────────

  Widget _buildStepContent(_R r) {
    return switch (_step) {
      0 => _buildStep1(r),
      1 => _buildStep2(r),
      _ => _buildStep3(r),
    };
  }

  Widget _buildStep1(_R r) {
    return Column(
      children: [
        _field('🧒', 'Your Name', (v) => _form['name'] = v, r: r),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(
                '🎂',
                'Age',
                (v) => _form['age'] = v,
                type: TextInputType.number,
                r: r,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _dropdown(r)),
          ],
        ),
        const SizedBox(height: 12),
        _field('🏫', 'School Name', (v) => _form['school'] = v, r: r),
        const SizedBox(height: 12),
        _field(
          '📧',
          'Your Email',
          (v) => _form['studentEmail'] = v,
          type: TextInputType.emailAddress,
          r: r,
        ),
        const SizedBox(height: 12),
        _field(
          '🔒',
          'Password',
          (v) => _form['password'] = v,
          obscure: true,
          r: r,
        ),
      ],
    );
  }

  Widget _buildStep2(_R r) {
    return Column(
      children: [
        _field('👤', 'Parent Name', (v) => _form['parentName'] = v, r: r),
        const SizedBox(height: 12),
        _field(
          '📱',
          'Phone Number',
          (v) => _form['parentPhone'] = v,
          type: TextInputType.phone,
          r: r,
        ),
        const SizedBox(height: 12),
        _field(
          '📧',
          'Parent Email',
          (v) => _form['parentEmail'] = v,
          type: TextInputType.emailAddress,
          r: r,
        ),
        const SizedBox(height: 14),
        Container(
          padding: EdgeInsets.all(r.isTablet ? 18 : 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFEE58), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📋', style: TextStyle(fontSize: r.fs(18, tablet: 20))),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Parent details are used only for class reminders and progress updates.',
                  style: TextStyle(
                    fontSize: r.fs(12, tablet: 13),
                    color: const Color(0xFF795548),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(_R r) {
    final List<String> selected = List<String>.from(_form['interests']);

    // On large screens, show 3-per-row; otherwise 2-per-row
    final cols = r.isLarge ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Choose your topics',
              style: TextStyle(
                fontSize: r.fs(14, tablet: 15),
                fontWeight: FontWeight.w800,
                color: kTextDark,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected.isEmpty ? const Color(0xFFF0F4FF) : kSelectedBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${selected.length} selected',
                style: TextStyle(
                  fontSize: r.fs(12, tablet: 13),
                  fontWeight: FontWeight.w700,
                  color: selected.isEmpty ? kTextMuted : kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Responsive grid: 2 cols on phone/tablet, 3+ on large
        Column(
          children: List.generate((_interests.length / cols).ceil(), (row) {
            return Row(
              children: List.generate(cols, (col) {
                final idx = row * cols + col;
                if (idx >= _interests.length) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: col < cols - 1 ? 10 : 0),
                    child: _interestTile(_interests[idx], selected, r),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }

  Widget _interestTile(String item, List<String> selected, _R r) {
    final isSelected = selected.contains(item);
    return GestureDetector(
      onTap: () => _toggleInterest(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(
          horizontal: r.isTablet ? 14 : 12,
          vertical: r.isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? kSelectedBg : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kPrimaryBlue : kCardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: r.fs(13, tablet: 14),
                  fontWeight: FontWeight.w700,
                  color: isSelected ? kPrimaryBlue : kTextDark,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: r.isTablet ? 22 : 20,
              height: r.isTablet ? 22 : 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? kPrimaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? kPrimaryBlue : const Color(0xFFC0D0F0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: r.isTablet ? 14 : 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SHARED FIELD + DROPDOWN
  // ─────────────────────────────────────────

  Widget _field(
    String emoji,
    String label,
    ValueChanged<String> onChange, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    required _R r,
  }) {
    return TextField(
      onChanged: onChange,
      keyboardType: type,
      obscureText: obscure,
      style: TextStyle(
        fontSize: r.fs(14, tablet: 15),
        fontWeight: FontWeight.w600,
        color: kTextDark,
      ),
      decoration: InputDecoration(
        labelText: '$emoji  $label',
        labelStyle: TextStyle(
          fontSize: r.fs(13, tablet: 14),
          color: kTextMuted,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: kInputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: r.isTablet ? 22 : 18,
          vertical: r.isTablet ? 18 : 16,
        ),
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

  Widget _dropdown(_R r) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // prevents overflow on narrow grade column
      decoration: InputDecoration(
        labelText: '📚  Grade',
        labelStyle: TextStyle(
          fontSize: r.fs(13, tablet: 14),
          color: kTextMuted,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: kInputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: r.isTablet ? 22 : 18,
          vertical: r.isTablet ? 18 : 16,
        ),
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
      style: TextStyle(
        fontSize: r.fs(14, tablet: 15),
        fontWeight: FontWeight.w600,
        color: kTextDark,
      ),
      items: _grades
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) => _form['grade'] = v ?? '',
    );
  }

  // ─────────────────────────────────────────
  //  NEXT BUTTON
  // ─────────────────────────────────────────

  Widget _buildNextButton(_R r) {
    final isLast = _step == 2;
    return GestureDetector(
      onTapDown: (_) {
        _btnCtrl.forward();
        setState(() => _btnPressed = true);
      },
      onTapUp: (_) {
        _btnCtrl.reverse();
        setState(() => _btnPressed = false);
        _nextStep();
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
          padding: EdgeInsets.symmetric(vertical: r.isTablet ? 18 : 16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              else ...[
                Text(
                  isLast ? 'Start Learning! 🎉' : 'Next Step',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.fs(17, tablet: 18),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLast
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: r.isTablet ? 22 : 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
