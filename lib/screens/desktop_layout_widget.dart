import 'package:flutter/material.dart';
import '../models/job.dart';
import 'saved_jobs_page.dart'; // If you use it in desktop/appbar
class DesktopLayoutWidget extends StatelessWidget {
  final List<Job> jobs;
  final List<int> savedIds;
  final List<Job> filteredJobs;
  final int? selectedJob;
  final Function(int) onToggleSave;
  final Function(Job) onSelectJob;

  const DesktopLayoutWidget({
    super.key,
    required this.jobs,
    required this.savedIds,
    required this.filteredJobs,
    required this.selectedJob,
    required this.onToggleSave,
    required this.onSelectJob,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// LEFT JOB LIST
        Expanded(
          flex: 3,
          child: buildJobList(),
        ),

        /// RIGHT DETAIL PANEL
        Expanded(
          flex: 2,
          child: selectedJob == null
              ? const Center(child: Text("Select a job"))
              : buildDetailPanel(),
        ),
      ],
    );
  }

  /// ============================
  /// JOB LIST
  /// ============================
  Widget buildJobList() {
    return Column(
      children: [
        /// SEARCH BAR (You can connect parent search later)
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
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
        ),

        /// JOB CARDS LIST
        Expanded(
          child: ListView.builder(
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];

              return GestureDetector(
                onTap: () => onSelectJob(job),
                child: Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Card(
                    elevation: 0.8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(job.logo,
                              style: const TextStyle(fontSize: 32)),

                          const SizedBox(width: 14),

                          /// JOB INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),

                                Text(job.company,
                                    style:
                                    const TextStyle(color: Colors.grey)),

                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 6,
                                  children: job.tags
                                      .map((e) => Chip(
                                    label: Text(
                                      e,
                                      style:
                                      const TextStyle(fontSize: 11),
                                    ),
                                  ))
                                      .toList(),
                                ),

                                const SizedBox(height: 8),

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

                          /// SAVE BUTTON
                          IconButton(
                            icon: Icon(
                              savedIds.contains(job.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                            onPressed: () => onToggleSave(job.id),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ============================
  /// DETAIL PANEL
  /// ============================
  Widget buildDetailPanel() {
    final job =
    jobs.firstWhere((element) => element.id == selectedJob);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 1,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 6),

              Text(job.company,
                  style: const TextStyle(color: Colors.blue)),

              const SizedBox(height: 20),

              const Text(
                  "We're looking for passionate engineers to build scalable systems."),

              const Spacer(),

              ElevatedButton(
                onPressed: () {},
                child: const Text("Apply Now"),
              )
            ],
          ),
        ),
      ),
    );
  }
}