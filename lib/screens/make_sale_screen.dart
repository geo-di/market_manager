import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/exit_alert.dart';
import 'package:market_manager/components/rounded_button.dart';
import 'package:market_manager/screens/barcode_scanner_screen.dart';
import 'package:market_manager/utilities.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class MakeSaleScreen extends StatefulWidget {
  static const String id = 'make_sale_screen';

  const MakeSaleScreen({super.key});

  @override
  State<MakeSaleScreen> createState() => _MakeSaleScreenState();
}

class _MakeSaleScreenState extends State<MakeSaleScreen> {
  String? barcode;
  late final String _sessionStore;

  String? name;
  int quantity = 0, originalQuantity = 0;
  int saleQuantity = 1;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Util.getCurrentUser(_auth, context);
    _sessionStore = Hive.box('session').get('store');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && barcode == null) {
      barcode = args['barcode'] as String?;
      _lookUpBarcodeInDB();
    }
  }

  Future<void> _lookUpBarcodeInDB() async {
    if (barcode == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('stores')
          .doc(_sessionStore)
          .collection('products')
          .doc(barcode)
          .get();

      if (!snapshot.exists) {
        print('Product not found in database');

        if (mounted) Navigator.pop(context);
        return;
      } else {
        setState(() {
          quantity = snapshot.get('quantity');
          name = snapshot.get('name');
          originalQuantity = snapshot.get('original_quantity');
        });

        _showProductConfirmationDialog();
      }
    } catch (e) {
      print('Error checking barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error looking up barcode')),
      );
    }
  }

  Future<void> _showProductConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ReusableDialog(
        title: 'Confirm Product',
        content: Text('Product: $name\nBarcode: $barcode\nStock: $quantity'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showSaleForm();
    } else {
      Navigator.of(context).pop(); // go back if not confirmed
    }
  }

  Future<void> _showSaleForm() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter quantity to sell (max: $quantity)'),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  initialValue: '1',
                  validator: (value) {
                    final intVal = int.tryParse(value ?? '');
                    if (intVal == null || intVal <= 0) {
                      return 'Enter a valid number';
                    }
                    if (intVal > quantity) {
                      return 'Cannot sell more than $quantity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    saleQuantity = int.parse(value!);
                  },
                ),
                SizedBox(height: 10),
                RoundedButton(
                  title: 'Confirm Sale',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    _processSale();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null && mounted) {
      Navigator.of(context).pop();
    }
  }




  Future<void> _processSale() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    final newQuantity = quantity - saleQuantity;

    try {
      await _firestore
          .collection('stores')
          .doc(_sessionStore)
          .collection('products')
          .doc(barcode)
          .update({'quantity': newQuantity, 'stock_ratio': newQuantity/originalQuantity});

      if (mounted) Navigator.of(context).pop(true); // Close modal

      await _showAnotherSaleDialog();
    } catch (e) {
      print('Error processing sale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing sale')),
      );
    }
  }

  Future<void> _showAnotherSaleDialog() async {
    final doAnother = await showDialog<bool>(
      context: context,
      builder: (_) => ReusableDialog(
        title: 'Sale Complete',
        content: Text('Do you want to process another product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (doAnother == true) {
      Navigator.pushReplacementNamed(context, BarcodeScannerScreen.id, arguments: {'destinationPage': MakeSaleScreen.id} );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Sale'),
      ),
      body: Center(
        child: Text(barcode != null ? 'Product: $name' : 'No product selected'),
      ),
    );
  }
}
