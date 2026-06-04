import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_login_status_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../../services/job_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckLoginStatusUseCase checkLoginStatusUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkLoginStatusUseCase,
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await checkLoginStatusUseCase(NoParams());
    result.fold((failure) => emit(Unauthenticated()), (isLoggedIn) async {
      if (isLoggedIn) {
        final profileResult = await getUserProfileUseCase(NoParams());
        profileResult.fold(
          (failure) => emit(Unauthenticated()),
          (user) {
            JobService.syncFromCloud();
            emit(Authenticated(user));
          },
        );
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? targetSalary,
    String? workPreference,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
  }) async {
    final currentState = state;
    if (currentState is Authenticated) {
      final result = await updateUserProfileUseCase(
        UpdateProfileParams(
          fullName: fullName,
          bio: bio,
          targetSalary: targetSalary,
          workPreference: workPreference,
          experience: experience,
          education: education,
        ),
      );

      result.fold((failure) => emit(AuthError(failure.message)), (_) async {
        // Refresh profile after update
        final profileResult = await getUserProfileUseCase(NoParams());
        profileResult.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(Authenticated(user)),
        );
      });
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        JobService.syncFromCloud();
        emit(Authenticated(user));
      },
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      RegisterParams(name: fullName, email: email, password: password),
    );
    result.fold((failure) => emit(AuthError(failure.message)), (_) {
      // After registration, we might want to login automatically
      login(email, password);
    });
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
}
