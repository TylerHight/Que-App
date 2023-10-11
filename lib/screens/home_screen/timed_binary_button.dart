// timed_binary_button.dart

import 'package:flutter/material.dart';
import 'dart:async';

// button that switches between two colors and
// optionally automatically turns off after a
// set duration

class TimedBinaryButton extends StatefulWidget {
  final Color? activeColor;
  final Color? inactiveColor;
  final IconData iconData;
  final Color? iconColor;
  final double buttonSize;
  final double iconSize;
  final Function()? onPressedGreyToColor;
  final Function()? onPressedColorToGrey;
  final Duration autoTurnOffDuration;
  final bool autoTurnOffEnabled; // Add a parameter to control auto turn-off

  TimedBinaryButton({
    this.activeColor,
    this.inactiveColor = Colors.grey,
    required this.iconData,
    this.iconColor = Colors.white,
    this.buttonSize = 48.0,
    this.iconSize = 24.0,
    this.onPressedGreyToColor,
    this.onPressedColorToGrey,
    required this.autoTurnOffDuration,
    this.autoTurnOffEnabled = true, // Default to auto turn-off enabled
  });

  @override
  _TimedBinaryButtonState createState() => _TimedBinaryButtonState();
}

class _TimedBinaryButtonState extends State<TimedBinaryButton>
    with SingleTickerProviderStateMixin {
  bool isLightOn = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Timer _autoTurnOffTimer;
  int _secondsLeft = 0; // Track the remaining seconds

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
        if (isLightOn) {
          widget.onPressedColorToGrey?.call();
        } else {
          widget.onPressedGreyToColor?.call();
        }
      }
    });

    if (widget.autoTurnOffEnabled) {
      _secondsLeft = widget.autoTurnOffDuration.inSeconds;
      _startAutoTurnOffTimer();
    }
  }

  void _startAutoTurnOffTimer() {
    _autoTurnOffTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        if (isLightOn) {
          toggleLight();
          widget.onPressedGreyToColor?.call();
        }
        timer.cancel();
      }
    });
  }

  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;
      if (!isLightOn) {
        // Reset the timer when the button is turned off
        _secondsLeft = 0;
        if (_autoTurnOffTimer != null && _autoTurnOffTimer.isActive) {
          _autoTurnOffTimer.cancel();
        }
      }
    });

    _animationController.forward();

    if (widget.autoTurnOffEnabled && isLightOn) {
      _secondsLeft = widget.autoTurnOffDuration.inSeconds;
      _startAutoTurnOffTimer();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoTurnOffTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.activeColor ?? Colors.grey[300];

    return GestureDetector(
      onTap: toggleLight,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: Container(
              width: widget.buttonSize,
              height: widget.buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLightOn ? buttonColor : widget.inactiveColor,
              ),
              child: Center(
                child: Icon(
                  widget.iconData,
                  color: widget.iconColor,
                  size: widget.iconSize,
                ),
              ),
            ),
          ),
          if (widget.autoTurnOffEnabled && isLightOn)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(4),
                child: Text(
                  '$_secondsLeft s',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
