import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_manager/constants.dart';

class NumericInputField extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final int? initialValue;
  final String? Function(String?)? validator;
  final bool isInt;

  const NumericInputField({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.validator,
    required this.isInt,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue?.toString(),
      decoration: kTextFieldDecoration(context).copyWith(
          labelText: label
      ),
      keyboardType: isInt ? TextInputType.number : TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          String newText;
          if(isInt) {
            newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
          } else {
            newText = newValue.text.replaceAll(RegExp(r"[^\d.]+"), '');

            if (newText.contains('.') && newText.indexOf('.') != newText.lastIndexOf('.')) {
              newText = oldValue.text;
            }
          }
          return TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          );
        }),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}
