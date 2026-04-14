import 'package:go_router/go_router.dart';

/// ── AUTH ─────────────────────────────────────────────────────────────────────
import '../screens/auth/common_login.dart';
import '../screens/auth/common_signup.dart';
import '../screens/auth/updatePassword.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/courses/courses_screen.dart';

/// ── ENGINEERING / POST-GRAD PORTAL ───────────────────────────────────────────
import '../screens/dashboard/main_dashboard.dart';
import '../screens/hackathons/hackathons_screen.dart';
import '../screens/internships/internships_screen.dart';
import '../screens/jobs/jobs_screen.dart';

/// ── PREMIUM ──────────────────────────────────────────────────────────────────
import '../screens/premium/premium_payment_screen.dart'; // ✅ NEW
/// ── OTHER SCREENS ────────────────────────────────────────────────────────────
import '../screens/profile/profile_screen.dart';
import '../screens/school/school_courses_screen.dart';
import '../screens/school/school_dashboard_screen.dart';

/// ── SCHOOL PORTAL ────────────────────────────────────────────────────────────
import '../screens/school/school_layout_screen.dart';
import '../screens/school/school_notifications_screen.dart';
import '../screens/school/school_profile_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',

  routes: [
    /// ── COMMON AUTH ────────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      builder: (context, state) => const CommonLoginScreen(),
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) => const CommonSignupScreen(),
    ),

    /// ── SAFETY NETS ────────────────────────────────────────────────────────
    GoRoute(path: '/school', redirect: (context, state) => '/school/layout'),
    GoRoute(path: '/school/login', redirect: (context, state) => '/login'),
    GoRoute(path: '/school/signup', redirect: (context, state) => '/signup'),

    /// ── ENGINEERING / POST-GRAD PORTAL ─────────────────────────────────────
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

    /// ── SCHOOL PORTAL ──────────────────────────────────────────────────────
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
      path: '/school/profile',
      builder: (context, state) => const SchoolProfileScreen(),
    ),

    /// ── PREMIUM ────────────────────────────────────────────────────────────
    // ✅ NEW — PremiumBottomSheet navigates here via context.push('/premium/payment')
    GoRoute(
      path: '/premium/payment',
      builder: (context, state) => const PremiumPaymentScreen(),
    ),

    /// ── PASSWORD UPDATE ────────────────────────────────────────────────────
    GoRoute(
      path: '/update-password',
      builder: (context, state) => const UpdatePasswordScreen(),
    ),

    GoRoute(
      path: '/school/notifications',
      builder: (context, state) => const SchoolNotificationsScreen(),
    ),
  ],
);
