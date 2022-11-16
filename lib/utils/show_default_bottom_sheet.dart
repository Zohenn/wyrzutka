import 'package:flutter/material.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showDefaultBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool fullScreen = false,
  Duration? duration,
  bool closeModals = true,
}) {
  if (closeModals) {
    Navigator.of(context).popUntil((route) => route is! ModalBottomSheetRoute);
  }
  return showMaterialModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    duration: duration,
    builder: (context) => DefaultBottomSheet(
      fullscreen: fullScreen,
      child: builder(context),
    ),
  );
}
