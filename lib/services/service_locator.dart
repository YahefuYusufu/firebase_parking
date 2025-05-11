// lib/services/service_locator.dart
import 'package:firebase_parking/data/repository/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_parking/data/datasources/auth_remote_datasource.dart';

import 'package:firebase_parking/domain/repositories/auth_repository.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';

/// Service locator for dependency injection using GetIt.
class ServiceLocator {
  // Private constructor to prevent instantiation
  ServiceLocator._();

  /// Singleton instance
  static final instance = GetIt.instance;
}

/// Global shorthand for the service locator
final sl = ServiceLocator.instance;

/// Initialize all dependencies
void setupServiceLocator() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(repository: sl()));

  // Add more dependencies as needed...
}
