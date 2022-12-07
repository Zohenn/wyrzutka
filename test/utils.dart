import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/main.dart';
import 'package:wyrzutka/theme/app_theme.dart';
import 'package:mockito/mockito.dart';

Widget wrapForTesting(
  Widget child, {
  List<Override> overrides = const [],
  List<NavigatorObserver> observers = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: AppTheme(
      child: Builder(
        builder: (context) => MaterialApp(
          theme: Theme.of(context),
          home: Scaffold(key: rootScaffoldKey, body: child),
          navigatorObservers: observers,
          localizationsDelegates: const [...GlobalMaterialLocalizations.delegates],
          locale: const Locale('pl'),
          supportedLocales: const [Locale('en'), Locale('pl')],
        ),
      ),
    ),
  );
}

Future<void> scrollToAndTap(WidgetTester tester, Finder buttonFinder) async {
  await tester.ensureVisible(buttonFinder);
  await tester.pumpAndSettle();
  await tester.tap(buttonFinder);
}

BuildContext getContext(WidgetTester tester) {
  return tester.firstElement(find.byType(Scaffold));
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

Completer<T> stubWithCompleter<T>(PostExpectation<Future<T>> expectation) {
  final completer = Completer<T>();
  expectation.thenAnswer((realInvocation) => completer.future);
  return completer;
}

Future<void> testLoadingIndicator(Finder defaultFinder, Finder loadingFinder, Completer completer, WidgetTester tester) async {
  expect(defaultFinder, findsNothing);
  expect(loadingFinder, findsOneWidget);

  completer.complete();
  await tester.pump();

  expect(defaultFinder, findsOneWidget);
  expect(loadingFinder, findsNothing);
}