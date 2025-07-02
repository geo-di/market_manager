import 'package:flutter/material.dart';

class HistoryPriceCard extends StatelessWidget {
  final String price;
  final String discount1;
  final String discount2;
  final String date;
  final String supplier;

  const HistoryPriceCard({
    Key? key,
    required this.price,
    required this.discount1,
    required this.discount2,
    required this.date,
    required this.supplier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              width: 90,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Date",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(width: 12),

            // Right: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRow("Price:", price),
                  _buildRow("Discounts:", "$discount1 + $discount2"),
                  _buildRow("Supplier:", supplier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
