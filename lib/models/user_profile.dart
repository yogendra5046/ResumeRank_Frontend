class UserProfile {
  final String name;
  final String role;
  final String bio;
  final String targetSalary;
  final String workPreference;
  final List<ExperienceItem> experience;
  final List<EducationItem> education;

  UserProfile({
    required this.name,
    required this.role,
    required this.bio,
    required this.targetSalary,
    required this.workPreference,
    required this.experience,
    required this.education,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role,
    'bio': bio,
    'targetSalary': targetSalary,
    'workPreference': workPreference,
    'experience': experience.map((e) => e.toJson()).toList(),
    'education': education.map((e) => e.toJson()).toList(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'Yogendra S.',
    role: json['role'] ?? 'Senior Software Engineer',
    bio: json['bio'] ?? 'Passionate developer building AI-driven career tools.',
    targetSalary: json['targetSalary'] ?? '\$120k - \$150k',
    workPreference: json['workPreference'] ?? 'Remote / Hybrid',
    experience: (json['experience'] as List? ?? [])
        .map((e) => ExperienceItem.fromJson(e))
        .toList(),
    education: (json['education'] as List? ?? [])
        .map((e) => EducationItem.fromJson(e))
        .toList(),
  );

  static UserProfile defaultProfile() => UserProfile(
    name: 'Yogendra S.',
    role: 'Senior Software Engineer',
    bio: 'Passionate developer building AI-driven career tools.',
    targetSalary: '\$120k - \$150k',
    workPreference: 'Remote / Hybrid',
    experience: [
      ExperienceItem(
        company: 'Tech Solutions',
        role: 'Senior Developer',
        period: '2021 - Present',
        description: 'Led frontend team for SaaS product.',
      ),
    ],
    education: [
      EducationItem(
        institution: 'University of Technology',
        degree: 'B.S. Computer Science',
        year: '2019',
      ),
    ],
  );
}

class ExperienceItem {
  final String company;
  final String role;
  final String period;
  final String description;

  ExperienceItem({
    required this.company,
    required this.role,
    required this.period,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'company': company,
    'role': role,
    'period': period,
    'description': description,
  };
  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
    company: json['company'] ?? '',
    role: json['role'] ?? '',
    period: json['period'] ?? '',
    description: json['description'] ?? '',
  );
}

class EducationItem {
  final String institution;
  final String degree;
  final String year;

  EducationItem({
    required this.institution,
    required this.degree,
    required this.year,
  });

  Map<String, dynamic> toJson() => {
    'institution': institution,
    'degree': degree,
    'year': year,
  };
  factory EducationItem.fromJson(Map<String, dynamic> json) => EducationItem(
    institution: json['institution'] ?? '',
    degree: json['degree'] ?? '',
    year: json['year'] ?? '',
  );
}
