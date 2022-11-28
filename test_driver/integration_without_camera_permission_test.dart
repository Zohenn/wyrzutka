import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await Process.run('adb', ['shell', 'pm', 'revoke', 'com.example.inzynierka', 'android.permission.CAMERA']);
  await integrationDriver();
}