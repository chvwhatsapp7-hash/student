import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  SHARED COURSE DATA
//  Import this in all three portal screens.
// ─────────────────────────────────────────────

class Instructor {
  final String name, role, avatar, experience;
  const Instructor({
    required this.name,
    required this.role,
    required this.avatar,
    required this.experience,
  });
}

class Course {
  final int id;
  final String emoji, title, desc, fullDescription;
  final String duration, rating, students, age, level, price;
  final Color bgColor;
  final String tag;
  final Color tagBg, tagColor;
  final Instructor instructor;
  final List<String> technologies, outcomes;
  final String schedule, totalLessons, certificate;

  const Course({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.fullDescription,
    required this.duration,
    required this.rating,
    required this.students,
    required this.age,
    required this.level,
    required this.price,
    required this.bgColor,
    required this.tag,
    required this.tagBg,
    required this.tagColor,
    required this.instructor,
    required this.technologies,
    required this.outcomes,
    required this.schedule,
    required this.totalLessons,
    required this.certificate,
  });
}

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kPrimaryBlue = Color(0xFF1A73E8);
const kDeepBlue = Color(0xFF0D47A1);
const kSkyBlue = Color(0xFF00B0FF);
const kBgPage = Color(0xFFF4F7FF);
const kCardBg = Color(0xFFFFFFFF);
const kCardBorder = Color(0xFFE0E8FB);
const kTextDark = Color(0xFF1A2A5E);
const kTextMuted = Color(0xFF6B80B3);
const kEnrolledGreen = Color(0xFF2E7D32);
const kInterestedAmber = Color(0xFFE65100);
const kSelectedBg = Color(0xFFE8F1FE);

// ─────────────────────────────────────────────
//  COURSE DATA (Dynamic from API)
// ─────────────────────────────────────────────

final List<Course> kCourses = [];

const List<String> kAgeFilters = ['All', '8-12', '10-14', '12-16', '13-17'];

const List<String> kAvatarOptions = [
  '🧑‍💻',
  '👧',
  '👦',
  '👩‍🔬',
  '👨‍🔬',
  '👩‍🎨',
  '👨‍🎨',
  '🦸',
  '🧙',
  '👩‍🚀',
  '👨‍🚀',
  '🎓',
];

const List<String> kGradeOptions = [
  'Grade 5',
  'Grade 6',
  'Grade 7',
  'Grade 8',
  'Grade 9',
  'Grade 10',
  'Grade 11',
  'Grade 12',
];
