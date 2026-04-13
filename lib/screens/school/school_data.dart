import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  SHARED COURSE DATA
//  Import this in all three portal screens.
// ─────────────────────────────────────────────

class Instructor {
  final String name, role, avatar, experience;
  const Instructor({
    required this.name, required this.role,
    required this.avatar, required this.experience,
  });
}

class Course {
  final int    id;
  final String emoji, title, desc, fullDescription;
  final String duration, rating, students, age, level, price;
  final Color  bgColor;
  final String tag;
  final Color  tagBg, tagColor;
  final Instructor     instructor;
  final List<String>   technologies, outcomes;
  final String schedule, totalLessons, certificate;

  const Course({
    required this.id,
    required this.emoji,  required this.title,
    required this.desc,   required this.fullDescription,
    required this.duration, required this.rating,
    required this.students, required this.age,
    required this.level,  required this.price,
    required this.bgColor,
    required this.tag,    required this.tagBg,
    required this.tagColor,
    required this.instructor,
    required this.technologies, required this.outcomes,
    required this.schedule, required this.totalLessons,
    required this.certificate,
  });
}

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kPrimaryBlue     = Color(0xFF1A73E8);
const kDeepBlue        = Color(0xFF0D47A1);
const kSkyBlue         = Color(0xFF00B0FF);
const kBgPage          = Color(0xFFF4F7FF);
const kCardBg          = Color(0xFFFFFFFF);
const kCardBorder      = Color(0xFFE0E8FB);
const kTextDark        = Color(0xFF1A2A5E);
const kTextMuted       = Color(0xFF6B80B3);
const kEnrolledGreen   = Color(0xFF2E7D32);
const kInterestedAmber = Color(0xFFE65100);
const kSelectedBg      = Color(0xFFE8F1FE);

// ─────────────────────────────────────────────
//  COURSE DATA
// ─────────────────────────────────────────────

