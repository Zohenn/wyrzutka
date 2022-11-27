import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/screens/widgets/sort_proposal_delete_dialog.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'sort_proposal_delete_dialog_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductService>()])
void main() {
  final product = Product(
      id: 'foo',
      name: 'name',
      user: 'user',
      addedDate: FirestoreDateTime.serverTimestamp(),
      sortProposals: {'bar': Sort(id: 'bar', user: 'user', elements: [])});
  final sortProposal = product.sortProposals.values.first;
  late MockProductService mockProductService;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SortProposalDeleteDialog(product: product, sortProposal: sortProposal),
        overrides: [productServiceProvider.overrideWithValue(mockProductService)],
      ),
    );
  }

  setUp(() {
    mockProductService = MockProductService();
  });

  testWidgets('Should call ProductService.deleteSortProposal on delete tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń propozycję'));
    await tester.pumpAndSettle();

    verify(mockProductService.deleteSortProposal(product, sortProposal.id)).called(1);
  });

  testWidgets('Should show loading indicator during deletion', (tester) async {
    final completer = stubWithCompleter(when(mockProductService.deleteSortProposal(any, any)));
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń propozycję'));
    await tester.pump();

    await testLoadingIndicator(
      find.bySemanticsLabel('Usuń propozycję'),
      find.bySemanticsLabel('Ładowanie'),
      completer,
      tester,
    );
  });

  testWidgets('Should show snackbar on error', (tester) async {
    when(mockProductService.deleteSortProposal(any, any)).thenAnswer((realInvocation) => Future.error(Exception()));
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń propozycję'));
    await tester.pumpAndSettle();

    expect(find.textContaining('błąd'), findsOneWidget);
  });

  testWidgets('Should not close dialog on error', (tester) async {
    when(mockProductService.deleteSortProposal(any, any)).thenAnswer((realInvocation) => Future.error(Exception()));
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń propozycję'));
    await tester.pumpAndSettle();

    expect(find.text('Usuń propozycję'), findsOneWidget);
  });

  testWidgets('Should close dialog on success', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Usuń propozycję'));
    await tester.pumpAndSettle();

    expect(find.text('Usuń propozycję'), findsNothing);
  });

  testWidgets('Should close dialog on cancel tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(find.text('Anuluj'), findsNothing);
  });
}
