import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/restaurant_screen.dart';
import 'theme/nomnom_theme.dart';
import 'models/restaurant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/menu':
            return MaterialPageRoute(
              builder: (context) =>
                  MenuScreen(restaurant: settings.arguments as Restaurant),
            );
          case '/restaurant':
            return MaterialPageRoute(
              builder: (context) => RestaurantScreen(
                restaurant: settings.arguments as Restaurant,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}
