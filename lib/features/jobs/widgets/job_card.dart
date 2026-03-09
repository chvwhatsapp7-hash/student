import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {

  final String title;
  final String company;
  final String location;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        title: Text(title),

        subtitle: Text("$company • $location"),

        trailing: const Icon(Icons.arrow_forward_ios),

      ),

    );
  }
}