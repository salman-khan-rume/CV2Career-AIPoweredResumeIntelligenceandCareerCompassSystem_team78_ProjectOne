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
import '../screens/skill_gap_input_screen.dart';
import '../screens/career_roadmap_input_screen.dart';
import '../screens/career_roadmap_result_screen.dart';
import '../screens/analysis_history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/confirm_email_screen.dart';
import '../screens/welcome_user_screen.dart';
import '../screens/reset_password_screen.dart';
import '../widgets/main_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// GoRouter provider - watches auth state to redirect unauthenticated users.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: RouterRefreshNotifier(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session != null;
      final authEvent = authState.value?.event;
      final isGuestMode = ref.read(guestModeProvider);

      // 1. If in password recovery mode, force reset password route
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        if (state.matchedLocation != AppRoutes.resetPassword) {
          return AppRoutes.resetPassword;
        }
        return null;
      }

      // List of public routes that don't require any login/guest mode checks
      final isPublicRoute = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.confirmEmail;

      // 2. If logged in, prevent accessing public auth routes
      if (isLoggedIn) {
        final isAuthRoute = state.matchedLocation == AppRoutes.welcome ||
            state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.forgotPassword;
        if (isAuthRoute) {
          return AppRoutes.home;
        }
      }

      // 3. If not logged in and not in guest mode, force welcome page (unless accessing public route)
      if (!isLoggedIn && !isGuestMode && !isPublicRoute) {
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

      // Reset Password
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Confirm Email
      GoRoute(
        path: AppRoutes.confirmEmail,
        builder: (context, state) => const ConfirmEmailScreen(),
      ),

      // Welcome User
      GoRoute(
        path: AppRoutes.welcomeUser,
        builder: (context, state) => const WelcomeUserScreen(),
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
          final extra = state.extra;
          if (extra is AnalysisResult) {
            return AnalysisResultScreen(result: extra);
          } else if (extra is Map) {
            return AnalysisResultScreen(result: AnalysisResult.fromJson(Map<String, dynamic>.from(extra)));
          } else {
            return const Scaffold(
              body: Center(child: Text('Invalid state. Please analyze resume again.')),
            );
          }
        },
      ),

      // Career Compass Analysing (Screen 12)
      GoRoute(
        path: AppRoutes.careerCompassAnalysing,
        builder: (context, state) {
          final extra = state.extra;
          final data = extra is Map ? Map<String, dynamic>.from(extra) : <String, dynamic>{};
          return CareerCompassAnalysingScreen(
            resumeText: data['resumeText'] as String? ?? '',
            answers: data['answers'] as List? ?? [],
          );
        },
      ),

      // Career Compass Results (Screen 13)
      GoRoute(
        path: AppRoutes.careerCompassResults,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is List<CareerDomain>) {
            return CareerCompassResultsScreen(domains: extra);
          } else if (extra is List) {
            return CareerCompassResultsScreen(
              domains: extra
                  .map((e) => CareerDomain.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList(),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Please take the Career Compass questionnaire again.')),
            );
          }
        },
      ),

      // Career Domain Detail (Screen 14)
      GoRoute(
        path: AppRoutes.careerDomainDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is CareerDomain) {
            return CareerDomainDetailScreen(domain: extra);
          } else if (extra is Map) {
            return CareerDomainDetailScreen(domain: CareerDomain.fromJson(Map<String, dynamic>.from(extra)));
          } else {
            return const Scaffold(
              body: Center(child: Text('Domain detail not found.')),
            );
          }
        },
      ),

      // Skill Gap Analyser (Screen 15)
      GoRoute(
        path: AppRoutes.skillGap,
        builder: (context, state) {
          final extra = state.extra;
          final data = extra is Map ? Map<String, dynamic>.from(extra) : <String, dynamic>{};
          return SkillGapScreen(
            domainKey: data['domainKey'] as String?,
            userSkills: data['userSkills'] != null ? List<String>.from(data['userSkills'] as List) : null,
            dynamicReport: data['dynamicReport'] is Map ? Map<String, dynamic>.from(data['dynamicReport'] as Map) : null,
          );
        },
      ),

      // Skill Gap Input Screen
      GoRoute(
        path: AppRoutes.skillGapInput,
        builder: (context, state) => const SkillGapInputScreen(),
      ),

      // Career Roadmap Input Screen
      GoRoute(
        path: AppRoutes.careerRoadmapInput,
        builder: (context, state) => const CareerRoadmapInputScreen(),
      ),

      // Career Roadmap Result Screen
      GoRoute(
        path: AppRoutes.careerRoadmapResult,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return CareerRoadmapResultScreen(roadmapData: Map<String, dynamic>.from(extra));
          } else {
            return const Scaffold(
              body: Center(child: Text('Invalid roadmap data. Please try again.')),
            );
          }
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

// Notifier that triggers GoRouter to re-evaluate redirects when auth state or guest mode changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(guestModeProvider, (_, __) => notifyListeners());
  }
}
