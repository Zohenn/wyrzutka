import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/repositories/query_filter.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/widgets/sort_elements_input.dart';
import 'package:inzynierka/services/image_upload_service.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductRepository>(), MockSpec<ImageUploadService>(), MockSpec<File>()])
void main() {
  late AppUser authUser;
  late Product product;
  late MockProductRepository mockProductRepository;
  late MockImageUploadService mockImageUploadService;
  late ProviderContainer container;
  late ProductService productService;

  createContainer() {
    container = ProviderContainer(
      overrides: [
        authUserProvider.overrideWith((ref) => authUser),
        productRepositoryProvider.overrideWithValue(mockProductRepository),
        imageUploadServiceProvider.overrideWithValue(mockImageUploadService),
      ],
    );
  }

  setUp(() {
    authUser = AppUser(
      id: 'id',
      email: 'email',
      name: 'name',
      surname: 'surname',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );
    product = Product(id: 'foo', name: 'Produkt', user: 'id', addedDate: FirestoreDateTime.serverTimestamp());
    mockProductRepository = MockProductRepository();
    mockImageUploadService = MockImageUploadService();
    when(mockImageUploadService.uploadWithFile(any, any))
        .thenAnswer((realInvocation) => Future.value(realInvocation.positionalArguments[1]));
    createContainer();
    productService = container.read(productServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('updateFromModel', () {
    late ProductFormModel model;

    setUp(() {
      model =
          ProductFormModel(id: 'foo', name: 'Produkt2', keywords: ['keyword'], symbols: ['symbol'], product: product);
    });

    test('Should not upload image if photo is null', () async {
      await productService.updateFromModel(model);

      verifyNever(mockImageUploadService.uploadWithFile(any, any));
    });

    test('Should upload image if photo is not null', () async {
      model = model.copyWith(photo: MockFile());
      await productService.updateFromModel(model);

      verify(mockImageUploadService.uploadWithFile(model.photo, any, width: 500, height: 500)).called(1);
      verify(mockImageUploadService.uploadWithFile(model.photo, any, width: 80, height: 80)).called(1);
    });

    test('Should call update for correct product id', () async {
      await productService.updateFromModel(model);

      verify(mockProductRepository.update(model.id, any, any)).called(1);
    });

    test('Should not update photo urls if photo is null', () async {
      await productService.updateFromModel(model);

      final updateData =
          verify(mockProductRepository.update(any, captureAny, any)).captured.first as Map<String, dynamic>;
      expect(updateData.keys.toList(), isNot(containsAll(['photo', 'photoSmall'])));
    });

    test('Should update photo urls if photo is not null', () async {
      model = model.copyWith(photo: MockFile());
      await productService.updateFromModel(model);

      final updateData =
          verify(mockProductRepository.update(any, captureAny, any)).captured.first as Map<String, dynamic>;
      expect(updateData.keys.toList(), containsAll(['photo', 'photoSmall']));
    });

    test('Should update all base fields', () async {
      await productService.updateFromModel(model);

      final updateData =
          verify(mockProductRepository.update(any, captureAny, any)).captured.first as Map<String, dynamic>;
      expect(
        updateData,
        isA<Map<String, dynamic>>()
            .having((o) => o['name'], 'name', model.name)
            .having((o) => o['keywords'], 'keywords', model.keywords)
            .having((o) => o['symbols'], 'symbols', model.symbols),
      );
    });

    test('Should not update photo urls in product if photo is null', () async {
      await productService.updateFromModel(model);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;
      expect(
        newProduct,
        isA<Product>()
            .having((o) => o.photo, 'photo', product.photo)
            .having((o) => o.photoSmall, 'photoSmall', product.photoSmall),
      );
    });

    test('Should update photo urls in product if photo is not null', () async {
      model = model.copyWith(photo: MockFile());
      await productService.updateFromModel(model);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;
      expect(
        newProduct,
        isA<Product>()
            .having((o) => o.photo, 'photo', isNot(product.photo))
            .having((o) => o.photoSmall, 'photoSmall', isNot(product.photoSmall)),
      );
    });

    test('Should update all base fields in product', () async {
      await productService.updateFromModel(model);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;
      expect(
        newProduct,
        isA<Product>()
            .having((o) => o.name, 'name', model.name)
            .having((o) => o.keywords, 'keywords', model.keywords)
            .having((o) => o.symbols, 'symbols', model.symbols),
      );
    });

    test('Should not update sort if was not verified', () async {
      await productService.updateFromModel(model);

      final updateData =
          verify(mockProductRepository.update(any, captureAny, any)).captured.first as Map<String, dynamic>;
      expect(updateData.keys.toList(), isNot(contains('sort')));
    });

    test('Should not update sort in product if was not verified', () async {
      await productService.updateFromModel(model);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;
      expect(
        newProduct,
        isA<Product>()
            .having((o) => o.sort, 'sort', product.sort),
      );
    });

    // todo: test if sort is also updated
  });

  group('findVariant', () {
    late List<String> keywords;

    setUp(() {
      keywords = ['a', 'b'];
    });

    test('Should find product by keywords', () async {
      await productService.findVariant(keywords);

      final filters = verify(mockProductRepository.fetchNext(filters: captureAnyNamed('filters'), batchSize: 1))
          .captured
          .first as List<QueryFilter>;
      final filter = filters.first;
      expect(filters, hasLength(1));
      expect(
        filter,
        isA<QueryFilter>()
            .having((o) => o.field, 'field', 'keywords')
            .having((o) => o.operator, 'operator', FilterOperator.arrayContainsAny)
            .having((o) => o.value, 'value', keywords),
      );
    });
  });

  group('search', () {
    test('Should call search from repository', () async {
      const value = 'search';
      await productService.search(value);

      verify(mockProductRepository.search('searchName', value)).called(1);
    });
  });

  group('addSortProposal', () {
    late SortElements elements;
    late List<SortElement> flatElements;

    setUp(() {
      when(mockProductRepository.collection).thenReturn(
        FakeFirebaseFirestore()
            .collection('test')
            .withConverter(fromFirestore: Product.fromFirestore, toFirestore: Product.toFirestore),
      );
      elements = {
        ElementContainer.plastic: [
          SortElement(container: ElementContainer.plastic, name: 'Butelka'),
          SortElement(container: ElementContainer.plastic, name: 'Nakrętka')
        ],
        ElementContainer.paper: [SortElement(container: ElementContainer.paper, name: 'Opakowanie')]
      };
      flatElements = elements.values.flattened.toList();
    });

    test('Should call update for correct product id', () async {
      await productService.addSortProposal(product, elements);

      verify(mockProductRepository.update(product.id, any, any)).called(1);
    });

    test('Should have new sort proposal in update data', () async {
      await productService.addSortProposal(product, elements);

      final updateData =
          verify(mockProductRepository.update(any, captureAny, any)).captured.first as Map<String, dynamic>;
      final sortProposalKey = updateData.keys.first.split('.').last;
      final sortProposalData = updateData.values.first as Map<String, dynamic>;
      expect(updateData.keys, hasLength(1));
      expect(updateData.keys.first, startsWith('sortProposals.'));
      expect(sortProposalKey, isNotEmpty);
      expect(
        sortProposalData,
        isA<Map<String, dynamic>>()
            .having((o) => o['user'], 'user', authUser.id)
            .having((o) => o['voteBalance'], 'voteBalance', 0)
            .having((o) => o['votes'], 'votes', {}).having(
                (o) => o['elements'], 'elements', flatElements.map((e) => e.toJson())),
      );
    });

    test('Should add new sort proposal to product', () async {
      await productService.addSortProposal(product, elements);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;
      expect(newProduct.sortProposals, isNotEmpty);
      expect(
        newProduct.sortProposals.values.first,
        isA<Sort>()
            .having((o) => o.id, 'id', isNotEmpty)
            .having((o) => o.user, 'user', authUser.id)
            .having((o) => o.voteBalance, 'voteBalance', 0)
            .having((o) => o.votes, 'votes', {}).having((o) => o.elements, 'elements', flatElements),
      );
    });

    test('Should not remove other sort proposals from product', () async {
      final sortProposal = Sort(id: 'id', user: 'user', elements: [], voteBalance: 0, votes: {});
      product = product.copyWith(sortProposals: {sortProposal.id: sortProposal});
      await productService.addSortProposal(product, elements);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;
      expect(newProduct.sortProposals, hasLength(2));
      expect(newProduct.sortProposals[sortProposal.id], sortProposal);
    });

    test('Should throw when called with empty map', () async {
      await expectLater(productService.addSortProposal(product, {}), throwsA(isA<EmptySortProposalException>()));
    });

    test('Should throw when called with map containing only empty lists', () async {
      final SortElements _elements = {
        ElementContainer.plastic: [],
        ElementContainer.paper: [],
      };
      await expectLater(productService.addSortProposal(product, _elements), throwsA(isA<EmptySortProposalException>()));
    });
  });

  group('deleteSortProposal', () {
    late Product productWithProposals;
    late String sortProposalId;

    setUp(() {
      sortProposalId = '1';
      productWithProposals = product.copyWith(sortProposals: {
        '1': Sort(
          id: '1',
          user: authUser.id,
          elements: [SortElement(container: ElementContainer.plastic, name: 'Butelka')],
          voteBalance: 1,
          votes: {},
        ),
        '2': Sort(
          id: '2',
          user: authUser.id,
          elements: [SortElement(container: ElementContainer.paper, name: 'Opakowanie')],
          voteBalance: 0,
          votes: {},
        ),
      });
    });

    test('Should call update for correct product id', () async {
      await productService.deleteSortProposal(productWithProposals, sortProposalId);

      verify(mockProductRepository.update(productWithProposals.id, any, any)).called(1);
    });

    test('Should mark sort proposal for deletion in update data', () async {
      await productService.deleteSortProposal(productWithProposals, sortProposalId);

      final updateData =
          verify(mockProductRepository.update(any, captureAny, any)).captured.first as Map<String, dynamic>;
      final sortProposalKey = 'sortProposals.$sortProposalId';

      expect(updateData.keys.toList(), [sortProposalKey]);
      expect(updateData[sortProposalKey], FieldValue.delete());
    });

    test('Should remove sort proposal from product', () async {
      await productService.deleteSortProposal(productWithProposals, sortProposalId);

      final newProduct = verify(mockProductRepository.update(any, any, captureAny)).captured.first as Product;

      expect(newProduct.sortProposals, {...productWithProposals.sortProposals}..remove(sortProposalId));
    });
  });
}
