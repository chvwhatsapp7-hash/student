import 'package:flutter/material.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,

        showUnselectedLabels: true,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Jobs",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Internships",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: "Hackathons",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}
