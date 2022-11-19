import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils.dart';

const defaultPhotoPath = 'photo.png';
const defaultName = 'Produkt';
const defaultKeywords = 'woda gazowana';

class FakeXFile extends Fake implements XFile {
  FakeXFile(this.path);

  @override
  final String path;
}

class FakeFile extends Fake implements File {
  FakeFile(this.path);

  @override
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FakeFile && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}

tapNextStep(WidgetTester tester) async {
  final buttonFinder = find.text('Następny krok');
  await scrollToAndTap(tester, buttonFinder);
}

Future<void> fillPhoto(WidgetTester tester) async {
  await tester.tap(find.textContaining('Dodaj zdjęcie'), warnIfMissed: false);
  Navigator.of(getContext(tester)).pop(FakeFile(defaultPhotoPath));
}

Future<void> fillName(WidgetTester tester, [String? _name]) =>
    tester.enterText(find.bySemanticsLabel('Nazwa produktu'), _name ?? defaultName);

Future<void> fillKeywords(WidgetTester tester, [String? _keywords]) =>
    tester.enterText(find.bySemanticsLabel('Słowa kluczowe'), _keywords ?? defaultKeywords);

Future<void> fillAll(WidgetTester tester) async {
  await fillPhoto(tester);
  await fillName(tester);
  await fillKeywords(tester);
}
