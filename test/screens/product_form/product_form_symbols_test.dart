import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product_symbol/product_symbol.dart';
import 'package:wyrzutka/repositories/product_symbol_repository.dart';
import 'package:wyrzutka/screens/product_form/product_form.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'product_form_symbols_test.mocks.dart';
import 'utils.dart';

@GenerateNiceMocks([MockSpec<ProductService>(), MockSpec<ProductSymbolRepository>()])
void main() {
  final Product partialProduct = Product(
    id: '478594',
    name: 'Edytowany produkt',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    keywords: {'słowo', 'klucz'},
    photo: 'editPhoto.png',
  );
  final symbols = [
    ProductSymbol(id: '1', name: 'Symbol 1', photo: 'photo1.png'),
    ProductSymbol(id: '2', name: 'Symbol 2', photo: 'photo2.png'),
    ProductSymbol(id: '3', name: 'Symbol 3', photo: 'photo3.png'),
  ];
  final pickedSymbols = symbols.take(2).toList();
  final pickedIds = pickedSymbols.map((e) => e.id).toList();
  late MockProductSymbolRepository mockProductSymbolRepository;
  late MockProductService mockProductService;

  buildWidget() => wrapForTesting(
        ProductForm.edit(product: partialProduct),
        overrides: [
          productServiceProvider.overrideWithValue(mockProductService),
          productSymbolRepositoryProvider.overrideWithValue(mockProductSymbolRepository),
          productSymbolsProvider.overrideWith((ref, ids) => symbols.where((element) => ids.contains(element.id)).toList()),
        ],
      );

  pickSymbols(tester) async {
    await scrollToAndTap(tester, find.text('Lista symboli'));
    Navigator.of(getContext(tester)).pop([...pickedIds]);
  }

  openSymbolsStep(WidgetTester tester) async {
    await tapNextStep(tester);
    await tester.pumpAndSettle();
  }

  setUp(() {
    mockProductSymbolRepository = MockProductSymbolRepository();
    mockProductService = MockProductService();
    when(mockProductService.findVariant(any)).thenAnswer((realInvocation) => Future.value(null));
  });

  testWidgets('Should open symbols sheet on tap', (tester) async {
    await tester.pumpWidget(buildWidget());
    await openSymbolsStep(tester);

    await scrollToAndTap(tester, find.text('Lista symboli'));
    await tester.pumpAndSettle();

    expect(find.text('Lista oznaczeń'), findsOneWidget);
  });

  testWidgets('Should show newly picked symbols', (tester) async {
    await tester.pumpWidget(buildWidget());
    await openSymbolsStep(tester);

    await pickSymbols(tester);
    await tester.pumpAndSettle();

    for (var symbol in symbols) {
      final matcher = pickedSymbols.contains(symbol) ? findsOneWidget : findsNothing;
      expect(find.text(symbol.name), matcher);
    }
  });

  testWidgets('Should delete symbol on tap', (tester) async {
    await tester.pumpWidget(buildWidget());
    await openSymbolsStep(tester);

    await pickSymbols(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.byTooltip('Usuń oznaczenie ${pickedSymbols.first.name}'));
    await tester.pumpAndSettle();
    final newSymbols = pickedSymbols.skip(1).toList();

    for (var symbol in symbols) {
      final matcher = newSymbols.contains(symbol) ? findsOneWidget : findsNothing;
      expect(find.text(symbol.name), matcher);
    }
  });

  testWidgets('Should go to next step on tap when no symbols were picked', (tester) async {
    await tester.pumpWidget(buildWidget());
    await openSymbolsStep(tester);

    await tapNextStep(tester);
    await tester.pumpAndSettle();

    expect(find.text('Lista symboli'), findsNothing);
    expect(find.text('Zapisz produkt'), findsOneWidget);
  });

  testWidgets('Should go to next step on tap when symbols were picked', (tester) async {
    await tester.pumpWidget(buildWidget());
    await openSymbolsStep(tester);

    await pickSymbols(tester);

    await tapNextStep(tester);
    await tester.pumpAndSettle();

    expect(find.text('Lista symboli'), findsNothing);
    expect(find.text('Zapisz produkt'), findsOneWidget);
  });
}
