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
  final Device device;
  final BleService bleService;

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
    required this.device,
    required this.bleService,
  }) : super(key: key);

  @override
  _TimedBinaryButtonState createState() => _TimedBinaryButtonState();
}

class _TimedBinaryButtonState extends State<TimedBinaryButton> with SingleTickerProviderStateMixin {
  bool isLightOn = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _autoTurnOffTimer;
  Timer? _periodicEmissionTimer;
  int _secondsLeft = 0;
  int _periodicEmissionSecondsLeft = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeTimers();
  }

  void _initializeAnimation() {
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

    _animationController.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isDisposed) {
      _animationController.reverse();
      if (isLightOn) {
        widget.onPressedTurnOff?.call();
      } else {
        widget.onPressedTurnOn?.call();
      }
    }
  }

  void _initializeTimers() {
    if (widget.autoTurnOffEnabled) {
      _secondsLeft = widget.autoTurnOffDuration.inSeconds;
      _startAutoTurnOffTimer();
    }

    if (widget.periodicEmissionEnabled) {
      _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
      _startPeriodicEmissionTimer();
    }
  }

  void _startAutoTurnOffTimer() {
    _autoTurnOffTimer?.cancel();
    if (!_isDisposed) {
      _autoTurnOffTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }

        if (_secondsLeft > 0) {
          if (mounted) {
            setState(() {
              _secondsLeft--;
            });
          }
        } else {
          if (isLightOn && mounted) {
            toggleLight();
            widget.onPressedTurnOff?.call();
          }
          timer.cancel();
        }
      });
    }
  }

  void _startPeriodicEmissionTimer() {
    _periodicEmissionTimer?.cancel();
    if (!_isDisposed) {
      _periodicEmissionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }

        if (_periodicEmissionSecondsLeft > 0) {
          if (mounted) {
            setState(() {
              _periodicEmissionSecondsLeft--;
            });
          }
        } else {
          if (!isLightOn && mounted) {
            toggleLight();
            widget.onPressedTurnOn?.call();
          }
          if (mounted) {
            setState(() {
              _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
            });
          }
          timer.cancel();
        }
      });
    }
  }

  Future<void> toggleLight() async {
    if (!mounted) return;

    if (!widget.isConnected) {
      await showNotConnectedDialog(
        context: context,
        device: widget.device,
        bleService: widget.bleService,
        onConnected: () {
          if (!_isDisposed && !isLightOn) {
            setState(() {
              isLightOn = true;
            });
            if (widget.autoTurnOffEnabled) {
              _secondsLeft = widget.autoTurnOffDuration.inSeconds;
              _startAutoTurnOffTimer();
            }
            widget.onPressedTurnOn?.call();
          }
        },
      );
      return;
    }

    if (!_isDisposed && mounted) {
      setState(() {
        isLightOn = !isLightOn;

        if (!isLightOn) {
          _secondsLeft = 0;
          _autoTurnOffTimer?.cancel();
          widget.onPressedTurnOff?.call();
        } else {
          if (widget.autoTurnOffEnabled) {
            _secondsLeft = widget.autoTurnOffDuration.inSeconds;
            _startAutoTurnOffTimer();
          }

          if (widget.periodicEmissionEnabled) {
            _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
            _startPeriodicEmissionTimer();
          }
          widget.onPressedTurnOn?.call();
        }
      });

      if (!isLightOn && widget.periodicEmissionEnabled) {
        _periodicEmissionSecondsLeft = widget.periodicEmissionTimerDuration.inSeconds;
        _startPeriodicEmissionTimer();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoTurnOffTimer?.cancel();
    _periodicEmissionTimer?.cancel();
    _animationController.removeStatusListener(_handleAnimationStatus);
    _animationController.dispose();
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