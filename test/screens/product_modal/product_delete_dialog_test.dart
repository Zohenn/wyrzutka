import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/screens/product_modal/product_delete_dialog.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'product_delete_dialog_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductRepository>()])
void main() {
  final product = Product(id: '1', name: 'Product name', user: 'user', addedDate: FirestoreDateTime.serverTimestamp());
  late MockProductRepository mockProductRepository;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        ProductDeleteDialog(product: product),
        overrides: [
          productRepositoryProvider.overrideWithValue(mockProductRepository),
        ],
      ),
    );
  }

  setUp(() {
    mockProductRepository = MockProductRepository();
  });

  testWidgets('Should close dialog on tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(find.text('Usuń produkt'), findsNothing);
    verifyNever(mockProductRepository.delete(any));
  });

  testWidgets('Should delete product on tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń produkt'));
    await tester.pumpAndSettle();

    verify(mockProductRepository.delete(product.id)).called(1);
  });

  testWidgets('Should close modal on success', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń produkt'));
    await tester.pumpAndSettle();

    expect(find.text('Usuń produkt'), findsNothing);
  });

  testWidgets('Should show error snackbar on error', (tester) async {
    when(mockProductRepository.delete(any)).thenAnswer((realInvocation) => Future.error(Error()));
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń produkt'));
    await tester.pumpAndSettle();

    expect(find.textContaining('błąd'), findsOneWidget);
  });

  testWidgets('Should not close dialog on error', (tester) async {
    when(mockProductRepository.delete(any)).thenAnswer((realInvocation) => Future.error(Error()));
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń produkt'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Usuń produkt'), findsOneWidget);
  });
}
