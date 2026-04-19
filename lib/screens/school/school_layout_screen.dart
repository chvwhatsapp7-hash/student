import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'school_courses_screen.dart';
import 'school_dashboard_screen.dart';
import 'school_profile_screen.dart';
import 'school_state.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const kPrimaryBlue = Color(0xFF1A73E8);
const kDeepBlue = Color(0xFF0D47A1);
const kSkyBlue = Color(0xFF00B0FF);
const kBgPage = Color(0xFFF4F7FF);
const kCardBg = Color(0xFFFFFFFF);
const kCardBorder = Color(0xFFE0E8FB);
const kTextDark = Color(0xFF1A2A5E);
const kTextMuted = Color(0xFF6B80B3);
const kSelectedBg = Color(0xFFE8F1FE);

// ─────────────────────────────────────────────
//  RESPONSIVE HELPER
// ─────────────────────────────────────────────

class _R {
  final BuildContext ctx;
  const _R(this.ctx);

  double get w => MediaQuery.sizeOf(ctx).width;
  double get ts => MediaQuery.textScalerOf(ctx).scale(1.0).clamp(1.0, 1.3);

  /// ≥ 600 dp → tablet layout (side rail instead of bottom nav)
  bool get isTablet => w >= 600;

  /// ≥ 900 dp → large (wider rail with labels always visible)
  bool get isLarge => w >= 900;

  double fs(double mobile, {double? tablet, double? large}) {
    double base = mobile;
    if (isLarge && large != null) base = large;
    if (isTablet && tablet != null) base = tablet;
    return base / ts;
  }

  double get hPad => isLarge
      ? w * 0.04
      : isTablet
      ? 24.0
      : 20.0;

  /// Rail width on tablet / large
  double get railWidth => isLarge ? 220.0 : 72.0;
}

// ─────────────────────────────────────────────
//  NAV ITEM MODEL
// ─────────────────────────────────────────────

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    activeIcon: Icons.dashboard_rounded,
    inactiveIcon: Icons.dashboard_outlined,
    label: 'Dashboard',
  ),
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
  final SchoolStateNotifier _schoolState = SchoolStateNotifier();

  int _selectedIndex = 0;

  late List<AnimationController> _navAnims;
  late List<Animation<double>> _navScales;
  late AnimationController _pageAnim;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;
  late AnimationController _headerAnim;

  final List<Widget> _screens = const [
    SchoolDashboardScreen(),
    SchoolCoursesScreen(),
    SchoolProfileScreen(),
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
    _pageFade = CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
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
            begin: 0.85,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();
  }

  @override
  void dispose() {
    _schoolState.dispose();
    _headerAnim.dispose();
    _pageAnim.dispose();
    for (final c in _navAnims) c.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.lightImpact();
    _navAnims[_selectedIndex].reverse();
    _navAnims[index].forward();
    _pageAnim.reset();
    _pageAnim.forward();
    setState(() => _selectedIndex = index);
  }

  // ─────────────────────────────────────────
  //  BUILD — phone vs tablet/large layout
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = _R(context);

    return SchoolStateProvider(
      notifier: _schoolState,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: kBgPage,
          // On tablet+ use a side-rail layout; on phone keep original column+bottomNav
          body: r.isTablet ? _buildTabletLayout(r) : _buildPhoneLayout(r),
          bottomNavigationBar: r.isTablet ? null : _buildBottomNav(r),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  PHONE LAYOUT  (original structure)
  // ─────────────────────────────────────────

  Widget _buildPhoneLayout(_R r) {
    return Column(
      children: [
        _buildTopBar(r),
        Expanded(child: _animatedPage()),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  TABLET / LARGE LAYOUT  (side rail)
  // ─────────────────────────────────────────

  Widget _buildTabletLayout(_R r) {
    return Column(
      children: [
        // Top bar spans full width
        _buildTopBar(r),
        Expanded(
          child: Row(
            children: [
              // Side navigation rail
              _buildSideRail(r),
              // Thin divider
              Container(width: 1.5, color: kCardBorder),
              // Page content
              Expanded(child: _animatedPage()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _animatedPage() {
    return FadeTransition(
      opacity: _pageFade,
      child: SlideTransition(
        position: _pageSlide,
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TOP BAR
  // ─────────────────────────────────────────

  Widget _buildTopBar(_R r) {
    return ListenableBuilder(
      listenable: _schoolState,
      builder: (_, __) {
        final profile = _schoolState.profile;
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
                padding: EdgeInsets.fromLTRB(r.hPad, 12, r.hPad, 14),
                child: Row(
                  children: [
                    // Logo tile
                    Container(
                      width: r.isTablet ? 48 : 42,
                      height: r.isTablet ? 48 : 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '🚀',
                          style: TextStyle(fontSize: r.fs(20, tablet: 23)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Brand name — wrap in Flexible so it can shrink
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TechPath',
                            style: TextStyle(
                              fontSize: r.fs(17, tablet: 19),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Kids Learning',
                            style: TextStyle(
                              fontSize: r.fs(11, tablet: 12),
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Points chip — hide label on very small screens
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.isTablet ? 16 : 10,
                        vertical: r.isTablet ? 9 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⭐',
                            style: TextStyle(fontSize: r.fs(13, tablet: 15)),
                          ),
                          // Hide "pts" text on narrow screens (< 360dp)
                          if (r.w >= 360) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${profile.totalPoints}',
                              style: TextStyle(
                                fontSize: r.fs(12, tablet: 14),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bell icon
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/school/notifications');
                      },
                      child: Container(
                        width: r.isTablet ? 44 : 36,
                        height: r.isTablet ? 44 : 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: r.isTablet ? 22 : 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Avatar
                    Container(
                      width: r.isTablet ? 44 : 36,
                      height: r.isTablet ? 44 : 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          profile.avatar,
                          style: TextStyle(fontSize: r.fs(16, tablet: 21)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  SIDE RAIL  (tablet / large only)
  // ─────────────────────────────────────────

  Widget _buildSideRail(_R r) {
    return Container(
      width: r.railWidth,
      color: kCardBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.isLarge ? 12 : 8,
                  vertical: 4,
                ),
                child: GestureDetector(
                  onTap: () => _onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: ScaleTransition(
                    scale: _navScales[index],
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: r.isLarge ? 16 : 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? kSelectedBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: kCardBorder, width: 1.5)
                            : null,
                      ),
                      child: r.isLarge
                          // Large: icon + label side-by-side
                          ? Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Icon(
                                    isSelected
                                        ? item.activeIcon
                                        : item.inactiveIcon,
                                    key: ValueKey(isSelected),
                                    size: 22,
                                    color: isSelected
                                        ? kPrimaryBlue
                                        : kTextMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: r.fs(13, tablet: 14),
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? kPrimaryBlue
                                          : kTextMuted,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          // Compact rail: icon only, centered
                          : Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Icon(
                                  isSelected
                                      ? item.activeIcon
                                      : item.inactiveIcon,
                                  key: ValueKey(isSelected),
                                  size: 24,
                                  color: isSelected ? kPrimaryBlue : kTextMuted,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BOTTOM NAV  (phone only)
  // ─────────────────────────────────────────

  Widget _buildBottomNav(_R r) {
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
            children: List.generate(_navItems.length, _buildBottomNavItem),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index) {
    final item = _navItems[index];
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
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
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
