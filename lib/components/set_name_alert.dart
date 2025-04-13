import 'package:flutter/material.dart';
import 'package:market_manager/constants.dart';

class SetNameAlert extends StatefulWidget {
  const SetNameAlert({super.key});

  @override
  State<SetNameAlert> createState() => _SetNameAlertState();
}

class _SetNameAlertState extends State<SetNameAlert> {

  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 2,
      backgroundColor: kAppWhite,

      title: const Text(
        'Please enter your name',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w700
        ),
      ),
      content: TextField(
        controller: _nameController,
        decoration: kTextFieldDecoration(context).copyWith(
          hintText: 'Enter your name',
        ),
        style: TextStyle(
          color: Colors.black87
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 14),

          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          onPressed: () {
            Navigator.pop(context, _nameController.text.trim());
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
