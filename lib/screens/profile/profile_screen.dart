import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  final List<Map<String, dynamic>> skills = [
    {"name": "React", "level": 0.85},
    {"name": "Python", "level": 0.78},
    {"name": "TypeScript", "level": 0.72},
    {"name": "Node.js", "level": 0.68},
    {"name": "SQL", "level": 0.80},
  ];

  final List<Map<String, String>> certifications = [
    {
      "name": "AWS Cloud Practitioner",
      "issuer": "Amazon Web Services",
      "date": "Mar 2024"
    },
    {
      "name": "Python for Data Science",
      "issuer": "Coursera – IBM",
      "date": "Jan 2024"
    }
  ];

  final List<Map<String, dynamic>> projects = [
    {
      "title": "CareerBridge App",
      "desc": "Full-stack job portal with skill matching algorithm",
      "tech": ["React", "Node", "MongoDB"]
    },
    {
      "title": "ML Price Predictor",
      "desc": "House price prediction model",
      "tech": ["Python", "Flask"]
    }
  ];

  final List<Map<String, String>> applications = [
    {"role": "Frontend Developer", "company": "Flipkart", "status": "Shortlisted"},
    {"role": "ML Intern", "company": "Microsoft", "status": "Applied"},
    {"role": "Backend Engineer", "company": "Razorpay", "status": "Viewed"}
  ];

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            /// PROFILE HEADER
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 5)
                ],
              ),
              padding: const EdgeInsets.only(top: 20, bottom: 60),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 15,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              "A",
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Arjun Patel",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "B.Tech Computer Science • 3rd Year",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "SRM Institute of Technology",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        /// PROFILE STRENGTH
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    "Profile Strength",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    "72%",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: 0.72,
                                  backgroundColor: Colors.white24,
                                  color: Colors.white,
                                  minHeight: 8,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// TABS
            TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "Skills"),
                Tab(text: "Certifications"),
                Tab(text: "Projects"),
                Tab(text: "Applications"),
              ],
            ),

            /// TAB CONTENT
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [

                  /// OVERVIEW
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "About Me",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Passionate full-stack developer with interest in AI/ML. "
                              "Looking for internships to build scalable systems.",
                          style: TextStyle(fontSize: 14, height: 1.5),
                        )
                      ],
                    ),
                  ),

                  /// SKILLS
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: skills.map((skill) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(skill["name"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("${(skill["level"] * 100).toInt()}%",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: skill["level"],
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.blueAccent,
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  /// CERTIFICATIONS
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: certifications.map((cert) {
                        return Card(
                          color: Colors.blue[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.workspace_premium,
                                color: Colors.orange),
                            title: Text(cert["name"]!),
                            subtitle:
                            Text("${cert["issuer"]} • ${cert["date"]}"),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  /// PROJECTS
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: projects.map((project) {
                        return Card(
                          color: Colors.green[50],
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project["title"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(project["desc"]),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: project["tech"]
                                      .map<Widget>((tech) => Chip(
                                    label: Text(tech),
                                    backgroundColor:
                                    Colors.green[100],
                                  ))
                                      .toList(),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  /// APPLICATIONS
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: applications.map((app) {
                        Color statusColor;

                        switch (app["status"]) {
                          case "Shortlisted":
                            statusColor = Colors.green;
                            break;
                          case "Viewed":
                            statusColor = Colors.orange;
                            break;
                          default:
                            statusColor = Colors.blue;
                        }

                        return Card(
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.work),
                            title: Text(app["role"]!),
                            subtitle: Text(app["company"]!),
                            trailing: Chip(
                              label: Text(app["status"]!),
                              backgroundColor: statusColor.withOpacity(0.2),
                              labelStyle: TextStyle(color: statusColor),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
