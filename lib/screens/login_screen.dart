import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_manager/components/rounded_button.dart';
import 'package:market_manager/constants.dart';
import 'package:market_manager/screens/menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _auth = FirebaseAuth.instance;


  late String email;
  late String password;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Icon(
                        FontAwesomeIcons.cartShopping,
                        size: 60,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Hero(
                      tag: 'text', 
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          'Market Manager',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 25,

                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email'
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password'
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Log In',
              color: Colors.lightBlueAccent,
              onPressed: () async {
                try {
                  final user = await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password
                  );
                  if (user != null) {
                    Navigator.pushNamed(context, MenuScreen.id);
                  }
                } on FirebaseAuthException catch (e) {
                  print("Firebase Auth Error: ${e.message}");
                  _emailController.clear();
                  _passwordController.clear();
                } catch (e) {
                  print("Unknown Error: ${e.toString()}");
                  _emailController.clear();
                  _passwordController.clear();
                }

              },
            ),
          ],
        )
      ),
    );
  }
}
