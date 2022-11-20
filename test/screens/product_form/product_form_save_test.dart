import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/providers/image_picker_provider.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../mocks/mock_navigator_observer.dart';
import '../../utils.dart';
import 'product_form_save_test.mocks.dart';
import 'utils.dart';

@GenerateNiceMocks([
  MockSpec<ProductService>(),
  MockSpec<ImagePicker>(),
])
void main() {
  late Product partialProduct = Product(
    id: '478594',
    name: 'Edytowany produkt',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    keywords: ['słowo', 'klucz'],
    photo: 'editPhoto.png',
  );

  late MockProductService mockProductService;
  late MockImagePicker mockImagePicker;
  late MockNavigatorObserver mockNavigatorObserver;

  openSaveStep(WidgetTester tester, [bool skipFill = false]) async {
    if (!skipFill) {
      await fillAll(tester);
    }
    await tester.pumpAndSettle();

    await tapNextStep(tester);
    await tester.pumpAndSettle();
    await tapNextStep(tester);
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await tester.pumpAndSettle();
  }

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(ProductForm(id: partialProduct.id), overrides: [
        productServiceProvider.overrideWithValue(mockProductService),
        imagePickerProvider.overrideWithValue(mockImagePicker),
      ], observers: [
        mockNavigatorObserver
      ]),
    );

    await openSaveStep(tester);
  }

  buildVariantWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(ProductForm(id: partialProduct.id), overrides: [
        productServiceProvider.overrideWithValue(mockProductService),
        imagePickerProvider.overrideWithValue(mockImagePicker),
      ], observers: [
        mockNavigatorObserver
      ]),
    );

    await fillAll(tester);
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Tak'));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Zapisz produkt'));
    await tester.pumpAndSettle();
  }

  buildEditWidget(WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        wrapForTesting(ProductForm.edit(product: partialProduct), overrides: [
          productServiceProvider.overrideWithValue(mockProductService),
          imagePickerProvider.overrideWithValue(mockImagePicker),
        ], observers: [
          mockNavigatorObserver
        ]),
      );

      await openSaveStep(tester, true);
    });
  }

  setUp(() {
    mockProductService = MockProductService();
    when(mockProductService.findVariant(any)).thenAnswer((realInvocation) => Future.value(partialProduct));
    mockImagePicker = MockImagePicker();
    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((realInvocation) => Future.value(FakeXFile(defaultPhotoPath)));
    mockNavigatorObserver = MockNavigatorObserver();
  });

  testWidgets('Should create product if new', (tester) async {
    await buildWidget(tester);

    verify(mockProductService.createFromModel(any, null)).called(1);
    verifyNever(mockProductService.updateFromModel(any));
  });

  testWidgets('Should create product with variant if variant was selected', (tester) async {
    await buildVariantWidget(tester);

    verify(mockProductService.createFromModel(any, partialProduct)).called(1);
    verifyNever(mockProductService.updateFromModel(any));
  });

  testWidgets('Should update product in edit mode', (tester) async {
    await buildEditWidget(tester);

    verify(mockProductService.updateFromModel(any)).called(1);
    verifyNever(mockProductService.createFromModel(any));
  });

  testWidgets('Should close form when button is tapped on success', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Super!'));
    await tester.pumpAndSettle();

    // first call to close photo modal, second call to close form
    verify(mockNavigatorObserver.didPop(any, any)).called(2);
  });

  testWidgets('Should retry on tap when saving throws', (tester) async {
    when(mockProductService.createFromModel(any)).thenAnswer((realInvocation) => Future.error(Exception()));
    await buildWidget(tester);

    clearInteractions(mockProductService);

    await scrollToAndTap(tester, find.text('Spróbuj ponownie'));
    await tester.pumpAndSettle();

    verify(mockProductService.createFromModel(any)).called(1);
  });
}
