import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// ── AUTH SERVICE ─────────────────────────────────────────────────────────────
// adjust path to your AuthService
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
const _publicRoutes = ['/login', '/signup', '/update-password'];

final GoRouter router = GoRouter(
  initialLocation: '/login',

  // ── ONLY ADDITION: auth redirect ──────────────────────────────────────────
  redirect: (context, state) async {
    final auth = AuthService();
    final location = state.matchedLocation;

    // Let public routes through immediately
    if (_publicRoutes.contains(location)) {
      // But if already logged in and going to /login, redirect to dashboard
      final token = auth.accessToken;
      final uid = auth.userId;
      if (token != null && token.isNotEmpty && uid != null && uid.isNotEmpty) {
        try {
          if (!JwtDecoder.isExpired(token)) {
            final roleId = int.tryParse(auth.roleId ?? '') ?? 0;
            return roleId == 2 ? '/school/layout' : '/engineering';
          }
        } catch (_) {}
      }
      return null; // stay on public route
    }

    // Protected route — check token
    final token = auth.accessToken;
    final uid = auth.userId;

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

    // Not authenticated → send to login
    if (!isValid) return '/login';

    return null; // all good, proceed
  },

  // ─────────────────────────────────────────────────────────────────────────
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

    GoRoute(
      path: '/select-role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
  ],
);
