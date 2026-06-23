import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/analysis_result.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/score_circle.dart';
import '../widgets/loading_error_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Screen 7 (logged-in) + Screen 8 (guest).
// Detected at runtime via isGuestProvider.
// Guest sees a sign-in banner but can still upload and use compass.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.primarySurface.withValues(alpha: 0.3),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(analysisHistoryProvider),
            child: CustomScrollView(
            slivers: [
              // Greeting header
              SliverToBoxAdapter(
                child: _HomeHeader(isGuest: isGuest, profile: profile),
              ),

              // Guest sign-in banner
              if (isGuest)
                SliverToBoxAdapter(
                  child: _GuestBanner(),
                ),

              // Quick action cards
              SliverToBoxAdapter(
                child: _QuickActions(),
              ),

              // Recent analyses header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingH,
                    AppDimens.sp24,
                    AppDimens.paddingH,
                    AppDimens.sp12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.recentAnalyses,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (!isGuest)
                        TextButton(
                          onPressed: () => context.go(AppRoutes.history),
                          child: const Text(AppStrings.viewAll),
                        ),
                    ],
                  ),
                ),
              ),

              // Recent analyses list
              if (isGuest)
                const SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    message: AppStrings.noAnalysesYet,
                    icon: Icons.description_outlined,
                  ),
                )
              else
                _RecentAnalysesList(),

              // Information & Guides header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingH,
                    AppDimens.sp24,
                    AppDimens.paddingH,
                    AppDimens.sp8,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Information & Help Guides',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),

              // Info 2x2 grid
              SliverToBoxAdapter(
                child: _InfoActions(),
              ),

              // Subtle copyright footer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '© 2026 CV2Career • Team 78',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textDisabled,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// Greeting header with user name and time-based greeting.
class _HomeHeader extends ConsumerWidget {
  final bool isGuest;
  final AsyncValue profile;

  const _HomeHeader({required this.isGuest, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = AppUtils.timeGreeting();

    // Build user name: Guest > profile displayName > email part > fallback.
    final name = isGuest
        ? 'Guest'
        : profile.when(
            data: (p) => p?.nameForGreeting ?? 'there',
            loading: () => '...',
            error: (_, __) => 'there',
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp24,
        AppDimens.paddingH,
        AppDimens.sp8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name!',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn().slideX(begin: -0.05, end: 0),
          const SizedBox(height: 4),
          Text(
            AppStrings.homeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }
}

// Banner nudging guest users to sign in.
class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp12,
        AppDimens.paddingH,
        0,
      ),
      child: AppCard(
        color: AppColors.primarySurface,
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: AppDimens.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.guestBannerTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    AppStrings.guestBannerSub,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text(AppStrings.signInNow),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }
}

// Quick-action cards: Upload Resume, Career Compass, and Check Skill Gap.
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp20,
        AppDimens.paddingH,
        0,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppDimens.sp12,
        mainAxisSpacing: AppDimens.sp12,
        childAspectRatio: 1.0,
        children: [
          _GradientActionCard(
            icon: Icons.upload_file_rounded,
            title: AppStrings.uploadResumeCard,
            subtitle: AppStrings.uploadResumeCardSub,
            gradientColors: const [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
            onTap: () => context.push(AppRoutes.upload),
            delay: 150,
          ),
          _GradientActionCard(
            icon: Icons.explore_rounded,
            title: AppStrings.careerCompassCard,
            subtitle: AppStrings.careerCompassCardSub,
            gradientColors: const [
              Color(0xFF2E5AA8),
              Color(0xFF60A5FA),
            ],
            onTap: () => context.go(AppRoutes.careerCompassQuestionnaire),
            delay: 250,
          ),
          _GradientActionCard(
            icon: Icons.analytics_outlined,
            title: 'Check Skill Gap',
            subtitle: 'Compare CV vs Job description using AI',
            gradientColors: const [
              Color(0xFF0F766E),
              Color(0xFF14B8A6),
            ],
            onTap: () => context.push(AppRoutes.skillGapInput),
            delay: 350,
          ),
          _GradientActionCard(
            icon: Icons.map_outlined,
            title: 'Career Roadmap',
            subtitle: 'Personalized step-by-step career path using AI',
            gradientColors: const [
              Color(0xFF1A365D),
              Color(0xFF0D9488),
            ],
            onTap: () => context.push(AppRoutes.careerRoadmapInput),
            delay: 450,
          ),
        ],
      ),
    );
  }
}

