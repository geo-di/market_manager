
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:market_manager/components/history_line_chart.dart';
import 'package:market_manager/components/history_price_card.dart';
import 'package:market_manager/components/reusable_card.dart';
import 'package:market_manager/constants.dart';
import 'package:market_manager/models/history_entry.dart';
import 'package:market_manager/utilities.dart';


final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ShowProductScreen extends StatefulWidget {

  static const String id = 'show_product_screen';
  const ShowProductScreen({super.key});

  @override
  State<ShowProductScreen> createState() => _ShowProductScreenState();
}

class _ShowProductScreenState extends State<ShowProductScreen> {

  String? barcode;
  String? name, categoryName, bestSupplier;
  int quantity = 0, vat = 0;
  double price = 0;
  bool trackStock = false;

  List<HistoryEntry> historyList = [];
  Map<DateTime, double> chartData = {};

  List<Map>? supplierMaps;

  bool doneLoading = false;


  late final String _sessionStore;

  @override
  void initState() {
    super.initState();

    Util.getCurrentUser(_auth, context);

    _sessionStore = Hive.box('session').get('store');

    _getSuppliers();

  }

  _getSuppliers () async {
    supplierMaps = await Util.getSuppliers(_firestore, _sessionStore);
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

        if (!mounted) return;

        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: Text('Product Not Found'),
              content: Text('This product is not in the database. Do you want to add it?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Add Product'),
                ),
              ],
            );
          },
        );

        if (result == true) {
          Navigator.pushReplacementNamed(
            context,
            'add_product_screen',
            arguments: {'barcode': barcode},
          );
        } else {
          Navigator.of(context).pop();
        }

        return;
      } else {
        quantity = snapshot.get('quantity');
        name = snapshot.get('name');
        price = snapshot.get('price');
        trackStock = snapshot.get('track_stock') ?? false;
        String categoryId = snapshot.get('categoryId');


        final categorySnapshot = await _firestore
            .collection('stores')
            .doc(_sessionStore)
            .collection('categories')
            .doc(categoryId)
            .get();


        if(categorySnapshot.exists) {
          categoryName = categorySnapshot.get('name');
          vat = categorySnapshot.get('vat');

          final threeMonthsAgo = DateTime.now().subtract(Duration(days: 90));

          final historySnapshot = await _firestore
              .collection('stores')
              .doc(_sessionStore)
              .collection('products')
              .doc(barcode)
              .collection('history')
              .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(threeMonthsAgo))
              .get();



          historyList = historySnapshot.docs
              .map((doc) => HistoryEntry.fromDoc(doc))
              .toList();




          bestSupplier = supplierMaps!
              .firstWhereOrNull((sup) => sup['uid'] == Util.getBestSupplierId(historyList))?['name'] ?? 'Unknown';




          chartData = {
            for (var entry in historyList) entry.createdAt: entry.finalPrice
          };



          if (mounted) {
            setState(() {
              doneLoading = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error checking barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error looking up barcode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!doneLoading) {
      return Center(
        child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.primary
        ),
      );
    } else {
      return Scaffold(
      appBar: AppBar(
        title: Text(barcode != null ? '$barcode' : 'No barcode'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReusableCard(
                    cardChild: VerticalInfo(
                      icon: FontAwesomeIcons.barcode,
                      title: "Name",
                      info: name!,
                    ),
                ),
                ReusableCard(
                    cardChild:
                    VerticalInfo(
                        icon: Icons.category,
                        title: "Category",
                        info: categoryName!,
                    ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReusableCard(
                  cardChild: VerticalInfo(
                    icon: FontAwesomeIcons.euroSign,
                    title: "Price (With VAT)",
                    info: '\€$price (\€${((price + price * vat/100) * 100).round() / 100})',
                  ),
                ),
                ReusableCard(
                  cardChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VerticalInfo(
                        icon: FontAwesomeIcons.box,
                        title: "Stock",
                        info: "$quantity",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Text(
                              'Track Stock',
                              style: kSubtitleTextDecoration.copyWith(
                                color: kAppWhite,
                                fontSize: 14,
                              ),
                            ),
                            Checkbox(
                              value: trackStock,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    trackStock = value;
                                  });
                                  _firestore
                                      .collection('stores')
                                      .doc(_sessionStore)
                                      .collection('products')
                                      .doc(barcode)
                                      .update({'track_stock': trackStock});
                                }
                              },
                              checkColor: kAppWhite,
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReusableCard(
                    cardChild: VerticalInfo(
                        title: "Best Supplier right now:",
                        info: bestSupplier!,
                    ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReusableCard(
                    cardChild: HistoryLineChart (
                      data: chartData,
                      isInteractive: false,
                    ),
                  onPress:() {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,

                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return ShowHistoryDetailed(
                            chartData: chartData,
                            historyList: historyList,
                            suppliers: supplierMaps,
                          );
                        }
                    );
                  }
                )
              ],
            ),
          ),

        ],
      ),
    );
    }
  }


}

  class ShowHistoryDetailed extends StatelessWidget {
    ShowHistoryDetailed({required this.chartData, required this.historyList, this.suppliers});

    final Map<DateTime, double> chartData;
    final List<HistoryEntry> historyList;
    final List<Map>? suppliers;



    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController)
          {
            return GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Column(
                      children:[
                        Flexible(
                          flex: 2,
                          child: HistoryLineChart(
                            data: chartData,
                            isInteractive: true,
                          ),
                        ),
                        Flexible(
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 250,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration: Duration(milliseconds: 2000),
                              autoPlayInterval: Duration(seconds: 8),
                              viewportFraction: 0.8,
                            ),
                            items: historyList.map((entry) {
                              return HistoryPriceCard(
                                price: "\€${entry.price.toStringAsFixed(2)}",
                                discount1: "${entry.discount1.toStringAsFixed(0)}%",
                                discount2: "${entry.discount2.toStringAsFixed(0)}%",
                                date: DateFormat('yyyy-MM-dd').format(entry.createdAt),
                                supplier: suppliers!
                                    .firstWhereOrNull((sup) => sup['uid'] == entry.supplierId)?['name'] ?? 'Unknown'
                                ,
                              );
                            }).toList(),
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
            );
          }
        ),
      );
    }
  }

class VerticalInfo extends StatelessWidget {

  final IconData? icon;
  final String title;
  final String info;
  VerticalInfo({this.icon, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: icon != null ? 40 : 0,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: kSubtitleTextDecoration.copyWith(
              color: kAppWhite,
              fontWeight: FontWeight.bold,

            ),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            info,
            style: kSubtitleTextDecoration.copyWith(
              color: kAppWhite,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
