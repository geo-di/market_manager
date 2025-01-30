import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';

class DateCircle extends StatelessWidget {
  const DateCircle({
    super.key,
    required String month,
    required int day,
    required String weekday,
  }) : _month = month, _day = day, _weekday = weekday;

  final String _month;
  final int _day;
  final String _weekday;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_month $_day',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87
              ),
            ),
            Text(
                _weekday,
                style: kSubtitleTextDecoration.copyWith(color: Colors.black54)
            ),
          ],
        ),
      ),
    );
  }
}