// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_parking/config/theme/app_theme.dart';
import 'package:firebase_parking/config/theme/theme_provider.dart';
import 'package:firebase_parking/data/datasources/auth_remote_datasource.dart';
import 'package:firebase_parking/data/datasources/vehicle_remote_datasource.dart';
import 'package:firebase_parking/data/repository/auth_repository_impl.dart';
import 'package:firebase_parking/data/repository/vehicle_repository_impl.dart';
import 'package:firebase_parking/domain/repositories/auth_repository.dart';
import 'package:firebase_parking/domain/repositories/vehicle_repository.dart';
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
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
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
import 'package:provider/provider.dart';

// Global navigator key for navigation outside of context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
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
        // Add VehicleBloc provider
        BlocProvider<VehicleBloc>(create: (context) => sl<VehicleBloc>()),
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

  // Register repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<VehicleRepository>(() => VehicleRepositoryImpl(remoteDataSource: sl()));

  // Register data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  sl.registerLazySingleton<VehicleRemoteDataSource>(() => VehicleRemoteDataSourceImpl(firestore: sl()));

  // Register vehicle use cases
  sl.registerLazySingleton(() => AddVehicle(sl()));
  sl.registerLazySingleton(() => GetUserVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleById(sl()));
  sl.registerLazySingleton(() => UpdateVehicle(sl()));
  sl.registerLazySingleton(() => DeleteVehicle(sl()));
  sl.registerLazySingleton(() => CheckRegistrationExists(sl()));
  sl.registerLazySingleton(() => SearchVehiclesByRegistration(sl()));

  // Register BLoCs
  sl.registerFactory<auth_bloc.AuthBloc>(() => auth_bloc.AuthBloc(repository: sl()));
  sl.registerFactory<VehicleBloc>(
    () => VehicleBloc(
      addVehicleUseCase: sl(),
      getUserVehiclesUseCase: sl(),
      getVehicleByIdUseCase: sl(),
      updateVehicleUseCase: sl(),
      deleteVehicleUseCase: sl(),
      checkRegistrationExistsUseCase: sl(),
      searchVehiclesByRegistrationUseCase: sl(),
      repository: sl(), // Added repository
    ),
  );
}
