import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

class CourseItem {
  final String name;
  final String icon;
  final Color bgColor;
  final String tag;
  final Color tagBg;
  final Color tagColor;

  const CourseItem({
    required this.name,
    required this.icon,
    required this.bgColor,
    required this.tag,
    required this.tagBg,
    required this.tagColor,
  });
}

class DayItem {
  final String shortName;
  final String fullName;
  const DayItem({required this.shortName, required this.fullName});
}

class TimeSlot {
  final String id;
  final String icon;
  final String label;
  final String time;
  final bool available;
  const TimeSlot({
    required this.id,
    required this.icon,
    required this.label,
    required this.time,
    required this.available,
  });
}

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue    = Color(0xFF1A73E8);
const kDeepBlue       = Color(0xFF0D47A1);
const kSkyBlue        = Color(0xFF00B0FF);
const kBgPage         = Color(0xFFF4F7FF);
const kCardBg         = Color(0xFFFFFFFF);
const kCardBorder     = Color(0xFFE0E8FB);
const kTextDark       = Color(0xFF1A2A5E);
const kTextMuted      = Color(0xFF6B80B3);
const kSelectedBg     = Color(0xFFE8F1FE);
const kSelectedBorder = Color(0xFF1A73E8);

final List<CourseItem> kCourses = [
  CourseItem(
    name: 'Python for Kids',  icon: '🐍',
    bgColor: const Color(0xFFFFF3E0), tag: 'Popular',
    tagBg: const Color(0xFFFFF3E0),   tagColor: const Color(0xFFE65100),
  ),
  CourseItem(
    name: 'Intro to AI',      icon: '🤖',
    bgColor: const Color(0xFFE3F2FD), tag: 'Trending',
    tagBg: const Color(0xFFE3F2FD),   tagColor: const Color(0xFF1565C0),
  ),
  CourseItem(
    name: 'Scratch Programming', icon: '🎮',
    bgColor: const Color(0xFFF3E5F5), tag: 'Beginner',
    tagBg: const Color(0xFFF3E5F5),   tagColor: const Color(0xFF7B1FA2),
  ),
  CourseItem(
    name: 'App Dev Basics',   icon: '📱',
    bgColor: const Color(0xFFE8F5E9), tag: 'New',
    tagBg: const Color(0xFFE8F5E9),   tagColor: const Color(0xFF2E7D32),
  ),
  CourseItem(
    name: 'Robotics',         icon: '🦾',
    bgColor: const Color(0xFFFCE4EC), tag: 'Fun',
    tagBg: const Color(0xFFFCE4EC),   tagColor: const Color(0xFFC62828),
  ),
  CourseItem(
    name: 'Web Design',       icon: '🎨',
    bgColor: const Color(0xFFE0F7FA), tag: 'Creative',
    tagBg: const Color(0xFFE0F7FA),   tagColor: const Color(0xFF00696A),
  ),
];

final List<DayItem> kDays = [
  const DayItem(shortName: 'Mon', fullName: 'Monday'),
  const DayItem(shortName: 'Tue', fullName: 'Tuesday'),
  const DayItem(shortName: 'Wed', fullName: 'Wednesday'),
  const DayItem(shortName: 'Thu', fullName: 'Thursday'),
  const DayItem(shortName: 'Fri', fullName: 'Friday'),
  const DayItem(shortName: 'Sat', fullName: 'Saturday'),
];

final List<TimeSlot> kSlots = [
  const TimeSlot(id: 'm1', icon: '🌅', label: 'Morning',      time: '9:00 AM – 10:30 AM',  available: true),
  const TimeSlot(id: 'm2', icon: '☀️', label: 'Late Morning', time: '10:45 AM – 12:15 PM', available: true),
  const TimeSlot(id: 'a1', icon: '🌤️', label: 'Afternoon',    time: '2:00 PM – 3:30 PM',   available: false),
  const TimeSlot(id: 'a2', icon: '🌇', label: 'Evening',      time: '3:45 PM – 5:15 PM',   available: true),
];

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────

class SchoolBookingScreen extends StatefulWidget {
  const SchoolBookingScreen({super.key});

  @override
  State<SchoolBookingScreen> createState() => _SchoolBookingScreenState();
}

