import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.bio,
    super.targetSalary,
    super.workPreference,
    super.experience,
    super.education,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'] ?? '',
      targetSalary: json['target_salary'] ?? '',
      workPreference: json['work_preference'] ?? '',
      experience: (json['experience'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
      education: (json['education'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'bio': bio,
      'target_salary': targetSalary,
      'work_preference': workPreference,
      'experience': experience,
      'education': education,
    };
  }
}
