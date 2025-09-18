import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/rounded_button.dart';
import 'package:market_manager/components/set_name_alert.dart';
import 'package:market_manager/constants.dart';
import 'package:market_manager/screens/menu_screen.dart';
import 'package:market_manager/utilities.dart';


final _firestore = FirebaseFirestore.instance;

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

  Future<String?> _showSetDisplayNameDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => SetNameAlert(),
    );
  }

  @override
  void initState() {
    super.initState();

    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _passwordController.clear();
    email = '';
    password = '';
  }

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
                        color: Theme.of(context).colorScheme.primary,
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
                          style: kAnimatedTitleDecoration(context).copyWith(fontSize: 25),
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
              decoration: kTextFieldDecoration(context).copyWith(
                  labelText: 'Enter your email'
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
              decoration: kTextFieldDecoration(context).copyWith(
                labelText: 'Password',
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Log In',
              color: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                try {
                  final userCredential = await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password
                  );

                  User? user = userCredential.user;

                  if (user != null) {
                    Util.closeKeyboard(context);

                    if (user.displayName == null || user.displayName!.isEmpty) {
                      String? newDisplayName = await _showSetDisplayNameDialog();

                      if (newDisplayName != null && newDisplayName.isNotEmpty) {
                        await user.updateDisplayName(newDisplayName);
                        await user.reload();

                        await _firestore.collection('user').doc(user.uid).update({
                          'name': user.displayName,
                        });
                      } else {
                        return;
                      }
                    }
                    final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

                    if (docSnapshot.exists) {
                      final data = docSnapshot.data();
                      final String store = data?['store'];

                      final storeBox = Hive.box('session');
                      storeBox.put('store', store);

                      debugPrint(store);
                      debugPrint(Hive.box('session').get('store'));


                      Navigator.pushNamed(context, MenuScreen.id);
                    } else {
                      debugPrint('error getting data');
                    }


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
