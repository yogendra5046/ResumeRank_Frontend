import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, String?>> getToken();
  Future<Either<Failure, User>> getUserProfile();
  Future<Either<Failure, void>> updateUserProfile({
    String? fullName,
    String? bio,
    String? targetSalary,
    String? workPreference,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
  });
}
