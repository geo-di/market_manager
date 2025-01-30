import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_manager/components/date_circle.dart';
import 'package:market_manager/components/exit_alert.dart';
import 'package:market_manager/components/icon_content.dart';
import 'package:market_manager/components/reusable_card.dart';
import 'package:market_manager/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  void getCurrentUser() async {
    if(_auth.currentUser != null){
      print(_auth.currentUser?.email);
      loggedInUser = _auth.currentUser!;
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _auth.signOut();
  }

  @override
  void initState() {
    super.initState();

    getDate();
    getCurrentUser();
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
          title: Text('Hello ${loggedInUser.email}!'),
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
                      onPress: (){}
                  ),
                  ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.plus,
                          label: 'Add product'
                      ),
                      onPress: (){}
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
                      onPress: (){}
                  ),
                  ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.listCheck,
                          label: 'Show stock'
                      ),
                      onPress: (){}
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
                )
            )
          ],
        ),
      ),
    );
  }
}
