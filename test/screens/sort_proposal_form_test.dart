import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product/sort_element.dart';
import 'package:wyrzutka/repositories/sort_element_template_repository.dart';
import 'package:wyrzutka/screens/sort_proposal_form.dart';
import 'package:wyrzutka/screens/widgets/sort_elements_field.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';
import 'sort_proposal_form_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductService>(), MockSpec<SortElementTemplateRepository>()])
void main() {
  late Product product = Product(id: 'id', name: 'name', user: 'user', addedDate: FirestoreDateTime.serverTimestamp());
  late SortElement element = SortElement(container: ElementContainer.plastic, name: 'Name', description: 'Desc');
  late MockProductService mockProductService;
  late MockSortElementTemplateRepository mockSortElementTemplateRepository;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SortProposalForm(product: product),
        overrides: [
          productServiceProvider.overrideWithValue(mockProductService),
          sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
        ],
      ),
    );
  }

  addElement(WidgetTester tester) async {
    await scrollToAndTap(tester, find.text(element.container.containerName));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj element'));

    final context = getContext(tester);
    Navigator.of(context).pop(ElementModel(element.name, element.description!));
  }

  addElementAndSave(WidgetTester tester) async {
    await scrollToAndTap(tester, find.text(element.container.containerName));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj element'));

    final context = getContext(tester);
    Navigator.of(context).pop(ElementModel(element.name, element.description!));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj propozycję'));
  }

  setUp(() {
    mockProductService = MockProductService();
    mockSortElementTemplateRepository = MockSortElementTemplateRepository();
  });

  testWidgets('Should not save when proposal is empty', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Dodaj propozycję'));

    verifyNever(mockProductService.addSortProposal(product, any));
  });

  testWidgets('Should not save when container is empty', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text(ElementContainer.values.first.containerName));
    await scrollToAndTap(tester, find.text('Dodaj propozycję'));

    verifyNever(mockProductService.addSortProposal(product, any));
  });

  testWidgets('Should show added element', (tester) async {
    await buildWidget(tester);

    await addElement(tester);
    await tester.pumpAndSettle();

    expect(find.text(element.name), findsOneWidget);
    expect(find.text(element.description!), findsOneWidget);
  });

  testWidgets('Should save proposal with added element', (tester) async {
    await buildWidget(tester);

    await addElementAndSave(tester);
    await tester.pumpAndSettle();

    verify(mockProductService.addSortProposal(product, {
      element.container: [element]
    })).called(1);
  });

  testWidgets('Should close modal on success', (tester) async {
    await buildWidget(tester);

    await addElementAndSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Dodaj propozycję'), findsNothing);
  });

  testWidgets('Should show snackbar on success', (tester) async {
    await buildWidget(tester);

    await addElementAndSave(tester);
    await tester.pump();

    expect(find.textContaining('zapisana'), findsOneWidget);
  });

  testWidgets('Should not close modal on error', (tester) async {
    when(mockProductService.addSortProposal(any, any)).thenAnswer((realInvocation) => Future.error(Error()));
    await buildWidget(tester);

    await addElementAndSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Dodaj propozycję'), findsOneWidget);
  });

  testWidgets('Should show error snackbar on error', (tester) async {
    when(mockProductService.addSortProposal(any, any)).thenAnswer((realInvocation) => Future.error(Error()));
    await buildWidget(tester);

    await addElementAndSave(tester);
    await tester.pump();

    expect(find.textContaining('błąd'), findsOneWidget);
  });

  testWidgets('Should show loading indicator when saving proposal', (tester) async {
    final completer = stubWithCompleter(when(mockProductService.addSortProposal(product, any)));
    await buildWidget(tester);

    await addElementAndSave(tester);
    await tester.pump();

    await testLoadingIndicator(
      find.bySemanticsLabel('Dodaj propozycję'),
      find.bySemanticsLabel('Ładowanie'),
      completer,
      tester,
    );
  });
}
