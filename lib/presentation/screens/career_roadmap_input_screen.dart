import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../providers/app_routes.dart';
import '../providers/career_roadmap_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_error_widgets.dart';

class CareerRoadmapInputScreen extends ConsumerStatefulWidget {
  const CareerRoadmapInputScreen({super.key});

  @override
  ConsumerState<CareerRoadmapInputScreen> createState() => _CareerRoadmapInputScreenState();
}

class _CareerRoadmapInputScreenState extends ConsumerState<CareerRoadmapInputScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Target Role
  final TextEditingController _targetRoleController = TextEditingController();
  final List<String> _popularRoles = [
    'Software Engineer',
    'Data Scientist',
    'Product Manager',
    'UI/UX Designer',
    'DevOps Engineer',
    'Cybersecurity Analyst',
  ];

  // Step 2: Background & Level
  String _currentStatus = 'Student / Self-taught';
  String _experienceLevel = 'Beginner (No experience)';

  final List<String> _statusOptions = [
    'Student / Self-taught',
    'Career Switcher (Non-tech background)',
    'Tech Professional (Looking to level up/pivot)',
  ];

  final List<String> _levelOptions = [
    'Beginner (No experience)',
    'Intermediate (1-2 years experience)',
    'Advanced (3+ years experience)',
  ];

  // Step 3: Skills & Commitment
  final TextEditingController _currentSkillsController = TextEditingController();
  String _studyHours = '3-4 hours (Focused)';

  final List<String> _hoursOptions = [
    '1-2 hours (Part-time)',
    '3-4 hours (Focused)',
    '5+ hours (Full-time / High intensity)',
  ];

  @override
  void dispose() {
    _targetRoleController.dispose();
    _currentSkillsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _targetRoleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please tell us what role you want to achieve.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _generateRoadmap();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _generateRoadmap() async {
    final target = _targetRoleController.text.trim();
    final background = 'Current Status: $_currentStatus. '
        'Experience Level: $_experienceLevel. '
        'Current skills/technologies known: ${_currentSkillsController.text.trim().isNotEmpty ? _currentSkillsController.text.trim() : "None mentioned"}. '
        'Daily commitment: $_studyHours.';

    final success = await ref.read(careerRoadmapProvider.notifier).generateRoadmap(
          targetRole: target,
          currentCondition: background,
        );

    if (success && mounted) {
      final data = ref.read(careerRoadmapProvider).roadmapData;
      if (data != null) {
        context.pushReplacement(AppRoutes.careerRoadmapResult, extra: data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roadmapState = ref.watch(careerRoadmapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Career Roadmap'),
        leading: BackButton(onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
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
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Step Indicator Progress Bar
                  _buildProgressIndicator(),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimens.paddingH),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppDimens.sp8),
                          if (_currentStep == 0) _buildStepOne(),
                          if (_currentStep == 1) _buildStepTwo(),
                          if (_currentStep == 2) _buildStepThree(),
                          const SizedBox(height: AppDimens.sp32),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Buttons Row
                  _buildBottomNavigation(),
                ],
              ),
            ),
            if (roadmapState.isLoading)
              const LoadingOverlay(message: 'AI is formulating your personalized Career Roadmap...'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingH, vertical: AppDimens.sp12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              final isDone = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone 
                          ? AppColors.success 
                          : (isCurrent ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: (isCurrent || isDone) ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                  if (index < _totalSteps - 1)
                    Container(
                      width: 50,
                      height: 2,
                      color: index < _currentStep ? AppColors.success : AppColors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _currentStep == 0 
                ? 'Step 1: Your Target Role' 
                : _currentStep == 1 
                    ? 'Step 2: Experience & Background' 
                    : 'Step 3: Skillset & Budget',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you want to be?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'Enter the career path or specific job title you are aiming to reach.',
          style: Theme.of(context).textTheme.bodySmall,
        ).animate().fadeIn(delay: 50.ms),
        const SizedBox(height: AppDimens.sp24),
        TextField(
          controller: _targetRoleController,
          decoration: const InputDecoration(
            labelText: 'Target Job Title',
            hintText: 'e.g. Full Stack Web Developer',
            prefixIcon: Icon(Icons.stars),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: AppDimens.sp24),
        Text(
          'Popular Suggestions:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularRoles.map((role) {
            return ChoiceChip(
              label: Text(role),
              selected: _targetRoleController.text == role,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _targetRoleController.text = role;
                  });
                }
              },
            );
          }).toList(),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about your background',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'This helps our AI tailor the starting point of your roadmap.',
          style: Theme.of(context).textTheme.bodySmall,
        ).animate().fadeIn(delay: 50.ms),
        const SizedBox(height: AppDimens.sp24),
        
        Text(
          'Current Profile / Scenario:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        ..._statusOptions.map((opt) {
          final isSelected = _currentStatus == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => setState(() => _currentStatus = opt),
              color: isSelected ? AppColors.primarySurface : AppColors.card,
              borderRadius: 12,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Radio<String>(
                    value: opt,
                    groupValue: _currentStatus,
                    onChanged: (val) {
                      if (val != null) setState(() => _currentStatus = val);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(opt, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          );
        }).toList().animate().fadeIn(delay: 150.ms),

        const SizedBox(height: AppDimens.sp16),
        Text(
          'Target-Related Experience:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        ..._levelOptions.map((opt) {
          final isSelected = _experienceLevel == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => setState(() => _experienceLevel = opt),
              color: isSelected ? AppColors.primarySurface : AppColors.card,
              borderRadius: 12,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Radio<String>(
                    value: opt,
                    groupValue: _experienceLevel,
                    onChanged: (val) {
                      if (val != null) setState(() => _experienceLevel = val);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(opt, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          );
        }).toList().animate().fadeIn(delay: 250.ms),
      ],
    );
  }

  Widget _buildStepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Current Skills & Commitment',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        Text(
          'Provide details on what you know and how much time you can spend.',
          style: Theme.of(context).textTheme.bodySmall,
        ).animate().fadeIn(delay: 50.ms),
        const SizedBox(height: AppDimens.sp24),
        TextField(
          controller: _currentSkillsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Current Skills & Technologies',
            hintText: 'e.g. JavaScript, Basic HTML/CSS, Git, Excel',
            prefixIcon: Icon(Icons.psychology),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: AppDimens.sp24),
        
        Text(
          'Daily Learning Time Budget:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 8),
        ..._hoursOptions.map((opt) {
          final isSelected = _studyHours == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => setState(() => _studyHours = opt),
              color: isSelected ? AppColors.primarySurface : AppColors.card,
              borderRadius: 12,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Radio<String>(
                    value: opt,
                    groupValue: _studyHours,
                    onChanged: (val) {
                      if (val != null) setState(() => _studyHours = val);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(opt, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          );
        }).toList().animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingH),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(_currentStep == _totalSteps - 1 ? 'Generate Roadmap' : 'Next Step'),
            ),
          ),
        ],
      ),
    );
  }
}
