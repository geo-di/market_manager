import 'package:flutter/material.dart';

class Util {

  static String formatMonth(int month){
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    return monthNames[month - 1];

  }

  static String formatWeekday(int weekday) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];

    if(weekday < 1 || weekday > 7) {
      return 'Invalid weekday';
    }
    return dayNames[weekday -1];
  }

  static closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}