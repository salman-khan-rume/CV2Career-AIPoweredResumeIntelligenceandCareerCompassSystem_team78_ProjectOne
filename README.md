# 🧭 CV2Career — AI-Powered Resume Intelligence & Career Compass

[![Flutter](https://img.shields.io/badge/Flutter-3.3.0%20%2B-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white&style=for-the-badge)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white&style=for-the-badge)](https://supabase.com)
[![Groq AI](https://img.shields.io/badge/Groq%20AI-LLaMA%203.3-orange?logo=meta&logoColor=white&style=for-the-badge)](https://groq.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blueviolet?style=for-the-badge)](#)

**CV2Career** is a modern, premium Flutter-based mobile and web application designed to bridge the gap between job seekers' resumes and their career goals. Leveraging state-of-the-art AI analysis (via the LLaMA 3.3 model on Groq) and a robust Supabase backend, the app parses resume files (PDF, DOCX, TXT), evaluates resume formatting & keyword targeting (ATS Score), and maps a personalized path forward through career matchmaking, skill-gap analysis, and actionable learning roadmaps.

> [!IMPORTANT]
> **Looking for the step-by-step application user manual?**
> We have created a comprehensive, visual guide covering all 4 major features and necessary steps to get the most out of the application.
> Read the [CV2Career User Guide](file:///c:/Users/Salman%20Khan%20Rume/cv2career/USER_GUIDE.md).

---

## 🌟 Key Features

### 1. 🔍 Resume Intelligence (ATS & Quality Check)
* **File Processing:** Upload and parse resumes in `.pdf`, `.docx`, and `.txt` formats locally using custom byte-level parsing and Syncfusion libraries.
* **Double Scoring Gauge:** Visualization of **Overall Resume Quality** (clarity, completeness) and **ATS Optimization Score** (keyword density, layout compatibility) using interactive charts.
* **Vulnerability Spotting:** Detects missing standard sections (e.g., LinkedIn URL, Summary), flags weak/vague phrasing (e.g., "responsible for", "worked on"), and highlights missing high-value industry keywords.
* **Structured Suggestions:** Provides categorized recommendations: **Add**, **Remove**, and **Improve**.

### 2. 🧭 Career Compass (Path Matchmaking)
* **Interactive Questionnaire:** An intuitive profile quiz assessing professional goals, work style, industry interests, and technical strengths.
* **AI Matchmaking:** Merges resume background with quiz answers to recommend the top matching career domains (e.g., Frontend Engineer, Cloud Architect, Product Manager).
* **Match Score Card:** Renders match percentages, structured reasoning based on user input, required target skills, and real industry-standard certifications.

### 3. 🎯 Skill Gap Analyser
* **Multi-Route Analysis:** Measure readiness against recommended career domains or paste a specific **Job Description (JD)** for a target role.
* **Visual Categorization:** Segregates skill requirements into:
  * **Present:** Successfully demonstrated in the resume.
  * **Partial:** Mentioned but needs strengthening.
  * **Missing:** Completely absent but required.
* **Prioritized Up-skilling Roadmap:** Recommends specific, real-world educational resources (e.g., Coursera, Udemy, freeCodeCamp) and certifications sorted by priority (High/Medium/Low).

### 4. 🗺️ Interactive Career Roadmaps
* **Milestone Planning:** Generates a 3-5 phase timeline based on target roles and current conditions.
* **Interactive Checklists:** Actionable milestones per phase to track progress.
* **Direct Learning Resources:** Clickable direct URLs to official documentation (e.g., MDN, roadmap.sh) and high-quality online courses.

### 5. 📂 User Profiles & History Tracking
* **Primary CV:** Save a main resume to profiles for quick re-analysis without uploading every time.
* **Historical Trend Charts:** Logged-in users can view past resume evaluations and monitor score improvement trends over time.

---

## 🛠️ Architecture & Tech Stack

The project follows a clean, modern Flutter architecture with structured state management and dynamic styling.

```
lib/
├── core/
│   ├── constants/    # Theme colors, dimensions, static assets, and text strings
│   ├── theme/        # Light and Dark theme specifications (Material 3)
│   └── utils/        # Validation logic and general utilities
├── data/
│   ├── models/       # Data serialization structures (ResumeAnalysis, UserProfile, SkillGap, etc.)
│   └── services/     # API connection logic (Supabase, Groq AI, PDF/DOCX Parser)
└── presentation/
    ├── providers/    # State management (Riverpod & GoRouter router definition)
    ├── screens/      # Screen layouts and UI pages
    └── widgets/      # Reusable UI cards, gauges, buttons, and animations
```

### Stack Components:
* **Frontend:** Flutter, Dart SDK `^3.3.0`
* **State Management:** Riverpod (`flutter_riverpod` + code generation via `riverpod_generator`)
* **Routing:** GoRouter (`go_router`)
* **Backend:** Supabase (`supabase_flutter`) for authentication, PostgreSQL storage, and bucket file uploads
* **AI Provider:** Groq AI client hosting the LLaMA 3.3 Versatile model
* **Animations:** `flutter_animate` (micro-interactions) and `lottie` (loading and success animations)
* **Visualizations:** `fl_chart` and `percent_indicator` for dashboard analytics

---

## 🗄️ Database Schema & Services

The backend runs on **Supabase** with the following tables. Rows are secure, governed by Row Level Security (RLS) policies relative to authenticated users.

### 1. `profiles`
Stores user profile information and primary resume storage paths.
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  primary_cv_url TEXT,
  primary_cv_text TEXT,
  primary_cv_name TEXT,
  primary_cv_updated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. `resume_analyses`
Saves resume intelligence results.
```sql
CREATE TABLE resume_analyses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_url TEXT,
  raw_text TEXT,
  overall_score INT NOT NULL,
  ats_score INT NOT NULL,
  missing_sections TEXT[] DEFAULT '{}',
  weak_language TEXT[] DEFAULT '{}',
  missing_keywords TEXT[] DEFAULT '{}',
  suggestions JSONB DEFAULT '[]',
  ai_provider TEXT DEFAULT 'gemini',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. `career_compass_results`
Saves questionnaires and matchmaking outcomes.
```sql
CREATE TABLE career_compass_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  analysis_id UUID REFERENCES resume_analyses ON DELETE SET NULL,
  questionnaire JSONB NOT NULL DEFAULT '[]',
  recommendations JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4. `skill_gap_results`
Tracks skill requirements, gaps, and personal learning paths.
```sql
CREATE TABLE skill_gap_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  compass_result_id UUID REFERENCES career_compass_results ON DELETE SET NULL,
  career_domain TEXT NOT NULL,
  acceptance_score INT NOT NULL,
  skills_present TEXT[] DEFAULT '{}',
  skills_partial TEXT[] DEFAULT '{}',
  skills_missing TEXT[] DEFAULT '{}',
  roadmap JSONB NOT NULL DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5. Storage Buckets
* `resumes`: A private bucket hosting uploaded resume files (named `${userId}/${uuid}.${extension}`).
* `avatars`: A public bucket hosting user profile profile pictures.

---

## 🚀 Getting Started

To run CV2Career locally, follow these configuration steps:

### Prerequisites
* Flutter SDK (version `>=3.3.0`)
* A Groq API Key (for LLaMA AI services)
* A Supabase Project URL and Anon Key

### 📦 Setup & Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/cv2career.git
   cd cv2career
   ```

2. **Configure environment variables:**
   Create a `.env` file in the root of the project:
   ```env
   GROQ_API_KEY=your_groq_api_key_here
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run Riverpod Code Generator:**
   Generate the provider and router files using build_runner:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🎨 Visual Design Guidelines

* **Harmonious Palettes:** Uses modern Tailored Slate colors (`0xFF020617` background for Dark Mode, `0xFFF8FAFC` for Light Mode) with dynamic Indigo Primary and Teal Accents.
* **Typography:** Clean fonts imported securely via the Google Fonts library (`Inter` / `Outfit`).
* **Visual Polish:** Shimmer loaders, Lottie vector animations, and smooth fade-in animations across all list views using the `flutter_animate` package.

---

## 📄 License
This project is proprietary and confidential. All rights reserved.
