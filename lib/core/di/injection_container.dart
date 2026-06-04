import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/analysis/data/datasources/analysis_remote_data_source.dart';
import '../../features/analysis/data/repositories/analysis_repository_impl.dart';
import '../../features/analysis/domain/repositories/analysis_repository.dart';
import '../../features/analysis/domain/usecases/analyze_resume_usecase.dart';
import '../../features/analysis/presentation/bloc/analysis_cubit.dart';
import '../../features/history/data/datasources/history_local_data_source.dart';
import '../../features/history/data/datasources/history_remote_data_source.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/history_usecases.dart';
import '../../features/history/presentation/bloc/history_cubit.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/check_login_status_usecase.dart';
import '../../features/auth/domain/usecases/get_user_profile_usecase.dart';
import '../../features/auth/domain/usecases/update_user_profile_usecase.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  //? Auth
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      checkLoginStatusUseCase: sl(),
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
    ),
  );

  //? History
  // Cubit
  sl.registerFactory(
    () => HistoryCubit(getHistoryUseCase: sl(), saveHistoryUseCase: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SaveHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(dio: sl()),
  );

  //? Analysis
  // Cubit
  sl.registerFactory(() => AnalysisCubit(analyzeResumeUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => AnalyzeResumeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AnalysisRemoteDataSource>(
    () => AnalysisRemoteDataSourceImpl(dio: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckLoginStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  //! Core
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    DioClient(dio, sl<AuthLocalDataSource>());
    return dio;
  });

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
