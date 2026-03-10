import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class SchoolDashboardScreen extends StatefulWidget {
  const SchoolDashboardScreen({super.key});

  @override
  State<SchoolDashboardScreen> createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController xpController;
  late ConfettiController confettiController;

  double xp = 0.7;

  @override
  void initState() {
    super.initState();

    xpController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    xpController.dispose();
    confettiController.dispose();
    super.dispose();
  }

  final upcoming = [
    {"day":"Mon","time":"10:00 AM","subject":"Python Basics","emoji":"🐍"},
    {"day":"Wed","time":"3:00 PM","subject":"Scratch Programming","emoji":"🎮"},
    {"day":"Fri","time":"11:00 AM","subject":"AI Concepts","emoji":"🤖"},
  ];

  final featuredCourses = [
    {"emoji":"🐍","title":"Python for Kids","desc":"Create your first program","students":"340"},
    {"emoji":"🤖","title":"Intro to AI","desc":"Learn how machines think","students":"218"},
    {"emoji":"🎮","title":"Scratch Games","desc":"Build your own game","students":"567"},
  ];

  final leaderboard = [
    {"name":"Riya","points":"320"},
    {"name":"Aarav","points":"280"},
    {"name":"Kabir","points":"240"},
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfff5f7ff),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Text("🤖"),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hi! I'm your coding robot 🤖")));
        },
      ),

      body: SafeArea(
        child: Stack(
          children: [

            SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// WELCOME
                  const Text(
                    "Hey Riya 👋",
                    style: TextStyle(fontSize:26,fontWeight: FontWeight.bold),
                  ),

                  const Text(
                    "Let's build something amazing today!",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height:20),

                  /// XP PROGRESS
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff667eea),Color(0xff764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [

                        /// Animated Progress Ring
                        TweenAnimationBuilder(
                          tween: Tween(begin: 0.0,end: xp),
                          duration: const Duration(seconds:2),

                          builder:(context,value,child){

                            return SizedBox(
                              width:70,
                              height:70,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [

                                  CircularProgressIndicator(
                                    value: value,
                                    strokeWidth:6,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
                                  ),

                                  Text(
                                    "${(value*100).toInt()}%",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )

                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(width:20),

                        /// XP BAR
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                "Level Progress",
                                style: TextStyle(color: Colors.white),
                              ),

                              const SizedBox(height:6),

                              LinearProgressIndicator(
                                value: xp,
                                color: Colors.orange,
                                backgroundColor: Colors.white24,
                              ),

                              const SizedBox(height:6),

                              const Text(
                                "240 / 350 XP",
                                style: TextStyle(color: Colors.white70,fontSize:12),
                              )

                            ],
                          ),
                        )

                      ],
                    ),
                  ),

                  const SizedBox(height:20),

                  /// DAILY CHALLENGE
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [

                        const Text("🔥",style: TextStyle(fontSize:32)),

                        const SizedBox(width:10),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Daily Challenge",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              Text(
                                "Complete a Python quiz today!",
                                style: TextStyle(fontSize:12),
                              )

                            ],
                          ),
                        ),

                        ElevatedButton(
                          onPressed: (){
                            confettiController.play();
                          },
                          child: const Text("Start"),
                        )

                      ],
                    ),
                  ),

                  const SizedBox(height:20),

                  /// UPCOMING
                  const Text(
                    "Upcoming Classes",
                    style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height:10),

                  Column(
                    children: upcoming.map((cls){

                      return Container(
                        margin: const EdgeInsets.only(bottom:10),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Row(
                          children: [

                            Text(cls["emoji"]!,style: const TextStyle(fontSize:30)),

                            const SizedBox(width:10),

                            Expanded(
                              child: Text(
                                cls["subject"]!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            Text(cls["day"]!),

                          ],
                        ),
                      );

                    }).toList(),
                  ),

                  const SizedBox(height:20),

                  /// COURSES LIST
                  const Text(
                    "Popular Courses",
                    style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height:10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: featuredCourses.length,

                    itemBuilder:(context,i){

                      final c = featuredCourses[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom:12),
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff667eea),Color(0xff764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Row(
                          children: [

                            Text(c["emoji"]!,style: const TextStyle(fontSize:30)),

                            const SizedBox(width:10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    c["title"]!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  Text(
                                    c["desc"]!,
                                    style: const TextStyle(
                                        color: Colors.white70,fontSize:12),
                                  ),

                                ],
                              ),
                            ),

                            Text(
                              "${c["students"]} 👩‍🎓",
                              style: const TextStyle(color: Colors.white),
                            )

                          ],
                        ),
                      );

                    },
                  ),

                  const SizedBox(height:20),

                  /// LEADERBOARD
                  const Text(
                    "🏆 Leaderboard",
                    style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height:10),

                  Column(
                    children: leaderboard.map((l){

                      return Container(
                        margin: const EdgeInsets.only(bottom:8),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Row(
                          children: [

                            const Icon(Icons.emoji_events,color: Colors.orange),

                            const SizedBox(width:10),

                            Expanded(child: Text(l["name"]!)),

                            Text("${l["points"]} XP")

                          ],
                        ),
                      );

                    }).toList(),
                  ),

                  const SizedBox(height:40),

                ],
              ),
            ),

            /// CONFETTI
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirection: pi/2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
              ),
            )

          ],
        ),
      ),
    );
  }
}