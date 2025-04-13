import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/date_circle.dart';
import 'package:market_manager/components/exit_alert.dart';
import 'package:market_manager/components/icon_content.dart';
import 'package:market_manager/components/reusable_card.dart';
import 'package:market_manager/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_manager/screens/add_product_screen.dart';
import 'package:market_manager/screens/barcode_scanner_screen.dart';
import 'package:market_manager/screens/chat_screen.dart';
import 'package:market_manager/utilities.dart';

late User loggedInUser;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  static const String id = 'menu_screen';

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  late int _day;
  late String _month;
  late String _weekday;

  final _auth = FirebaseAuth.instance;

  void getDate() {
    DateTime date = DateTime.now();

    _day = date.day;
    _month = Util.formatMonth(date.month);
    _weekday = Util.formatWeekday(date.weekday);

  }



  @override
  void dispose() {
    super.dispose();

    //TODO move this to _showBackDialog
    _auth.signOut();
    Hive.box('session').clear();
  }

  @override
  void initState() {
    super.initState();

    getDate();
    loggedInUser = Util.getCurrentUser( _auth, context);
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ExitAlert(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        //TODO add functionality on settings
        appBar: AppBar(
          title: Text('Hello ${loggedInUser.displayName}!'),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.settings))
          ],
        ),
        body: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReusableCard(
                    cardChild: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DateCircle(month: _month, day: _day, weekday: _weekday),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(15),
                            child: Text(
                              '3 tasks left!',
                              style: kSubtitleTextDecoration,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPress: () {
                      //TODO go to calendar
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReusableCard(
                      cardChild: IconContent(
                          icon: Icons.chat_rounded,
                          label: 'Chat'
                      ),
                      onPress: (){
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                  ),
                  ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.plus,
                          label: 'Add product'
                      ),
                      onPress: (){
                        Navigator.pushNamed(context, BarcodeScannerScreen.id, arguments: {'destinationPage': AddProductScreen.id} );
                      }
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.searchengin,
                          label: 'Search product'
                      ),
                      onPress: (){
                        //TODO go to search product
                      }
                  ),
                  ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.listCheck,
                          label: 'Show stock'
                      ),
                      onPress: (){
                        //TODO go to show stock
                      }
                  ),
                ],
              ),
            ),
            ReusableCard(
                cardChild: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                          'Make a sale',
                          style: kSubtitleTextDecoration,
                      ),
                    ),
                  ],
                ),
              onPress: () {
                  //TODO go to make sale
              },
            )
          ],
        ),
      ),
    );
  }
}
