import 'package:flutter/material.dart';

class BinaryButton extends StatefulWidget {
  final Color? activeColor;
  final Color? inactiveColor;
  final double buttonSize;
  final double iconSize;
  final IconData iconData;
  final Color? iconColor;
  final VoidCallback? onPressedGreyToColor; // Restored onPressed parameters
  final VoidCallback? onPressedColorToGrey; // as optional parameters

  BinaryButton({
    this.activeColor,
    this.inactiveColor = Colors.grey,
    this.buttonSize = 48.0,
    this.iconSize = 24.0,
    required this.iconData,
    this.iconColor,
    this.onPressedGreyToColor, // Restored onPressed parameters
    this.onPressedColorToGrey, // as optional parameters
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
          widget.onPressedColorToGrey?.call();
        } else {
          widget.onPressedGreyToColor?.call();
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
    final buttonColor = widget.activeColor ?? Colors.grey[300];
    final iconColor = widget.iconColor ?? Colors.white;

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
              size: widget.iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
