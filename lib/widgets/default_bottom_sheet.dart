import 'package:flutter/material.dart';

class DefaultBottomSheet extends StatelessWidget {
  const DefaultBottomSheet({
    Key? key,
    required this.child,
    this.fullscreen = false,
  }) : super(key: key);

  final Widget child;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final _child = Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24)),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
    if (fullscreen) {
      return SafeArea(child: _child);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: _child,
    );
  }
}
