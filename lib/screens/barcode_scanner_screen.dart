import 'package:flutter/material.dart';
import 'package:market_manager/screens/menu_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  static const String id = 'barcode_scanner_screen';

  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    controller.start();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  // Toggle flash (torch) on/off
  void toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? destinationPage = args?['destinationPage'];

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture barcodes) {
              final firstBarcode = barcodes.barcodes.firstOrNull?.rawValue;
              if (firstBarcode != null) {
                controller.stop();
                if (destinationPage != null) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    destinationPage,
                    ModalRoute.withName(MenuScreen.id),
                    arguments: {'barcode': firstBarcode},
                  );
                }
              }
            },
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: FloatingActionButton(
              onPressed: toggleFlash,
              child: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
            ),
          ),
        ],
      ),
    );
  }
}
