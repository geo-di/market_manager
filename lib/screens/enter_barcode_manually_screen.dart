import 'package:flutter/material.dart';

class EnterBarcodeManuallyScreen extends StatefulWidget {
  static const String id = 'enter_barcode_manually_screen';

  @override
  _EnterBarcodeManuallyScreenState createState() => _EnterBarcodeManuallyScreenState();
}

class _EnterBarcodeManuallyScreenState extends State<EnterBarcodeManuallyScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Barcode Manually')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Barcode'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _barcodeController.text.trim());
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
