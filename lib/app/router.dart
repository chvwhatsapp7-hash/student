import 'package:go_router/go_router.dart';

import '../screens/landing/landing_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/signup/signup_screen.dart';

import '../screens/dashboard/main_dashboard.dart';
import '../screens/dashboard/school_home.dart';

import '../screens/jobs/jobs_screen.dart';
import '../screens/internships/internships_screen.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/hackathons/hackathons_screen.dart';
import '../screens/courses/courses_screen.dart';
import '../screens/profile/profile_screen.dart';

/// SCHOOL PORTAL SCREENS
import '../screens/school/school_layout_screen.dart';
import '../screens/school/school_dashboard_screen.dart';
import '../screens/school/school_courses_screen.dart';
import '../screens/school/school_booking_screen.dart';
import '../screens/school/school_login_screen.dart';
import '../screens/school/school_signup_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',

  routes: [

    /// LANDING
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),

    /// LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    /// SIGNUP
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    /// ENGINEERING PORTAL
    GoRoute(
      path: '/engineering',
      builder: (context, state) => const MainDashboard(),
    ),

    /// SCHOOL HOME (portal selection)
    GoRoute(
      path: '/school',
      builder: (context, state) => const SchoolHome(),
    ),

    /// SCHOOL LOGIN
    GoRoute(
      path: '/school/login',
      builder: (context, state) => const SchoolLoginScreen(),
    ),

    /// SCHOOL SIGNUP
    GoRoute(
      path: '/school/signup',
      builder: (context, state) => const SchoolSignupScreen(),
    ),

    /// SCHOOL MAIN LAYOUT (BOTTOM NAVIGATION)
    GoRoute(
      path: '/school/layout',
      builder: (context, state) => const SchoolLayoutScreen(),
    ),

    /// SCHOOL DASHBOARD
    GoRoute(
      path: '/school/dashboard',
      builder: (context, state) => const SchoolDashboardScreen(),
    ),

    /// SCHOOL COURSES
    GoRoute(
      path: '/school/courses',
      builder: (context, state) => const SchoolCoursesScreen(),
    ),

    /// SCHOOL BOOKING
    GoRoute(
      path: '/school/booking',
      builder: (context, state) => const SchoolBookingScreen(),
    ),

    /// OTHER SCREENS
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobsScreen(),
    ),

    GoRoute(
      path: '/internships',
      builder: (context, state) => const InternshipsScreen(),
    ),

    GoRoute(
      path: '/companies',
      builder: (context, state) => const CompaniesScreen(),
    ),

    GoRoute(
      path: '/hackathons',
      builder: (context, state) => const HackathonsScreen(),
    ),

    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesScreen(),
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);