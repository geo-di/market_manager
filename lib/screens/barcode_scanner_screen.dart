import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';
import 'package:market_manager/screens/menu_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'enter_barcode_manually_screen.dart';


class BarcodeScannerScreen extends StatefulWidget {
  static const String id = 'barcode_scanner_screen';

  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController controller;
  bool isFlashOn = false;
  bool isScanning = false; // flag to prevent multiple scans

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(); // create a new instance

    // Check camera permission
    Permission.camera.status.then((status) {
      if (!status.isGranted) {
        Navigator.pushReplacementNamed(context, EnterBarcodeManuallyScreen.id);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose(); // properly release the camera
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
            onDetect: (BarcodeCapture barcodes) async {
              if (isScanning) return; // Prevent multiple scans
              setState(() {
                isScanning = true; // Mark scanning as in-progress
              });

              final firstBarcode = barcodes.barcodes.firstOrNull?.rawValue;
              if (firstBarcode != null) {
                await controller.stop(); // Stop scanning immediately
                if (destinationPage != null) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    destinationPage,
                    ModalRoute.withName(MenuScreen.id),
                    arguments: {'barcode': firstBarcode},
                  );
                }
              }

              // Reset the scanning flag after a short delay to prevent multiple scans
              Future.delayed(Duration(seconds: 1), () {
                if (!mounted) return;

                setState(() {
                  isScanning = false; // Reset scanning flag
                });
                controller.start(); // Restart the scanner
              });
            },
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: toggleFlash,
              child: Icon(
                isFlashOn ? Icons.flash_off : Icons.flash_on,
                color: kAppWhite,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: () async {
                final manualCode = await Navigator.pushNamed(context, EnterBarcodeManuallyScreen.id);
                if (manualCode != null && destinationPage != null) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    destinationPage,
                    ModalRoute.withName(MenuScreen.id),
                    arguments: {'barcode': manualCode},
                  );
                }
              },
              icon: Icon(
                Icons.edit,
                color: kAppWhite,
              ),
              label: Text(
                "Enter Manually",
                style: TextStyle(
                  color: kAppWhite
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

