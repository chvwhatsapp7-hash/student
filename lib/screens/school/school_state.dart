import 'package:flutter/material.dart';
import '../../services/school_api_service.dart';

// ─────────────────────────────────────────────
//  ENUMS & MODELS  (single source of truth)
// ─────────────────────────────────────────────

enum CourseStatus { none, interested, enrolled }

class StudentProfile {
  final String name;
  final String grade;
  final String school;
  final String avatar;
  final int    totalPoints;
  final int    streakDays;

  const StudentProfile({
    this.name        = 'Aryan Sharma',
    this.grade       = 'Grade 8',
    this.school      = 'Delhi Public School',
    this.avatar      = '🧑‍💻',
    this.totalPoints = 1240,
    this.streakDays  = 14,
  });

  StudentProfile copyWith({
    String? name,
    String? grade,
    String? school,
    String? avatar,
    int?    totalPoints,
    int?    streakDays,
  }) =>
      StudentProfile(
        name:        name        ?? this.name,
        grade:       grade       ?? this.grade,
        school:      school      ?? this.school,
        avatar:      avatar      ?? this.avatar,
        totalPoints: totalPoints ?? this.totalPoints,
        streakDays:  streakDays  ?? this.streakDays,
      );
}

// ─────────────────────────────────────────────
//  SCHOOL STATE  —  InheritedNotifier wrapper
// ─────────────────────────────────────────────

class SchoolStateNotifier extends ChangeNotifier {
  // course id → status
  final Map<int, CourseStatus> _statuses = {};
  StudentProfile _profile = const StudentProfile();
  bool _challengeDone = false;

  // ── getters ───────────────────────────────
  Map<int, CourseStatus> get statuses      => Map.unmodifiable(_statuses);
  StudentProfile         get profile       => _profile;
  bool                   get challengeDone => _challengeDone;

  CourseStatus statusOf(int id) => _statuses[id] ?? CourseStatus.none;

  int get enrolledCount   =>
      _statuses.values.where((s) => s == CourseStatus.enrolled).length;
  int get interestedCount =>
      _statuses.values.where((s) => s == CourseStatus.interested).length;

// ── mutations ─────────────────────────────

  void setStatus(int id, CourseStatus status) {
    _statuses[id] = status;
    notifyListeners();
  }

  void updateProfile(StudentProfile p) {
    _profile = p;
    notifyListeners();
    // Background sync via SchoolApiService
    SchoolApiService.instance.updateProfile(p.name, p.grade, p.school);
  }

  Future<void> fetchProfile() async {
    final data = await SchoolApiService.instance.getProfile();
    if (data != null) {
      _profile = _profile.copyWith(
        name: data['full_name'] ?? _profile.name,
        grade: data['degree'] ?? _profile.grade,
        school: data['university'] ?? _profile.school,
      );
      notifyListeners();
    }
  }

  void completeChallenge() {
    if (_challengeDone) return;
    _challengeDone = true;
    _profile = _profile.copyWith(totalPoints: _profile.totalPoints + 50);
    notifyListeners();
  }
}


// ── Provider widget ────────────────────────

class SchoolStateProvider extends InheritedNotifier<SchoolStateNotifier> {
  const SchoolStateProvider({
    super.key,
    required SchoolStateNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static SchoolStateNotifier of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<SchoolStateProvider>();
    assert(result != null, 'No SchoolStateProvider found in context');
    return result!.notifier!;
  }
}
