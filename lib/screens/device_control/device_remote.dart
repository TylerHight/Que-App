import 'package:flutter/material.dart';
import 'dart:math'; // Import dart:math for generating random icons

class DeviceRemote extends StatelessWidget {
  final String title;
  final VoidCallback? onButton1Pressed;
  final VoidCallback? onButton2Pressed;
  final VoidCallback? onButton3Pressed;
  final VoidCallback? onButton4Pressed;
  final VoidCallback? onMainButton1Pressed;
  final VoidCallback? onMainButton2Pressed;

  const DeviceRemote({
    Key? key,
    required this.title,
    this.onButton1Pressed,
    this.onButton2Pressed,
    this.onButton3Pressed,
    this.onButton4Pressed,
    this.onMainButton1Pressed,
    this.onMainButton2Pressed,
  }) : super(key: key);

  // Generate a random icon
  Icon _generateRandomIcon() {
    List<IconData> icons = [
      Icons.lightbulb,
      Icons.power,
      Icons.play_arrow,
      Icons.pause,
      Icons.volume_up,
      Icons.volume_down,
    ];
    final random = Random();
    return Icon(icons[random.nextInt(icons.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Add visible borders
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: onButton1Pressed,
                      child: _generateRandomIcon(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onButton2Pressed,
                      child: _generateRandomIcon(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onButton3Pressed,
                      child: _generateRandomIcon(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onButton4Pressed,
                      child: _generateRandomIcon(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 20.0),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: onMainButton1Pressed,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    padding: EdgeInsets.all(15.0),
                    child: Center(
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: onMainButton2Pressed,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    padding: EdgeInsets.all(15.0),
                    child: Center(
                      child: Icon(Icons.remove),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
