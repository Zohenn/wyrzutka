import 'package:flutter/material.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/widgets/generic_popup_menu_item.dart';

class RadioPopupMenuItem<T> extends GenericPopupMenuItem<T> {
  const RadioPopupMenuItem({
    super.key,
    super.value,
    super.enabled,
    super.padding,
    super.height,
    super.mouseCursor,
    super.child,
    super.onTap,
    required this.radioValue,
    required this.groupValue,
    required this.onChanged,
  }): super(type: PopupMenuItemType.action);

  final T radioValue;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  PopupMenuItemState<T, RadioPopupMenuItem<T>> createState() => _RadioPopupMenuItemState<T>();
}

class _RadioPopupMenuItemState<T> extends PopupMenuItemState<T, RadioPopupMenuItem<T>> {
  @override
  void handleTap() {
    widget.onChanged?.call(widget.radioValue);
  }

  @override
  Widget? buildChild() {
    return Row(
      children: [
        Radio<T>(
          value: widget.radioValue,
          groupValue: widget.groupValue,
          onChanged: widget.onChanged,
          activeColor: AppColors.positive,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8.0),
        if(widget.child != null)
          widget.child!,
      ],
    );
  }
}