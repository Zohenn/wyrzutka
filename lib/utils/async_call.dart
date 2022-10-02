import 'package:flutter/material.dart';
import 'package:inzynierka/utils/error_snack_bar.dart';

Future<void> asyncCall(
  BuildContext context,
  Future Function() action, {
  String? message,
}) async {
  try {
    await action.call();
  } catch (err, stack) {
    debugPrint(err.toString());
    debugPrintStack(stackTrace: stack);
    ScaffoldMessenger.of(context).showSnackBar(
      errorSnackBar(context: context, message: message ?? 'W trakcie przetwarzania wystąpił błąd.'),
    );
  }
}
