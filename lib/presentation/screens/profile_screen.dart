import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/app_routes.dart';
import '../providers/theme_provider.dart';
import '../providers/resume_analysis_provider.dart';
import '../../data/models/user_profile.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_error_widgets.dart';
import '../widgets/edit_profile_dialog.dart';

// Screen 17: Profile.
// Shows user info, edit option, total analyses, and sign-out button.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final themeMode = ref.watch(themeProvider);

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.profileTitle)),
        body: EmptyStateWidget(
          message: 'Sign in to view your profile and track your progress.',
          icon: Icons.person_outline,
          action: ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text(AppStrings.signInNow),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.primarySurface.withOpacity(0.3),
              AppColors.background,
            ],
          ),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final profile = ref.watch(userProfileProvider);

            return profile.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, st) {
                return ErrorStateWidget(
                  message: 'Failed to load profile.\nError: ${e.toString()}',
                  onRetry: () => ref.invalidate(userProfileProvider),
                );
              },
              data: (user) {
                if (user == null) {
                  return ErrorStateWidget(
                    message: 'No profile data available.',
                    onRetry: () => ref.invalidate(userProfileProvider),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(AppDimens.paddingH),
                  children: [
                    // Avatar + name + edit button header
                    _ProfileHeader(
                      displayName: user.nameForGreeting,
                      email: user.email,
                      avatarUrl: user.avatarUrl,
                    ).animate().fadeIn(),
                    const SizedBox(height: AppDimens.sp20),

                    // Stats: Total analyses + Member since
                    _StatsRow(
                      totalAnalyses: user.totalAnalyses,
                      memberSince: AppUtils.formatDate(user.createdAt),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: AppDimens.sp20),

                    // Saved Primary CV Card
                    _PrimaryCvCard(user: user).animate().fadeIn(delay: 125.ms),
                    const SizedBox(height: AppDimens.sp20),

                    // Menu section (History, Theme Toggle, About, Privacy)
                    _MenuSection(items: [
                      _MenuItem(
                        icon: Icons.history_outlined,
                        label: AppStrings.historyTitle,
                        onTap: () => context.go(AppRoutes.history),
                      ),
                      _MenuItem(
                        icon: themeMode == AppThemeMode.light
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        label: themeMode == AppThemeMode.light
                            ? 'Dark Mode'
                            : 'Light Mode',
                        onTap: () => ref.read(themeProvider.notifier).toggle(),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        label: AppStrings.aboutApp,
                        onTap: () => _showAbout(context),
                      ),
                      _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: AppStrings.privacyPolicy,
                        onTap: () => _showPrivacyPolicy(context),
                      ),
                    ]).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: AppDimens.sp20),

                    // Sign out button (prominent at bottom)
                    _SignOutButton().animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppDimens.sp32),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.aboutApp),
        content: const Text(
          'CV2Career is a premium, state-of-the-art AI-powered career intelligence platform designed to empower professionals. '
          'Our advanced engine parses and analyzes your CV/resume, scoring it against industry ATS (Applicant Tracking System) benchmarks, '
          'and provides key missing keyword recommendations.\n\n'
          'Additionally, our Career Compass questionnaire guides you toward the best-fit roles, while our Skill Gap Analyser maps out a personalized learning and certification roadmap to secure your dream job.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            'At CV2Career, we take your privacy seriously. Your resumes and career data are processed securely.\n\n'
            '1. Data Collection: We collect name, email, and CV content to generate AI resume scores and career roadmap recommendations.\n\n'
            '2. AI Processing: Resumes are analyzed using secure AI engines (Gemini and Groq). We do not share your personal information with third parties.\n\n'
            '3. Storage: Registered users have their history stored securely in our Supabase databases. Guests process data in-memory without persistent logs.\n\n'
            '4. Your Rights: You can update your profile name, modify your avatar, or request complete account deletion at any time.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

}

