// binary_button.dart

import 'package:flutter/material.dart';

// Button used to alternate between two states. Changes between two
// colors and has a pressing animation.

class BinaryButton extends StatefulWidget {
  final Color? activeColor; // Change the type to Color?
  final Color? inactiveColor;
  final IconData iconData;
  final Color? iconColor;
  final double buttonSize;
  final double iconSize;
  final Function()? onPressedGreyToColor; // Nullable function for grey to color
  final Function()? onPressedColorToGrey; // Nullable function for color to grey

  BinaryButton({
    this.activeColor, // Make it nullable
    this.inactiveColor = Colors.grey,
    required this.iconData,
    this.iconColor = Colors.white,
    this.buttonSize = 48.0,
    this.iconSize = 24.0,
    this.onPressedGreyToColor, // Nullable function for grey to color
    this.onPressedColorToGrey, // Nullable function for color to grey
  });

  @override
  _BinaryButtonState createState() => _BinaryButtonState();
}

class _BinaryButtonState extends State<BinaryButton>
    with SingleTickerProviderStateMixin {
  bool isLightOn = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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
          widget.onPressedColorToGrey?.call(); // Execute callback for color to grey if it's provided
        } else {
          widget.onPressedGreyToColor?.call(); // Execute callback for grey to color if it's provided
        }
      }
    });
  }

  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.activeColor ?? Colors.grey[300]; // Use the default color if buttonColor is null

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




