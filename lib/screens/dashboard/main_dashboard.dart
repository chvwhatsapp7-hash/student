import 'package:flutter/material.dart';

import '../jobs/jobs_screen.dart';
import '../internships/internships_screen.dart';
import '../companies/companies_screen.dart';
import '../hackathons/hackathons_screen.dart';
import '../profile/profile_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    JobsScreen(),
    InternshipsScreen(),
    CompaniesScreen(),
    HackathonsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: pages[currentIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: "Jobs",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: "Internships",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: "Companies",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.code_outlined),
            activeIcon: Icon(Icons.code),
            label: "Hackathons",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}