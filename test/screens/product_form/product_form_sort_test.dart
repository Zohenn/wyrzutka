import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product/sort.dart';
import 'package:wyrzutka/models/product/sort_element.dart';
import 'package:wyrzutka/providers/image_picker_provider.dart';
import 'package:wyrzutka/repositories/product_symbol_repository.dart';
import 'package:wyrzutka/repositories/sort_element_template_repository.dart';
import 'package:wyrzutka/screens/product_form/product_form.dart';
import 'package:wyrzutka/screens/widgets/sort_elements_field.dart';
import 'package:wyrzutka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../utils.dart';
import 'product_form_sort_test.mocks.dart';
import 'utils.dart';

@GenerateNiceMocks([
  MockSpec<ProductService>(),
  MockSpec<ProductSymbolRepository>(),
  MockSpec<ImagePicker>(),
  MockSpec<SortElementTemplateRepository>(),
])
void main() {
  const defaultPhotoPath = 'photo.png';
  late Product partialProduct = Product(
    id: '478594',
    name: 'Edytowany produkt',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    keywords: {'słowo', 'klucz'},
    photo: 'editPhoto.png',
  );
  const selectedContainer = ElementContainer.bio;
  final elementModel = ElementModel('Opakowanie', 'Zgnieć');
  final containers = ElementContainer.values.where((element) => element != ElementContainer.empty);

  late MockProductSymbolRepository mockProductSymbolRepository;
  late MockProductService mockProductService;
  late MockImagePicker mockImagePicker;
  late MockSortElementTemplateRepository mockSortElementTemplateRepository;

  selectContainer(WidgetTester tester) async {
    await scrollToAndTap(tester, find.bySemanticsLabel(selectedContainer.containerName).first);
  }

  openSortStep(WidgetTester tester, [bool skipFill = false]) async {
    if (!skipFill) {
      await fillAll(tester);
    }
    await tester.pumpAndSettle();

    await tapNextStep(tester);
    await tester.pumpAndSettle();
    await tapNextStep(tester);
    await tester.pumpAndSettle();
  }

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        ProductForm(id: partialProduct.id),
        overrides: [
          productServiceProvider.overrideWithValue(mockProductService),
          productSymbolRepositoryProvider.overrideWithValue(mockProductSymbolRepository),
          productSymbolsProvider.overrideWith((ref, ids) => []),
          imagePickerProvider.overrideWithValue(mockImagePicker),
          sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
          allSortElementTemplatesProvider.overrideWithValue([]),
        ],
      ),
    );

    await openSortStep(tester);
  }

  buildEditWidget(WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        wrapForTesting(
          ProductForm.edit(product: partialProduct),
          overrides: [
            productServiceProvider.overrideWithValue(mockProductService),
            productSymbolRepositoryProvider.overrideWithValue(mockProductSymbolRepository),
            productSymbolsProvider.overrideWith((ref, ids) => []),
            imagePickerProvider.overrideWithValue(mockImagePicker),
            sortElementTemplateRepositoryProvider.overrideWithValue(mockSortElementTemplateRepository),
            allSortElementTemplatesProvider.overrideWithValue([]),
          ],
        ),
      );

      await openSortStep(tester, true);
    });
  }

  setUp(() {
    mockProductSymbolRepository = MockProductSymbolRepository();
    mockProductService = MockProductService();
    mockImagePicker = MockImagePicker();
    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((realInvocation) => Future.value(FakeXFile(defaultPhotoPath)));
    when(mockProductService.findVariant(any)).thenAnswer((realInvocation) => Future.value(null));
    mockSortElementTemplateRepository = MockSortElementTemplateRepository();
  });

  testWidgets('Should not show containers in edit mode if product is not verified', (tester) async {
    await buildEditWidget(tester);

    for (var container in containers) {
      expect(find.bySemanticsLabel(container.containerName), findsNothing);
    }
  });

  testWidgets('Should go to save in edit mode if product is not verified', (tester) async {
    await buildEditWidget(tester);

    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await mockNetworkImagesFor(() => tester.pumpAndSettle());

    expect(find.text('Zapisywanie produktu'), findsOneWidget);
  });

  testWidgets('Should show containers in edit mode if product is verified', (tester) async {
    partialProduct = partialProduct.copyWith(
      sort: Sort.verified(user: 'user', elements: [SortElement(container: ElementContainer.plastic, name: 'name')]),
    );
    await buildEditWidget(tester);

    for (var container in containers) {
      expect(find.bySemanticsLabel(container.containerName), findsOneWidget);
    }
  });

  testWidgets('Should show previous sort data in edit mode if product is verified', (tester) async {
    const selectedContainer = ElementContainer.plastic;
    partialProduct = partialProduct.copyWith(
      sort: Sort.verified(user: 'user', elements: [SortElement(container: selectedContainer, name: 'name')]),
    );
    await buildEditWidget(tester);

    for (var container in containers) {
      final shouldBeSelected = container == selectedContainer;
      expect(
        tester.getSemantics(find.bySemanticsLabel(container.containerName).first),
        matchesSemantics(isSelected: shouldBeSelected),
      );
    }
    expect(find.text(partialProduct.sort!.elements.first.name), findsOneWidget);
  });

  testWidgets('Should go to save in edit mode if product is verified', (tester) async {
    partialProduct = partialProduct.copyWith(
      sort: Sort.verified(user: 'user', elements: [SortElement(container: ElementContainer.plastic, name: 'name')]),
    );
    await buildEditWidget(tester);

    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await mockNetworkImagesFor(() => tester.pumpAndSettle());

    expect(find.text('Zapisywanie produktu'), findsOneWidget);
  });

  testWidgets('Should select container on tap', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    for (var container in containers) {
      final shouldBeSelected = container == selectedContainer;
      expect(
        tester.getSemantics(find.bySemanticsLabel(container.containerName).first),
        matchesSemantics(isSelected: shouldBeSelected),
      );
    }
  });

  testWidgets('Should deselect container on tap', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    await selectContainer(tester);
    await tester.pumpAndSettle();

    for (var container in containers) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(container.containerName).first),
        matchesSemantics(isSelected: false),
      );
    }
  });

  testWidgets('Should open element dialog on tap', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj element'));
    await tester.pumpAndSettle();

    expect(find.text('Nowy element'), findsOneWidget);
  });

  testWidgets('Should show newly added element', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj element'));
    Navigator.of(getContext(tester)).pop(elementModel);
    await tester.pumpAndSettle();

    expect(find.text(elementModel.name), findsOneWidget);
    expect(find.text(elementModel.desc), findsOneWidget);
  });

  testWidgets('Should delete element on tap', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj element'));
    Navigator.of(getContext(tester)).pop(elementModel);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.byTooltip('Usuń element'));
    await tester.pumpAndSettle();

    expect(find.text(elementModel.name), findsNothing);
    expect(find.text(elementModel.desc), findsNothing);
  });

  testWidgets('Should go to save when sort is empty', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await tester.pumpAndSettle();

    expect(find.text('Zapisywanie produktu'), findsOneWidget);
  });

  testWidgets('Should not go to save when container has no elements', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await tester.pumpAndSettle();

    expect(find.text('Zapisywanie produktu'), findsNothing);
  });

  testWidgets('Should go to save when container has elements', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dodaj element'));
    Navigator.of(getContext(tester)).pop(elementModel);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await tester.pumpAndSettle();

    expect(find.text('Zapisywanie produktu'), findsOneWidget);
  });
}
