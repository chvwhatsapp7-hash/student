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
