/// timed_binary_button.dart

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
  final Function()? onPressedTurnOn;
  final Function()? onPressedTurnOff;
  final Duration autoTurnOffDuration;
  final bool autoTurnOffEnabled;
  final Duration periodicEmissionTimerDuration;
  final bool periodicEmissionEnabled;

  const TimedBinaryButton({super.key,
    this.activeColor,
    this.inactiveColor = Colors.grey,
    required this.iconData,
    this.iconColor = Colors.white,
    this.buttonSize = 48.0,
    this.iconSize = 24.0,
    this.onPressedTurnOn,
    this.onPressedTurnOff,
    required this.autoTurnOffDuration,
    this.autoTurnOffEnabled = false,
    required this.periodicEmissionTimerDuration,
    this.periodicEmissionEnabled = false,
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
  Timer? _periodicEmissionTimer; // Declare _periodicEmissionTimer as nullable
  int _secondsLeft = 0; // Track the remaining seconds

  @override
  void initState() {
    super.initState();
    _autoTurnOffTimer = Timer(Duration.zero, () {});

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
          widget.onPressedTurnOff?.call();
        } else {
          widget.onPressedTurnOn?.call();
        }
      }
    });

    if (widget.autoTurnOffEnabled) {
      _secondsLeft = widget.autoTurnOffDuration.inSeconds;
      _autoTurnOffTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft > 0) {
          setState(() {
            _secondsLeft--;
            print('Time remaining: $_secondsLeft seconds');
          });
        } else {
          if (isLightOn) {
            toggleLight();
            widget.onPressedTurnOn?.call();
          }
          timer.cancel();
        }
      });
      print('Auto Turn-Off Timer started');
    }
  }


  Timer _startAutoTurnOffTimer() {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
          print('Time remaining: $_secondsLeft seconds');
        });
      } else {
        if (isLightOn) {
          toggleLight();
          widget.onPressedTurnOn?.call();
        }
        timer.cancel();
      }
    });
  }


  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;

      if (!isLightOn) {
        // Reset the auto turn-off timer when the button is turned off
        _secondsLeft = 0;
        if (_autoTurnOffTimer.isActive) {
          _autoTurnOffTimer.cancel();
        }
        widget.onPressedTurnOff?.call(); // Call onPressedTurnOff immediately
      } else {
        if (widget.autoTurnOffEnabled) {
          _secondsLeft = widget.autoTurnOffDuration.inSeconds;
          // Initialize the timer before starting it
          _autoTurnOffTimer = _startAutoTurnOffTimer();
        }

        if (widget.periodicEmissionEnabled) {
          // Cancel the existing periodic emission timer if it's active
          _periodicEmissionTimer?.cancel();
        }
        widget.onPressedTurnOn?.call(); // Call onPressedTurnOn immediately
      }
    });

    if (!isLightOn && widget.periodicEmissionEnabled) {
      // Start the periodic emission timer when the button turns off
      _startPeriodicEmissionTimer();
    }

    if (isLightOn) {
      print('Button turned on');
    }
  }


  void _startPeriodicEmissionTimer() {
    _periodicEmissionTimer = Timer.periodic(widget.periodicEmissionTimerDuration, (timer) {
      // When the periodic emission timer reaches zero, light up the button
      // and activate it for the specified autoTurnOffDuration
      if (!isLightOn) {
        toggleLight();
        widget.onPressedTurnOn?.call();
        print('Periodic Emission Triggered');
      }
    });
    print('Periodic Emission Timer started');
  }


  @override
  void dispose() {
    _animationController.dispose();
    _autoTurnOffTimer.cancel();
    _periodicEmissionTimer?.cancel();
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
                padding: const EdgeInsets.all(4),
                child: Text(
                  '$_secondsLeft s',
                  style: const TextStyle(
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