import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/restaurant_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'theme/nomnom_theme.dart';
import 'models/restaurant.dart';
import 'providers/auth_state_provider.dart';
import 'nav/route_tracker.dart';
import 'widgets/nomnom_appbar.dart';
import 'widgets/nomnom_scaffold.dart';
import 'nav/route_constants.dart';
import 'services/allergen_service.dart';
import 'controllers/edit_profile_controller.dart';
import 'controllers/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final allergenService = AllergenService();
  await allergenService.getAllergens(); // fills cache (list & maps)

  final authStateProvider = AuthStateProvider();
  await authStateProvider.loadCurrentUser(); // Load profile before UI starts

  runApp(
    MultiProvider(
      providers: [
        Provider<AllergenService>.value(value: allergenService),
        ChangeNotifierProvider<AuthStateProvider>.value(
          value: authStateProvider,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget of the NomNom Safe application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NomNom Safe',
      debugShowCheckedModeBanner: false,
      theme: nomnomTheme,
      navigatorObservers: [routeObserver],
      home: NomNomScaffold(appBar: NomnomAppBar(), body: const HomeScreen()),
      onGenerateRoute: (settings) {
        currentRouteName =
            settings.name; // Track current route globally before screen builds

        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 0,
                appBar: NomnomAppBar(),
                body: const HomeScreen(),
              ),
              settings: settings,
            );
          case AppRoutes.menu:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 1,
                appBar: NomnomAppBar(),
                body: MenuScreen(restaurant: settings.arguments as Restaurant),
              ),
              settings: settings,
            );
          case AppRoutes.restaurant:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 2,
                appBar: NomnomAppBar(),
                body: RestaurantScreen(
                  restaurant: settings.arguments as Restaurant,
                ),
              ),
              settings: settings,
            );
          case AppRoutes.signIn:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 3,
                appBar: NomnomAppBar(),
                body: SignInScreen(),
              ),
              settings: settings,
            );
          case AppRoutes.signUp:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 4,
                appBar: NomnomAppBar(),
                body: SignUpScreen(),
              ),
              settings: settings,
            );
          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 5,
                appBar: NomnomAppBar(),
                body: ChangeNotifierProvider(
                  create: (_) => ProfileController(
                    authProvider: context.read<AuthStateProvider>(),
                    allergenService: context.read<AllergenService>(),
                  ),
                  child: ProfileScreen(),
                ),
              ),
              settings: settings,
            );
          case AppRoutes.editProfile:
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 6,
                appBar: NomnomAppBar(),
                body: ChangeNotifierProvider(
                  create: (context) => EditProfileController(
                    authProvider: context.read<AuthStateProvider>(),
                  ),
                  child: const EditProfileScreen(),
                ),
              ),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}
