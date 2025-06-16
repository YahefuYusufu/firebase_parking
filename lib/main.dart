import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_parking/config/theme/app_theme.dart';
import 'package:firebase_parking/config/theme/theme_provider.dart';
import 'package:firebase_parking/data/datasources/auth_remote_datasource.dart';
import 'package:firebase_parking/data/datasources/issue_data_source.dart';
import 'package:firebase_parking/data/datasources/parking_data_source.dart';
import 'package:firebase_parking/data/datasources/parking_space_remote_datasource.dart';
import 'package:firebase_parking/data/datasources/vehicle_remote_datasource.dart';
import 'package:firebase_parking/data/datasources/notification_local_datasource.dart';
import 'package:firebase_parking/data/repository/auth_repository_impl.dart';
import 'package:firebase_parking/data/repository/issue_repository_impl.dart';
import 'package:firebase_parking/data/repository/notification_repository_impl.dart';
import 'package:firebase_parking/data/repository/parking_repository_impl.dart';
import 'package:firebase_parking/data/repository/parking_space_repository_impl.dart';
import 'package:firebase_parking/data/repository/vehicle_repository_impl.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';
import 'package:firebase_parking/domain/repositories/issue_repository.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart';
import 'package:firebase_parking/domain/repositories/parking_space_repository.dart';
import 'package:firebase_parking/domain/repositories/vehicle_repository.dart';
import 'package:firebase_parking/domain/repositories/notification_repository.dart';
import 'package:firebase_parking/domain/usecases/issue/create_issue_usecase.dart';
import 'package:firebase_parking/domain/usecases/issue/get_user_issues_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/create_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/end_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/get_active_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/get_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/get_user_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking_space/create_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/delete_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_all_parking_spaces.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_available_spaces_count.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_space_by_id.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_space_by_number.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_spaces_by_level.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_spaces_by_section.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_spaces_by_status.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_space_by_vehicle_id.dart';
import 'package:firebase_parking/domain/usecases/parking_space/occupy_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/update_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/vacate_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/watch_parking_spaces.dart';
import 'package:firebase_parking/domain/usecases/vehicles/add_vehicle.dart';
import 'package:firebase_parking/domain/usecases/vehicles/check_registration_exists.dart';
import 'package:firebase_parking/domain/usecases/vehicles/delete_vehicle.dart';
import 'package:firebase_parking/domain/usecases/vehicles/get_user_vehicles.dart';
import 'package:firebase_parking/domain/usecases/vehicles/get_vehicle_by_id.dart';
import 'package:firebase_parking/domain/usecases/vehicles/search_vehicles_by_registration.dart';
import 'package:firebase_parking/domain/usecases/vehicles/update_vehicle.dart';
import 'package:firebase_parking/firebase_options.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart' as auth_bloc;
import 'package:firebase_parking/presentation/blocs/auth/auth_event.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/issue/issue_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:firebase_parking/presentation/blocs/notification/notification_bloc.dart';
import 'package:firebase_parking/presentation/blocs/notification/notification_event.dart';
import 'package:firebase_parking/presentation/pages/auth/complete_profile_screen.dart';
import 'package:firebase_parking/presentation/pages/auth/login_screen.dart';
import 'package:firebase_parking/presentation/pages/auth/register_screen.dart';
import 'package:firebase_parking/presentation/pages/parking/parking_screen.dart';
import 'package:firebase_parking/presentation/pages/profile/edit_profile_screen.dart';
import 'package:firebase_parking/presentation/pages/vehicles/vehicles_screen.dart';
import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_form_screen.dart';
import 'package:firebase_parking/presentation/splash/splash_screen.dart';
import 'package:firebase_parking/presentation/widgets/responsive/responsive_layout.dart';
import 'package:firebase_parking/services/data_provider.dart';
import 'package:firebase_parking/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

