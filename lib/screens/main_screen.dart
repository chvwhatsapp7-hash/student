import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'dashboard/dashboard_screen.dart';
import 'jobs/jobs_screen.dart';
import 'internships/internships_screen.dart';
import 'hackathons/hackathons_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    JobsScreen(),
    InternshipsScreen(),
    HackathonsScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _navDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard, color: Color(0xFF1D4ED8)),
      label: "Dashboard",
    ),
    NavigationDestination(
      icon: Icon(Icons.work_outline),
      selectedIcon: Icon(Icons.work, color: Color(0xFF1D4ED8)),
      label: "Jobs",
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school, color: Color(0xFF1D4ED8)),
      label: "Internships",
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events, color: Color(0xFF1D4ED8)),
      label: "Hackathons",
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person, color: Color(0xFF1D4ED8)),
      label: "Profile",
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: Responsive.isDesktop(context)
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              backgroundColor: Colors.white,
              elevation: 2,
              selectedIconTheme: const IconThemeData(color: Color(0xFF1D4ED8)),
              unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4ED8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                    ),
                    if (Responsive.isDesktop(context)) ...[
                      const SizedBox(width: 8),
                      const Text(
                        "StudentHub",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text("Dashboard"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work),
                  label: Text("Jobs"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: Text("Internships"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: Text("Hackathons"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text("Profile"),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ResponsiveCenter(
                child: _screens[_selectedIndex],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFFEFF6FF),
          destinations: _navDestinations,
        ),
      ),
    );
  }
}
