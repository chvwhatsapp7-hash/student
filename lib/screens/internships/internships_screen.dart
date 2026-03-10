import 'package:flutter/material.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  String tab = "All";
  List<int> saved = [];

  final internships = [
    {
      "id": 1,
      "title": "Frontend Intern",
      "company": "Myntra",
      "location": "Bangalore",
      "stipend": "₹20,000/mo",
      "type": "Paid",
      "duration": "3 months",
      "match": 94,
      "logo": "🩷",
      "tags": ["React", "CSS"],
      "remote": false
    },
    {
      "id": 2,
      "title": "ML Research Intern",
      "company": "Microsoft Research",
      "location": "Hyderabad",
      "stipend": "₹35,000/mo",
      "type": "Paid",
      "duration": "6 months",
      "match": 89,
      "logo": "🔵",
      "tags": ["Python", "Deep Learning"],
      "remote": true
    },
    {
      "id": 3,
      "title": "Open Source Contributor",
      "company": "Mozilla Foundation",
      "location": "Remote",
      "stipend": "Unpaid",
      "type": "Unpaid",
      "duration": "2 months",
      "match": 85,
      "logo": "🦊",
      "tags": ["JavaScript", "HTML"],
      "remote": true
    },
    {
      "id": 4,
      "title": "Social Impact Tech Intern",
      "company": "TechForGood NGO",
      "location": "Delhi",
      "stipend": "Unpaid + Certificate",
      "type": "Unpaid",
      "duration": "1 month",
      "match": 75,
      "logo": "💚",
      "tags": ["Python", "Data"],
      "remote": false
    },
  ];

  void toggleSave(int id) {
    setState(() {
      if (saved.contains(id)) {
        saved.remove(id);
      } else {
        saved.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = tab == "All"
        ? internships
        : internships.where((i) => i["type"] == tab).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Internships"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// TAB SWITCHER
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ["All", "Paid", "Unpaid"].map((t) {
                  final active = tab == t;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        tab = t;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                            active ? Colors.blue : Colors.grey[600]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// BANNER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("💼 Paid Internships Available",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Top companies offering up to ₹40K/month",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INTERNSHIP LIST
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final intern = filtered[index];
                  final id = intern["id"] as int;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              intern["logo"].toString(),
                              style: const TextStyle(fontSize: 24),
                            ),
                            IconButton(
                              icon: Icon(
                                saved.contains(id)
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: saved.contains(id)
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                toggleSave(id);
                              },
                            )
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// TITLE
                        Text(
                          intern["title"].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        /// COMPANY
                        Text(
                          intern["company"].toString(),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),

                        const SizedBox(height: 6),

                        /// LOCATION & DURATION
                        Text(
                          "${intern["location"]} • ${intern["duration"]}",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),

                        const SizedBox(height: 10),

                        /// STIPEND TAG
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: intern["type"] == "Paid"
                                ? Colors.green[50]
                                : Colors.purple[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            intern["stipend"].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: intern["type"] == "Paid"
                                  ? Colors.green
                                  : Colors.purple,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// APPLY BUTTON
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 36),
                          ),
                          child: const Text("Apply"),
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