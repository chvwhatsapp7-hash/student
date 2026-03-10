import 'package:flutter/material.dart';

class SchoolCoursesScreen extends StatefulWidget {
  const SchoolCoursesScreen({super.key});

  @override
  State<SchoolCoursesScreen> createState() => _SchoolCoursesScreenState();
}

class _SchoolCoursesScreenState extends State<SchoolCoursesScreen>
    with SingleTickerProviderStateMixin {

  String ageFilter = "All";
  List<int> enrolled = [];

  final List<Map<String, dynamic>> courses = [

    {
      "id":1,
      "emoji":"🐍",
      "title":"Python for Kids",
      "desc":"Learn coding with fun projects!",
      "duration":"8 weeks",
      "rating":"4.9",
      "students":"340",
      "age":"10-14",
      "level":"Beginner",
      "price":"₹2,999"
    },

    {
      "id":2,
      "emoji":"🤖",
      "title":"Intro to AI & ML",
      "desc":"Discover how robots think!",
      "duration":"6 weeks",
      "rating":"4.8",
      "students":"218",
      "age":"12-16",
      "level":"Beginner",
      "price":"₹3,499"
    },

    {
      "id":3,
      "emoji":"🎮",
      "title":"Scratch Programming",
      "desc":"Build awesome games!",
      "duration":"4 weeks",
      "rating":"5.0",
      "students":"567",
      "age":"8-12",
      "level":"Super Easy",
      "price":"₹1,999"
    },

    {
      "id":4,
      "emoji":"📱",
      "title":"App Development",
      "desc":"Create your own mobile app!",
      "duration":"10 weeks",
      "rating":"4.7",
      "students":"189",
      "age":"13-17",
      "level":"Intermediate",
      "price":"₹3,999"
    },

  ];

  final List<String> filters = ["All","8-12","10-14","12-16","13-17"];

  @override
  Widget build(BuildContext context) {

    final filtered = ageFilter == "All"
        ? courses
        : courses.where((c)=>c["age"]==ageFilter).toList();

    return Scaffold(

      backgroundColor: const Color(0xfff6f7fb),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Text(
                    "🎓 Our Courses",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  SizedBox(height:4),

                  Text(
                    "Fun tech learning for school students!",
                    style: TextStyle(color: Colors.grey),
                  ),

                ],
              ),
            ),

            /// FILTER
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal:16),
                itemCount: filters.length,
                itemBuilder: (context,i){

                  final f = filters[i];
                  final selected = f==ageFilter;

                  return GestureDetector(

                    onTap:(){
                      setState(() {
                        ageFilter = f;
                      });
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds:300),
                      margin: const EdgeInsets.only(right:10),

                      padding: const EdgeInsets.symmetric(
                          horizontal:16,
                          vertical:10
                      ),

                      decoration: BoxDecoration(
                          color: selected
                              ? Colors.deepPurple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6
                            )
                          ]
                      ),

                      child: Center(
                        child: Text(
                          f=="All" ? "All Ages" : "Ages $f",
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.black
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height:10),

            /// COURSE LIST
            Expanded(
              child: ListView.builder(

                itemCount: filtered.length,
                padding: const EdgeInsets.all(16),

                itemBuilder:(context,i){

                  final c = filtered[i];
                  final isEnrolled = enrolled.contains(c["id"]);

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 500 + (i*100)),
                    tween: Tween<double>(begin: 0, end: 1),

                    builder:(context,double val,child){

                      return Transform.translate(
                        offset: Offset(0,50*(1-val)),
                        child: Opacity(
                          opacity: val,
                          child: child,
                        ),
                      );
                    },

                    child: Container(

                      margin: const EdgeInsets.only(bottom:16),

                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10
                            )
                          ]
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: Row(
                          children: [

                            /// EMOJI
                            Container(
                              width:60,
                              height:60,
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade50,
                                  borderRadius: BorderRadius.circular(16)
                              ),
                              child: Center(
                                child: Text(
                                  c["emoji"],
                                  style: const TextStyle(fontSize:30),
                                ),
                              ),
                            ),

                            const SizedBox(width:14),

                            /// DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    c["title"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:16
                                    ),
                                  ),

                                  const SizedBox(height:4),

                                  Text(
                                    c["desc"],
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize:12
                                    ),
                                  ),

                                  const SizedBox(height:8),

                                  Row(
                                    children: [

                                      const Icon(Icons.star,
                                          size:16,
                                          color: Colors.orange),

                                      Text(" ${c["rating"]}"),

                                      const SizedBox(width:10),

                                      Text(
                                        "${c["students"]} students",
                                        style: const TextStyle(
                                            fontSize:12,
                                            color: Colors.grey
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),

                            /// PRICE + BUTTON
                            Column(
                              children: [

                                Text(
                                  c["price"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:16
                                  ),
                                ),

                                const SizedBox(height:8),

                                ElevatedButton(

                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: isEnrolled
                                          ? Colors.green
                                          : Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20)
                                      )
                                  ),

                                  onPressed:(){

                                    setState(() {
                                      if(!enrolled.contains(c["id"])){
                                        enrolled.add(c["id"]);
                                      }
                                    });

                                    Navigator.pushNamed(
                                      context,
                                      "/school/booking",
                                    );

                                  },

                                  child: Text(
                                      isEnrolled
                                          ? "Enrolled"
                                          : "Join"
                                  ),
                                )
                              ],
                            )

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}