// Circular avatar + user name and email, with edit button.
class _ProfileHeader extends ConsumerWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) return;

      final ext = file.extension?.toLowerCase() ?? 'png';

      if (!context.mounted) return;
      // Show a temporary snackbar loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading avatar...'),
          duration: Duration(seconds: 2),
        ),
      );

      final supabaseService = ref.read(supabaseServiceProvider);
      final publicUrl = await supabaseService.uploadAvatarBytes(bytes, ext);

      // Update the user profile
      await supabaseService.updateProfile(avatarUrl: publicUrl);

      // Invalidate provider to trigger UI redraw
      ref.invalidate(userProfileProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Avatar updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload avatar: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty && avatarUrl != 'null';

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primarySurface,
              backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
              child: !hasAvatar
                  ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickAndUploadAvatar(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sp12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayName.isEmpty ? 'User' : displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22),
              color: AppColors.primary,
              onPressed: () => _showEditDialog(context, displayName),
              tooltip: AppStrings.editProfile,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Show edit profile dialog modal.
  void _showEditDialog(BuildContext context, String currentName) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(currentName: currentName),
    );
  }
}

// Total analyses + member since stats.
class _StatsRow extends StatelessWidget {
  final int totalAnalyses;
  final String memberSince;

  const _StatsRow({required this.totalAnalyses, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: AppStrings.totalAnalyses,
              value: totalAnalyses.toString(),
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: _StatItem(
              label: AppStrings.memberSince,
              value: memberSince,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
      ],
    );
  }
}

// List of tappable menu items inside a card.
class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(e.value.icon, color: AppColors.primary, size: 22),
                title: Text(e.value.label,
                    style: Theme.of(context).textTheme.bodyMedium),
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
                onTap: e.value.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _confirmSignOut(context, ref),
      icon: Icon(Icons.logout, color: AppColors.danger, size: 20),
      label: Text(
        AppStrings.signOut,
        style: TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.danger.withOpacity(0.4), width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        shape: const StadiumBorder(),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.signOut),
        content: const Text(AppStrings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              ref.read(guestModeProvider.notifier).setGuest(false);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: Text(
              AppStrings.confirm,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCvCard extends ConsumerStatefulWidget {
  final UserProfile user;
  const _PrimaryCvCard({required this.user});

  @override
  ConsumerState<_PrimaryCvCard> createState() => _PrimaryCvCardState();
}

class _PrimaryCvCardState extends ConsumerState<_PrimaryCvCard> {
  bool _isProcessing = false;
  String? _statusMessage;

  Future<void> _uploadCV() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Opening file picker...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
        return;
      }

      final picked = result.files.single;
      final bytes = picked.bytes;
      if (bytes == null) {
        throw Exception('Could not read file bytes. Please try again.');
      }

      if (picked.size > 5 * 1024 * 1024) {
        throw Exception('File exceeds the 5 MB limit.');
      }

      final ext = picked.extension?.toLowerCase() ?? '';
      if (!['pdf', 'docx', 'txt'].contains(ext)) {
        throw Exception('Unsupported file format. Please upload PDF, DOCX, or TXT.');
      }

      setState(() {
        _statusMessage = 'Extracting resume text...';
      });

      // Extract text
      final pdfService = ref.read(pdfServiceProvider);
      final extractedText = await pdfService.extractTextFromBytes(bytes, ext);

      setState(() {
        _statusMessage = 'Uploading and saving primary CV...';
      });

      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.savePrimaryCV(
        bytes: bytes,
        fileName: picked.name,
        extension: ext,
        extractedText: extractedText,
      );

      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Primary CV saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save CV: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _deleteCV() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Primary CV?'),
        content: const Text(
          'Are you sure you want to delete your primary CV? This will remove it from our servers, and you will need to upload a resume manually when running new skill gap analyses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Deleting primary CV...';
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.deletePrimaryCV();
      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Primary CV deleted.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete CV: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCV = widget.user.primaryCvName != null && widget.user.primaryCvName!.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_ind_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Primary CV',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (hasCV && !_isProcessing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Saved',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage ?? 'Processing...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else if (hasCV)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.primaryCvName!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.user.primaryCvUpdatedAt != null
                                  ? 'Saved on ${AppUtils.formatDate(widget.user.primaryCvUpdatedAt!)}'
                                  : 'Saved CV',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _uploadCV,
                          icon: const Icon(Icons.sync, size: 16),
                          label: const Text('Replace'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _deleteCV,
                          icon: Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: AppColors.danger.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No primary CV saved yet. Save your CV to analyze skill gaps directly against job descriptions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _uploadCV,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Primary CV'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
