import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_manager/components/rounded_button.dart';
import 'package:market_manager/screens/login_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
                onTap: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Icon(
                        FontAwesomeIcons.cartShopping,
                      size: 150,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
          Hero(
            tag: 'text',
            child: Material(
              color: Colors.transparent,
              child: AnimatedTextKit(
                isRepeatingAnimation: false,
                animatedTexts: [
                  TyperAnimatedText(
                    'Market',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                    ),
                  ),TyperAnimatedText(
                    'Manager',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                    ),
                  ),TyperAnimatedText(
                    'Market\nManager',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
              // RoundedButton(
              //   title: 'Log In',
              //   color: Colors.lightBlueAccent,
              //   onPressed: () {
              //     Navigator.pushNamed(context, LoginScreen.id);
              //   },
              // ),
              // RoundedButton(
              //   title: 'Register',
              //   color: Colors.lightBlueAccent,
              //   onPressed: (){
              //
              //   },
              // ),
            ],
          )
      ),
    );
  }
}
