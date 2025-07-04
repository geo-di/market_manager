import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_manager/components/animated_title.dart';
import 'package:market_manager/screens/login_screen.dart';
import 'package:market_manager/screens/menu_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
            ),
            GestureDetector(
              onTap: () async {
                await Future.delayed(const Duration(seconds: 1));

                final user = FirebaseAuth.instance.currentUser;


                if (user != null) {
                  Navigator.pushNamed(context, MenuScreen.id);
                } else {
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                }
              },
              child: Hero(
                tag: 'logo',
                child: Container(
                  margin: EdgeInsets.only(right: 15),
                  child: Icon(
                    FontAwesomeIcons.cartShopping,
                    size: 150,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            AnimatedTitle(),
          ],
        ),
      ),
    );
  }
}


