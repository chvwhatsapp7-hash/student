import 'package:flutter/material.dart';

class SchoolDashboardScreen extends StatelessWidget {
  const SchoolDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final upcoming = [
      {"day":"Mon","time":"10:00 AM","subject":"Python Basics","emoji":"🐍","color":Colors.deepPurple},
      {"day":"Wed","time":"3:00 PM","subject":"Scratch Programming","emoji":"🎮","color":Colors.pink},
      {"day":"Fri","time":"11:00 AM","subject":"AI Concepts","emoji":"🤖","color":Colors.blue},
    ];

    final featuredCourses = [
      {"emoji":"🐍","title":"Python for Kids","desc":"Create your first program!","students":"340"},
      {"emoji":"🤖","title":"Intro to AI","desc":"What is Artificial Intelligence?","students":"218"},
      {"emoji":"🎮","title":"Scratch Games","desc":"Build your own game!","students":"567"},
    ];

    final achievements = [
      {"emoji":"🏆","label":"First Login!"},
      {"emoji":"⭐","label":"5 Day Streak"},
      {"emoji":"🚀","label":"Fast Learner"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff5f7ff),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// WELCOME CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Hey, Riya! 👋",
                      style: TextStyle(fontSize:22,fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height:4),

                    const Text(
                      "Ready to learn something amazing today?",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height:14),

                    Row(
                      children: [
                        _stat("5","Day Streak 🔥",Colors.purple),
                        const SizedBox(width:8),
                        _stat("240","Points ⭐",Colors.orange),
                        const SizedBox(width:8),
                        _stat("3","Courses 📚",Colors.green),
                      ],
                    )

                  ],
                ),
              ),

              const SizedBox(height:20),

              /// UPCOMING CLASSES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    "Upcoming Classes",
                    style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
                  ),

                  TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context,"/school/booking");
                    },
                    child: const Text("See all"),
                  )

                ],
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

                        Text(
                          cls["emoji"] as String,
                          style: const TextStyle(fontSize:32),
                        ),

                        const SizedBox(width:10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                cls["subject"] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),

                              Text(
                                "${cls["day"]} • ${cls["time"]}",
                                style: const TextStyle(color: Colors.grey,fontSize:12),
                              ),

                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),

                          decoration: BoxDecoration(
                            color: cls["color"] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: Text(
                            cls["day"] as String,
                            style: const TextStyle(color: Colors.white,fontSize:12),
                          ),
                        )

                      ],
                    ),
                  );

                }).toList(),
              ),

              const SizedBox(height:20),

              /// POPULAR COURSES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    "Popular Courses",
                    style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
                  ),

                  TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context,"/school/courses");
                    },
                    child: const Text("See all"),
                  )

                ],
              ),

              const SizedBox(height:10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 140,
                ),

                itemCount: featuredCourses.length,

                itemBuilder:(context,i){

                  final c = featuredCourses[i];

                  return GestureDetector(

                    onTap: (){
                      Navigator.pushNamed(context,"/school/courses");
                    },

                    child: Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff667eea),Color(0xff764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(c["emoji"] as String,style: const TextStyle(fontSize:32)),

                          const SizedBox(height:6),

                          Text(
                            c["title"] as String,
                            style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),

                          Text(
                            c["students"] as String,
                            style: const TextStyle(color: Colors.white70,fontSize:12),
                          )

                        ],
                      ),
                    ),
                  );

                },
              ),

              const SizedBox(height:20),

              /// BADGES
              const Text(
                "🏅 Your Badges",
                style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
              ),

              const SizedBox(height:10),

              Row(
                children: achievements.map((a){

                  return Expanded(

                    child: Container(
                      margin: const EdgeInsets.only(right:8),
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        children: [

                          Text(a["emoji"] as String,style: const TextStyle(fontSize:28)),

                          const SizedBox(height:6),

                          Text(
                            a["label"] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize:12,fontWeight: FontWeight.bold),
                          )

                        ],
                      ),
                    ),
                  );

                }).toList(),
              ),

              const SizedBox(height:20),

              /// CTA BOOK CLASS
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff667eea),Color(0xff764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "📅 Book a Class",
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),

                        Text(
                          "Online & Offline slots available!",
                          style: TextStyle(color: Colors.white70,fontSize:12),
                        )

                      ],
                    ),

                    ElevatedButton(
                      onPressed: (){
                        Navigator.pushNamed(context,"/school/booking");
                      },
                      child: const Text("Book Now"),
                    )

                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value,String label,Color color){

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          children: [

            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:18,
                color: color,
              ),
            ),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize:10),
            )

          ],
        ),
      ),
    );
  }
}