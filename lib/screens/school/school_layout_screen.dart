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

  /// IMPORTANT: remove const so UI updates correctly
  final List<Widget> _screens = [
    const SchoolDashboardScreen(),
    const SchoolCoursesScreen(),
    const SchoolBookingScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.transparent,

      /// BODY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffEEF2FF),
              Color(0xffFDF4FF),
              Color(0xffF0FDFA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              /// HEADER
              Container(
                margin: const EdgeInsets.fromLTRB(16,16,16,10),
                padding: const EdgeInsets.symmetric(horizontal:16,vertical:14),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0,6),
                    )
                  ],
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// LOGO
                    Row(
                      children: [

                        Container(
                          height:42,
                          width:42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff667eea),
                                Color(0xff764ba2)
                              ],
                            ),
                          ),
                          child: const Text("🚀",style: TextStyle(fontSize:20)),
                        ),

                        const SizedBox(width:10),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "TechPath",
                              style: TextStyle(
                                fontSize:17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Kids Learning",
                              style: TextStyle(
                                fontSize:12,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    /// XP + AVATAR
                    Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal:12,
                              vertical:6
                          ),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.shade100,
                                Colors.orange.shade200
                              ],
                            ),
                          ),

                          child: const Row(
                            children: [
                              Text("⭐"),
                              SizedBox(width:4),
                              Text(
                                "240 pts",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(width:10),

                        Container(
                          height:38,
                          width:38,
                          alignment: Alignment.center,

                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff667eea),
                                Color(0xfff093fb)
                              ],
                            ),
                          ),

                          child: const Text("👦",style: TextStyle(fontSize:16)),
                        )
                      ],
                    )
                  ],
                ),
              ),

              /// PAGE CONTENT (BEST FOR NAVIGATION)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),

                  child: IndexedStack(
                    key: ValueKey(_selectedIndex),
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),

      /// FLOATING BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16,0,16,16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
            )
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),

          child: BottomNavigationBar(

            currentIndex: _selectedIndex,
            onTap: _onTap,

            backgroundColor: Colors.white,
            elevation: 0,

            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,

            type: BottomNavigationBarType.fixed,

            items: const [

              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: "Dashboard",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                label: "Courses",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded),
                label: "Booking",
              ),

            ],
          ),
        ),
      ),
    );
  }
}
