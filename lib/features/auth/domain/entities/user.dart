import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String bio;
  final String targetSalary;
  final String workPreference;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> education;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.bio = "",
    this.targetSalary = "",
    this.workPreference = "",
    this.experience = const [],
    this.education = const [],
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    bio,
    targetSalary,
    workPreference,
    experience,
    education,
  ];
}
