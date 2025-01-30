import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:market_manager/screens/home_screen.dart';
import 'package:market_manager/screens/login_screen.dart';
import 'package:market_manager/screens/menu_screen.dart';
import 'package:market_manager/theme.dart' as themes;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MarketManager());
}

class MarketManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Manager',
      theme: themes.lightTheme,
      darkTheme: themes.lightTheme,
      themeMode: ThemeMode.system,

      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id : (context) => HomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        MenuScreen.id : (context) => MenuScreen(),
      },
    );
  }
}


