import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_manager/components/icon_content.dart';
import 'package:market_manager/components/reusable_card.dart';
import 'package:market_manager/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    _month = formatMonth(date.month);
    _weekday = formatWeekday(date.weekday);

    print('Date: $_day $_month $_weekday');

  }

  String formatMonth(int month){
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    return monthNames[month - 1];

  }

  String formatWeekday(int weekday) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];

    if(weekday < 1 || weekday > 7) {
      return 'Invalid weekday';
    }
    return dayNames[weekday -1];
  }

  void getCurrentUser() async {
    if(_auth.currentUser != null){
      print(_auth.currentUser?.email);
      loggedInUser = _auth.currentUser!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO change theme
      appBar: AppBar(
        title: Text('Hello ${loggedInUser.email}!'),
      ),
      body: Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ReusableCard(
                      cardChild: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(15),
                              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_month $_day',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87
                                    ),
                                  ),
                                  Text(
                                    _weekday,
                                    style: kSubtitleTextDecoration.copyWith(color: Colors.black54)
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              child: ReusableCard(
                                cardChild: Text(
                                  '3 tasks left!',
                                  style: kSubtitleTextDecoration,
                                ),
                              ),
                          ),
                        ],
                      ),
                      onPress: () {

                      }
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
                Expanded(
                  child: ReusableCard(
                      cardChild: IconContent(
                          icon: Icons.chat_rounded,
                          label: 'Chat'
                      ),
                      onPress: (){}
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.plus,
                          label: 'Add product'
                      ),
                      onPress: (){}
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
                Expanded(
                  child: ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.searchengin,
                          label: 'Search product'
                      ),
                      onPress: (){}
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                      cardChild: IconContent(
                          icon: FontAwesomeIcons.listCheck,
                          label: 'Show stock'
                      ),
                      onPress: (){}
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: ReusableCard(cardChild: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                        'Make a sale',
                      style: kSubtitleTextDecoration,
                    ),
                  ),
                ],
              )),
          )
        ],
      ),
    );
  }
}
