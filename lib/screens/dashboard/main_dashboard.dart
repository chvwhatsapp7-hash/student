import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../courses/courses_screen.dart' hide CompaniesScreen;
import '../dashboard/dashboard_screen.dart';
import '../internships/internships_screen.dart';
import '../jobs/jobs_screen.dart';
import '../profile/profile_screen.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk = Color(0xFF0F172A);
const kSlate = Color(0xFF334155);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);
const kBgPage = Color(0xFFF0F4F8);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kPrimary = Color(0xFF1D4ED8);
const kAccent = Color(0xFF38BDF8);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  NAV ITEM MODEL
// ─────────────────────────────────────────────

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool hasBadge;
  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.hasBadge = false,
  });
}

const _navItems = [
  _NavItem(
    activeIcon: Icons.dashboard_rounded,
    inactiveIcon: Icons.dashboard_outlined,
    label: 'Home',
  ),
  _NavItem(
    activeIcon: Icons.work_rounded,
    inactiveIcon: Icons.work_outline_rounded,
    label: 'Jobs',
    hasBadge: true,
  ),
  _NavItem(
    activeIcon: Icons.rocket_launch_rounded,
    inactiveIcon: Icons.rocket_launch_outlined,
    label: 'Intern',
  ),
  // _NavItem(
  //   activeIcon: Icons.business_rounded,
  //   inactiveIcon: Icons.business_outlined,
  //   label: 'Companies',
  // ),
  // _NavItem(
  //   activeIcon: Icons.code_rounded,
  //   inactiveIcon: Icons.code_rounded,
  //   label: 'Hack',
  // ),
  _NavItem(
    activeIcon: Icons.menu_book_rounded,
    inactiveIcon: Icons.menu_book_outlined,
    label: 'Courses',
  ),
  _NavItem(
    activeIcon: Icons.person_rounded,
    inactiveIcon: Icons.person_outline_rounded,
    label: 'Profile',
  ),
];

const _pageTitles = [
  'Dashboard',
  'Jobs',
  'Internships',
  // 'Companies',
  // 'Hackathons',
  'Courses',
  'Profile',
];

// ─────────────────────────────────────────────
//  MAIN DASHBOARD
// ─────────────────────────────────────────────

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _topBarAnim;
  late AnimationController _pageAnim;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;
  late List<AnimationController> _navAnims;
  late List<Animation<double>> _navScales;

  final List<Widget> _pages = const [
    DashboardScreen(),
    JobsScreen(),
    InternshipsScreen(),
    // CompaniesScreen(),
    // HackathonsScreen(),
    CoursesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _topBarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pageAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _pageFade = CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut));

    _navAnims = List.generate(
      _navItems.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
        value: i == 0 ? 1.0 : 0.0,
      ),
    );
    _navScales = _navAnims
        .map(
          (c) => Tween<double>(
            begin: 0.82,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();
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
                  child: IndexedStack(index: _currentIndex, children: _pages),
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
    final sw = MediaQuery.of(context).size.width;

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
            padding: EdgeInsets.fromLTRB(
              sw * 0.05,
              sw * 0.03,
              sw * 0.05,
              sw * 0.035,
            ),
            child: Row(
              children: [
                // Logo tile
                Container(
                  width: sw * 0.10,
                  height: sw * 0.10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('⚡', style: TextStyle(fontSize: sw * 0.050)),
                  ),
                ),
                SizedBox(width: sw * 0.03),

                // Brand + page subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NextStep',
                        style: TextStyle(
                          fontSize: sw * 0.043,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _pageTitles[_currentIndex],
                          key: ValueKey(_currentIndex),
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w600,
                            color: kAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification bell
                Stack(
                  children: [
                    Container(
                      width: sw * 0.09,
                      height: sw * 0.09,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: sw * 0.048,
                      ),
                    ),
                    Positioned(
                      top: sw * 0.018,
                      right: sw * 0.018,
                      child: Container(
                        width: sw * 0.018,
                        height: sw * 0.018,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: sw * 0.025),

                // Avatar
                Container(
                  width: sw * 0.09,
                  height: sw * 0.09,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.28),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '👨‍💻',
                      style: TextStyle(fontSize: sw * 0.043),
                    ),
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
    final sw = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(top: BorderSide(color: kBorder, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.015,
            vertical: sw * 0.025,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(i, sw),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, double sw) {
    final item = _navItems[index];
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
            // CHANGED: removed dynamic horizontal padding (was sw * 0.035 when
            // selected, sw * 0.025 unselected) — now fixed at sw * 0.025 so
            // the pill width does not jump when labels are always visible.
            horizontal: sw * 0.025,
            vertical: sw * 0.020,
          ),
          decoration: BoxDecoration(
            color: isSelected ? kSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: isSelected ? Border.all(color: kBorder, width: 1.5) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon + optional badge dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      key: ValueKey(isSelected),
                      size: sw * 0.050, // ~20px on 400px screen
                      color: isSelected ? kPrimary : kMuted,
                    ),
                  ),
                  if (item.hasBadge && !isSelected)
                    Positioned(
                      top: -sw * 0.008,
                      right: -sw * 0.008,
                      child: Container(
                        width: sw * 0.018,
                        height: sw * 0.018,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              // ─────────────────────────────────────────────
              // CHANGED: Label is now ALWAYS visible for every
              // nav item, not just the selected one.
              //
              // BEFORE (labels only showed when selected):
              //   AnimatedSize(
              //     ...
              //     child: isSelected
              //         ? Row(children: [...Text(item.label)])
              //         : const SizedBox.shrink(),  // ← this hid all labels
              //   ),
              //
              // AFTER (label always rendered, only style changes):
              //   AnimatedDefaultTextStyle animates color and weight
              //   between selected (kPrimary, w800) and
              //   unselected (kMuted, w600) states smoothly.
              // ─────────────────────────────────────────────
              SizedBox(width: sw * 0.015),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: sw * 0.030,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? kPrimary : kMuted,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
