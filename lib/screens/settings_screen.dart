import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:market_manager/components/exit_alert.dart';
import 'package:market_manager/components/rounded_button.dart';
import 'package:market_manager/constants.dart';

import 'package:market_manager/utilities.dart';


late User loggedInUser;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String id = 'settings_screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late final String _sessionStore;

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _vatController = TextEditingController();
  final FocusNode _vatFocusNode = FocusNode();
  final _newUserEmailController = TextEditingController();
  final _newUserPasswordController = TextEditingController();


  late List<String> categories;
  late List<String> suppliers;

  List<Map>? categoryMaps;
  List<Map>? supplierMaps;

  bool isLoading = true;
  bool isAdmin = false;


  @override
  void initState() {
    super.initState();

    _sessionStore = Hive.box('session').get('store');

    loggedInUser = Util.getCurrentUser( _auth, context);

    _fetchAdminStatus();
    _getDropdownLists();

    _nameController.text = loggedInUser.displayName ?? '';
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _vatController.dispose();
    _vatFocusNode.dispose();
    _newUserEmailController.dispose();
    _newUserPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdminStatus() async {
    try {
      final userDoc = await _firestore.collection('users').doc(loggedInUser.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          isAdmin = userDoc.data()?['isAdmin'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user role')),
        );
      }
    }
  }


  void _getDropdownLists () async {


    categoryMaps = await Util.getCategories(_firestore, _sessionStore);
    supplierMaps = await Util.getSuppliers(_firestore, _sessionStore);

    if (!mounted) return;

    setState(() {
      categories = categoryMaps!
          .map((cat) => "${cat['name']} (${cat['vat']}%)")
          .toList();
      suppliers = supplierMaps!.map((sup) => sup['name'] as String).toList();
      isLoading = false;
    });
  }

  Future<void> updateDisplayName() async {
    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name is being updated. Please wait')),
      );

      await loggedInUser.updateDisplayName(_nameController.text);
      await loggedInUser.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name')),
      );
    }
  }


  Future<void> addSupplier(String name) async {
    if (name.isEmpty) return;
    await _firestore
        .collection('stores')
        .doc(_sessionStore)
        .collection('suppliers')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _getDropdownLists();
  }

  Future<void> deleteSupplier(String name) async {
    final snapshot = await _firestore
        .collection('stores')
        .doc(_sessionStore)
        .collection('suppliers')
        .where('name', isEqualTo: name)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    _getDropdownLists();
  }

  Future<void> addCategory(String name, double vat) async {
    if (name.isEmpty) return;
    await _firestore
        .collection('stores')
        .doc(_sessionStore)
        .collection('categories')
        .add({
      'name': name,
      'vat': vat,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _getDropdownLists();
  }

  Future<void> deleteCategory(String name) async {
    final snapshot = await _firestore
        .collection('stores')
        .doc(_sessionStore)
        .collection('categories')
        .where('name', isEqualTo: name)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    _getDropdownLists();
  }

  Future<void> addNewUser() async {
    final email = _newUserEmailController.text.trim();
    final password = _newUserPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email and password cannot be empty')),
      );
      return;
    }

    final adminEmail = _auth.currentUser?.email;

    if (adminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No admin session found')),
      );
      return;
    }

    try {

      final adminPassword = await promptForAdminPassword(context);

      if (adminPassword == null || adminPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin password required to re-authenticate')),
        );
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = userCredential.user;
      if (newUser == null) throw Exception('User creation failed');

      await _firestore.collection('users').doc(newUser.uid).set({
        'email': email,
        'isAdmin': false,
        'store': _sessionStore,
        'createdAt': FieldValue.serverTimestamp(),
      });



      await _auth.signOut();
      final adminCredential = await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      loggedInUser = adminCredential.user!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User created successfully')),
      );

      _newUserEmailController.clear();
      _newUserPasswordController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Change Display Name
            Text('Change Display Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: _nameController,
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'Change Name'
                ),
            ),
            const SizedBox(height: 8),
            RoundedButton(
                title: 'Update Name',
                color: Theme.of(context).colorScheme.primary,
                onPressed: updateDisplayName,

            ),

            if (isAdmin) ...[
              const SizedBox(height: 16),
              Divider(),

              // Manage Suppliers
              Text('Suppliers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...suppliers.map((s) => ListTile(
                title: Text(s),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => deleteSupplier(s)),
              )),
              TextField(
                onSubmitted: (value) => addSupplier(value.trim()),
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'Add Supplier'
                ),

              ),

              const SizedBox(height: 16),

              Divider(),

              // Manage Categories
              Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...categoryMaps!.map((c) => ListTile(
                title: Text("${c['name']} (${c['vat']}%)"),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteCategory(c['name']),
                ),
              )),
              TextField(
                controller: _categoryController,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_vatFocusNode);
                },
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'Category Name'
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _vatController,
                focusNode: _vatFocusNode,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: kTextFieldDecoration(context).copyWith(
                    labelText: 'VAT'
                ),
                onSubmitted: (value) {
                  final name = _categoryController.text.trim();
                  final vat = double.tryParse(_vatController.text.trim()) ?? 0.0;
                  addCategory(name, vat);
                  _categoryController.clear();
                  _vatController.clear();
                },
              ),

              const SizedBox(height: 24),
              Divider(),

              Text('Add New User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _newUserEmailController,
                decoration: kTextFieldDecoration(context).copyWith(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newUserPasswordController,
                decoration: kTextFieldDecoration(context).copyWith(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              RoundedButton(
                title: 'Add New User',
                color: Theme.of(context).colorScheme.primary,
                onPressed: addNewUser,
              ),
            ],

          ],
        ),
      ),
    );
  }

  Future<String?> promptForAdminPassword(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => ReusableDialog(
        title: 'Re-enter Admin Password',
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: kTextFieldDecoration(context).copyWith(
            labelText: 'Admin Password',

          ),
          style: TextStyle(
            color: Colors.black
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

}