class _GradientActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final int delay;

  const _GradientActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.gradientColors,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -15,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.sp12,
                    vertical: AppDimens.sp16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 36),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp12,
        AppDimens.paddingH,
        0,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppDimens.sp12,
        mainAxisSpacing: AppDimens.sp12,
        childAspectRatio: 1.0,
        children: [
          _InfoCardTile(
            icon: Icons.menu_book_rounded,
            title: 'How to Use',
            onTap: () => _showHowToUseSheet(context),
          ),
          _InfoCardTile(
            icon: Icons.star_border_rounded,
            title: 'Additional Features',
            onTap: () => _showFeaturesSheet(context),
          ),
          _InfoCardTile(
            icon: Icons.supervised_user_circle_outlined,
            title: 'Guest Capabilities',
            onTap: () => _showGuestLimitsSheet(context),
          ),
          _InfoCardTile(
            icon: Icons.info_outline_rounded,
            title: 'About Developers',
            onTap: () => _showDevelopersSheet(context),
          ),
        ],
      ),
    );
  }
}

class _InfoCardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _InfoCardTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── BOTTOM SHEETS FOR HELP & INFO ────────────────────────────────────────

void _showHowToUseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppDimens.paddingH),
        children: [
          _buildSheetHandle(),
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'How to Use CV2Career',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBulletStep('1', 'Upload & Analyze Resume', 'Navigate to the "Upload Resume" tab, choose your CV/Resume file (PDF, DOCX, or TXT format), and let the AI extract details. You will get a detailed breakdown of your ATS (Applicant Tracking System) score, layout formatting recommendations, content impact suggestions, and a precise checklist of missing keywords to tailor your CV.'),
          _buildBulletStep('2', 'Discover via Career Compass', 'Launch the "Career Compass" questionnaire. Answer questions about your passions, working style, skills, and values. The AI will cross-reference your answers against dynamic tech sectors to identify the best-fit career domains tailored to your profile.'),
          _buildBulletStep('3', 'Bridge Your Skill Gaps', 'Use the "Check Skill Gap" tool. Paste any specific job description you want to apply for. The engine compares it with your current CV, flagging matching skills, missing keywords, and critical credentials you need to acquire.'),
          _buildBulletStep('4', 'Follow Your Custom Roadmap', 'Use the "Career Roadmap" feature to build a step-by-step learning journey. It provides estimated timelines, structured phases, and learning resources (such as specific certifications, online courses, and hands-on projects) to guide you from where you are to your goal.'),
          _buildBulletStep('5', 'Track Your Progress & History', 'For signed-in users, every resume analysis, skill gap comparison, and career compass result is saved securely. You can review past evaluations, monitor improvements in your ATS score over time, and update your information on the fly.'),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

void _showFeaturesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppDimens.paddingH),
        children: [
          _buildSheetHandle(),
          Row(
            children: [
              Icon(Icons.star_border_rounded, color: AppColors.warning, size: 24),
              const SizedBox(width: 8),
              Text(
                'Additional Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(Icons.dark_mode_outlined, 'Light & Dark Theme Toggle', 'Switch between light and dark mode in the profile section to adapt the screen brightness to your environment.'),
          _buildFeatureItem(Icons.face_retouching_natural_outlined, 'Customise Personal Profile', 'Update your display name and upload a customized avatar image to personalize your dashboard experience.'),
          _buildFeatureItem(Icons.cloud_done_outlined, 'Save a Primary CV', 'Upload a master CV in your profile screen. This CV will persist across sessions and serve as the default input for skill analysis and roadmapping.'),
          _buildFeatureItem(Icons.history_edu_outlined, 'Interactive History Hub', 'Access and manage your complete history of ATS scores, skill gap analyses, and roadmaps. Delete old analysis results or review past suggestions in a single consolidated tab.'),
          _buildFeatureItem(Icons.lock_reset_outlined, 'Secure Passwords & Accounts', 'Change your password or request a reset link securely through Supabase authentication in the profile tab, protecting your data.'),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

void _showGuestLimitsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppDimens.paddingH),
        children: [
          _buildSheetHandle(),
          Row(
            children: [
              Icon(Icons.supervised_user_circle_outlined, color: AppColors.danger, size: 24),
              const SizedBox(width: 8),
              Text(
                'Guest Capabilities & Limits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Guest Capabilities (No Sign-In)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• Run Full AI Resume Analysis: Check your resume for ATS score, structure, and keyword checklist.\n'
            '• Career Compass Discovery: Complete the 18-question assessment to get AI career suggestions.\n'
            '• Compare Skill Gaps: Paste a job description and compare it against your uploaded resume.\n'
            '• Generate Roadmaps: Create a step-by-step career path for any target profession.\n'
            '• Immediate Processing: All evaluations run in real-time, in-memory on our servers.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Guest Limitations & Constraints',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• No Persistence: Because guest data is in-memory, all results, uploaded resumes, and questionnaire answers are permanently discarded when you close or restart the app.\n'
            '• No Profile Customization: You cannot save a primary CV, customize your display name, or change profile pictures.\n'
            '• No History Dashboard: You cannot track your ATS score improvement trends or access previous analysis history.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Registered User Privileges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Registered profiles sync automatically with our Supabase cloud database. This grants access to a permanent resume history dashboard, ATS score trend tracking, primary CV uploads, and user profile customizations.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

void _showDevelopersSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppDimens.paddingH),
        children: [
          _buildSheetHandle(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'About the Developers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Team 78 - Project One',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Department of Computer Science and Engineering\nLeading University • Batch 62, Section I',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Salman
          _buildDevItemCard(
            context,
            name: 'Salman Khan Rume',
            id: '0182320012101384',
            email: 'salmankhanrume62@gmail.com',
            initials: 'SK',
          ),
          const SizedBox(height: 12),

          // Tasmia (Diya)
          _buildDevItemCard(
            context,
            name: 'Tasmia Haque Diya',
            id: '0182320012101347',
            email: 'tasmiahaqueofficial@gmail.com',
            initials: 'TH',
          ),
          const SizedBox(height: 12),

          // Rehana (Juhi)
          _buildDevItemCard(
            context,
            name: 'Rehana Parvin Juhi',
            id: '0182320012101397',
            email: 'parvinjuhi387@gmail.com',
            initials: 'RP',
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

Widget _buildSheetHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Widget _buildBulletStep(String num, String title, String desc) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildFeatureItem(IconData icon, String title, String desc) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDevItemCard(
  BuildContext context, {
  required String name,
  required String id,
  required String email,
  required String initials,
}) {
  Future<void> sendEmailHelper(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrl(emailLaunchUri);
    } catch (_) {}
  }

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ID: $id',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.envelope, size: 18),
          onPressed: () => sendEmailHelper(email),
          color: AppColors.primary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

// Shows the 3 most recent analyses for logged-in users.
class _RecentAnalysesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(analysisHistoryProvider);

    return history.when(
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingH),
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(analysisHistoryProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyStateWidget(
              message: AppStrings.noAnalysesYet,
              icon: Icons.description_outlined,
            ),
          );
        }
        final recent = items.take(3).toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingH,
                0,
                AppDimens.paddingH,
                AppDimens.sp12,
              ),
              child: _AnalysisHistoryCard(result: recent[index], index: index),
            ),
            childCount: recent.length,
          ),
        );
      },
    );
  }
}

// A single analysis result card in the recent list.
class _AnalysisHistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final int index;

  const _AnalysisHistoryCard({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.analysisResult, extra: result),
      child: Row(
        children: [
          ScoreCircle(
            score: result.overallScore,
            label: AppStrings.overallScore,
            size: AppDimens.scoreCircleSm,
            fontSize: 14,
          ),
          const SizedBox(width: AppDimens.sp16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.resumeFileName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatDate(result.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'ATS: ${result.atsScore}/100',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.05, end: 0);
  }
}
