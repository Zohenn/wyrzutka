import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/image_picker_provider.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'product_form_information_test.mocks.dart';
import 'utils.dart';

@GenerateNiceMocks([MockSpec<ProductService>(), MockSpec<ImagePicker>()])
void main() {
  const productId = '584937539';
  const photoPath = 'photo.png';
  const name = 'Produkt';
  const keywords = 'woda gazowana';
  final keywordsList = keywords.split(' ').toList();
  final Product variant =
      Product(id: '1234', name: 'name', user: 'user', addedDate: FirestoreDateTime.serverTimestamp());
  final Product editedProduct = Product(
    id: '478594',
    name: 'Edytowany produkt',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    keywords: ['słowo', 'klucz'],
    photo: 'editPhoto.png',
  );
  late MockProductService mockProductService;
  late MockImagePicker mockImagePicker;

  buildWidget() => wrapForTesting(
        ProductForm(id: productId),
        overrides: [
          productServiceProvider.overrideWithValue(mockProductService),
          imagePickerProvider.overrideWithValue(mockImagePicker),
        ],
      );

  buildEditWidget() => wrapForTesting(
        ProductForm.edit(product: editedProduct),
        overrides: [
          productServiceProvider.overrideWithValue(mockProductService),
          imagePickerProvider.overrideWithValue(mockImagePicker),
        ],
      );

  setUp(() {
    mockProductService = MockProductService();
    mockImagePicker = MockImagePicker();
    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((realInvocation) => Future.value(FakeXFile(photoPath)));
    when(mockProductService.findVariant(keywordsList)).thenAnswer((realInvocation) => Future.value(variant));
  });

  testWidgets('Should show product id', (tester) async {
    await tester.pumpWidget(buildWidget());

    expect(find.text(productId), findsOneWidget);
  });

  testWidgets('Should show filled photo', (tester) async {
    await tester.pumpWidget(buildWidget());

    await fillPhoto(tester);
    await tester.pumpAndSettle();

    expect(find.image(FileImage(FakeFile(photoPath))), findsOneWidget);
  });

  group('validation', () {
    testWidgets('Should not go to next step when photo is empty', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillName(tester);
      await fillKeywords(tester, 'keywords');

      await tester.pumpAndSettle();
      await tapNextStep(tester);
      await tester.pumpAndSettle();

      expect(find.text(name), findsOneWidget);
      expect(find.text('keywords'), findsOneWidget);
      expect(find.bySemanticsLabel('Nazwa produktu'), findsOneWidget);
    });

    testWidgets('Should not go to next step when name is empty', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillPhoto(tester);
      await fillKeywords(tester);

      await tester.pumpAndSettle();
      await tapNextStep(tester);
      await tester.pumpAndSettle();

      expect(find.text(keywords), findsOneWidget);
      expect(find.bySemanticsLabel('Nazwa produktu'), findsOneWidget);
    });

    testWidgets('Should not go to next step when name is whitespace only', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillPhoto(tester);
      await fillName(tester, ' ');
      await fillKeywords(tester);

      await tester.pumpAndSettle();
      await tapNextStep(tester);
      await tester.pumpAndSettle();

      expect(find.text(keywords), findsOneWidget);
      expect(find.bySemanticsLabel('Nazwa produktu'), findsOneWidget);
    });

    testWidgets('Should not go to next step when keywords are empty', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillPhoto(tester);
      await fillName(tester);

      await tester.pumpAndSettle();
      await tapNextStep(tester);
      await tester.pumpAndSettle();

      expect(find.text(name), findsOneWidget);
      expect(find.bySemanticsLabel('Nazwa produktu'), findsOneWidget);
    });

    testWidgets('Should not go to next step when keywords are whitespace only', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillPhoto(tester);
      await fillName(tester);
      await fillKeywords(tester, ' ');

      await tester.pumpAndSettle();
      await tapNextStep(tester);
      await tester.pumpAndSettle();

      expect(find.text(name), findsOneWidget);
      expect(find.bySemanticsLabel('Nazwa produktu'), findsOneWidget);
    });

    testWidgets('Should go to next step when all fields are filled', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillAll(tester);

      await tester.pumpAndSettle();
      await tapNextStep(tester);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Nazwa produktu'), findsNothing);
      expect(find.text('Lista symboli'), findsOneWidget);
    });
  });

  group('variant', () {
    testWidgets('Should show found variant', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillAll(tester);

      await tester.pumpAndSettle();

      verify(mockProductService.findVariant(keywordsList)).called(1);
      expect(find.text(variant.name), findsOneWidget);
    });

    testWidgets('Should mark variant as confirmed on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillAll(tester);

      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.text('Tak'));
      await tester.pumpAndSettle();

      expect(find.text(variant.name), findsOneWidget);
      expect(find.textContaining('Oznaczono jako wariant produktu'), findsOneWidget);
      expect(find.text('Następny krok'), findsNothing);
    });

    testWidgets('Should discard variant on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillAll(tester);

      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.text('Nie'));
      await tester.pumpAndSettle();

      expect(find.text(variant.name), findsNothing);
    });

    testWidgets('Should cancel confirmed variant on tap', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillAll(tester);
      await tester.pumpAndSettle();
      await scrollToAndTap(tester, find.text('Tak'));
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.text('Cofnij'));
      await tester.pumpAndSettle();

      expect(find.text(variant.name), findsOneWidget);
      expect(find.text('Tak'), findsOneWidget);
    });

    testWidgets('Should go to save when variant is confirmed', (tester) async {
      await tester.pumpWidget(buildWidget());

      await fillAll(tester);
      await tester.pumpAndSettle();
      await scrollToAndTap(tester, find.text('Tak'));
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, find.text('Zapisz produkt'));
      await tester.pumpAndSettle();

      expect(find.text('Zapisywanie produktu'), findsOneWidget);
    });
  });

  group('edit', () {
    testWidgets('Should show previous photo', (tester) async {
      await tester.pumpWidget(buildEditWidget());

      expect(find.image(NetworkImage(editedProduct.photo!)), findsOneWidget);
    });

    testWidgets('Should show new photo after change', (tester) async {
      await tester.pumpWidget(buildEditWidget());

      await tester.tap(find.image(NetworkImage(editedProduct.photo!)), warnIfMissed: false);
      Navigator.of(getContext(tester)).pop(FakeFile(photoPath));
      await tester.pumpAndSettle();

      expect(find.image(FileImage(FakeFile(photoPath))), findsOneWidget);
      expect(find.image(NetworkImage(editedProduct.photo!)), findsNothing);
    });

    testWidgets('Should fill fields from product', (tester) async {
      await tester.pumpWidget(buildEditWidget());

      expect(find.text(editedProduct.id), findsOneWidget);
      expect(find.text(editedProduct.name), findsOneWidget);
      expect(find.text(editedProduct.keywords.join(' ')), findsOneWidget);
    });
  });
}
