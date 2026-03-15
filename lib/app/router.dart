import 'package:go_router/go_router.dart';

/// AUTH — common entry point for all roles
import '../screens/auth/common_login.dart';
import '../screens/auth/common_signup.dart';

/// LANDING
import '../screens/landing/landing_screen.dart';

/// ENGINEERING PORTAL
import '../screens/dashboard/main_dashboard.dart';
import '../screens/jobs/jobs_screen.dart';
import '../screens/internships/internships_screen.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/hackathons/hackathons_screen.dart';
import '../screens/courses/courses_screen.dart';
import '../screens/profile/profile_screen.dart';

/// SCHOOL PORTAL
import '../screens/school/school_login_screen.dart';
import '../screens/school/school_signup_screen.dart';
import '../screens/school/school_layout_screen.dart';
import '../screens/school/school_dashboard_screen.dart';
import '../screens/school/school_courses_screen.dart';
import '../screens/school/school_booking_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  APP FLOW
//
//  /                    → LandingScreen
//  /login               → CommonLoginScreen   (role selector + sign in)
//  /signup              → CommonSignupScreen  (role selector + register)
//
//  role = engineering / postgrad:
//    /engineering        → MainDashboard      (eng bottom-nav shell)
//    /jobs /internships /companies /hackathons /courses /profile
//
//  role = school:
//    /school/login       → SchoolLoginScreen
//    /school/signup      → SchoolSignupScreen
//    /school/layout      → SchoolLayoutScreen (school bottom-nav shell)
//    /school/dashboard   → SchoolDashboardScreen  (tab inside layout)
//    /school/courses     → SchoolCoursesScreen     (tab inside layout)
//    /school/booking     → SchoolBookingScreen     (tab inside layout)
//
//  SAFETY NET:
//    /school             → redirects to /school/login
//    (prevents GoException if any old Navigator.pushNamed('/school') survives)
// ─────────────────────────────────────────────────────────────────────────────

final GoRouter router = GoRouter(
  initialLocation: '/',

  // ── Safety-net redirect ──────────────────────────────────────────────────
  // If anything navigates to bare /school, redirect to /school/login
  redirect: (context, state) {
    if (state.matchedLocation == '/school') {
      return '/school/login';
    }
    return null; // no redirect needed
  },

  routes: [

    // ── LANDING ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),

    // ── COMMON AUTH ─────────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      builder: (context, state) => const CommonLoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const CommonSignupScreen(),
    ),

    // ── SAFETY NET: bare /school → /school/login ─────────────────────────
    GoRoute(
      path: '/school',
      redirect: (context, state) => '/school/login',
    ),

    // ── ENGINEERING / POST-GRAD PORTAL ──────────────────────────────────────
    GoRoute(
      path: '/engineering',
      builder: (context, state) => const MainDashboard(),
    ),
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

    // ── SCHOOL PORTAL ────────────────────────────────────────────────────────
    GoRoute(
      path: '/school/login',
      builder: (context, state) => const SchoolLoginScreen(),
    ),
    GoRoute(
      path: '/school/signup',
      builder: (context, state) => const SchoolSignupScreen(),
    ),
    GoRoute(
      path: '/school/layout',
      builder: (context, state) => const SchoolLayoutScreen(),
    ),
    GoRoute(
      path: '/school/dashboard',
      builder: (context, state) => const SchoolDashboardScreen(),
    ),
    GoRoute(
      path: '/school/courses',
      builder: (context, state) => const SchoolCoursesScreen(),
    ),
    GoRoute(
      path: '/school/booking',
      builder: (context, state) => const SchoolBookingScreen(),
    ),

  ],
);