final List<Course> kCourses = [
  Course(
    id: 1, emoji: '🐍', title: 'Python for Kids',
    desc: 'Learn coding with fun real-world projects!',
    fullDescription:
    'Dive into programming with Python — one of the most popular and '
        'beginner-friendly languages in the world. Through hands-on mini-projects '
        'like a quiz game, a weather app, and a simple chatbot, students learn '
        'the fundamentals of logic, problem-solving, and computational thinking. '
        'No prior experience needed!',
    duration: '8 weeks', rating: '4.9', students: '340',
    age: '10-14', level: 'Beginner', price: '₹2,999',
    bgColor: Color(0xFFFFF3E0),
    tag: 'Popular', tagBg: Color(0xFFFFF3E0), tagColor: Color(0xFFE65100),
    instructor: const Instructor(name: 'Priya Sharma',
        role: 'Software Engineer & Educator', avatar: '👩‍💻',
        experience: '6 yrs teaching kids coding'),
    technologies: ['Python 3', 'Turtle Graphics', 'Pygame', 'VS Code'],
    outcomes: [
      'Write Python programs independently',
      'Understand loops, conditions & functions',
      'Build 3 complete mini-projects',
      'Debug and fix code with confidence',
    ],
    schedule: 'Mon & Wed · 4:00 PM – 5:30 PM',
    totalLessons: '16 live lessons',
    certificate: 'Yes — shareable digital certificate',
  ),
  Course(
    id: 2, emoji: '🤖', title: 'Intro to AI & ML',
    desc: 'Discover how robots think and learn!',
    fullDescription:
    'What makes a computer "smart"? Students explore AI and Machine Learning '
        'through interactive demos, visual tools, and a final project where they '
        'train their own image classifier. No heavy math — just pure curiosity!',
    duration: '6 weeks', rating: '4.8', students: '218',
    age: '12-16', level: 'Beginner', price: '₹3,499',
    bgColor: Color(0xFFE3F2FD),
    tag: 'Trending', tagBg: Color(0xFFE3F2FD), tagColor: Color(0xFF1565C0),
    instructor: const Instructor(name: 'Arjun Mehta',
        role: 'ML Engineer at TechCorp', avatar: '👨‍🔬',
        experience: '4 yrs in AI education'),
    technologies: ['Teachable Machine', 'Scratch ML', 'Python Basics', 'Google Colab'],
    outcomes: [
      'Understand what AI & ML really means',
      'Train a simple image recognition model',
      'Build a smart sorting game',
      'Present an AI-powered mini project',
    ],
    schedule: 'Tue & Thu · 5:00 PM – 6:00 PM',
    totalLessons: '12 live lessons',
    certificate: 'Yes — with project showcase',
  ),
  Course(
    id: 3, emoji: '🎮', title: 'Scratch Programming',
    desc: 'Build awesome games from scratch!',
    fullDescription:
    'Scratch is the perfect launchpad for young coders. Using a fun drag-and-drop '
        'interface, students create animations, interactive stories, and their own '
        'video games — all while learning core programming concepts.',
    duration: '4 weeks', rating: '5.0', students: '567',
    age: '8-12', level: 'Super Easy', price: '₹1,999',
    bgColor: Color(0xFFF3E5F5),
    tag: 'Best Seller', tagBg: Color(0xFFF3E5F5), tagColor: Color(0xFF7B1FA2),
    instructor: const Instructor(name: 'Kavya Nair',
        role: 'Primary School CS Teacher', avatar: '👩‍🏫',
        experience: '5 yrs with young learners'),
    technologies: ['Scratch 3.0', 'MIT App Inventor', 'Canva for Kids'],
    outcomes: [
      'Create animated stories & characters',
      'Design a playable arcade game',
      'Understand events and broadcasting',
      'Share projects with the Scratch community',
    ],
    schedule: 'Sat · 10:00 AM – 12:00 PM',
    totalLessons: '8 live sessions',
    certificate: 'Yes — fun achievement badge',
  ),
  Course(
    id: 4, emoji: '📱', title: 'App Development',
    desc: 'Create your own mobile app from day 1!',
    fullDescription:
    'Starting from UI design to writing real code, students walk through every '
        'stage of making a mobile app. By the final week, each student ships a working '
        'app to their phone — something they built entirely themselves.',
    duration: '10 weeks', rating: '4.7', students: '189',
    age: '13-17', level: 'Intermediate', price: '₹3,999',
    bgColor: Color(0xFFE8F5E9),
    tag: 'New', tagBg: Color(0xFFE8F5E9), tagColor: Color(0xFF2E7D32),
    instructor: const Instructor(name: 'Rohan Desai',
        role: 'Flutter & Android Developer', avatar: '👨‍💻',
        experience: '7 yrs mobile development'),
    technologies: ['Flutter', 'Dart', 'Figma', 'Firebase', 'Android Studio'],
    outcomes: [
      'Design app screens in Figma',
      'Write Dart code from scratch',
      'Connect app to a live database',
      'Publish your app to a device',
    ],
    schedule: 'Mon, Wed & Fri · 6:00 PM – 7:30 PM',
    totalLessons: '30 live lessons',
    certificate: 'Yes — industry-style certificate',
  ),
  Course(
    id: 5, emoji: '🦾', title: 'Robotics Basics',
    desc: 'Build and program your own robot!',
    fullDescription:
    'Students assemble a simple robot kit and write code that makes it move, '
        'sense obstacles, and react to the environment. A perfect mix of electronics, '
        'logic, and creativity — ideal for curious minds who love to build things.',
    duration: '6 weeks', rating: '4.9', students: '142',
    age: '10-14', level: 'Beginner', price: '₹3,299',
    bgColor: Color(0xFFFCE4EC),
    tag: 'Fun', tagBg: Color(0xFFFCE4EC), tagColor: Color(0xFFC62828),
    instructor: const Instructor(name: 'Siddharth Rao',
        role: 'Robotics & IoT Specialist', avatar: '🧑‍🔧',
        experience: '8 yrs in STEM education'),
    technologies: ['Arduino', 'C++ Basics', 'Tinkercad', 'Sensor Modules'],
    outcomes: [
      'Assemble a working robot kit',
      'Write motor & sensor control code',
      'Design an obstacle-avoidance path',
      'Demonstrate robot at the final show',
    ],
    schedule: 'Sat & Sun · 11:00 AM – 12:30 PM',
    totalLessons: '12 live sessions',
    certificate: 'Yes — with robotics project report',
  ),
  Course(
    id: 6, emoji: '🎨', title: 'Web Design',
    desc: 'Design beautiful websites with HTML & CSS!',
    fullDescription:
    'Learn to turn ideas into real websites! This course takes students through '
        'designing and coding beautiful web pages using HTML, CSS, and just a sprinkle '
        'of JavaScript. Finish with a personal portfolio website live on the internet.',
    duration: '5 weeks', rating: '4.8', students: '276',
    age: '12-16', level: 'Beginner', price: '₹2,499',
    bgColor: Color(0xFFE0F7FA),
    tag: 'Creative', tagBg: Color(0xFFE0F7FA), tagColor: Color(0xFF00696A),
    instructor: const Instructor(name: 'Ananya Iyer',
        role: 'UI/UX Designer & Frontend Dev', avatar: '👩‍🎨',
        experience: '5 yrs design & education'),
    technologies: ['HTML5', 'CSS3', 'JavaScript', 'Figma', 'GitHub Pages'],
    outcomes: [
      'Build a multi-page website from scratch',
      'Style pages with modern CSS',
      'Make websites work on mobile screens',
      'Host a live portfolio site online',
    ],
    schedule: 'Tue & Thu · 4:30 PM – 6:00 PM',
    totalLessons: '10 live lessons',
    certificate: 'Yes — with portfolio review',
  ),
];

const List<String> kAgeFilters = ['All', '8-12', '10-14', '12-16', '13-17'];

const List<String> kAvatarOptions = [
  '🧑‍💻', '👧', '👦', '👩‍🔬', '👨‍🔬', '👩‍🎨', '👨‍🎨',
  '🦸', '🧙', '👩‍🚀', '👨‍🚀', '🎓',
];

const List<String> kGradeOptions = [
  'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8',
  'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12',
];
