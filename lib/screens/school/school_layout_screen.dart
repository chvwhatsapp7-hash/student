import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'school_dashboard_screen.dart';
import 'school_courses_screen.dart';
import 'school_booking_screen.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue  = Color(0xFF1A73E8);
const kDeepBlue     = Color(0xFF0D47A1);
const kSkyBlue      = Color(0xFF00B0FF);
const kBgPage       = Color(0xFFF4F7FF);
const kCardBg       = Color(0xFFFFFFFF);
const kCardBorder   = Color(0xFFE0E8FB);
const kTextDark     = Color(0xFF1A2A5E);
const kTextMuted    = Color(0xFF6B80B3);
const kSelectedBg   = Color(0xFFE8F1FE);

// ─────────────────────────────────────────────
//  NAV ITEM MODEL
// ─────────────────────────────────────────────

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String   label;
  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    activeIcon:   Icons.dashboard_rounded,
    inactiveIcon: Icons.dashboard_outlined,
    label: 'Dashboard',
  ),
  _NavItem(
    activeIcon:   Icons.menu_book_rounded,
    inactiveIcon: Icons.menu_book_outlined,
    label: 'Courses',
  ),
  _NavItem(
    activeIcon:   Icons.calendar_month_rounded,
    inactiveIcon: Icons.calendar_month_outlined,
    label: 'Booking',
  ),
];

// ─────────────────────────────────────────────
//  LAYOUT SCREEN
// ─────────────────────────────────────────────

class SchoolLayoutScreen extends StatefulWidget {
  const SchoolLayoutScreen({super.key});

  @override
  State<SchoolLayoutScreen> createState() => _SchoolLayoutScreenState();
}

class _SchoolLayoutScreenState extends State<SchoolLayoutScreen>
    with TickerProviderStateMixin {

  int _selectedIndex = 0;
  int _previousIndex = 0;

  // Per-tab animation controllers for the nav pill
  late List<AnimationController> _navAnims;
  late List<Animation<double>>   _navScales;

  // Page transition controller
  late AnimationController _pageAnim;
  late Animation<double>   _pageFade;
  late Animation<Offset>   _pageSlide;

  // Header entrance
  late AnimationController _headerAnim;

  final List<Widget> _screens = const [
    SchoolDashboardScreen(),
    SchoolCoursesScreen(),
    SchoolBookingScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _pageAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();

    _pageFade  = CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.04), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut));

    _navAnims = List.generate(
      _navItems.length,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
        value: i == 0 ? 1.0 : 0.0,
      ),
    );
    _navScales = _navAnims.map((c) =>
        Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        ),
    ).toList();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _pageAnim.dispose();
    for (final c in _navAnims) c.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.lightImpact();

    // Animate nav items
    _navAnims[_selectedIndex].reverse();
    _navAnims[index].forward();

    // Animate page transition
    _pageAnim.reset();
    _pageAnim.forward();

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kBgPage,
        body: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: FadeTransition(
                opacity: _pageFade,
                child: SlideTransition(
                  position: _pageSlide,
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────

  Widget _buildTopBar() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(
        opacity: _headerAnim.value,
        child: Transform.translate(
          offset: Offset(0, -10 * (1 - _headerAnim.value)),
          child: child,
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              children: [
                // Logo tile
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('🚀', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                // Brand name
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TechPath',
                      style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Kids Learning',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // XP chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 5),
                      Text(
                        '240 pts',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Avatar
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: const Center(
                    child: Text('👦', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAV ─────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(top: BorderSide(color: kCardBorder, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, _buildNavItem),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item       = _navItems[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _navScales[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? kSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: isSelected
                ? Border.all(color: kCardBorder, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  key: ValueKey(isSelected),
                  size: 22,
                  color: isSelected ? kPrimaryBlue : kTextMuted,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: isSelected
                    ? Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}