import 'package:flutter/material.dart';
import 'dart:async';
import '../dialogs/not_connected_dialog.dart';
import 'package:que_app/core/models/device/device.dart';
import 'package:que_app/core/services/ble/ble_service.dart';

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
  final bool isConnected;
  final Device device;  // Add device parameter
  final BleService bleService;  // Add bleService parameter

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
    required this.isConnected,
    required this.device,  // Add to constructor
    required this.bleService,  // Add to constructor
  }) : super(key: key);

  @override
  _TimedBinaryButtonState createState() => _TimedBinaryButtonState();
}

class _TimedBinaryButtonState extends State<TimedBinaryButton> with SingleTickerProviderStateMixin {
  bool isLightOn = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Timer _autoTurnOffTimer;
  Timer? _periodicEmissionTimer;
  int _secondsLeft = 0;
  int _periodicEmissionSecondsLeft = 0;

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

  void toggleLight() async {
    if (!widget.isConnected) {
      await showNotConnectedDialog(
        context: context,
        device: widget.device,
        bleService: widget.bleService,
        onConnected: () {
          // Try the operation again after connection
          if (!isLightOn) {
            setState(() {
              isLightOn = true;
            });
            if (widget.autoTurnOffEnabled) {
              _secondsLeft = widget.autoTurnOffDuration.inSeconds;
              _autoTurnOffTimer = _startAutoTurnOffTimer();
            }
            widget.onPressedTurnOn?.call();
          }
        },
      );
      return;
    }

    setState(() {
      isLightOn = !isLightOn;

      if (!isLightOn) {
        _secondsLeft = 0;
        if (_autoTurnOffTimer.isActive) {
          _autoTurnOffTimer.cancel();
        }
        widget.onPressedTurnOff?.call();
      } else {
        if (widget.autoTurnOffEnabled) {
          _secondsLeft = widget.autoTurnOffDuration.inSeconds;
          _autoTurnOffTimer = _startAutoTurnOffTimer();
        }

        if (widget.periodicEmissionEnabled) {
          _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
          _periodicEmissionTimer = _startPeriodicEmissionTimer();
        }
        widget.onPressedTurnOn?.call();
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
      int hours = seconds ~/ 3600;
      return '$hours' 'h';
    } else if (seconds >= 60) {
      int minutes = seconds ~/ 60;
      return '$minutes' 'm';
    } else {
      return '$seconds' 's';
    }
  }
}