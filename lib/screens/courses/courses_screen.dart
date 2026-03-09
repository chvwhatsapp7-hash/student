import 'package:flutter/material.dart';

class Course {
  final int id;
  final String title;
  final String category;
  final String duration;
  final String price;
  final List<String> mode;
  final double rating;
  final int students;
  final String level;
  final String instructor;
  final String badge;
  final List<String> tags;
  final String desc;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.price,
    required this.mode,
    required this.rating,
    required this.students,
    required this.level,
    required this.instructor,
    required this.badge,
    required this.tags,
    required this.desc,
  });
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String selectedCategory = "All";
  Set<int> enrolled = {};

  final categories = [
    "All",
    "AI/ML",
    "Web Dev",
    "App Dev",
    "Data Science",
    "Cloud",
    "Cybersecurity"
  ];

  final List<Course> courses = [
    Course(
      id: 1,
      title: "Machine Learning Masterclass",
      category: "AI/ML",
      duration: "3 months",
      price: "₹4,999",
      mode: ["Online", "Offline"],
      rating: 4.8,
      students: 1240,
      level: "Intermediate",
      instructor: "Dr. Priya Sharma",
      badge: "🤖",
      tags: ["Python", "TensorFlow", "Scikit-learn"],
      desc: "From basics to deployment. Build real ML models.",
    ),
    Course(
      id: 2,
      title: "Full Stack Web Development",
      category: "Web Dev",
      duration: "4 months",
      price: "₹5,999",
      mode: ["Online"],
      rating: 4.9,
      students: 2100,
      level: "Beginner",
      instructor: "Ravi Kumar",
      badge: "🌐",
      tags: ["React", "Node.js", "MongoDB"],
      desc: "Build complete web apps from scratch.",
    ),
    Course(
      id: 3,
      title: "Flutter App Development",
      category: "App Dev",
      duration: "2 months",
      price: "₹3,499",
      mode: ["Online", "Offline"],
      rating: 4.7,
      students: 870,
      level: "Beginner",
      instructor: "Ananya Rao",
      badge: "📱",
      tags: ["Flutter", "Dart", "Firebase"],
      desc: "Build beautiful cross-platform apps.",
    ),
    Course(
      id: 4,
      title: "Data Science with Python",
      category: "Data Science",
      duration: "3 months",
      price: "₹4,499",
      mode: ["Online"],
      rating: 4.6,
      students: 1560,
      level: "Intermediate",
      instructor: "Kiran Mehta",
      badge: "📊",
      tags: ["Python", "Pandas", "Tableau"],
      desc: "Analyze and visualize data effectively.",
    ),
    Course(
      id: 5,
      title: "AWS Cloud Practitioner",
      category: "Cloud",
      duration: "6 weeks",
      price: "₹2,999",
      mode: ["Online"],
      rating: 4.8,
      students: 3200,
      level: "Beginner",
      instructor: "Suresh Nair",
      badge: "☁️",
      tags: ["AWS", "Cloud", "DevOps"],
      desc: "Become cloud-ready in 6 weeks.",
    ),
    Course(
      id: 6,
      title: "Ethical Hacking & Cybersecurity",
      category: "Cybersecurity",
      duration: "2 months",
      price: "₹3,999",
      mode: ["Online", "Offline"],
      rating: 4.7,
      students: 940,
      level: "Intermediate",
      instructor: "Arjun Pillai",
      badge: "🔐",
      tags: ["Security", "Kali Linux", "Networking"],
      desc: "Learn offensive security and protection.",
    ),
  ];

  Color levelColor(String level) {
    switch (level) {
      case "Beginner":
        return Colors.green;
      case "Intermediate":
        return Colors.orange;
      case "Advanced":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == "All"
        ? courses
        : courses.where((c) => c.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Courses"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Courses",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Specialized programs to land your dream job",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            /// BANNER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🎓 Get Job-Ready",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    "95% Placement",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// CATEGORY FILTER
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((c) {
                  final active = selectedCategory == c;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        active ? Colors.purple : Colors.white,
                        foregroundColor:
                        active ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCategory = c;
                        });
                      },
                      child: Text(c),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            /// COURSE GRID
            Expanded(
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final course = filtered[index];
                  final isEnrolled = enrolled.contains(course.id);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(course.badge,
                                style: const TextStyle(fontSize: 30)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: levelColor(course.level)
                                    .withOpacity(.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course.level,
                                style: TextStyle(
                                  color: levelColor(course.level),
                                  fontSize: 11,
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          course.title,
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          course.desc,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 8),

                        Text("⏱ ${course.duration}",
                            style: const TextStyle(fontSize: 12)),

                        Text("⭐ ${course.rating}",
                            style: const TextStyle(fontSize: 12)),

                        Text("👨‍🎓 ${course.students} students",
                            style: const TextStyle(fontSize: 12)),

                        const Spacer(),

                        /// PRICE + BUTTON
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              course.price,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEnrolled
                                    ? Colors.green[100]
                                    : Colors.purple,
                                foregroundColor: isEnrolled
                                    ? Colors.green[800]
                                    : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  enrolled.add(course.id);
                                });
                              },
                              child: Text(
                                  isEnrolled ? "Enrolled!" : "Register"),
                            )
                          ],
                        )
                      ],
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
