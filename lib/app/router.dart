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
const _publicRoutes = ['/', '/login', '/signup', '/update-password'];

final GoRouter router = GoRouter(
  // ── App opens to landing screen, not login ─────────────────────────────────
  initialLocation: '/',

  // ── Auth redirect ──────────────────────────────────────────────────────────
  redirect: (context, state) async {
    final auth     = AuthService();
    final location = state.matchedLocation;

    // Let public routes through immediately
    if (_publicRoutes.contains(location)) {
      // If already logged in and visiting '/' or '/login', send to dashboard
      if (location == '/' || location == '/login') {
        final token = auth.accessToken;
        final uid   = auth.userId;
        if (token != null && token.isNotEmpty && uid != null && uid.isNotEmpty) {
          try {
            if (!JwtDecoder.isExpired(token)) {
              final roleId = int.tryParse(auth.roleId ?? '') ?? 0;
              return roleId == 2 ? '/school/layout' : '/engineering';
            }
          } catch (_) {}
        }
      }
      return null; // stay on public route
    }

    // Protected route — verify token
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

    // Try refresh if access token expired
    if (!isValid && auth.refreshToken != null) {
      isValid = await auth.refreshTokens();
    }

    // Not authenticated → send to landing (not login, so user sees the app)
    if (!isValid) return '/';

    return null; // all good, proceed
  },

  // ─────────────────────────────────────────────────────────────────────────
  routes: [
    /// ── LANDING  ───────────────────────────────────────────────────────────
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
    // FIX: school/layout is the ROOT shell — sub-routes are nested under it
    // so that context.pop() works correctly from dashboard, courses, profile
    GoRoute(
      path: '/school/layout',
      builder: (context, state) => const SchoolLayoutScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',  // resolves to /school/layout/dashboard
          builder: (context, state) => const SchoolDashboardScreen(),
          routes: [
            GoRoute(
              path: 'notifications', // resolves to /school/layout/dashboard/notifications
              builder: (context, state) => const SchoolNotificationsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'courses',  // resolves to /school/layout/courses
          builder: (context, state) => const SchoolCoursesScreen(),
        ),
        GoRoute(
          path: 'profile',  // resolves to /school/layout/profile
          builder: (context, state) => const SchoolProfileScreen(),
        ),
      ],
    ),

    // Keep old flat paths as redirects for backward compat (deep links, etc.)
    GoRoute(path: '/school/dashboard',      redirect: (_, __) => '/school/layout/dashboard'),
    GoRoute(path: '/school/courses',        redirect: (_, __) => '/school/layout/courses'),
    GoRoute(path: '/school/profile',        redirect: (_, __) => '/school/layout/profile'),
    GoRoute(path: '/school/notifications',  redirect: (_, __) => '/school/layout/dashboard/notifications'),

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

    GoRoute(
      path: '/select-role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
  ],
);
