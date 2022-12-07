import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/product_symbol/product_symbol.dart';
import 'package:wyrzutka/repositories/product_symbol_repository.dart';
import 'package:wyrzutka/screens/product_form/product_symbols_sheet.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../utils.dart';
import 'product_symbols_sheet_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductSymbolRepository>()])
void main() {
  final symbols = [
    ProductSymbol(id: '1', name: 'Symbol 1', photo: 'photo1.png'),
    ProductSymbol(id: '2', name: 'Symbol 2', photo: 'photo2.png'),
    ProductSymbol(id: '3', name: 'Symbol 3', photo: 'photo3.png'),
  ];
  final symbolsToSelect = symbols.take(2).toList();
  late MockProductSymbolRepository mockProductSymbolRepository;
  late List<String> defaultSymbols;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        Container(),
        overrides: [
          productSymbolRepositoryProvider.overrideWithValue(mockProductSymbolRepository),
          allProductSymbolsProvider.overrideWithValue(symbols)
        ],
      ),
    );
    final context = getContext(tester);
    final completer = Completer<List<String>?>();
    showDefaultBottomSheet(context: context, builder: (context) => ProductSymbolsSheet(symbols: defaultSymbols))
        .then((value) => completer.complete(value));
    await mockNetworkImagesFor(() => tester.pumpAndSettle());
    return completer;
  }

  selectSymbols(WidgetTester tester) async {
    for (var symbol in symbolsToSelect) {
      await tester.tap(find.image(NetworkImage(symbol.photo)));
    }
  }

  setUp(() {
    mockProductSymbolRepository = MockProductSymbolRepository();
    defaultSymbols = [];
  });

  testWidgets('Should fetch all symbols', (tester) async {
    await buildWidget(tester);

    verify(mockProductSymbolRepository.fetchAll()).called(1);
  });

  testWidgets('Should show all symbols', (tester) async {
    await buildWidget(tester);

    for (var symbol in symbols) {
      expect(find.image(NetworkImage(symbol.photo)), findsOneWidget);
    }
  });

  testWidgets('Should select symbol on tap', (tester) async {
    await buildWidget(tester);

    final symbol = symbols.first;
    await tester.tap(find.bySemanticsLabel(symbol.name));
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.bySemanticsLabel(symbol.name)), matchesSemantics(isSelected: true));
  });

  testWidgets('Should mark default symbols as selected', (tester) async {
    defaultSymbols = [symbols.first.id, symbols.last.id];
    await buildWidget(tester);

    for(var symbol in symbols){
      final shouldBeSelected = defaultSymbols.contains(symbol.id);

      expect(tester.getSemantics(find.bySemanticsLabel(symbol.name)), matchesSemantics(isSelected: shouldBeSelected));
    }
  });

  testWidgets('Should deselect symbol on tap', (tester) async {
    defaultSymbols = [symbols.first.id, symbols.last.id];
    await buildWidget(tester);

    final symbol = symbols.first;
    await tester.tap(find.bySemanticsLabel(symbol.name));
    await tester.pumpAndSettle();

    defaultSymbols.remove(symbol.id);

    for(var symbol in symbols){
      final shouldBeSelected = defaultSymbols.contains(symbol.id);

      expect(tester.getSemantics(find.bySemanticsLabel(symbol.name)), matchesSemantics(isSelected: shouldBeSelected));
    }
  });

  testWidgets('Should close sheet on close tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Zamknij'));
    await tester.pumpAndSettle();

    expect(find.text('Lista oznaczeń'), findsNothing);
  });

  testWidgets('Should close sheet on confirm tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Zatwierdź'));
    await tester.pumpAndSettle();

    expect(find.text('Lista oznaczeń'), findsNothing);
  });

  testWidgets('Should return selected symbols on confirm tap', (tester) async {
    final completer = await buildWidget(tester);

    await selectSymbols(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zatwierdź'));
    await tester.pumpAndSettle();

    final result = await completer.future;

    expect(result, symbolsToSelect.map((e) => e.id).toList());
  });
}
