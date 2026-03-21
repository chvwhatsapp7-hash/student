import 'package:go_router/go_router.dart';

/// ── AUTH (one common login + signup for ALL roles) ───────────────────────────
import '../screens/auth/common_login.dart';
import '../screens/auth/common_signup.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/courses/courses_screen.dart';

/// ── ENGINEERING / POST-GRAD PORTAL ───────────────────────────────────────────
import '../screens/dashboard/main_dashboard.dart';
import '../screens/hackathons/hackathons_screen.dart';
import '../screens/internships/internships_screen.dart';
import '../screens/jobs/jobs_screen.dart';

/// ── LANDING ──────────────────────────────────────────────────────────────────
import '../screens/landing/landing_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/school/school_booking_screen.dart';
import '../screens/school/school_courses_screen.dart';
import '../screens/school/school_dashboard_screen.dart';

/// ── SCHOOL PORTAL ────────────────────────────────────────────────────────────
import '../screens/school/school_layout_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COMPLETE APP FLOW
//
//  /                       LandingScreen
//  /login                  CommonLoginScreen   ← ONE page for ALL roles
//  /signup                 CommonSignupScreen  ← ONE page for ALL roles
//
//  After login/signup — role decides the destination:
//
//  💼 Engineering / 📚 Post-Grad  →  /engineering  (MainDashboard)
//     /jobs          JobsScreen
//     /internships   InternshipsScreen
//     /companies     CompaniesScreen
//     /hackathons    HackathonsScreen
//     /courses       CoursesScreen
//     /profile       ProfileScreen
//
//  🎒 School  →  /school/layout  (SchoolLayoutScreen — bottom-nav shell)
//     /school/dashboard   SchoolDashboardScreen   (tab 0)
//     /school/courses     SchoolCoursesScreen      (tab 1)
//     /school/booking     SchoolBookingScreen      (tab 2)
//
//  SAFETY NETS (redirect stale paths so app never hard-crashes):
//     /school             →  /school/layout
//     /school/login       →  /login
//     /school/signup      →  /signup
// ─────────────────────────────────────────────────────────────────────────────

final GoRouter router = GoRouter(
  initialLocation: '/',

  routes: [
    // ── LANDING ────────────────────────────────────────────────────────────
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),

    // ── COMMON AUTH ────────────────────────────────────────────────────────
    // Single login page — dropdown selects role, routes accordingly
    GoRoute(
      path: '/login',
      builder: (context, state) => const CommonLoginScreen(),
    ),
    // Single signup page — dropdown selects role, routes accordingly
    GoRoute(
      path: '/signup',
      builder: (context, state) => const CommonSignupScreen(),
    ),

    // ── SAFETY NETS ────────────────────────────────────────────────────────
    // Redirect any stale /school routes to the correct unified pages
    GoRoute(path: '/school', redirect: (context, state) => '/school/layout'),
    GoRoute(path: '/school/login', redirect: (context, state) => '/login'),
    GoRoute(path: '/school/signup', redirect: (context, state) => '/signup'),

    // ── ENGINEERING / POST-GRAD PORTAL ─────────────────────────────────────
    GoRoute(
      path: '/engineering',
      builder: (context, state) => const MainDashboard(),
    ),
    GoRoute(path: '/jobs', builder: (context, state) => const JobsScreen()),
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

    // ── SCHOOL PORTAL ──────────────────────────────────────────────────────
    // /school/layout is the bottom-nav shell — always enter here first
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
