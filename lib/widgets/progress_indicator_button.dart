import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum ButtonType {
  elevated,
  outlined,
}

class ProgressIndicatorButton extends StatelessWidget {
  const ProgressIndicatorButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
    this.type = ButtonType.elevated,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;
  final ButtonType type;

  @override
  Widget build(BuildContext context) {
    final _onPressed = onPressed != null
        ? () {
            if (!isLoading) {
              onPressed?.call();
            }
          }
        : null;
    final _child = Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: [
        Opacity(
          opacity: isLoading ? 0 : 1,
          child: child,
        ),
        if (isLoading)
          Semantics(
            label: 'Ładowanie',
            child: SizedBox.fromSize(
              size: const Size(36, 18),
              child: const SpinKitThreeBounce(
                size: 18,
                color: Colors.black54,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );

    switch (type) {
      case ButtonType.elevated:
        return ElevatedButton(onPressed: _onPressed, style: style, child: _child);
      case ButtonType.outlined:
        return OutlinedButton(onPressed: _onPressed, style: style, child: _child);
    }
  }
}
