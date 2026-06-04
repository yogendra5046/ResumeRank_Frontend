import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      await localDataSource.cacheToken(response.token);
      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      await remoteDataSource.register(email, password, name);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final user = await remoteDataSource.getUserProfile();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    String? fullName,
    String? bio,
    String? targetSalary,
    String? workPreference,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
  }) async {
    try {
      await remoteDataSource.updateUserProfile(
        fullName: fullName,
        bio: bio,
        targetSalary: targetSalary,
        workPreference: workPreference,
        experience: experience,
        education: education,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
