import 'package:flutter/material.dart';

class SchoolCoursesScreen extends StatefulWidget {
  const SchoolCoursesScreen({super.key});

  @override
  State<SchoolCoursesScreen> createState() => _SchoolCoursesScreenState();
}

class _SchoolCoursesScreenState extends State<SchoolCoursesScreen> {

  String ageFilter = "All";
  List<int> enrolled = [];

  final List<Map<String, dynamic>> courses = [

    {
      "id":1,
      "emoji":"🐍",
      "title":"Python for Kids",
      "desc":"Learn to code with fun projects!",
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

      backgroundColor: const Color(0xfff5f7ff),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// Title
              const Text(
                "🎓 Our Courses",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height:4),

              const Text(
                "Fun tech learning for school students!",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height:20),

              /// Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xff667eea),Color(0xff764ba2)]
                    ),
                    borderRadius: BorderRadius.circular(24)
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Summer Learning 2025 🌟",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    const SizedBox(height:6),

                    const Text(
                      "Register now — limited seats available!",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height:16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [

                        _BannerStat("6","Courses"),
                        _BannerStat("2K+","Students"),
                        _BannerStat("100%","Fun!"),

                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height:24),

              /// Age Filter
              const Text(
                "🎂 Filter by Age Group",
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height:10),

              Wrap(
                spacing:8,
                children: filters.map((f){

                  final selected = f==ageFilter;

                  return GestureDetector(

                    onTap:(){
                      setState(() {
                        ageFilter=f;
                      });
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal:14,vertical:8
                      ),

                      decoration: BoxDecoration(
                          color: selected ? Colors.purple.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selected
                                  ? Colors.purple
                                  : Colors.grey.shade300
                          )
                      ),

                      child: Text(
                        f=="All" ? "👶 All Ages" : "Ages $f",
                        style: TextStyle(
                            color: selected
                                ? Colors.purple
                                : Colors.grey
                        ),
                      ),
                    ),
                  );

                }).toList(),
              ),

              const SizedBox(height:20),

              /// Course List
              GridView.builder(

                itemCount: filtered.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12
                ),

                itemBuilder:(context,i){

                  final c = filtered[i];
                  final isEnrolled = enrolled.contains(c["id"]);

                  return Container(

                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8
                          )
                        ]
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            c["emoji"],
                            style: const TextStyle(fontSize:40),
                          ),

                          const SizedBox(height:6),

                          Text(
                            c["title"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                          ),

                          const SizedBox(height:4),

                          Text(
                            c["desc"],
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize:12,
                                color: Colors.grey
                            ),
                          ),

                          const Spacer(),

                          Text(
                            c["price"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:18
                            ),
                          ),

                          const SizedBox(height:6),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(

                              style: ElevatedButton.styleFrom(
                                  backgroundColor: isEnrolled
                                      ? Colors.green.shade100
                                      : Colors.purple,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
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
                                      ? "Enrolled! 🎉"
                                      : "Register Now 🚀"
                              ),
                            ),
                          )

                        ],
                      ),
                    ),
                  );
                },
              )

            ],
          ),
        ),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {

  final String value;
  final String label;

  const _BannerStat(this.value,this.label);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal:16,
          vertical:10
      ),

      decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(16)
      ),

      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),

          Text(
            label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize:12
            ),
          )

        ],
      ),
    );
  }
}