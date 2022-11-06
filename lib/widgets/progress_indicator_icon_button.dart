import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProgressIndicatorIconButton extends StatelessWidget {
  const ProgressIndicatorIconButton({
    super.key,
    this.isLoading = false,
    this.spinnerColor = Colors.black54,
    // IconButton code
    this.iconSize,
    this.visualDensity,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    required this.onPressed,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback = true,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
    required this.icon,
  });

  final bool isLoading;
  final Color spinnerColor;

  // IconButton code
  final double? iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final double? splashRadius;
  final Widget icon;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? color;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? disabledColor;
  final VoidCallback? onPressed;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final bool enableFeedback;
  final BoxConstraints? constraints;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed != null
          ? () {
              if (!isLoading) {
                onPressed?.call();
              }
            }
          : null,
      iconSize: iconSize,
      visualDensity: visualDensity,
      padding: padding,
      alignment: alignment,
      splashRadius: splashRadius,
      color: color,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      disabledColor: disabledColor,
      mouseCursor: mouseCursor,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: tooltip,
      enableFeedback: enableFeedback,
      constraints: constraints,
      style: style,
      isSelected: isSelected,
      selectedIcon: selectedIcon,
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: icon,
          ),
          if (isLoading)
            SpinKitDoubleBounce(
              size: 20,
              color: spinnerColor,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
