import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/dashboard_screen.dart';
import '../jobs/jobs_screen.dart';
import '../internships/internships_screen.dart';
import '../companies/companies_screen.dart';
import '../hackathons/hackathons_screen.dart';
import '../courses/courses_screen.dart';
import '../profile/profile_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — Engineering Theme
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kSlate      = Color(0xFF334155);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);
const kBgPage     = Color(0xFFF0F4F8);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  NAV ITEM MODEL
// ─────────────────────────────────────────────

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String   label;
  final bool     hasBadge;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.hasBadge = false,
  });
}

const _navItems = [
  _NavItem(
    activeIcon:   Icons.dashboard_rounded,
    inactiveIcon: Icons.dashboard_outlined,
    label: 'Home',
  ),
  _NavItem(
    activeIcon:   Icons.work_rounded,
    inactiveIcon: Icons.work_outline_rounded,
    label: 'Jobs',
    hasBadge: true,
  ),
  _NavItem(
    activeIcon:   Icons.rocket_launch_rounded,
    inactiveIcon: Icons.rocket_launch_outlined,
    label: 'Intern',
  ),
  _NavItem(
    activeIcon:   Icons.business_rounded,
    inactiveIcon: Icons.business_outlined,
    label: 'Companies',
  ),
  _NavItem(
    activeIcon:   Icons.code_rounded,
    inactiveIcon: Icons.code_rounded,
    label: 'Hack',
  ),
  _NavItem(
    activeIcon:   Icons.person_rounded,
    inactiveIcon: Icons.person_outline_rounded,
    label: 'Profile',
  ),
];

// ─────────────────────────────────────────────
//  ENGINEERING HOME
// ─────────────────────────────────────────────

class EngineeringHome extends StatefulWidget {
  const EngineeringHome({super.key});

  @override
  State<EngineeringHome> createState() => _EngineeringHomeState();
}

class _EngineeringHomeState extends State<EngineeringHome>
    with TickerProviderStateMixin {

  int _currentIndex = 0;

  // Page transition
  late AnimationController _pageAnim;
  late Animation<double>   _pageFade;
  late Animation<Offset>   _pageSlide;

  // Top bar entrance
  late AnimationController _topBarAnim;

  // Per-nav-item scale
  late List<AnimationController> _navAnims;
  late List<Animation<double>>   _navScales;

  final List<Widget> _pages = const [
    DashboardScreen(),
    JobsScreen(),
    InternshipsScreen(),
    CompaniesScreen(),
    HackathonsScreen(),
    CoursesScreen(),
    ProfileScreen(),
  ];

  // Tab labels for top bar context
  final List<String> _pageTitles = [
    'Dashboard',
    'Jobs',
    'Internships',
    'Companies',
    'Hackathons',
    'Courses',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();

    _topBarAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();

    _pageAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300),
    )..forward();

    _pageFade  = CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.03), end: Offset.zero,
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
        Tween<double>(begin: 0.82, end: 1.0).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        ),
    ).toList();
  }

  @override
  void dispose() {
    _topBarAnim.dispose();
    _pageAnim.dispose();
    for (final c in _navAnims) c.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();

    _navAnims[_currentIndex].reverse();
    _navAnims[index].forward();

    _pageAnim.reset();
    _pageAnim.forward();

    setState(() => _currentIndex = index);
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
                    index: _currentIndex,
                    children: _pages,
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
      animation: _topBarAnim,
      builder: (_, child) => Opacity(
        opacity: _topBarAnim.value,
        child: Transform.translate(
          offset: Offset(0, -10 * (1 - _topBarAnim.value)),
          child: child,
        ),
      ),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              children: [
                // Logo tile
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                // Brand + current page
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NextStep',
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _pageTitles[_currentIndex],
                          key: ValueKey(_currentIndex),
                          style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: kAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile avatar + notification
                Stack(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white, size: 19,
                      ),
                    ),
                    Positioned(
                      top: 7, right: 7,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: kAccent, shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Avatar
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.28), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('👨‍💻', style: TextStyle(fontSize: 17)),
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
        border: Border(top: BorderSide(color: kBorder, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              _buildNavItem,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item       = _navItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _navScales[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? kSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: isSelected
                ? Border.all(color: kBorder, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge wrapper
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      key: ValueKey(isSelected),
                      size: 20,
                      color: isSelected ? kPrimary : kMuted,
                    ),
                  ),
                  if (item.hasBadge && !isSelected)
                    Positioned(
                      top: -3, right: -3,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: kAccent, shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              // Label expands when selected
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: isSelected
                    ? Row(
                  children: [
                    const SizedBox(width: 7),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: kPrimary,
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