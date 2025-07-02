import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/screens/login_screen.dart';

import 'models/history_entry.dart';
import 'models/task.dart';

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


  static String getBestSupplierId(List<HistoryEntry> historyList) {
    final Map<String, HistoryEntry> mostRecentPerSupplier = {};

    for (var entry in historyList) {
      final existing = mostRecentPerSupplier[entry.supplierId];
      if (existing == null || entry.createdAt.isAfter(existing.createdAt)) {
        mostRecentPerSupplier[entry.supplierId] = entry;
      }
    }

    HistoryEntry? bestEntry;
    for (var entry in mostRecentPerSupplier.values) {
      if (bestEntry == null || entry.finalPrice < bestEntry.finalPrice) {
        bestEntry = entry;
      }
    }

    return bestEntry?.supplierId ?? '';
  }

  static Future<List<Task>> retrieveTasks() async {
    final box = await Hive.openBox<Task>('list');
    return box.values.toList();
  }


  //Used for fake date
  static List<Map<String, dynamic>> generateHistoryData(int count) {
    final random = Random();
    final now = DateTime.now();
    final start = now.subtract(Duration(days: 365)); // 1 year ago

    return List.generate(count, (index) {
      // Random date between start and now
      final randomDays = random.nextInt(365);
      final randomMinutes = random.nextInt(1440); // 24*60 mins
      final randomDate = start.add(Duration(days: randomDays, minutes: randomMinutes));

      return {
        'quantity': 5 + index,
        'price': 10.0 + index,
        'supplierId': 'G4tvjPW6YyM0AV5AKwhi',
        'discount1': index % 3 == 0 ? 5 : 0,
        'discount2': index % 5 == 0 ? 2 : 0,
        'createdAt': Timestamp.fromDate(randomDate),
      };
    });
  }


  static Future<void> bulkAddHistory({
    required String storeId,
    required String barcode,
    required List<Map<String, dynamic>> historyEntries,
  }) async {
    final firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();
    const int batchSize = 500;
    int count = 0;

    for (var entry in historyEntries) {
      final docRef = firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .doc(barcode)
          .collection('history')
          .doc(); // auto-generated ID
      batch.set(docRef, entry);
      count++;

      // Commit every 500 writes
      if (count % batchSize == 0) {
        await batch.commit();
        batch = firestore.batch();
      }
    }

    // Commit remaining
    if (count % batchSize != 0) {
      await batch.commit();
    }

    print('✅ Added $count history entries.');
  }


}