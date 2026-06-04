import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase
    implements UseCase<Either<Failure, void>, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateUserProfile(
      fullName: params.fullName,
      bio: params.bio,
      targetSalary: params.targetSalary,
      workPreference: params.workPreference,
      experience: params.experience,
      education: params.education,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? fullName;
  final String? bio;
  final String? targetSalary;
  final String? workPreference;
  final List<Map<String, dynamic>>? experience;
  final List<Map<String, dynamic>>? education;

  const UpdateProfileParams({
    this.fullName,
    this.bio,
    this.targetSalary,
    this.workPreference,
    this.experience,
    this.education,
  });

  @override
  List<Object?> get props => [
    fullName,
    bio,
    targetSalary,
    workPreference,
    experience,
    education,
  ];
}