// Global navigator key for navigation outside of context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EMERGENCY: Clear all notifications immediately to prevent LED crash
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.cancelAll();
    print("🚨 EMERGENCY: Cleared all notifications at startup to prevent LED crash");
  } catch (e) {
    print("⚠️ Could not clear notifications at startup: $e");
  }

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Failed to initialize Firebase: $e");
  }

  // Initialize service locator (dependency injection)
  setupServiceLocator();

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        BlocProvider<auth_bloc.AuthBloc>(create: (context) => sl<auth_bloc.AuthBloc>()..add(AuthCheckRequested())),
        // Add NotificationBloc provider first (others depend on it)
        BlocProvider<NotificationBloc>(create: (context) => sl<NotificationBloc>()..add(const InitializeNotifications())),
        // Add VehicleBloc provider
        BlocProvider<VehicleBloc>(create: (context) => sl<VehicleBloc>()),
        // Add ParkingSpaceBloc provider
        BlocProvider<ParkingSpaceBloc>(create: (context) => sl<ParkingSpaceBloc>()),
        // Update ParkingBloc provider to include NotificationBloc
        BlocProvider<ParkingBloc>(
          create: (context) {
            final notificationBloc = context.read<NotificationBloc>();
            final parkingBloc = sl<ParkingBloc>(param1: notificationBloc);

            // 🔗 CONNECT NOTIFICATION SERVICE TO PARKING BLOC
            final notificationDataSource = sl<NotificationLocalDataSource>() as NotificationLocalDataSourceImpl;
            notificationDataSource.setParkingBloc(parkingBloc);
            print("🔗 Connected notification actions to ParkingBloc");

            return parkingBloc;
          },
        ),
        // Add IssueBloc provider
        BlocProvider<IssueBloc>(create: (context) => sl<IssueBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return BlocListener<auth_bloc.AuthBloc, AuthState>(
          listener: (context, state) {
            // Handle authentication state changes for navigation
            if (state is Unauthenticated) {
              // Use navigatorKey to navigate when context might not have a Navigator
              navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
            }
          },
          child: MaterialApp(
            navigatorKey: navigatorKey, // Set the navigator key
            title: 'ParkOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const ResponsiveLayout(),
              '/complete_profile': (context) => const CompleteProfileScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
              '/vehicles': (context) => const VehiclesScreen(),
              '/vehicles/add': (context) => const VehicleFormScreen(),
              '/parking': (context) => const ParkingScreen(),
            },
            initialRoute: '/splash',
          ),
        );
      },
    );
  }
}

