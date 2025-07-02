import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final DateTime createdAt;
  final double discount1;
  final double discount2;
  final double price;
  final String supplierId;

  HistoryEntry({
    required this.createdAt,
    required this.discount1,
    required this.discount2,
    required this.price,
    required this.supplierId,
  });

  double get finalPrice => price * (1 - discount1 / 100) * (1 - discount2 / 100);


  factory HistoryEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HistoryEntry(
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      discount1: (data['discount1'] ?? 0).toDouble(),
      discount2: (data['discount2'] ?? 0).toDouble(),
      price: (data['price'] ?? 0).toDouble(),
      supplierId: data['supplierId'] ?? '',
    );
  }

}
