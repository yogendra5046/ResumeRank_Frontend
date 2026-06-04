import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String email, String password);
  Future<void> register(String email, String password, String name);
  Future<UserModel> getUserProfile();
  Future<void> updateUserProfile({
    String? fullName,
    String? bio,
    String? targetSalary,
    String? workPreference,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['detail'] ?? e.message);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> register(String email, String password, String name) async {
    try {
      final response = await dio.post(
        "/auth/register",
        data: {"email": email, "password": password, "full_name": name},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException();
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['detail'] ?? e.message);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await dio.get("/auth/me");
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['detail'] ?? e.message);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateUserProfile({
    String? fullName,
    String? bio,
    String? targetSalary,
    String? workPreference,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
  }) async {
    try {
      final response = await dio.put(
        "/auth/profile",
        data: {
          if (fullName != null) "full_name": fullName,
          if (bio != null) "bio": bio,
          if (targetSalary != null) "target_salary": targetSalary,
          if (workPreference != null) "work_preference": workPreference,
          if (experience != null) "experience": experience,
          if (education != null) "education": education,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException();
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['detail'] ?? e.message);
    } catch (e) {
      throw ServerException();
    }
  }
}
