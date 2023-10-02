import 'package:flutter/material.dart';
import 'binary_button.dart'; // Import the EmissionButton widget
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double emissionDuration = EmissionDurationSettings.defaultDuration;
  double periodicEmissionFrequency = PeriodicEmissionSettings.defaultDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 16), // Add spacing from the top
        Container(
          margin: EdgeInsets.only(right: 16), // Add spacing from the right edge
          child: BinaryButton( // Positive Emission Release Button
            buttonColor: Colors.green,  // Customize the button color
            iconData: Icons.power_settings_new, // Customize the icon
          ), // Keep the Power Button at the top right
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BinaryButton(
                  buttonColor: Colors.cyan,  // Customize the button color
                  iconData: Icons.air, // Customize the icon
                ),
                SizedBox(height: 20), // Add spacing between EmissionButton and sliders
                Slider( // Emission Duration Slider
                  value: emissionDuration,
                  min: EmissionDurationSettings.min,
                  max: EmissionDurationSettings.max,
                  divisions: EmissionDurationSettings.divisions,
                  onChanged: (double value) {
                    setState(() {
                      emissionDuration = value;
                    });
                  },
                  // display the selected value
                  label: emissionDuration.toStringAsFixed(1),
                ),
                Slider( // Periodic Emission Frequency Slider
                  value: periodicEmissionFrequency,
                  min: PeriodicEmissionSettings.min,
                  max: PeriodicEmissionSettings.max,
                  divisions: PeriodicEmissionSettings.divisions,
                  onChanged: (double value) {
                    setState(() {
                      periodicEmissionFrequency = value;
                    });
                  },
                  // display the selected value
                  label: periodicEmissionFrequency.toStringAsFixed(1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
