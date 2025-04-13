import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:market_manager/screens/add_product_screen.dart';
import 'package:market_manager/screens/barcode_scanner_screen.dart';
import 'package:market_manager/screens/chat_screen.dart';
import 'package:market_manager/screens/home_screen.dart';
import 'package:market_manager/screens/login_screen.dart';
import 'package:market_manager/screens/menu_screen.dart';
import 'package:market_manager/theme.dart' as themes;

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.openBox('session');

  await Firebase.initializeApp();
  runApp(MarketManager());
}

class MarketManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Manager',
      theme: themes.lightTheme,
      darkTheme: themes.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id : (context) => HomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        MenuScreen.id : (context) => MenuScreen(),
        ChatScreen.id : (context) => ChatScreen(),
        AddProductScreen.id : (context) => AddProductScreen(),
        BarcodeScannerScreen.id : (context) => BarcodeScannerScreen()
      },
    );
  }
}


