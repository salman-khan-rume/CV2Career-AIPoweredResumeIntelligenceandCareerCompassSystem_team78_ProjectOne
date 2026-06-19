import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/app_utils.dart';
import '../providers/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/resume_analysis_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_error_widgets.dart';

class SkillGapInputScreen extends ConsumerStatefulWidget {
  const SkillGapInputScreen({super.key});

  @override
  ConsumerState<SkillGapInputScreen> createState() => _SkillGapInputScreenState();
}

class _SkillGapInputScreenState extends ConsumerState<SkillGapInputScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CV Selection state
  bool _useSavedCV = true;
  PlatformFile? _newCvFile;
  String? _newCvText;

  // Job Description state
  final TextEditingController _jdTextController = TextEditingController();
  final TextEditingController _jdUrlController = TextEditingController();
  PlatformFile? _jdFile;
  String? _jdFileText;

  // Global analysis progress state
  bool _isProcessing = false;
  String _loadingMessage = 'Preparing analysis...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jdTextController.dispose();
    _jdUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickNewCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      if (picked.size > 5 * 1024 * 1024) {
        throw Exception('File exceeds 5 MB limit.');
      }

      setState(() {
        _isProcessing = true;
        _loadingMessage = 'Extracting resume text...';
      });

      final ext = picked.extension?.toLowerCase() ?? '';
      final bytes = picked.bytes;
      if (bytes == null) {
        throw Exception('Could not read file bytes.');
      }

      final pdfService = ref.read(pdfServiceProvider);
      final text = await pdfService.extractTextFromBytes(bytes, ext);

      setState(() {
        _newCvFile = picked;
        _newCvText = text;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read CV: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickJDFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      if (picked.size > 5 * 1024 * 1024) {
        throw Exception('File exceeds 5 MB limit.');
      }

      setState(() {
        _isProcessing = true;
        _loadingMessage = 'Extracting job description text...';
      });

      final ext = picked.extension?.toLowerCase() ?? '';
      final bytes = picked.bytes;
      if (bytes == null) {
        throw Exception('Could not read file bytes.');
      }

      final pdfService = ref.read(pdfServiceProvider);
      final text = await pdfService.extractTextFromBytes(bytes, ext);

      setState(() {
        _jdFile = picked;
        _jdFileText = text;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read job description: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<String> _fetchTextFromUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Server returned status code ${response.statusCode}');
      }
      
      final html = response.body;
      var cleanText = html.replaceAll(RegExp(r'<script[^>]*>([\s\S]*?)<\/script>', caseSensitive: false), '');
      cleanText = cleanText.replaceAll(RegExp(r'<style[^>]*>([\s\S]*?)<\/style>', caseSensitive: false), '');
      cleanText = cleanText.replaceAll(RegExp(r'<[^>]*>'), ' ');
      cleanText = cleanText
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"');
      cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      if (cleanText.isEmpty) {
        throw Exception('No readable text content found on this webpage.');
      }
      
      return cleanText;
    } catch (e) {
      throw Exception(
        'Failed to read webpage content. Anti-bot protections on job boards frequently block automated fetch tools.\n\n'
        'Recommended: Copy the job description text and use the "Paste Text" tab instead.'
      );
    }
  }

  Future<void> _analyse() async {
    // 1. Get CV Text
    String? cvText;
    if (_useSavedCV) {
      final profileState = ref.read(userProfileProvider);
      final savedText = profileState.value?.primaryCvText;
      if (savedText == null || savedText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please upload a primary CV in your profile first, or upload a new CV below.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      cvText = savedText;
    } else {
      if (_newCvText == null || _newCvText!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select and upload a CV.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      cvText = _newCvText;
    }

    // 2. Get JD Text based on selected tab
    String? jdText;
    final currentTab = _tabController.index;
    setState(() {
      _isProcessing = true;
    });

    try {
      if (currentTab == 0) {
        // Paste Text
        final text = _jdTextController.text.trim();
        if (text.isEmpty) {
          throw Exception('Please paste the job description text.');
        }
        jdText = text;
      } else if (currentTab == 1) {
        // Upload File
        if (_jdFileText == null || _jdFileText!.trim().isEmpty) {
          throw Exception('Please select and upload a job description file.');
        }
        jdText = _jdFileText;
      } else if (currentTab == 2) {
        // Paste URL
        final url = _jdUrlController.text.trim();
        if (url.isEmpty) {
          throw Exception('Please enter a job listing URL.');
        }
        setState(() {
          _loadingMessage = 'Fetching job description from URL...';
        });
        jdText = await _fetchTextFromUrl(url);
      }

      if (jdText == null || jdText.trim().isEmpty) {
        throw Exception('Job description is empty.');
      }

      setState(() {
        _loadingMessage = 'AI comparing CV and Job Description...';
      });

      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.analyzeSkillGapWithJD(
        resumeText: cvText!,
        jobDescriptionText: jdText,
      );

      if (!mounted) return;
      context.push(AppRoutes.skillGap, extra: {
        'dynamicReport': result,
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.danger),
                const SizedBox(width: 8),
                const Text('Analysis Error'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(e.toString().replaceAll('Exception: ', '')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _loadingMessage = 'Preparing analysis...';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    final hasSavedCV = profile?.primaryCvName?.isNotEmpty == true;

    // Default to new CV upload if no saved CV exists.
    if (!hasSavedCV && _useSavedCV) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _useSavedCV = false;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Skill Gap'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Compare your CV directly against a Job Description (JD) using advanced AI to spot gaps and recommended learning paths.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sp24),

                  // Section 1: CV Selection
                  Text(
                    '1. Select your CV / Resume',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sp12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasSavedCV) ...[
                          RadioListTile<bool>(
                            value: true,
                            groupValue: _useSavedCV,
                            onChanged: (val) {
                              if (val != null) setState(() => _useSavedCV = val);
                            },
                            title: const Text('Use Saved Primary CV'),
                            subtitle: Text(
                              profile?.primaryCvName ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                          ),
                          const Divider(height: 1),
                        ],
                        RadioListTile<bool>(
                          value: false,
                          groupValue: _useSavedCV,
                          onChanged: (val) {
                            if (val != null) setState(() => _useSavedCV = val);
                          },
                          title: const Text('Upload a different CV'),
                          subtitle: _newCvFile != null
                              ? Text(_newCvFile!.name, style: TextStyle(color: AppColors.success))
                              : const Text('PDF, DOCX, or TXT (Max 5MB)'),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                        if (!_useSavedCV) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickNewCV,
                              icon: const Icon(Icons.upload_file),
                              label: Text(_newCvFile != null ? 'Change CV File' : 'Pick CV File'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.sp24),

                  // Section 2: Job Description
                  Text(
                    '2. Provide the Job Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sp12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: const [
                            Tab(text: 'Paste Text', icon: Icon(Icons.paste)),
                            Tab(text: 'Upload File', icon: Icon(Icons.description)),
                            Tab(text: 'Paste URL', icon: Icon(Icons.link)),
                          ],
                        ),
                        SizedBox(
                          height: 240,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Tab 1: Paste text
                              Padding(
                                padding: const EdgeInsets.all(AppDimens.sp16),
                                child: TextField(
                                  controller: _jdTextController,
                                  maxLines: 8,
                                  decoration: InputDecoration(
                                    hintText: 'Paste the requirements, responsibilities, or complete job posting details here...',
                                    hintStyle: TextStyle(color: AppColors.textDisabled),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              // Tab 2: Upload file
                              Padding(
                                padding: const EdgeInsets.all(AppDimens.sp16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _jdFile != null ? Icons.task_outlined : Icons.upload_file_outlined,
                                      size: 48,
                                      color: _jdFile != null ? AppColors.success : AppColors.textDisabled,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _jdFile != null ? _jdFile!.name : 'Upload the job spec sheet or PDF',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_jdFile != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        AppUtils.formatFileSize(_jdFile!.size),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _pickJDFile,
                                      child: Text(_jdFile != null ? 'Change File' : 'Choose File'),
                                    ),
                                  ],
                                ),
                              ),
                              // Tab 3: Paste URL
                              Padding(
                                padding: const EdgeInsets.all(AppDimens.sp16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _jdUrlController,
                                      decoration: const InputDecoration(
                                        labelText: 'Job Listing Link',
                                        hintText: 'https://careers.google.com/jobs/results/...',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.link),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Due to anti-bot measures, job boards (e.g. LinkedIn, Indeed) often block automated page readers. If fetching fails, please paste the text directly.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.sp32),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _analyse,
                    child: const Text('Analyse Skill Gap'),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppDimens.sp32),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            LoadingOverlay(message: _loadingMessage),
        ],
      ),
    );
  }
}
