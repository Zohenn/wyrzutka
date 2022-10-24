import 'package:flutter/material.dart';

class SizeAnimationHelper extends StatelessWidget {
  const SizeAnimationHelper({
    Key? key,
    required this.value,
    required this.child,
    this.alignment = Alignment.center,
    this.clip = true,
    this.animateHeight = true,
  }) : super(key: key);

  final double value;
  final Widget child;
  final AlignmentGeometry alignment;
  final bool clip;
  final bool animateHeight;

  @override
  Widget build(BuildContext context) {
    Widget _child = Opacity(
      opacity: value,
      child: Align(
        alignment: alignment,
        heightFactor: animateHeight ? value : null,
        widthFactor: !animateHeight ? value : null,
        child: child,
      ),
    );

    return clip ? ClipRect(child: _child) : _child;
  }
}
