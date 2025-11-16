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
import 'navigation/route_tracker.dart';
import 'widgets/nomnom_appbar.dart';
import 'widgets/nomnom_scaffold.dart';

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
      home: NomNomScaffold(appBar: NomnomAppBar(), body: const HomeScreen()),
      onGenerateRoute: (settings) {
        currentRouteName =
            settings.name; // Track current route globally before screen builds

        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 0,
                appBar: NomnomAppBar(),
                body: const HomeScreen(),
              ),
              settings: settings,
            );
          case '/menu':
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 1,
                appBar: NomnomAppBar(),
                body: MenuScreen(restaurant: settings.arguments as Restaurant),
              ),
              settings: settings,
            );
          case '/restaurant':
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
          case '/sign-in':
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 3,
                appBar: NomnomAppBar(),
                body: SignInScreen(),
              ),
              settings: settings,
            );
          case '/sign-up':
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 4,
                appBar: NomnomAppBar(),
                body: SignUpScreen(),
              ),
              settings: settings,
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 5,
                appBar: NomnomAppBar(),
                body: ProfileScreen(),
              ),
              settings: settings,
            );
          case '/edit-profile':
            return MaterialPageRoute(
              builder: (context) => NomNomScaffold(
                currentIndex: 6,
                appBar: NomnomAppBar(),
                body: EditProfileScreen(),
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
