import 'package:flutter/material.dart';

class EmissionButton extends StatefulWidget {
  @override
  _EmissionButtonState createState() => _EmissionButtonState();
}

class _EmissionButtonState extends State<EmissionButton>
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
    return GestureDetector(
      onTap: toggleLight,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLightOn ? Colors.cyan : Colors.grey[300],
          ),
          child: Center(
            child: Icon(
              Icons.air,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}