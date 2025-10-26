import 'package:eventpix/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((user) async {
      if (!mounted) return; 

      if (user == null) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else {
        await Provider.of<UserProvider>(context, listen: false).loadUser();

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'EventPix',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
