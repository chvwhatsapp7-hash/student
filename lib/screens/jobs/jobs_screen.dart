import 'dart:ui';
import 'package:flutter/material.dart';

class Job {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final int match;
  final String logo;
  final List<String> tags;
  final String exp;
  final String posted;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.match,
    required this.logo,
    required this.tags,
    required this.exp,
    required this.posted,
  });
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String activeFilter = "All";
  String search = "";
  int? selectedJob;

  List<int> saved = [2];

  final filters = ["All", "Full Time", "Remote", "Fresher", "Bangalore"];

  final List<Job> jobs = [
    Job(
        id: 1,
        title: "Software Engineer",
        company: "Google",
        location: "Bangalore",
        salary: "₹20-30 LPA",
        type: "Full Time",
        match: 95,
        logo: "🔵",
        tags: ["Python", "Cloud", "Golang"],
        exp: "Fresher",
        posted: "2d ago"),
    Job(
        id: 2,
        title: "Frontend Developer",
        company: "Flipkart",
        location: "Bangalore",
        salary: "₹12-18 LPA",
        type: "Full Time",
        match: 90,
        logo: "🟡",
        tags: ["React", "TypeScript", "CSS"],
        exp: "Fresher",
        posted: "1d ago"),
    Job(
        id: 3,
        title: "Data Analyst",
        company: "Paytm",
        location: "Noida",
        salary: "₹8-12 LPA",
        type: "Full Time",
        match: 82,
        logo: "🔷",
        tags: ["SQL", "Python", "Tableau"],
        exp: "0-1 yr",
        posted: "3d ago"),
  ];

  void toggleSave(int id) {
    setState(() {
      saved.contains(id) ? saved.remove(id) : saved.add(id);
    });
  }

  List<Job> getFilteredJobs() {
    return jobs.where((job) {
      final matchesSearch = job.title
          .toLowerCase()
          .contains(search.toLowerCase()) ||
          job.company.toLowerCase().contains(search.toLowerCase());

      final matchesFilter = activeFilter == "All" ||
          job.location.contains(activeFilter) ||
          job.type == activeFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredJobs();

    return Scaffold(
      backgroundColor: const Color(0xffeef1f7),
      appBar: AppBar(
        title: const Text("Jobs"),
        actions: [
          IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SavedJobsPage(
                            jobs: jobs, savedIds: saved)));
              })
        ],
      ),
      body: Row(
        children: [

          /// LEFT SIDE JOB LIST
          Expanded(
            flex: 3,
            child: Column(
              children: [

                /// SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Search jobs, companies...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none)),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                  ),
                ),

                /// FILTER CHIPS
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    itemBuilder: (context, i) {
                      final f = filters[i];
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: activeFilter == f,
                          onSelected: (_) {
                            setState(() {
                              activeFilter = f;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// JOB CARDS
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final job = filtered[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedJob = job.id;
                          });
                        },
                        child: glassCard(
                          child: Row(
                            children: [

                              Text(job.logo, style: const TextStyle(fontSize: 30)),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    Text(job.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),

                                    Text(job.company,
                                        style: const TextStyle(
                                            color: Colors.grey)),

                                    const SizedBox(height: 6),

                                    Wrap(
                                      spacing: 6,
                                      children: job.tags
                                          .map((e) => Chip(
                                          label: Text(e,
                                              style: const TextStyle(
                                                  fontSize: 11))))
                                          .toList(),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(job.salary,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),

                                    /// AI MATCH BAR
                                    LinearProgressIndicator(
                                      value: job.match / 100,
                                      minHeight: 6,
                                    ),

                                    Text("${job.match}% AI Match")
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: Icon(
                                  saved.contains(job.id)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                ),
                                onPressed: () => toggleSave(job.id),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),

          /// RIGHT SIDE DETAILS
        //   Expanded(
        //     flex: 2,
        //     child: selectedJob == null
        //         ? const Center(child: Text("Select a job"))
        //         : buildDetail(),
        //   )
        ],
      ),
    );
  }

  Widget buildDetail() {
    final job = jobs.firstWhere((j) => j.id == selectedJob);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(job.title,
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            Text(job.company, style: const TextStyle(color: Colors.blue)),

            const SizedBox(height: 20),

            const Text(
                "We're looking for passionate engineers to build scalable systems."),

            const Spacer(),

            ElevatedButton(
              onPressed: () => showApplyModal(job),
              child: const Text("Apply Now"),
            )
          ],
        ),
      ),
    );
  }

  void showApplyModal(Job job) {
    showDialog(
        context: context,
        builder: (_) {
          final name = TextEditingController();
          final email = TextEditingController();

          return AlertDialog(
            title: Text("Apply for ${job.title}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Application Submitted")));
                  },
                  child: const Text("Submit"))
            ],
          );
        });
  }

  Widget glassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30)),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;

  const SavedJobsPage({super.key, required this.jobs, required this.savedIds});

  @override
  Widget build(BuildContext context) {
    final savedJobs =
    jobs.where((j) => savedIds.contains(j.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Jobs")),
      body: ListView.builder(
        itemCount: savedJobs.length,
        itemBuilder: (_, i) {
          final job = savedJobs[i];

          return ListTile(
            title: Text(job.title),
            subtitle: Text(job.company),
            trailing: const Icon(Icons.bookmark),
          );
        },
      ),
    );
  }
}
