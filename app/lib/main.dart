import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:provider/provider.dart';
import 'navigation/route_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authStateProvider = AuthStateProvider();
  await authStateProvider.loadCurrentUser(); // Load profile before UI starts

  runApp(
    ChangeNotifierProvider<AuthStateProvider>.value(
      value: authStateProvider,
      child: const MyApp(),
    ),
  );
}

/* Root widget of the NomNom Safe application */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NomNom Safe',
      debugShowCheckedModeBanner: false,
      theme: nomnomTheme,
      navigatorObservers: [routeObserver],
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        currentRouteName =
            settings.name; // Track current route globally before screen builds

        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
              settings: settings,
            );
          case '/menu':
            return MaterialPageRoute(
              builder: (context) =>
                  MenuScreen(restaurant: settings.arguments as Restaurant),
              settings: settings,
            );
          case '/restaurant':
            return MaterialPageRoute(
              builder: (context) => RestaurantScreen(
                restaurant: settings.arguments as Restaurant,
              ),
              settings: settings,
            );
          case '/sign-in':
            return MaterialPageRoute(
              builder: (context) => const SignInScreen(),
              settings: settings,
            );
          case '/sign-up':
            return MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
              settings: settings,
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
              settings: settings,
            );
          case '/edit-profile':
            return MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}