// Service locator setup for dependency injection
void setupServiceLocator() {
  final sl = ServiceLocator.instance;

  // External dependencies
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Register notification data source and repository
  sl.registerLazySingleton<NotificationLocalDataSource>(() => NotificationLocalDataSourceImpl());
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(localDataSource: sl()));

  // Register repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<VehicleRepository>(() => VehicleRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ParkingRepository>(() => ParkingRepositoryImpl(parkingDataSource: sl(), vehicleDataSource: sl(), parkingSpaceDataSource: sl()));
  sl.registerLazySingleton<IssueRepository>(() => IssueRepositoryImpl(dataSource: sl()));

  // Register data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  sl.registerLazySingleton<VehicleRemoteDataSource>(() => VehicleRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton<ParkingDataSource>(() => FirebaseParkingDataSource(firestore: sl()));
  sl.registerLazySingleton<IssueDataSource>(() => FirebaseIssueDataSource(firestore: sl()));

  // Register vehicle use cases
  sl.registerLazySingleton(() => AddVehicle(sl()));
  sl.registerLazySingleton(() => GetUserVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleById(sl()));
  sl.registerLazySingleton(() => UpdateVehicle(sl()));
  sl.registerLazySingleton(() => DeleteVehicle(sl()));
  sl.registerLazySingleton(() => CheckRegistrationExists(sl()));
  sl.registerLazySingleton(() => SearchVehiclesByRegistration(sl()));

  // Register parking use cases
  sl.registerLazySingleton(() => CreateParkingUseCase(sl()));
  sl.registerLazySingleton(() => GetParkingUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveParkingUseCase(sl()));
  sl.registerLazySingleton(() => GetUserParkingUseCase(sl()));
  sl.registerLazySingleton(() => EndParkingUseCase(sl()));

  // Register issue use cases
  sl.registerLazySingleton(() => CreateIssueUseCase(sl()));
  sl.registerLazySingleton(() => GetUserIssuesUseCase(sl()));

  // Register parking space datasource
  sl.registerLazySingleton<ParkingSpaceRemoteDataSource>(() => ParkingSpaceRemoteDataSourceImpl(firestore: sl()));

  // Register parking space repository
  sl.registerLazySingleton<ParkingSpaceRepository>(() => ParkingSpaceRepositoryImpl(remoteDataSource: sl()));

  // Register parking space use cases
  sl.registerLazySingleton(() => GetAllParkingSpaces(sl()));
  sl.registerLazySingleton(() => GetParkingSpacesByStatus(sl()));
  sl.registerLazySingleton(() => GetParkingSpacesBySection(sl()));
  sl.registerLazySingleton(() => GetParkingSpacesByLevel(sl()));
  sl.registerLazySingleton(() => GetParkingSpaceById(sl()));
  sl.registerLazySingleton(() => GetParkingSpaceByNumber(sl()));
  sl.registerLazySingleton(() => CreateParkingSpace(sl()));
  sl.registerLazySingleton(() => UpdateParkingSpace(sl()));
  sl.registerLazySingleton(() => DeleteParkingSpace(sl()));
  sl.registerLazySingleton(() => OccupyParkingSpace(sl()));
  sl.registerLazySingleton(() => VacateParkingSpace(sl()));
  sl.registerLazySingleton(() => GetAvailableSpacesCount(sl()));
  sl.registerLazySingleton(() => GetSpaceByVehicleId(sl()));
  sl.registerLazySingleton(() => WatchParkingSpaces(sl()));

  // Register BLoCs
  sl.registerFactory<auth_bloc.AuthBloc>(() => auth_bloc.AuthBloc(repository: sl()));

  // Register NotificationBloc
  sl.registerFactory<NotificationBloc>(() => NotificationBloc(notificationRepository: sl()));

  sl.registerFactory<VehicleBloc>(
    () => VehicleBloc(
      addVehicleUseCase: sl(),
      getUserVehiclesUseCase: sl(),
      getVehicleByIdUseCase: sl(),
      updateVehicleUseCase: sl(),
      deleteVehicleUseCase: sl(),
      checkRegistrationExistsUseCase: sl(),
      searchVehiclesByRegistrationUseCase: sl(),
      repository: sl(),
    ),
  );

  // Register ParkingSpaceBloc
  sl.registerFactory<ParkingSpaceBloc>(
    () => ParkingSpaceBloc(
      getAllParkingSpaces: sl(),
      getParkingSpacesByStatus: sl(),
      getParkingSpacesBySection: sl(),
      getParkingSpacesByLevel: sl(),
      getParkingSpaceById: sl(),
      getParkingSpaceByNumber: sl(),
      createParkingSpace: sl(),
      updateParkingSpace: sl(),
      deleteParkingSpace: sl(),
      occupyParkingSpace: sl(),
      vacateParkingSpace: sl(),
      getAvailableSpacesCount: sl(),
      getSpaceByVehicleId: sl(),
      watchParkingSpaces: sl(),
    ),
  );

  // Register ParkingBloc with NotificationBloc dependency
  sl.registerFactoryParam<ParkingBloc, NotificationBloc, void>(
    (notificationBloc, _) => ParkingBloc(
      createParking: sl(),
      getParking: sl(),
      getActiveParking: sl(),
      getUserParking: sl(),
      endParking: sl(),
      notificationBloc: notificationBloc,
      parkingRepository: sl(),
    ),
  );

  // Register IssueBloc
  sl.registerFactory<IssueBloc>(() => IssueBloc(createIssue: sl(), getUserIssues: sl()));
}
