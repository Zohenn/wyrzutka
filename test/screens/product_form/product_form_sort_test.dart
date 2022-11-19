import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/providers/image_picker_provider.dart';
import 'package:inzynierka/repositories/product_symbol_repository.dart';
import 'package:inzynierka/repositories/sort_element_template_repository.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/widgets/sort_elements_input.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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
  final Product partialProduct = Product(
    id: '478594',
    name: 'Edytowany produkt',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    keywords: ['słowo', 'klucz'],
    photo: 'editPhoto.png',
  );
  const selectedContainer = ElementContainer.bio;
  final elementModel = ElementModel('Opakowanie', 'Zgnieć');

  late MockProductSymbolRepository mockProductSymbolRepository;
  late MockProductService mockProductService;
  late MockImagePicker mockImagePicker;
  late MockSortElementTemplateRepository mockSortElementTemplateRepository;

  selectContainer(WidgetTester tester) async {
    await scrollToAndTap(tester, find.bySemanticsLabel(selectedContainer.containerName).first);
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

    await fillAll(tester);
    await tester.pumpAndSettle();

    await tapNextStep(tester);
    await tester.pumpAndSettle();
    await tapNextStep(tester);
    await tester.pumpAndSettle();
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

  testWidgets('Should select container on tap', (tester) async {
    await buildWidget(tester);

    await selectContainer(tester);
    await tester.pumpAndSettle();

    for (var container in ElementContainer.values.where((element) => element != ElementContainer.empty)) {
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

    for (var container in ElementContainer.values.where((element) => element != ElementContainer.empty)) {
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
