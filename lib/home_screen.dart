import 'package:flutter/material.dart';
import 'power_button.dart'; // Import the PowerButton widget
import 'emission_button.dart'; // Import the EmissionButton widget

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
          child: PowerButton(), // Keep the PowerButton at the top right
        ),
        Expanded(
          child: Center(
            child: EmissionButton(),
          ),
        ),
      ],
    );
  }
}
