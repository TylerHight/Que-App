import 'package:flutter/material.dart';
import 'power_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 16), // Add spacing from the top
        Container(
          margin: EdgeInsets.only(right: 16), // Add spacing from the right edge
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PowerButton(),
            ],
          ),
        ),
      ],
    );
  }
}