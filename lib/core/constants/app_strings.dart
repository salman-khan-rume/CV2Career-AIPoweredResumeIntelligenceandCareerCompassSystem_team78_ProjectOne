// All user-facing strings are defined here.
// Never hardcode strings in widget files.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'CV2Career';
  static const String appTagline = 'AI-Powered Resume Intelligence';

  // Splash
  static const String splashTagline = 'Your career journey starts here';

  // Onboarding
  static const String onboarding1Title = 'Upload Your Resume';
  static const String onboarding1Body =
      'Upload your resume in PDF, DOC, or TXT format and let AI do the heavy lifting.';
  static const String onboarding2Title = 'Get AI Insights';
  static const String onboarding2Body =
      'Receive your ATS score, quality analysis, and actionable suggestions instantly.';
  static const String onboarding3Title = 'Discover Your Career Path';
  static const String onboarding3Body =
      'Use Career Compass to find the best-fit domains and close your skill gaps.';
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';

  // Auth
  static const String welcomeTitle = 'Welcome to CV2Career';
  static const String welcomeSubtitle = 'Sign in to save your progress';
  static const String loginTitle = 'Sign In';
  static const String registerTitle = 'Create Account';
  static const String forgotPasswordTitle = 'Reset Password';
  static const String emailLabel = 'Email Address';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String fullNameLabel = 'Full Name';
  static const String loginButton = 'Sign In';
  static const String registerButton = 'Create Account';
  static const String forgotPasswordButton = 'Send Reset Link';
  static const String continueAsGuest = 'Continue as Guest';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signUpLink = 'Sign Up';
  static const String signInLink = 'Sign In';
  static const String forgotPasswordLink = 'Forgot Password?';
  static const String resetEmailSent = 'Password reset email sent. Check your inbox.';

  // Home
  static const String homeGreetingGuest = 'Hello, Guest!';
  static const String homeSubtitle = 'Ready to boost your career?';
  static const String uploadResumeCard = 'Upload Resume';
  static const String uploadResumeCardSub = 'Get AI-powered analysis';
  static const String careerCompassCard = 'Career Compass';
  static const String careerCompassCardSub = 'Find your best-fit path';
  static const String recentAnalyses = 'Recent Analyses';
  static const String noAnalysesYet = 'No analyses yet. Upload your first resume!';
  static const String viewAll = 'View All';
  static const String guestBannerTitle = 'Sign in to save your progress';
  static const String guestBannerSub = 'Your analyses will be saved for future reference.';
  static const String signInNow = 'Sign In Now';

  // Upload
  static const String uploadTitle = 'Upload Resume';
  static const String uploadSubtitle = 'Supported formats: PDF, DOC, DOCX, TXT (max 5 MB)';
  static const String uploadDropArea = 'Tap to select your resume file';
  static const String uploadButton = 'Analyse Resume';
  static const String uploadFileSelected = 'File selected';
  static const String uploadFileSizeError = 'File exceeds 5 MB limit. Please choose a smaller file.';
  static const String uploadFormatError = 'Unsupported format. Use PDF, DOC, DOCX, or TXT.';
  static const String uploading = 'Uploading...';
  static const String parsing = 'Parsing resume...';
  static const String analysing = 'Analysing with AI...';

  // Analysis Result
  static const String analysisResultTitle = 'Analysis Result';
  static const String overallScore = 'Overall Score';
  static const String atsScore = 'ATS Score';
  static const String suggestions = 'Suggestions';
  static const String addSuggestions = 'Add';
  static const String removeSuggestions = 'Remove';
  static const String improveSuggestions = 'Improve';
  static const String missingSections = 'Missing Sections';
  static const String weakLanguage = 'Weak Language';
  static const String missingKeywords = 'Missing Keywords';
  static const String viewCareerCompass = 'Explore Career Compass';
  static const String viewSkillGap = 'Check Skill Gap';

  // Career Compass
  static const String careerCompassTitle = 'Career Compass';
  static const String careerCompassIntro =
      'Answer a few questions so we can find your best-fit career domains.';
  static const String careerCompassAnalysing = 'Finding your best career matches...';
  static const String careerCompassResultTitle = 'Your Career Matches';
  static const String matchPercent = 'match';
  static const String requiredSkills = 'Required Skills';
  static const String certifications = 'Certifications';
  static const String viewSkillGapButton = 'Analyse Skill Gap';

  // Career Domain Detail
  static const String domainDetailTitle = 'Domain Details';
  static const String acceptanceProbability = 'Acceptance Probability';
  static const String whyThisDomain = 'Why This Domain?';

  // Skill Gap
  static const String skillGapTitle = 'Skill Gap Analyser';
  static const String skillPresent = 'Present';
  static const String skillPartial = 'Partial';
  static const String skillMissing = 'Missing';
  static const String improvementRoadmap = 'Improvement Roadmap';
  static const String recommendedCerts = 'Recommended Certifications';

  // History
  static const String historyTitle = 'Analysis History';
  static const String historyEmpty = 'No saved analyses yet.';
  static const String scoreTrend = 'Score Trend';
  static const String guestNoHistory = 'Sign in to view your analysis history.';

  // Profile
  static const String profileTitle = 'Profile';
  static const String signOut = 'Sign Out';
  static const String signOutConfirm = 'Are you sure you want to sign out?';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String memberSince = 'Member since';
  static const String totalAnalyses = 'Total Analyses';
  static const String privacyPolicy = 'Privacy Policy';
  static const String aboutApp = 'About CV2Career';

  // Bottom Nav
  static const String navHome = 'Home';
  static const String navCompass = 'Compass';
  static const String navHistory = 'History';
  static const String navProfile = 'Profile';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection. Please check your network.';
  static const String errorTimeout = 'Request timed out. Retrying...';
  static const String errorAiUnavailable = 'AI service is temporarily unavailable.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorPasswordTooShort = 'Password must be at least 8 characters.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorFieldRequired = 'This field is required.';
  static const String retry = 'Retry';

  // General
  static const String loading = 'Loading...';
  static const String save = 'Save';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String delete = 'Delete';
  static const String deleteConfirm = 'This action cannot be undone.';
}
