import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// ── AUTH SERVICE ─────────────────────────────────────────────────────────────
import '../../api_services/authservice.dart';

/// ── AUTH ─────────────────────────────────────────────────────────────────────
import '../screens/auth/common_login.dart';
import '../screens/auth/common_signup.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/updatePassword.dart';
import '../screens/companies/companies_screen.dart';
import '../screens/courses/courses_screen.dart';

/// ── ENGINEERING / POST-GRAD PORTAL ───────────────────────────────────────────
import '../screens/dashboard/main_dashboard.dart';
import '../screens/hackathons/hackathons_screen.dart';
import '../screens/internships/internships_screen.dart';
import '../screens/jobs/jobs_screen.dart';

/// ── LANDING ──────────────────────────────────────────────────────────────────
import '../screens/landing/landing_screen.dart';

/// ── PREMIUM ──────────────────────────────────────────────────────────────────
import '../screens/premium/premium_payment_screen.dart';

/// ── OTHER SCREENS ────────────────────────────────────────────────────────────
import '../screens/profile/profile_screen.dart';
import '../screens/school/school_courses_screen.dart';
import '../screens/school/school_dashboard_screen.dart';

/// ── SCHOOL PORTAL ────────────────────────────────────────────────────────────
import '../screens/school/school_layout_screen.dart';
import '../screens/school/school_notifications_screen.dart';
import '../screens/school/school_profile_screen.dart';

// Pages that don't need auth — redirect won't block these
const _publicRoutes = [
  '/',
  '/login',
  '/signup',
  '/update-password',
  '/select-role',
];

final GoRouter router = GoRouter(
  initialLocation: '/',

  redirect: (context, state) async {
    final auth     = AuthService();
    final location = state.matchedLocation;

    // ── Public routes ────────────────────────────────────────────────────────
    if (_publicRoutes.contains(location)) {
      if (location == '/' || location == '/login') {
        final token = auth.accessToken;
        final uid   = auth.userId;
        if (token != null && token.isNotEmpty && uid != null && uid.isNotEmpty) {
          try {
            if (!JwtDecoder.isExpired(token)) {
              final roleId = int.tryParse(auth.roleId ?? '') ?? 0;
              if (roleId == 2) return '/school/layout';
              if (roleId != 0) return '/engineering';
            }
          } catch (_) {}
        }
      }
      return null;
    }

    // ── Protected routes ─────────────────────────────────────────────────────
    final token = auth.accessToken;
    final uid   = auth.userId;

    bool isValid = false;
    if (token != null && token.isNotEmpty && uid != null && uid.isNotEmpty) {
      try {
        isValid = !JwtDecoder.isExpired(token);
      } catch (_) {
        isValid = false;
      }
    }

    if (!isValid && auth.refreshToken != null) {
      isValid = await auth.refreshTokens();
    }

    if (!isValid) return '/';

    return null;
  },

  routes: [
    /// ── LANDING ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),

    /// ── COMMON AUTH ────────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      builder: (context, state) => const CommonLoginScreen(),
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) => const CommonSignupScreen(),
    ),

    /// ── ROLE SELECTION (new user onboarding) ───────────────────────────────
    GoRoute(
      path: '/select-role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    /// ── SAFETY NETS ────────────────────────────────────────────────────────
    GoRoute(path: '/school',        redirect: (context, state) => '/school/layout'),
    GoRoute(path: '/school/login',  redirect: (context, state) => '/login'),
    GoRoute(path: '/school/signup', redirect: (context, state) => '/signup'),

    /// ── ENGINEERING / POST-GRAD PORTAL ─────────────────────────────────────
    GoRoute(
      path: '/engineering',
      builder: (context, state) => const MainDashboard(),
    ),

    GoRoute(path: '/jobs',        builder: (context, state) => const JobsScreen()),
    GoRoute(path: '/internships', builder: (context, state) => const InternshipsScreen()),
    GoRoute(path: '/companies',   builder: (context, state) => const CompaniesScreen()),
    GoRoute(path: '/hackathons',  builder: (context, state) => const HackathonsScreen()),
    GoRoute(path: '/courses',     builder: (context, state) => const CoursesScreen()),
    GoRoute(path: '/profile',     builder: (context, state) => const ProfileScreen()),

    /// ── SCHOOL PORTAL ──────────────────────────────────────────────────────
    GoRoute(
      path: '/school/layout',
      builder: (context, state) => const SchoolLayoutScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => const SchoolDashboardScreen(),
          routes: [
            GoRoute(
              path: 'notifications',
              builder: (context, state) => const SchoolNotificationsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'courses',
          builder: (context, state) => const SchoolCoursesScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const SchoolProfileScreen(),
        ),
      ],
    ),

    // Flat path redirects for backward compat
    GoRoute(path: '/school/dashboard',     redirect: (context, state) => '/school/layout/dashboard'),
    GoRoute(path: '/school/courses',       redirect: (context, state) => '/school/layout/courses'),
    GoRoute(path: '/school/profile',       redirect: (context, state) => '/school/layout/profile'),
    GoRoute(path: '/school/notifications', redirect: (context, state) => '/school/layout/dashboard/notifications'),

    /// ── PREMIUM ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/premium/payment',
      builder: (context, state) => const PremiumPaymentScreen(),
    ),

    /// ── PASSWORD UPDATE ────────────────────────────────────────────────────
    GoRoute(
      path: '/update-password',
      builder: (context, state) => const UpdatePasswordScreen(),
    ),
  ],
);
