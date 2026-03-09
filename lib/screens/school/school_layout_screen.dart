import 'package:flutter/material.dart';

import 'school_dashboard_screen.dart';
import 'school_courses_screen.dart';
import 'school_booking_screen.dart';

class SchoolLayoutScreen extends StatefulWidget {
  const SchoolLayoutScreen({super.key});

  @override
  State<SchoolLayoutScreen> createState() => _SchoolLayoutScreenState();
}

class _SchoolLayoutScreenState extends State<SchoolLayoutScreen> {

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SchoolDashboardScreen(),
    const SchoolCoursesScreen(),
    const SchoolBookingScreen(),
  ];
  void _onTap(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      /// Background Gradient
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color(0xfff0f4ff),
                  Color(0xfffdf4ff),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
            )
        ),

        child: Column(
          children: [

            /// TOP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal:16,vertical:10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        blurRadius:6,
                        color: Colors.black12
                    )
                  ]
              ),

              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// Logo
                    Row(
                      children: [

                        Container(
                          height:36,
                          width:36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                  colors:[
                                    Color(0xff667eea),
                                    Color(0xfff093fb)
                                  ]
                              )
                          ),
                          child: const Text("🚀"),
                        ),

                        const SizedBox(width:8),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "TechPath",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:14
                              ),
                            ),

                            Text(
                              "Kids",
                              style: TextStyle(
                                  color: Colors.purple,
                                  fontSize:11
                              ),
                            )

                          ],
                        )

                      ],
                    ),

                    /// Points + Avatar
                    Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal:10,
                              vertical:6
                          ),

                          decoration: BoxDecoration(
                              color: Colors.yellow.shade50,
                              borderRadius: BorderRadius.circular(20)
                          ),

                          child: const Row(
                            children: [
                              Text("⭐"),
                              SizedBox(width:4),
                              Text(
                                "240 pts",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(width:8),

                        Container(
                          height:34,
                          width:34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                  colors:[
                                    Color(0xff667eea),
                                    Color(0xfff093fb)
                                  ]
                              )
                          ),
                          child: const Text("👦"),
                        )

                      ],
                    )

                  ],
                ),
              ),
            ),

            /// PAGE CONTENT
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            )

          ],
        ),
      ),

      /// BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,

        onTap: _onTap,

        selectedItemColor: Colors.purple,

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Courses"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Book Class"
          ),

        ],
      ),
    );
  }
}