class _SchoolBookingScreenState extends State<SchoolBookingScreen>
    with TickerProviderStateMixin {

  String? selectedCourse;
  String? selectedMode;
  String? selectedDay;
  String? selectedSlotId;
  String? selectedSlotTime;
  bool confirmed = false;

  late AnimationController _headerAnim;
  late AnimationController _confirmAnim;
  late Animation<double>   _confirmScale;

  // Per-section stagger controllers
  late List<AnimationController> _sectionAnims;
  late List<Animation<double>>   _sectionFade;
  late List<Animation<Offset>>   _sectionSlide;

  bool get canBook =>
      selectedCourse != null &&
          selectedMode   != null &&
          selectedDay    != null &&
          selectedSlotId != null;

  int get stepsComplete =>
      [selectedCourse, selectedMode, selectedDay, selectedSlotId]
          .where((e) => e != null)
          .length;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _confirmAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _confirmScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _confirmAnim, curve: Curves.easeInOut),
    );

    // 4 section stagger animations
    _sectionAnims = List.generate(4, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    ));
    _sectionFade  = _sectionAnims.map((c) =>
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        ),
    ).toList();
    _sectionSlide = _sectionAnims.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        ),
    ).toList();

    // Stagger the sections
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 80), () {
        if (mounted) _sectionAnims[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _confirmAnim.dispose();
    for (final c in _sectionAnims) c.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (confirmed) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
              children: [
                _animatedSection(0, _buildCourseSection()),
                const SizedBox(height: 14),
                _animatedSection(1, _buildModeSection()),
                const SizedBox(height: 14),
                _animatedSection(2, _buildDaySection()),
                const SizedBox(height: 14),
                _animatedSection(3, _buildSlotSection()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, __) => Opacity(
        opacity: _headerAnim.value,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryBlue, kDeepBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Book Your Class',
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Text(
                      'Fill in the steps below to reserve your slot',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.78),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── PROGRESS BAR ───────────────────────────

  Widget _buildProgressBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: List.generate(4, (i) {
          final isDone   = i < stepsComplete;
          final isActive = i == stepsComplete;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isDone
                    ? kSkyBlue
                    : isActive
                    ? kPrimaryBlue
                    : const Color(0xFFDCE8FF),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── SECTION WRAPPER ────────────────────────

  Widget _animatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: _sectionFade[index],
      child: SlideTransition(
        position: _sectionSlide[index],
        child: child,
      ),
    );
  }

  Widget _buildSectionCard({
    required int stepNumber,
    required String title,
    required bool isDone,
    required Widget body,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F4FF), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: isDone ? kPrimaryBlue : const Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                        : Text(
                      '$stepNumber',
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: body,
          ),
        ],
      ),
    );
  }

  // ── STEP 1 : COURSE ────────────────────────

  Widget _buildCourseSection() {
    return _buildSectionCard(
      stepNumber: 1,
      title: 'Choose a Course',
      isDone: selectedCourse != null,
      body: Column(
        children: kCourses.map((c) {
          final isSelected = selectedCourse == c.name;
          return GestureDetector(
            onTap: () => setState(() => selectedCourse = c.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected ? kSelectedBg : const Color(0xFFFAFCFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? kSelectedBorder : const Color(0xFFE8F0FB),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Icon tile
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: c.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(c.icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name
                  Expanded(
                    child: Text(
                      c.name,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.tagBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.tag,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: c.tagColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Check circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryBlue : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? kPrimaryBlue
                            : const Color(0xFFC0D0F0),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 13)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── STEP 2 : MODE ──────────────────────────

  Widget _buildModeSection() {
    return _buildSectionCard(
      stepNumber: 2,
      title: 'Choose Mode',
      isDone: selectedMode != null,
      body: Row(
        children: [
          Expanded(child: _modeCard('online',  '🌐', 'Online',  'Learn from home')),
          const SizedBox(width: 12),
          Expanded(child: _modeCard('offline', '🏫', 'Offline', 'Attend in person')),
        ],
      ),
    );
  }

  Widget _modeCard(
      String value, String emoji, String title, String subtitle) {
    final isSelected = selectedMode == value;
    return GestureDetector(
      onTap: () => setState(() => selectedMode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kSelectedBg : const Color(0xFFFAFCFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kSelectedBorder : const Color(0xFFE0E8FB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: kTextDark)),
            const SizedBox(height: 3),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: kTextMuted)),
          ],
        ),
      ),
    );
  }

  // ── STEP 3 : DAY ───────────────────────────

  Widget _buildDaySection() {
    return _buildSectionCard(
      stepNumber: 3,
      title: 'Choose Day',
      isDone: selectedDay != null,
      body: Column(
        children: kDays.map((d) {
          final isSelected = selectedDay == d.shortName;
          return GestureDetector(
            onTap: () => setState(() => selectedDay = d.shortName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected ? kSelectedBg : const Color(0xFFFAFCFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? kSelectedBorder : const Color(0xFFE8F0FB),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryBlue : const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        d.shortName.substring(0, 2),
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : kPrimaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d.fullName,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  const Text('Weekly',
                      style: TextStyle(fontSize: 11, color: kTextMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── STEP 4 : TIME SLOT ─────────────────────

  Widget _buildSlotSection() {
    return _buildSectionCard(
      stepNumber: 4,
      title: 'Choose Time Slot',
      isDone: selectedSlotId != null,
      body: Column(
        children: kSlots.map((s) {
          final isSelected  = selectedSlotId == s.id;
          final isAvailable = s.available;
          return GestureDetector(
            onTap: isAvailable
                ? () => setState(() {
              selectedSlotId   = s.id;
              selectedSlotTime = s.time;
            })
                : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isAvailable ? 1.0 : 0.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: !isAvailable
                      ? const Color(0xFFF5F5F8)
                      : isSelected
                      ? kSelectedBg
                      : kCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? kSelectedBorder
                        : const Color(0xFFE8F0FB),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(s.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(s.time,
                              style: const TextStyle(
                                  fontSize: 12, color: kTextMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFFE6F4EA)
                            : const Color(0xFFFCE8E6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Full',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: isAvailable
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── BOTTOM BAR ─────────────────────────────

  Widget _buildBottomBar() {
    final List<String> chips = [
      if (selectedCourse  != null) selectedCourse!,
      if (selectedMode    != null)
        selectedMode == 'online' ? '🌐 Online' : '🏫 Offline',
      if (selectedDay     != null) selectedDay!,
      if (selectedSlotTime != null) selectedSlotTime!,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(top: BorderSide(color: Color(0xFFE8EFFC), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary chips
          if (chips.isNotEmpty)
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chips[i],
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A8F),
                    ),
                  ),
                ),
              ),
            ),
          if (chips.isNotEmpty) const SizedBox(height: 12),
          // Confirm button
          ScaleTransition(
            scale: _confirmScale,
            child: GestureDetector(
              onTapDown: canBook ? (_) => _confirmAnim.forward() : null,
              onTapUp: canBook ? (_) {
                _confirmAnim.reverse();
                setState(() => confirmed = true);
              } : null,
              onTapCancel: () => _confirmAnim.reverse(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: canBook
                      ? const LinearGradient(
                    colors: [kPrimaryBlue, kDeepBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                      : null,
                  color: canBook ? null : const Color(0xFFDDE4F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    canBook
                        ? '🚀  Confirm Booking'
                        : 'Complete all steps above',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: canBook ? Colors.white : const Color(0xFFA0AEC8),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SUCCESS SCREEN ─────────────────────────

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: kBgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Animated ring
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kPrimaryBlue, kSkyBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800,
                  color: kDeepBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your class has been scheduled.\nCheck your email for details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, color: kTextMuted, height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Booking summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kCardBorder, width: 1.5),
                ),
                child: Column(
                  children: [
                    _bookingRow('Course',  selectedCourse    ?? '—'),
                    _bookingRow('Mode',
                        selectedMode == 'online'
                            ? '🌐 Online'
                            : '🏫 Offline'),
                    _bookingRow('Day',
                        kDays.firstWhere(
                              (d) => d.shortName == selectedDay,
                          orElse: () =>
                          const DayItem(shortName: '', fullName: '—'),
                        ).fullName),
                    _bookingRow('Time',    selectedSlotTime  ?? '—',
                        isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Reset button
              GestureDetector(
                onTap: () => setState(() {
                  confirmed        = false;
                  selectedCourse   = null;
                  selectedMode     = null;
                  selectedDay      = null;
                  selectedSlotId   = null;
                  selectedSlotTime = null;
                }),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kPrimaryBlue, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '+ Book Another Class',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
            bottom: BorderSide(color: Color(0xFFF0F4FF), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: kTextMuted,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: kTextDark,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}