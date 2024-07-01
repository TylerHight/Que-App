import 'package:flutter/material.dart';
import 'dart:async';

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
  final bool isConnected; // New parameter

  const TimedBinaryButton({
    Key? key,
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
    required this.isConnected, // New parameter
  }) : super(key: key);

  @override
  _TimedBinaryButtonState createState() => _TimedBinaryButtonState();
}

class _TimedBinaryButtonState extends State<TimedBinaryButton> with SingleTickerProviderStateMixin {
  bool isLightOn = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Timer _autoTurnOffTimer;
  Timer? _periodicEmissionTimer; // Declare _periodicEmissionTimer as nullable
  int _secondsLeft = 0; // Track the remaining seconds for auto turn-off
  int _periodicEmissionSecondsLeft = 0; // Track the remaining seconds for periodic emission

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
      _autoTurnOffTimer = _startAutoTurnOffTimer();
      print('Auto Turn-Off Timer started');
    }

    if (widget.periodicEmissionEnabled) {
      _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
      _periodicEmissionTimer = _startPeriodicEmissionTimer();
      print('Periodic Emission Timer started');
    }
  }

  Timer _startAutoTurnOffTimer() {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
        // Convert to minutes if over 59 seconds
        if (_secondsLeft > 59) {
          int minutes = _secondsLeft ~/ 60;
          int seconds = _secondsLeft % 60;
          print('Auto Turn-Off: $minutes m $seconds s');
        } else {
          print('Auto Turn-Off: $_secondsLeft s');
        }
      } else {
        if (isLightOn) {
          toggleLight();
          widget.onPressedTurnOff?.call();
        }
        timer.cancel();
      }
    });
  }

  Timer _startPeriodicEmissionTimer() {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_periodicEmissionSecondsLeft > 0) {
        setState(() {
          _periodicEmissionSecondsLeft--;
        });
        // Convert to minutes if over 59 seconds
        if (_periodicEmissionSecondsLeft > 59) {
          int minutes = _periodicEmissionSecondsLeft ~/ 60;
          int seconds = _periodicEmissionSecondsLeft % 60;
          print('Periodic Emission: $minutes m $seconds s');
        } else {
          print('Periodic Emission: $_periodicEmissionSecondsLeft s');
        }
      } else {
        if (!isLightOn) {
          toggleLight();
          widget.onPressedTurnOn?.call();
        }
        _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
        timer.cancel();
      }
    });
  }

  void toggleLight() {
    setState(() {
      if (widget.isConnected) {
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
            _autoTurnOffTimer = _startAutoTurnOffTimer();
          }

          if (widget.periodicEmissionEnabled) {
            _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
            _periodicEmissionTimer = _startPeriodicEmissionTimer();
          }
          widget.onPressedTurnOn?.call(); // Call onPressedTurnOn immediately
        }
      }
    });

    if (!isLightOn && widget.periodicEmissionEnabled) {
      _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
      _startPeriodicEmissionTimer();
    }

    if (isLightOn) {
      print('Button turned on');
    }
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
                color: widget.isConnected ? (isLightOn ? buttonColor : widget.inactiveColor) : Colors.grey.shade300,
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
                  _formatTime(_secondsLeft),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (widget.periodicEmissionEnabled && !isLightOn)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Text(
                  _formatTime(_periodicEmissionSecondsLeft),
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

  String _formatTime(int seconds) {
    if (seconds >= 3600) {
      // More than or equal to 1 hour
      int hours = seconds ~/ 3600;
      return '$hours' 'h';
    } else if (seconds >= 60) {
      // More than or equal to 1 minute
      int minutes = seconds ~/ 60;
      return '$minutes' 'm';
    } else {
      // Less than 1 minute
      return '$seconds' 's';
    }
  }
}
