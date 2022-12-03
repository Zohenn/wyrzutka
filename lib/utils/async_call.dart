import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/main.dart';
import 'package:inzynierka/utils/snackbars.dart';
import 'package:inzynierka/utils/firebase_errors.dart';
import 'package:inzynierka/utils/test_mode.dart';

Future<void> asyncCall(
  BuildContext context,
  Future Function() action, {
  String? message,
}) async {
  try {
    await action.call();
  } catch (err, stack) {
    if (!kTestMode) {
      debugPrint(err.toString());
      debugPrintStack(stackTrace: stack);
    }
    final code = err is FirebaseException ? err.code : '';
    ScaffoldMessenger.of(rootScaffoldKey.currentContext!).showSnackBar(
      //ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
      errorSnackBar(
          context: context, message: firebaseErrors[code] ?? message ?? 'W trakcie przetwarzania wystąpił błąd.'),
    );
  }
}
