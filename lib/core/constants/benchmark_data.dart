// Industry benchmark skill data for v1.0.
// TBD-3: Replace with API/DB source post-v1.0.
// Structure: domainKey -> list of required skills with weight (impact score 1-10).
class BenchmarkData {
  BenchmarkData._();

  static const Map<String, List<Map<String, dynamic>>> domainSkills = {
    'software_engineering': [
      {'skill': 'Data Structures & Algorithms', 'weight': 10, 'cert': 'LeetCode / HackerRank'},
      {'skill': 'Version Control (Git)', 'weight': 9, 'cert': 'GitHub Foundations'},
      {'skill': 'Object-Oriented Programming', 'weight': 9, 'cert': null},
      {'skill': 'REST API Design', 'weight': 8, 'cert': null},
      {'skill': 'Unit Testing', 'weight': 8, 'cert': null},
      {'skill': 'SQL / Databases', 'weight': 7, 'cert': 'Oracle SQL Certification'},
      {'skill': 'CI/CD Pipelines', 'weight': 7, 'cert': 'GitHub Actions'},
      {'skill': 'Docker / Containers', 'weight': 7, 'cert': 'Docker Certified Associate'},
      {'skill': 'Agile / Scrum', 'weight': 6, 'cert': 'PSM I'},
      {'skill': 'System Design', 'weight': 9, 'cert': null},
    ],
    'data_science': [
      {'skill': 'Python', 'weight': 10, 'cert': null},
      {'skill': 'Machine Learning', 'weight': 10, 'cert': 'Google ML Crash Course'},
      {'skill': 'Statistics & Probability', 'weight': 9, 'cert': null},
      {'skill': 'Data Wrangling (pandas/numpy)', 'weight': 9, 'cert': null},
      {'skill': 'Data Visualisation', 'weight': 8, 'cert': 'Tableau Desktop Specialist'},
      {'skill': 'SQL', 'weight': 8, 'cert': null},
      {'skill': 'Deep Learning (TensorFlow/PyTorch)', 'weight': 7, 'cert': 'TensorFlow Developer Cert'},
      {'skill': 'Feature Engineering', 'weight': 7, 'cert': null},
      {'skill': 'Model Deployment', 'weight': 6, 'cert': 'AWS ML Specialty'},
      {'skill': 'NLP', 'weight': 6, 'cert': null},
    ],
    'ui_ux_design': [
      {'skill': 'Figma / Sketch', 'weight': 10, 'cert': 'Figma Professional'},
      {'skill': 'User Research', 'weight': 9, 'cert': null},
      {'skill': 'Wireframing & Prototyping', 'weight': 9, 'cert': null},
      {'skill': 'Visual Design Principles', 'weight': 8, 'cert': null},
      {'skill': 'Usability Testing', 'weight': 8, 'cert': null},
      {'skill': 'Information Architecture', 'weight': 7, 'cert': null},
      {'skill': 'Accessibility (WCAG)', 'weight': 7, 'cert': null},
      {'skill': 'Design Systems', 'weight': 7, 'cert': null},
      {'skill': 'HTML/CSS basics', 'weight': 5, 'cert': null},
      {'skill': 'Motion Design', 'weight': 4, 'cert': null},
    ],
    'cybersecurity': [
      {'skill': 'Network Security', 'weight': 10, 'cert': 'CompTIA Network+'},
      {'skill': 'Ethical Hacking / Pen Testing', 'weight': 9, 'cert': 'CEH / OSCP'},
      {'skill': 'SIEM Tools', 'weight': 8, 'cert': null},
      {'skill': 'Incident Response', 'weight': 8, 'cert': null},
      {'skill': 'Cryptography', 'weight': 8, 'cert': null},
      {'skill': 'Vulnerability Assessment', 'weight': 8, 'cert': 'CompTIA Security+'},
      {'skill': 'Cloud Security', 'weight': 7, 'cert': 'AWS Security Specialty'},
      {'skill': 'Compliance (ISO 27001, GDPR)', 'weight': 7, 'cert': null},
      {'skill': 'Scripting (Python/Bash)', 'weight': 6, 'cert': null},
      {'skill': 'Digital Forensics', 'weight': 5, 'cert': null},
    ],
    'cloud_devops': [
      {'skill': 'AWS / Azure / GCP', 'weight': 10, 'cert': 'AWS Solutions Architect'},
      {'skill': 'Docker & Kubernetes', 'weight': 10, 'cert': 'CKA'},
      {'skill': 'Infrastructure as Code (Terraform)', 'weight': 9, 'cert': 'HashiCorp Terraform'},
      {'skill': 'CI/CD (Jenkins/GitHub Actions)', 'weight': 9, 'cert': null},
      {'skill': 'Linux Administration', 'weight': 8, 'cert': 'RHCSA'},
      {'skill': 'Monitoring (Grafana/Prometheus)', 'weight': 7, 'cert': null},
      {'skill': 'Networking (VPC, DNS, Load Balancing)', 'weight': 7, 'cert': null},
      {'skill': 'Scripting (Bash/Python)', 'weight': 7, 'cert': null},
      {'skill': 'Git & Version Control', 'weight': 6, 'cert': null},
      {'skill': 'Site Reliability Engineering', 'weight': 6, 'cert': null},
    ],
    'mobile_development': [
      {'skill': 'Flutter / React Native', 'weight': 10, 'cert': null},
      {'skill': 'Dart / JavaScript', 'weight': 9, 'cert': null},
      {'skill': 'State Management', 'weight': 9, 'cert': null},
      {'skill': 'REST API Integration', 'weight': 8, 'cert': null},
      {'skill': 'UI/UX Principles', 'weight': 8, 'cert': null},
      {'skill': 'App Store Deployment', 'weight': 7, 'cert': null},
      {'skill': 'Testing (unit/widget/integration)', 'weight': 7, 'cert': null},
      {'skill': 'Performance Optimisation', 'weight': 6, 'cert': null},
      {'skill': 'Push Notifications', 'weight': 5, 'cert': null},
      {'skill': 'Firebase / Supabase', 'weight': 5, 'cert': null},
    ],
    'product_management': [
      {'skill': 'Product Roadmapping', 'weight': 10, 'cert': 'AIPMM CPM'},
      {'skill': 'User Story Writing', 'weight': 9, 'cert': null},
      {'skill': 'Agile / Scrum', 'weight': 9, 'cert': 'PSM I / CSPO'},
      {'skill': 'Market Research', 'weight': 8, 'cert': null},
      {'skill': 'Data Analysis', 'weight': 8, 'cert': null},
      {'skill': 'Stakeholder Management', 'weight': 8, 'cert': null},
      {'skill': 'A/B Testing', 'weight': 7, 'cert': null},
      {'skill': 'Wireframing', 'weight': 6, 'cert': null},
      {'skill': 'OKR / KPI Setting', 'weight': 7, 'cert': null},
      {'skill': 'Competitive Analysis', 'weight': 6, 'cert': null},
    ],
    'digital_marketing': [
      {'skill': 'SEO / SEM', 'weight': 10, 'cert': 'Google Analytics'},
      {'skill': 'Social Media Marketing', 'weight': 9, 'cert': 'Meta Blueprint'},
      {'skill': 'Content Marketing', 'weight': 9, 'cert': 'HubSpot Content Marketing'},
      {'skill': 'Email Marketing', 'weight': 8, 'cert': null},
      {'skill': 'Google Ads / PPC', 'weight': 8, 'cert': 'Google Ads Certification'},
      {'skill': 'Data Analytics', 'weight': 8, 'cert': 'Google Analytics 4'},
      {'skill': 'Copywriting', 'weight': 7, 'cert': null},
      {'skill': 'Marketing Automation', 'weight': 7, 'cert': 'HubSpot Marketing'},
      {'skill': 'CRM Tools', 'weight': 6, 'cert': 'Salesforce Admin'},
      {'skill': 'Video Marketing', 'weight': 5, 'cert': null},
    ],
  };

  // Human-readable domain labels
  static const Map<String, String> domainLabels = {
    'software_engineering': 'Software Engineering',
    'data_science': 'Data Science',
    'ui_ux_design': 'UI/UX Design',
    'cybersecurity': 'Cybersecurity',
    'cloud_devops': 'Cloud & DevOps',
    'mobile_development': 'Mobile Development',
    'product_management': 'Product Management',
    'digital_marketing': 'Digital Marketing',
  };

  // Domain icons (Material icon names as strings, used in UI)
  static const Map<String, String> domainIcons = {
    'software_engineering': 'code',
    'data_science': 'analytics',
    'ui_ux_design': 'palette',
    'cybersecurity': 'security',
    'cloud_devops': 'cloud',
    'mobile_development': 'phone_android',
    'product_management': 'inventory',
    'digital_marketing': 'campaign',
  };
}
