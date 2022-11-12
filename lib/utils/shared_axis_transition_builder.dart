import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

Widget sharedAxisTransitionBuilder(
  Widget child,
  Animation<double> primaryAnimation,
  Animation<double> secondaryAnimation,
) =>
    SharedAxisTransition(
      animation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      fillColor: Colors.white,
      child: child,
    );
