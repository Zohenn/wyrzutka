import 'package:flutter/material.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showDefaultBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showMaterialModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    builder: (context) => DefaultBottomSheet(
      child: builder(context),
    ),
  );
}
