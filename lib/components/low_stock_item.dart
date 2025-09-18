import 'package:flutter/material.dart';
import 'package:market_manager/screens/show_product_screen.dart';

class LowStockItem extends StatelessWidget {
  LowStockItem({required this.barcode, required this.name, required this.quantity});

  final String barcode;
  final String name;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
            width: double.infinity, // Full width
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left Column: barcode + name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barcode,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name.trim(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Quantity in red
                Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),


      ),
  onTap: () {
    Navigator.pushNamed(
      context,
      ShowProductScreen.id,
      arguments: {'barcode': barcode},
    );
  },
    );
  }
}
