import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/career_domain.dart';
import '../providers/app_routes.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../screens/resume_upload_screen.dart';
import '../screens/analysis_result_screen.dart';
import '../screens/career_compass_questionnaire_screen.dart';
import '../screens/career_compass_analysing_screen.dart';
import '../screens/career_compass_results_screen.dart';
import '../screens/career_domain_detail_screen.dart';
import '../screens/skill_gap_screen.dart';
import '../screens/analysis_history_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/main_shell.dart';

// GoRouter provider - watches auth state to redirect unauthenticated users.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: RouterRefreshNotifier(ref),
    redirect: (context, state) {
      // Protected routes require authentication (not just logged-in - guest is also allowed).
      // Only /history requires login (per SRS FR-7.3).
      final isHistory = state.matchedLocation == AppRoutes.history;
      final isLoggedIn = authState.value?.session != null;

      if (isHistory && !isLoggedIn) {
        return AppRoutes.welcome;
      }
      return null;
    },
    routes: [
      // Splash (Screen 1)
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding (Screen 2)
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Welcome / Auth Choice (Screen 3)
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Login (Screen 4)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Register (Screen 5)
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Forgot Password (Screen 6)
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main shell wraps screens with persistent bottom nav (Screens 7, 11, 16, 17)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home Dashboard (Screen 7 + 8 - auth/guest detected inside screen)
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          // Career Compass Questionnaire (Screen 11)
          GoRoute(
            path: AppRoutes.careerCompassQuestionnaire,
            builder: (context, state) =>
                const CareerCompassQuestionnaireScreen(),
          ),
          // Analysis History (Screen 16)
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const AnalysisHistoryScreen(),
          ),
          // Profile (Screen 17)
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Resume Upload (Screen 9) - full screen, no shell
      GoRoute(
        path: AppRoutes.upload,
        builder: (context, state) => const ResumeUploadScreen(),
      ),

      // Analysis Result (Screen 10)
      GoRoute(
        path: AppRoutes.analysisResult,
        builder: (context, state) {
          final result = state.extra as AnalysisResult;
          return AnalysisResultScreen(result: result);
        },
      ),

      // Career Compass Analysing (Screen 12)
      GoRoute(
        path: AppRoutes.careerCompassAnalysing,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CareerCompassAnalysingScreen(
            resumeText: data['resumeText'] as String,
            answers: data['answers'] as List,
          );
        },
      ),

      // Career Compass Results (Screen 13)
      GoRoute(
        path: AppRoutes.careerCompassResults,
        builder: (context, state) {
          final domains = state.extra as List<CareerDomain>;
          return CareerCompassResultsScreen(domains: domains);
        },
      ),

      // Career Domain Detail (Screen 14)
      GoRoute(
        path: AppRoutes.careerDomainDetail,
        builder: (context, state) {
          final domain = state.extra as CareerDomain;
          return CareerDomainDetailScreen(domain: domain);
        },
      ),

      // Skill Gap Analyser (Screen 15)
      GoRoute(
        path: AppRoutes.skillGap,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return SkillGapScreen(
            domainKey: data['domainKey'] as String,
            userSkills: List<String>.from(data['userSkills'] as List),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

// Notifier that triggers GoRouter to re-evaluate redirects when auth state changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
