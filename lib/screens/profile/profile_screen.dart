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

      body: Column(
        children: [

          /// PROFILE HEADER
          Stack(
            children: [

              Container(
                height: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                  ),
                ),
              ),

              Positioned(
                top: 110,
                left: 20,
                child: CircleAvatar(
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
              ),

              Positioned(
                top: 40,
                right: 15,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {},
                ),
              )
            ],
          ),

          const SizedBox(height: 50),

          /// NAME
          const Text(
            "Arjun Patel",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const Text(
            "B.Tech Computer Science • 3rd Year",
            style: TextStyle(color: Colors.blue),
          ),

          const Text(
            "SRM Institute of Technology",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 15),

          /// PROFILE STRENGTH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Profile Strength"),
                    Text(
                      "72%",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                LinearProgressIndicator(
                  value: 0.72,
                  backgroundColor: Colors.blue[100],
                  color: Colors.blue,
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// TABS
          TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Skills"),
              Tab(text: "Certifications"),
              Tab(text: "Projects"),
              Tab(text: "Applications"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [

                /// OVERVIEW
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    Text(
                      "About Me",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                        "Passionate full-stack developer with interest in AI/ML. "
                            "Looking for internships to build scalable systems.")
                  ],
                ),

                /// SKILLS
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: skills.map((skill) {

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(skill["name"]),
                              Text("${(skill["level"] * 100).toInt()}%")
                            ],
                          ),

                          const SizedBox(height: 4),

                          LinearProgressIndicator(
                            value: skill["level"],
                            color: Colors.blue,
                            backgroundColor: Colors.grey[300],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),

                /// CERTIFICATIONS
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: certifications.map((cert) {

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium,
                            color: Colors.orange),
                        title: Text(cert["name"]!),
                        subtitle: Text(
                            "${cert["issuer"]} • ${cert["date"]}"),
                      ),
                    );
                  }).toList(),
                ),

                /// PROJECTS
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: projects.map((project) {

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
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

                            const SizedBox(height: 6),

                            Wrap(
                              spacing: 6,
                              children: project["tech"]
                                  .map<Widget>((tech) => Chip(
                                label: Text(tech),
                              ))
                                  .toList(),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                /// APPLICATIONS
                ListView(
                  padding: const EdgeInsets.all(16),
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
                      child: ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(app["role"]!),
                        subtitle: Text(app["company"]!),
                        trailing: Chip(
                          label: Text(app["status"]!),
                          backgroundColor: statusColor.withOpacity(0.15),
                          labelStyle: TextStyle(color: statusColor),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
