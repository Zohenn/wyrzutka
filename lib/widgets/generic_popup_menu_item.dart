import 'package:flutter/material.dart';

enum PopupMenuItemType {
  presentation,
  action,
}

class GenericPopupMenuItem<T> extends PopupMenuItem<T> {
  const GenericPopupMenuItem({
    super.key,
    super.value,
    super.enabled,
    super.padding,
    super.height,
    super.mouseCursor,
    super.child,
    super.onTap,
    this.backgroundColor,
    this.type = PopupMenuItemType.action,
  });

  final Color? backgroundColor;
  final PopupMenuItemType type;

  @override
  PopupMenuItemState<T, GenericPopupMenuItem<T>> createState() => _GenericPopupMenuItemState<T>();
}

class _GenericPopupMenuItemState<T> extends PopupMenuItemState<T, GenericPopupMenuItem<T>> {
  @override
  void handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final bool isClickable = widget.type == PopupMenuItemType.action;
    TextStyle style = widget.textStyle ?? popupMenuTheme.textStyle ?? theme.textTheme.subtitle1!;

    if (!widget.enabled) {
      style = style.copyWith(color: theme.disabledColor);
    }

    Widget item = AnimatedDefaultTextStyle(
      style: style,
      duration: kThemeChangeDuration,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: widget.height),
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: isClickable ? 8.0 : 16.0),
        child: buildChild(),
      ),
    );

    if (!widget.enabled) {
      final bool isDark = theme.brightness == Brightness.dark;
      item = IconTheme.merge(
        data: IconThemeData(opacity: isDark ? 0.5 : 0.38),
        child: item,
      );
    }

    return MergeSemantics(
      child: Semantics(
        enabled: widget.enabled,
        button: true,
        child: Material(
          color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          child: InkWell(
            onTap: (widget.enabled && isClickable) ? handleTap : null,
            canRequestFocus: widget.enabled,
            child: item,
          ),
        ),
      ),
    );
  }
}
