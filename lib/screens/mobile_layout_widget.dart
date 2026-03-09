import 'package:flutter/material.dart';
import '../models/job.dart';
import 'saved_jobs_page.dart';

class MobileLayoutWidget extends StatelessWidget {
  final List<Job> jobs;
  final List<int> saved;
  final List<Job> filtered;
  final int? selectedJob;
  final Function(int) toggleSave;
  final Function(Job) selectJob;

  const MobileLayoutWidget({
    super.key,
    required this.jobs,
    required this.saved,
    required this.filtered,
    required this.selectedJob,
    required this.toggleSave,
    required this.selectJob,
  });

  @override
  Widget build(BuildContext context) {
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
                  builder: (_) => SavedJobsPage(jobs: jobs, savedIds: saved),
                ),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final job = filtered[index];

          return GestureDetector(
            onTap: () => selectJob(job),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(job.logo, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(job.company,
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: job.tags
                                      .map((e) => Chip(
                                      label: Text(
                                        e,
                                        style: const TextStyle(fontSize: 11),
                                      )))
                                      .toList(),
                                ),
                                const SizedBox(height: 6),
                                Text(job.salary,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                LinearProgressIndicator(
                                  value: job.match / 100,
                                  minHeight: 6,
                                ),
                                Text("${job.match}% AI Match"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(saved.contains(job.id)
                                ? Icons.bookmark
                                : Icons.bookmark_border),
                            onPressed: () => toggleSave(job.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}