import 'package:flutter/material.dart';
import 'timed_binary_button.dart';
import 'binary_button.dart';
import 'package:que_app/device_data.dart';
import 'package:provider/provider.dart';

class DeviceRemote extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const DeviceRemote({super.key, 
    required this.title,
    required this.onTap,
  });

  @override
  _DeviceRemoteState createState() => _DeviceRemoteState();
}

class _DeviceRemoteState extends State<DeviceRemote> with TickerProviderStateMixin {
  late AnimationController _ratingAnimationController;
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _ratingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _currentRating = 0;
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceSettings = deviceData.getDeviceSettings(widget.title);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    BinaryButton(
                      activeColor: Colors.green.shade400,
                      inactiveColor: Colors.grey.shade400,
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
                    const SizedBox(width: 8),
                    BinaryButton(
                      activeColor: Colors.transparent,
                      inactiveColor: Colors.transparent,
                      iconData: Icons.settings,
                      iconColor: Colors.grey.shade400,
                      buttonSize: 30.0,
                      iconSize: 32.0,
                      onPressedTurnOn: () {
                        widget.onTap();
                        // TODO: enable all emissions that are turned on in the device settings
                        // TODO: communicate via bluetooth to turn on the device
                      },
                      onPressedTurnOff: () {
                        widget.onTap();
                        // TODO: disable all emissions that are turned on in the device settings (but keep setting as on)
                        // TODO: communicate via bluetooth to turn off the device
                      },
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        BinaryButton(
                          activeColor: Colors.transparent,
                          inactiveColor: Colors.transparent,
                          iconData: Icons.assignment_add,
                          iconColor: Colors.grey.shade400,
                          buttonSize: 30.0,
                          iconSize: 30.0,
                          onPressedTurnOn: () {
                            _showNoteDialog(context, deviceData, widget.title);
                          },
                          onPressedTurnOff: () {
                            _showNoteDialog(context, deviceData, widget.title);
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
                const SizedBox(width: 8),
                TimedBinaryButton(
                  periodicEmissionTimerDuration: const Duration(seconds: 0),
                  activeColor: Colors.red.shade400,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.sentiment_very_dissatisfied,
                  buttonSize: 50.0,
                  iconSize: 38.0,
                  autoTurnOffDuration: Duration(seconds: deviceSettings.negativeEmissionDuration),
                  autoTurnOffEnabled: true,
                ),
                const SizedBox(width: 8),
                TimedBinaryButton(
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
    int rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter Note'),
                  TextField(
                    onChanged: (value) {
                      // You can update the note variable if needed
                      // note = value;
                    },
                    controller: noteController,
                    decoration: const InputDecoration(hintText: 'Enter your note here'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Settings Rating'),
                  AnimatedBuilder(
                    animation: _ratingAnimationController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                              (index) => IconButton(
                            icon: Icon(
                              index < _currentRating ? Icons.star : Icons.star_border,
                              color: index < _currentRating ? Colors.orange : Colors.grey,
                            ),
                            onPressed: () {
                              _animateRating(index + 1);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Save note and rating
                    //TODO: deviceData.setNoteAndRatingForDevice(title, noteController.text, rating);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _animateRating(int newRating) {
    setState(() {
      _currentRating = newRating;
    });

    _ratingAnimationController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 500), () {
      _ratingAnimationController.reset();
      Navigator.of(context).pop();
    });
  }
}
