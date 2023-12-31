import 'package:flutter/material.dart';
import 'timed_binary_button.dart';
import 'binary_button.dart';
import 'package:que_app/device_data.dart';
import 'package:provider/provider.dart';

class DeviceRemote extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  DeviceRemote({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceSettings = deviceData.getDeviceSettings(title);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    BinaryButton( // power button
                      activeColor: Colors.green.shade400,
                      inactiveColor: Colors.grey.shade300,
                      iconData: Icons.power_settings_new,
                      buttonSize: 28.0,
                      iconSize: 20.0,
                      onPressedTurnOn: () {
                        //onTap();
                      },
                      onPressedTurnOff: () {
                        //onTap();
                      },
                    ),
                    SizedBox(width: 8),
                    BinaryButton( // settings button
                      activeColor: Colors.white,
                      inactiveColor: Colors.white,
                      iconData: Icons.settings,
                      iconColor: Colors.grey.shade300,
                      buttonSize: 30.0,
                      iconSize: 32.0,
                      onPressedTurnOn: () {
                        onTap();
                        // TODO: enable all emissions that are turned on in the device settings
                        // TODO: communicate via bluetooth to turn on the device
                      },
                      onPressedTurnOff: () {
                        onTap();
                        // TODO: disable all emissions that are turned on in the device settings (but keep setting as on)
                        // TODO: communicate via bluetooth to turn off the device
                      },
                    ),
                    SizedBox(width: 8),
                    // Inside the DeviceRemote widget
                    Row(
                      children: [
                        BinaryButton( // note button
                          activeColor: Colors.white, // Change the color as per your preference
                          inactiveColor: Colors.white,
                          iconData: Icons.assignment_add,
                          iconColor: Colors.grey.shade300,
                          buttonSize: 30.0,
                          iconSize: 30.0,
                          onPressedTurnOn: () {
                            _showNoteDialog(context, deviceData, title);
                          },
                          onPressedTurnOff: (){
                            _showNoteDialog(context, deviceData, title);
                          },
                        ),
                      ],
                    ),

                  ],
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 8),
                TimedBinaryButton( // negative emission
                  periodicEmissionTimerDuration: Duration(seconds: 0),
                  activeColor: Colors.red.shade400,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.sentiment_very_dissatisfied,
                  buttonSize: 50.0,
                  iconSize: 38.0,
                  autoTurnOffDuration: Duration(seconds: deviceSettings.negativeEmissionDuration),
                  autoTurnOffEnabled: true,
                ),
                SizedBox(width: 8),
                TimedBinaryButton( // positive emission
                  periodicEmissionEnabled: deviceSettings.periodicEmissionEnabled,
                  periodicEmissionTimerDuration: Duration(seconds: deviceSettings.periodicEmissionTimerLength),
                  activeColor: Colors.green.shade500,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.mood,
                  buttonSize: 50.0,
                  iconSize: 38.0,
                  autoTurnOffDuration: Duration(seconds: deviceSettings.positiveEmissionDuration),
                  autoTurnOffEnabled: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, DeviceData deviceData, String title) {
    TextEditingController noteController = TextEditingController();
    int rating = 0; // Variable to store the selected rating

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enter Note'),
              IconButton(
                icon: Icon(Icons.thumbs_up_down),
                onPressed: () {
                  _showRatingDialog(context, (int selectedRating) {
                    // Update the rating when the user selects a value
                    rating = selectedRating;
                  });
                },
              ),
            ],
          ),
          content: TextField(
            onChanged: (value) {
              // You can update the note variable if needed
              // note = value;
            },
            controller: noteController,
            decoration: InputDecoration(hintText: 'Enter your note here'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save note and rating
                //TODO: deviceData.setNoteAndRatingForDevice(title, noteController.text, rating);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, Function(int) onRatingSelected) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate Current Settings'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
                  (index) => IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
                onPressed: () {
                  // Update the selectedRating when a star is tapped
                  selectedRating = index + 1;
                  onRatingSelected(selectedRating);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }

}
