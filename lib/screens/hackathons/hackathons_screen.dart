import 'package:flutter/material.dart';

class Hackathon {
  final int id;
  final String title;
  final String org;
  final String date;
  final String prize;
  final int participants;
  final List<String> tags;
  final String location;
  final String logo;

  Hackathon({
    required this.id,
    required this.title,
    required this.org,
    required this.date,
    required this.prize,
    required this.participants,
    required this.tags,
    required this.location,
    required this.logo,
  });
}

class HackathonsScreen extends StatefulWidget {
  const HackathonsScreen({super.key});

  @override
  State<HackathonsScreen> createState() => _HackathonsScreenState();
}

class _HackathonsScreenState extends State<HackathonsScreen> {
  Set<int> reminded = {};
  int? selected;

  final List<Hackathon> hackathons = [
    Hackathon(
      id: 1,
      title: "Smart India Hackathon 2025",
      org: "Government of India",
      date: "Dec 2025",
      prize: "₹1 Lakh",
      participants: 50000,
      tags: ["AI", "Govt", "Social Impact"],
      location: "Pan India",
      logo: "🇮🇳",
    ),
    Hackathon(
      id: 2,
      title: "HackWithInfy",
      org: "Infosys",
      date: "Feb 2026",
      prize: "₹50,000",
      participants: 10000,
      tags: ["Web", "Mobile", "Cloud"],
      location: "Online",
      logo: "🔵",
    ),
    Hackathon(
      id: 3,
      title: "Flipkart GRiD 6.0",
      org: "Flipkart",
      date: "Mar 2026",
      prize: "PPO + ₹75,000",
      participants: 25000,
      tags: ["ML", "Systems", "E-commerce"],
      location: "Bangalore",
      logo: "🟡",
    ),
    Hackathon(
      id: 4,
      title: "Code for Change",
      org: "Google India",
      date: "Apr 2026",
      prize: "\$5,000",
      participants: 8000,
      tags: ["Sustainability", "AI", "Web"],
      location: "Hyderabad",
      logo: "🔶",
    ),
  ];

  void showReminderDialog(int id) {
    selected = id;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("🔔 Set Reminder"),
          content: const Text(
              "We'll notify you when registrations open for this hackathon!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Not Now"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  reminded.add(id);
                });
                Navigator.pop(context);
              },
              child: const Text("Yes, Remind Me!"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Hackathons"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// HEADER
          Row(
            children: [
              const Text(
                "Hackathons",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "COMING SOON",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Compete, collaborate, and win with India's top hackathons",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          /// HERO BANNER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.purple, Colors.blue]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("🏆", style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text(
                  "Hackathon Season 2025-26",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "India's biggest coding competitions are coming.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// HACKATHON CARDS
          ...hackathons.map((hack) {
            final isReminded = reminded.contains(hack.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Text(hack.logo, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hack.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(hack.org,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("📅 ${hack.date}",
                          style: const TextStyle(fontSize: 12)),
                      Text("🏆 ${hack.prize}",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("👥 ${hack.participants}",
                          style: const TextStyle(fontSize: 12)),
                      Text("📍 ${hack.location}",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// TAGS
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: hack.tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  /// REMINDER BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isReminded ? Colors.green[100] : Colors.indigo,
                      foregroundColor:
                      isReminded ? Colors.green[800] : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    icon: Icon(isReminded ? Icons.check : Icons.notifications),
                    onPressed: () {
                      if (!isReminded) showReminderDialog(hack.id);
                    },
                    label: Text(
                        isReminded ? "Reminder Set!" : "Remind Me Later"),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
