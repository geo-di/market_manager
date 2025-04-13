import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_manager/screens/login_screen.dart';

class Util {

  static String formatMonth(int month){
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    return monthNames[month - 1];

  }

  static String formatWeekday(int weekday) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];

    if(weekday < 1 || weekday > 7) {
      return 'Invalid weekday';
    }
    return dayNames[weekday -1];
  }

  static closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }


  static getCurrentUser(FirebaseAuth auth, BuildContext context) {
    if (auth.currentUser != null) {
      debugPrint('Current user: ${auth.currentUser?.email}');
      return auth.currentUser;
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.id);
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getCategories(FirebaseFirestore firestore, String store) async {
    final snapshot = await firestore
        .collection('stores')
        .doc(store)
        .collection('categories')
        .get();

    final categoryMaps = snapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        'name': doc.data()['name'],
      };
    }).toList();

    return categoryMaps;
  }

  static Future<List<Map<String, dynamic>>> getSuppliers(FirebaseFirestore firestore, String store) async {
    final snapshot = await firestore
        .collection('stores')
        .doc(store)
        .collection('suppliers')
        .get();

    final supplierMaps = snapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        'name': doc.data()['name'],
      };
    }).toList();

    return supplierMaps;
  }

}