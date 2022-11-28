import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:inzynierka/main.dart' as app;

import 'config.dart';
import 'setup.dart';

void defaultPatrolTest(
  String description,
  PatrolTesterCallback callback, {
  String cameraPermissionAction = 'grant',
}) {
  patrolTest(
    description,
    config: patrolConfig,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      await setupIntegrationTest($, cameraPermissionAction);
      app.main();
      await callback($);
    },
  );
}

Future<void> scrollToAndTap(WidgetTester tester, Finder buttonFinder) async {
  await tester.ensureVisible(buttonFinder);
  await tester.pumpAndSettle();
  await tester.tap(buttonFinder);
}

void textSpanOnTap(Finder finder, String text) {
  final Element element = finder.evaluate().single;
  final RenderParagraph paragraph = element.renderObject as RenderParagraph;
  // The children are the individual TextSpans which have GestureRecognizers
  paragraph.text.visitChildren((dynamic span) {
    if (span.text != text) return true; // continue iterating.

    (span.recognizer as TapGestureRecognizer).onTap!();
    return false; // stop iterating, we found the one.
  });
}
