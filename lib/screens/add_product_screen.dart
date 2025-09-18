import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/rounded_button.dart';
import 'package:market_manager/constants.dart';
import 'package:market_manager/components/numeric_input_field.dart';
import 'package:market_manager/utilities.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class AddProductScreen extends StatefulWidget {
  static const String id = 'add_product_screen';

  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? barcode;

  late final String _sessionStore;

  final _formKey = GlobalKey<FormState>();

  String? name;
  double? price;
  int? quantity;
  String? category;
  String? supplier;

  bool hasDiscount = false;
  double discount1 = 0;
  double discount2 = 0;

  late List<String> categories;
  late List<String> suppliers;

  List<Map>? categoryMaps;
  List<Map>? supplierMaps;

  bool isLoading = true;
  bool barcodeAlreadyExists = false;



  void _getDropdownLists () async {

    categoryMaps = await  Util.getCategories(_firestore, _sessionStore);
    supplierMaps = await Util.getSuppliers(_firestore, _sessionStore);

    if (!mounted) return;

    setState(() {
      categories = categoryMaps!.map((cat) => cat['name'] as String).toList();
      suppliers = supplierMaps!.map((sup) => sup['name'] as String).toList();
      isLoading = false;
    });
  }

  void _lookUpBarcodeInDB() async {
    if (barcode == null) Navigator.pop(context);

    try {
      final snapshot = await _firestore
          .collection('stores')
          .doc(_sessionStore)
          .collection('products')
          .doc(barcode) 
          .get();

      if (snapshot.exists) {
        final existingData = snapshot.data();
        print('Product already exists: $existingData');
        barcodeAlreadyExists = true;

        
      } else {
        print('No product found with barcode $barcode');
      }
    } catch (e) {
      print('Error checking barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error looking up barcode')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Util.getCurrentUser(_auth, context);

    _sessionStore = Hive.box('session').get('store');

    _getDropdownLists();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: this.isLoading
          ? const Center(child: CircularProgressIndicator())
        : this.barcodeAlreadyExists
          ? addExistingProduct(context)
          : addProductFirstTime(context),
      );
    }

  Padding addExistingProduct(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).textTheme.bodySmall!.color!),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  barcode != null ? 'Product with barcode $barcode is being updated' : 'No barcode',
                  style: kSubtitleTextDecoration,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 16),

            NumericInputField(
              label: 'Quantity',
              isInt: true,
              initialValue: quantity,
              onChanged: (value) => quantity = int.tryParse(value),
              validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: kTextFieldDecoration(context).copyWith(
                  labelText: 'Supplier'
              ),
              items: suppliers
                  .map((sup) => DropdownMenuItem(value: sup, child: Text(sup)))
                  .toList(),
              validator: (value) => value == null ? 'Select supplier' : null,
              onChanged: (value) {
                final selectedMap = supplierMaps!.firstWhere((sup) => sup['name'] == value);
                supplier = selectedMap['uid'];
              },
            ),

            const SizedBox(height: 16),

            NumericInputField(
              label: 'Price',
              isInt: false,
              validator: (value) => value!.isEmpty ? 'Enter price' : null,
              onChanged: (value) => price = double.tryParse(value),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                setState(() {
                  hasDiscount = !hasDiscount;
                  discount1 = 0;
                  discount2 = 0;
                });
              },
              child: Row(
                children: [
                  Text('Does the product have a discount?'),
                  Checkbox(
                    value: hasDiscount,
                    onChanged: (newValue) {
                      setState(() {
                        hasDiscount = newValue ?? false;
                        discount1 = 0;
                        discount2 = 0;
                      });
                    },
                  ),
                ],
              ),
            ),

            if(hasDiscount)

              Column(
                children: [
                  const SizedBox(height: 16),

                  NumericInputField(
                    label: '1st Discount',
                    isInt: false,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');

                      if ((value == null || value.isEmpty || parsed == 0) && hasDiscount) {
                        return 'Enter first discount';
                      }

                      if (parsed != null && (parsed < 0 || parsed > 100)) {
                        return 'Discount must be between 0 and 100';
                      }

                      return null;
                    },
                    onChanged: (value) => discount1 = double.tryParse(value) ?? 0,
                  ),

                  const SizedBox(height: 16),

                  NumericInputField(
                    label: '2nd Discount',
                    isInt: false,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');

                      if (parsed != null && (parsed < 0 || parsed > 100)) {
                        return 'Discount must be between 0 and 100';
                      }

                      return null;
                    },
                    onChanged: (value) => discount2 = double.tryParse(value) ?? 0,

                  ),
                ],
              ),




            const SizedBox(height: 24),



            RoundedButton(
              title: 'Update Product Stock',
              color: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  DocumentSnapshot snapshot = await _firestore
                      .collection('stores')
                      .doc(_sessionStore)
                      .collection('products')
                      .doc(barcode)
                      .get();

                  if (snapshot.exists) {
                    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

                    double oldPrice = (data['price'] ?? 0).toDouble();
                    int oldQuantity = data['quantity'];

                    final productData = {
                      'price': ((((price! - price! * discount1/100) - price! * discount2/100)*quantity! + oldPrice * oldQuantity) / (quantity! + oldQuantity)  * 100).round() / 100,
                      'quantity': quantity! + oldQuantity,
                      'original_quantity': quantity! + oldQuantity,
                      'stock_ratio': 1,
                    };

                    final historyData = {
                      'quantity': quantity,
                      'price': price,
                      'supplierId': supplier,
                      'discount1': hasDiscount ? discount1 : 0,
                      'discount2': hasDiscount ? discount2 : 0,
                      'createdAt': FieldValue.serverTimestamp(),
                    };


                    try {
                      await _firestore
                          .collection('stores')
                          .doc(_sessionStore)
                          .collection('products')
                          .doc(barcode)
                          .update(productData);

                      await _firestore
                          .collection('stores')
                          .doc(_sessionStore)
                          .collection('products')
                          .doc(barcode)
                          .collection('history')
                          .add(historyData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product updated successfully')),
                      );

                      Navigator.pop(context);

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating product: $e')),
                      );
                    }

                  }

                }
              },


            ),
          ],
        ),
      ),
    );
  }
    
    
  Padding addProductFirstTime(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).textTheme.bodySmall!.color!),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    barcode != null ? 'Product with barcode $barcode is being added first time' : 'No barcode',
                    style: kSubtitleTextDecoration,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),


              const SizedBox(height: 16),


              TextFormField(
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'Product Name'
                ),
                validator: (value) => value!.isEmpty ? 'Enter product name' : null,
                onSaved: (value) => name = value,
              ),

              const SizedBox(height: 16),

              NumericInputField(
                label: 'Quantity',
                isInt: true,
                initialValue: quantity,
                onChanged: (value) => quantity = int.tryParse(value),
                validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'Category'
                ),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                validator: (value) => value == null ? 'Select category' : null,
                onChanged: (value) {
                  final selectedMap = categoryMaps!.firstWhere((cat) => cat['name'] == value);
                  category = selectedMap['uid'];
                }
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'Supplier'
                ),
                items: suppliers
                    .map((sup) => DropdownMenuItem(value: sup, child: Text(sup)))
                    .toList(),
                validator: (value) => value == null ? 'Select supplier' : null,
                onChanged: (value) {
                  final selectedMap = supplierMaps!.firstWhere((sup) => sup['name'] == value);
                  supplier = selectedMap['uid'];
                },
              ),

              const SizedBox(height: 16),

              NumericInputField(
                label: 'Price',
                isInt: false,
                validator: (value) => value!.isEmpty ? 'Enter price' : null,
                onChanged: (value) => price = double.tryParse(value),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  setState(() {
                    hasDiscount = !hasDiscount;
                    discount1 = 0;
                    discount2 = 0;
                  });
                },
                child: Row(
                  children: [
                    Text('Does the product have a discount?'),
                    Checkbox(
                      value: hasDiscount,
                      onChanged: (newValue) {
                        setState(() {
                          hasDiscount = newValue ?? false;
                          discount1 = 0;
                          discount2 = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),

              if(hasDiscount)

                Column(
                  children: [
                    const SizedBox(height: 16),

                    NumericInputField(
                      label: '1st Discount',
                      isInt: false,
                      validator: (value) =>
                      (value!.isEmpty || discount1 == 0)  && hasDiscount
                          ? 'Enter first discount'
                          : null,
                      onChanged: (value) => discount1 = double.tryParse(value) ?? 0,
                    ),

                    const SizedBox(height: 16),

                    NumericInputField(
                      label: '2nd Discount',
                      isInt: false,
                      onChanged: (value) => discount2 = double.tryParse(value) ?? 0,

                    ),
                  ],
                ),




              const SizedBox(height: 24),



              RoundedButton(
                title: 'Update Product Stock',
                color: Theme.of(context).colorScheme.primary,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final productData = {
                      'name': name,
                      'price': (((price! - price! * discount1/100) - price! * discount2/100) * 100).round() / 100,
                      'quantity': quantity,
                      'categoryId': category,
                      'original_quantity': quantity,
                      'stock_ratio': 1,
                      'track_stock': true,

                    };

                    final historyData = {
                      'quantity': quantity,
                      'price': price,
                      'supplierId': supplier,
                      'discount1': hasDiscount ? discount1 : 0,
                      'discount2': hasDiscount ? discount2 : 0,
                      'createdAt': FieldValue.serverTimestamp(),
                    };


                    try {
                      await _firestore
                          .collection('stores')
                          .doc(_sessionStore)
                          .collection('products')
                          .doc(barcode)
                          .set(productData);

                      await _firestore
                          .collection('stores')
                          .doc(_sessionStore)
                          .collection('products')
                          .doc(barcode)
                          .collection('history')
                          .add(historyData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product added successfully')),
                      );

                      Navigator.pop(context);

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding product: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
  }

