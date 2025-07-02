import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:market_manager/screens/add_product_screen.dart';
import 'package:market_manager/screens/barcode_scanner_screen.dart';
import 'package:market_manager/screens/chat_screen.dart';
import 'package:market_manager/screens/enter_barcode_manually_screen.dart';
import 'package:market_manager/screens/home_screen.dart';
import 'package:market_manager/screens/login_screen.dart';
import 'package:market_manager/screens/make_sale_screen.dart';
import 'package:market_manager/screens/menu_screen.dart';
import 'package:market_manager/screens/settings_screen.dart';
import 'package:market_manager/screens/show_product_screen.dart';
import 'package:market_manager/screens/show_stock_screen.dart';
import 'package:market_manager/screens/show_tasks_screen.dart';
import 'package:market_manager/theme.dart' as themes;

import 'package:hive/hive.dart';
import 'package:market_manager/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'models/task_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(TaskAdapter());

  Hive.openBox('session');

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskData()..loadTasks(),
      child: MarketManager(),
    ),
  );
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
        BarcodeScannerScreen.id : (context) => BarcodeScannerScreen(),
        ShowProductScreen.id : (context) => ShowProductScreen(),
        ShowStockScreen.id: (context) => ShowStockScreen(),
        EnterBarcodeManuallyScreen.id: (context) => EnterBarcodeManuallyScreen(),
        MakeSaleScreen.id: (context) => MakeSaleScreen(),
        ShowTasksScreen.id: (context) => ShowTasksScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
      },
    );
  }
}


