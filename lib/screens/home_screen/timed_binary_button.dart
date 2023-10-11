import 'package:flutter/material.dart';
import 'dart:async';

// button that switches between two colors and
// optionally automatically turns off after a
// set duration

class AutoOffBinaryButton extends StatefulWidget {
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

  AutoOffBinaryButton({
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
  _AutoOffBinaryButtonState createState() => _AutoOffBinaryButtonState();
}

class _AutoOffBinaryButtonState extends State<AutoOffBinaryButton>
    with SingleTickerProviderStateMixin {
  bool isLightOn = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Timer _autoTurnOffTimer;

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
      _autoTurnOffTimer = Timer(widget.autoTurnOffDuration, () {
        if (isLightOn) {
          toggleLight();
          widget.onPressedGreyToColor?.call();
        }
      });
    }
  }

  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;
    });

    _animationController.forward();

    if (widget.autoTurnOffEnabled) {
      if (_autoTurnOffTimer != null && _autoTurnOffTimer.isActive) {
        _autoTurnOffTimer.cancel();
      }
      _autoTurnOffTimer = Timer(widget.autoTurnOffDuration, () {
        if (isLightOn) {
          toggleLight();
          widget.onPressedGreyToColor?.call();
        }
      });
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
      child: AnimatedBuilder(
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
    );
  }
}
