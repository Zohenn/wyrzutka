import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProgressIndicatorButton extends StatelessWidget {
  const ProgressIndicatorButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        if (!isLoading) {
          onPressed();
        }
      },
      style: style,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: child,
          ),
          if (isLoading)
            SpinKitThreeBounce(
              size: 20,
              color: Colors.black54,
            )
          else
            SizedBox.shrink(),
        ],
      ),
    );
  }
}
