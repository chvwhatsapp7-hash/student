import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final String emoji;
  final double left;
  final double top;
  final double size;
  final double phase;
  final double amp;
  const _FloatItem({
    required this.emoji, required this.left, required this.top,
    required this.size,  required this.phase, required this.amp,
  });
}

const _floatItems = [
  _FloatItem(emoji: '🌟', left: 18,  top: 85,  size: 28, phase: 0.0, amp: 16),
  _FloatItem(emoji: '🚀', left: 75,  top: 52,  size: 26, phase: 0.9, amp: 20),
  _FloatItem(emoji: '🤖', left: 148, top: 96,  size: 30, phase: 1.8, amp: 14),
  _FloatItem(emoji: '💡', left: 218, top: 60,  size: 24, phase: 2.7, amp: 18),
  _FloatItem(emoji: '🎨', left: 296, top: 88,  size: 26, phase: 0.5, amp: 22),
  _FloatItem(emoji: '🔬', left: 348, top: 48,  size: 24, phase: 1.3, amp: 16),
  _FloatItem(emoji: '🟣', left: 12,  top: 420, size: 16, phase: 2.1, amp: 12),
  _FloatItem(emoji: '🔵', left: 355, top: 360, size: 15, phase: 0.7, amp: 10),
  _FloatItem(emoji: '🟡', left: 22,  top: 600, size: 14, phase: 1.5, amp: 14),
  _FloatItem(emoji: '🟢', left: 342, top: 580, size: 16, phase: 2.9, amp: 12),
  _FloatItem(emoji: '🔴', left: 180, top: 700, size: 14, phase: 0.3, amp: 16),
  _FloatItem(emoji: '🟠', left: 310, top: 680, size: 18, phase: 1.1, amp: 10),
];

// ─────────────────────────────────────────────
//  STEP META
// ─────────────────────────────────────────────

const _stepEmojis     = ['🎒', '👨‍👩‍👧', '🎯'];
const _stepTitles     = ["Tell us about you!", "Parent's Info", "Pick your interests!"];
const _stepSubtitles  = [
  "Let's get to know you first 👋",
  "Your parent's contact details",
  "What do you want to learn? 🚀",
];

const _interests = [
  '🐍 Python',  '🤖 AI / ML',
  '🎮 Game Dev', '📱 App Dev',
  '🌐 Web Design', '🔬 Robotics',
  '🎨 UI Design', '📊 Data Science',
];

const _grades = [
  'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8',
  'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12',
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
    'name':        '',
    'age':         '',
    'school':      '',
    'grade':       '',
    'parentName':  '',
    'parentPhone': '',
    'parentEmail': '',
    'interests':   <String>[],
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

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 5),
    )..repeat();

    _cardCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650),
    );
    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.16), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _stepCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380),
    )..value = 1.0;
    _stepFade  = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);
    _stepSlide = Tween<Offset>(
      begin: const Offset(0.06, 0), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));

    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
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

  void _nextStep() {
    if (_step < 2) {
      _animateStep(() => _step++);
    } else {
      // KEY FIX: go to /school/layout (nav shell), not /school
      context.go('/school/layout');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryBlue, kDeepBlue, Color(0xFF002171)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kSkyBlue.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80, left: -50,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          ..._floatItems.map(_buildFloatItem),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
        final dy = sin(_floatCtrl.value * 2 * pi + item.phase) * item.amp;
        return Positioned(
          left: item.left, top: item.top + dy,
          child: Opacity(
            opacity: 0.52,
            child: Text(item.emoji, style: TextStyle(fontSize: item.size)),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(26),
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
          _buildCardHeader(),
          const SizedBox(height: 18),
          _buildProgressBar(),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: _stepFade,
            child: SlideTransition(
              position: _stepSlide,
              child: _buildStepContent(),
            ),
          ),
          const SizedBox(height: 22),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _back,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kCardBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: kPrimaryBlue, size: 16,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: kSelectedBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kCardBorder),
              ),
              child: Text(
                'Step ${_step + 1} of 3',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  color: kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: kSelectedBg,
            shape: BoxShape.circle,
            border: Border.all(color: kCardBorder, width: 1.5),
          ),
          child: Center(
            child: Text(_stepEmojis[_step], style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _stepTitles[_step],
          style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: kTextDark, letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _stepSubtitles[_step],
          style: const TextStyle(fontSize: 13, color: kTextMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(3, (i) {
        final isDone   = i < _step;
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
                  : isActive ? kPrimaryBlue : const Color(0xFFDCE8FF),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    return switch (_step) {
      0 => _buildStep1(),
      1 => _buildStep2(),
      _ => _buildStep3(),
    };
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _field('🧒', 'Your Name',   (v) => _form['name']   = v),
        const SizedBox(height: 12),
        _field('🎂', 'Age',         (v) => _form['age']    = v,
            type: TextInputType.number),
        const SizedBox(height: 12),
        _dropdown(),
        const SizedBox(height: 12),
        _field('🏫', 'School Name', (v) => _form['school'] = v),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _field('👤', 'Parent Name',  (v) => _form['parentName']  = v),
        const SizedBox(height: 12),
        _field('📱', 'Phone Number', (v) => _form['parentPhone'] = v,
            type: TextInputType.phone),
        const SizedBox(height: 12),
        _field('📧', 'Parent Email', (v) => _form['parentEmail'] = v,
            type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFEE58), width: 1.5),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📋', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Parent details are used only for class reminders and progress updates.',
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
    );
  }

  Widget _buildStep3() {
    final List<String> selected = List<String>.from(_form['interests']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Choose your topics',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: kTextDark,
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
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: selected.isEmpty ? kTextMuted : kPrimaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          children: List.generate((_interests.length / 2).ceil(), (row) {
            final a = _interests[row * 2];
            final b = (row * 2 + 1 < _interests.length)
                ? _interests[row * 2 + 1] : null;
            return Row(
              children: [
                Expanded(child: _interestTile(a, selected)),
                if (b != null) ...[
                  const SizedBox(width: 10),
                  Expanded(child: _interestTile(b, selected)),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _interestTile(String item, List<String> selected) {
    final isSelected = selected.contains(item);
    return GestureDetector(
      onTap: () => _toggleInterest(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kSelectedBg : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kPrimaryBlue : kCardBorder, width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isSelected ? kPrimaryBlue : kTextDark,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? kPrimaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? kPrimaryBlue : const Color(0xFFC0D0F0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String emoji, String label, ValueChanged<String> onChange,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextField(
      onChanged: onChange,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
      decoration: InputDecoration(
        labelText: '$emoji  $label',
        labelStyle: const TextStyle(
            fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: kInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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

  Widget _dropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '📚  Grade',
        labelStyle: const TextStyle(
            fontSize: 13, color: kTextMuted, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: kInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
      items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => _form['grade'] = v ?? '',
    );
  }

  Widget _buildNextButton() {
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
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'Start Learning! 🎉' : 'Next Step',
                style: const TextStyle(
                  color: Colors.white, fontSize: 17,
                  fontWeight: FontWeight.w800, letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                color: Colors.white, size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

