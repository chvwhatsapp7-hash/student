import 'package:flutter/material.dart';

import '../jobs/jobs_screen.dart';
import '../internships/internships_screen.dart';
import '../companies/companies_screen.dart';
import '../hackathons/hackathons_screen.dart';
import '../profile/profile_screen.dart';

class EngineeringHome extends StatefulWidget {
  const EngineeringHome({super.key});

  @override
  State<EngineeringHome> createState() => _EngineeringHomeState();
}

class _EngineeringHomeState extends State<EngineeringHome> {

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

      appBar: AppBar(
        title: const Text("Engineering Portal"),
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: "Jobs",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Internships",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "Companies",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.code),
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