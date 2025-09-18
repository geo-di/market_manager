
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/low_stock_item.dart';
import 'package:market_manager/utilities.dart';


final _firestore = FirebaseFirestore.instance;
late User loggedInUser;
String? _sessionStore;


class ShowStockScreen extends StatefulWidget {
  const ShowStockScreen({super.key});

  static const String id = 'show_stock';

  @override
  State<ShowStockScreen> createState() => _ShowStockScreenState();
}

class _ShowStockScreenState extends State<ShowStockScreen> {

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    loggedInUser = Util.getCurrentUser(_auth, context);
    if(_sessionStore==null){
      _sessionStore = Hive.box('session').get('store');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Low Stock"),
      ),
      body: SafeArea(
          child: StreamBuilder(
              stream: _firestore
                  .collection('stores')
                  .doc(_sessionStore)
                  .collection('products')
                  .where('track_stock', isEqualTo: true)
                  .where('stock_ratio', isLessThan: 0.5)
                  .orderBy('stock_ratio', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .primary
                    ),
                  );
                } else {
                  final products = snapshot.data!.docs;

                  List<LowStockItem> productItems = [];
                  for (var product in products) {
                    final productName = product.get('name');
                    final productBarcode = product.id;
                    final productQuantity = product.get('quantity');

                    final productItem = LowStockItem(
                      barcode: productBarcode,
                      name: productName,
                      quantity: productQuantity,

                    );
                    productItems.add(productItem);
                  }

                  return ListView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20
                    ),
                    children: productItems,
                  );
                }
              }
            ),
      ),
    );
  }
}
