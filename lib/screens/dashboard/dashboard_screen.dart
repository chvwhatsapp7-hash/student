import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final recommended = [
      {
        "title": "Frontend Developer",
        "company": "TechNova India",
        "location": "Bangalore",
        "salary": "₹8-12 LPA",
        "match": "92%",
        "logo": "🔷",
        "type": "Full Time"
      },
      {
        "title": "ML Engineer Intern",
        "company": "DataMind Labs",
        "location": "Hyderabad",
        "salary": "₹25K/month",
        "match": "87%",
        "logo": "🟠",
        "type": "Internship"
      },
      {
        "title": "Backend Developer",
        "company": "CloudSoft Systems",
        "location": "Pune",
        "salary": "₹6-9 LPA",
        "match": "78%",
        "logo": "🟢",
        "type": "Full Time"
      },
    ];

    final nearby = [
      {"name": "Infosys", "city": "Bangalore", "distance": "2.3 km", "openings": "12", "logo": "🔵"},
      {"name": "Wipro", "city": "Hyderabad", "distance": "5.1 km", "openings": "8", "logo": "🟡"},
      {"name": "TCS", "city": "Chennai", "distance": "7.8 km", "openings": "20", "logo": "🔴"},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hey Arjun 👋",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "You have 3 new job matches today!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              TextField(
                decoration: InputDecoration(
                  hintText: "Search jobs, companies...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// STATS
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  statCard("📬", "14", "Applied"),
                  statCard("⭐", "5", "Shortlisted"),
                  statCard("💪", "72%", "Profile Score"),
                  statCard("🔖", "9", "Saved Jobs"),
                ],
              ),

              const SizedBox(height: 25),

              /// PROFILE STRENGTH
              profileStrengthCard(),

              const SizedBox(height: 25),

              /// RECOMMENDED JOBS
              const Text(
                "Recommended for You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Column(
                children: recommended.map((job) {

                  return jobCard(context, job);

                }).toList(),
              ),

              const SizedBox(height: 25),

              /// NEARBY COMPANIES
              const Text(
                "Companies Near You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nearby.length,

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),

                itemBuilder: (context, index) {

                  final c = nearby[index];

                  return Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(c["logo"]!, style: const TextStyle(fontSize: 22)),

                        const SizedBox(height: 10),

                        Text(
                          c["name"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          c["city"]!,
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const Spacer(),

                        Text(
                          "${c["openings"]} openings",
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              /// COURSES CTA
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Expanded(
                      child: Text(
                        "Boost your profile\nGet certified and stand out to recruiters.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                      ),
                      onPressed: () {},
                      child: const Text("Explore"),
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

  /// JOB CARD
  Widget jobCard(BuildContext context, Map<String, String> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(job["logo"]!),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  job["title"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  job["company"]!,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(job["location"]!,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 10),
                    Text(job["type"]!,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      job["salary"]!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${job["match"]} match",
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// PROFILE STRENGTH CARD
  Widget profileStrengthCard() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2563eb), Color(0xff1e40af)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile Strength",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                "72%",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          )
        ],
      ),
    );
  }

  /// STAT CARD
  Widget statCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(icon, style: const TextStyle(fontSize: 22)),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }
}
