import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';

class CareerRoadmapResultScreen extends StatelessWidget {
  final Map<String, dynamic> roadmapData;

  const CareerRoadmapResultScreen({
    super.key,
    required this.roadmapData,
  });

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString.trim());
      // Launch directly without canLaunchUrl check to prevent emulator/device query security failures
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open link: $urlString. Please copy and paste manually.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetRole = roadmapData['target_role'] as String? ?? 'Career Roadmap';
    final currentCondition = roadmapData['current_condition'] as String? ?? '';
    final timeline = roadmapData['estimated_timeline'] as String? ?? 'Flexible Timeline';
    final phasesList = roadmapData['phases'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Career Roadmap'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go(AppRoutes.home),
            tooltip: 'Close and return home',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingH),
                child: AppCard(
                  color: AppColors.primary,
                  padding: const EdgeInsets.all(AppDimens.sp16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              targetRole,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              timeline,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Target Goal Path',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (currentCondition.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        const Text(
                          'Starting Background:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentCondition,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.05, end: 0),
              ),

              const SizedBox(height: 16),

              // Timeline List of Phases
              Expanded(
                child: phasesList.isEmpty
                    ? const Center(
                        child: Text('No roadmap phases returned. Please try again.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.paddingH,
                          0,
                          AppDimens.paddingH,
                          AppDimens.sp24,
                        ),
                        itemCount: phasesList.length,
                        itemBuilder: (context, index) {
                          final phase = phasesList[index] as Map? ?? {};
                          final phaseNum = phase['phase_number'] as int? ?? (index + 1);
                          final phaseTitle = phase['title'] as String? ?? 'Phase';
                          final phaseDesc = phase['description'] as String? ?? '';
                          final phaseDur = phase['duration'] as String? ?? '';
                          final milestones = phase['milestones'] as List? ?? [];
                          final resources = phase['resources'] as List? ?? [];

                          return _buildTimelinePhaseCard(
                            context,
                            index: index,
                            total: phasesList.length,
                            phaseNum: phaseNum,
                            title: phaseTitle,
                            description: phaseDesc,
                            duration: phaseDur,
                            milestones: milestones.cast<String>(),
                            resources: resources,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelinePhaseCard(
    BuildContext context, {
    required int index,
    required int total,
    required int phaseNum,
    required String title,
    required String description,
    required String duration,
    required List<String> milestones,
    required List<dynamic> resources,
  }) {
    // Generate distinct color markers based on phase index
    final List<Color> colorsList = [
      AppColors.primary,
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF0D9488), // Teal
      const Color(0xFFD97706), // Amber
    ];
    final markerColor = colorsList[index % colorsList.length];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vertical Line Indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$phaseNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < total - 1)
                Expanded(
                  child: Container(
                    width: 2,
                    color: markerColor.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: markerColor,
                                ),
                          ),
                        ),
                        if (duration.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: markerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              duration,
                              style: TextStyle(
                                color: markerColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (description.isNotEmpty) ...[
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (milestones.isNotEmpty) ...[
                      const Text(
                        'Target Milestones:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...milestones.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                    ],
                    if (resources.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 6),
                      const Text(
                        'Recommended Resources:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...resources.map((resItem) {
                        final res = resItem as Map? ?? {};
                        final name = res['name'] as String? ?? 'Learning Link';
                        final url = res['url'] as String? ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: url.isNotEmpty ? () => _launchURL(context, url) : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.open_in_new,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 150)).slideX(begin: 0.05, end: 0);
  }
}
