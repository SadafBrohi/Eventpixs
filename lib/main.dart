import 'package:eventpix/providers/user_provider.dart';
import 'package:eventpix/screens/about/about_screen.dart';
import 'package:eventpix/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final userProvider = UserProvider();
  await userProvider.loadUser();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const EventPixApp(),
    ),
  );
}


class EventPixApp extends StatelessWidget {
  const EventPixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventPix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 42, 110, 228),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 42, 110, 228),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF0D1B2A), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF5C6B73), fontSize: 14),
          titleLarge: TextStyle(
            color: Color(0xFF0D1B2A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 42, 110, 228),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        AboutScreen.routeName: (_) => AboutScreen(),
        ProfileScreen.routeName: (_) => ProfileScreen(),
      },
    );
  }
}
