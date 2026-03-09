import 'package:flutter/material.dart';
import '../models/job.dart';

class SavedJobsPage extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;

  const SavedJobsPage({super.key, required this.jobs, required this.savedIds});

  @override
  Widget build(BuildContext context) {
    final savedJobs = jobs.where((j) => savedIds.contains(j.id)).toList();

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
