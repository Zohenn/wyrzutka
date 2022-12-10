import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product/product_filters.dart';
import 'package:wyrzutka/models/product/sort.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/providers/firebase_provider.dart';
import 'package:wyrzutka/repositories/repository.dart';
import 'package:wyrzutka/services/image_upload_service.dart';
import 'package:wyrzutka/repositories/product_repository.dart';
import 'package:wyrzutka/repositories/query_filter.dart';
import 'package:wyrzutka/screens/product_form/product_form.dart';
import 'package:wyrzutka/screens/widgets/sort_elements_field.dart';

final productServiceProvider = Provider(ProductService.new);

class EmptySortProposalException implements Exception {}

class ProductService {
  ProductService(this.ref);

  final Ref ref;

  ProductRepository get productRepository => ref.read(productRepositoryProvider);

  Future<Product> createFromModel(ProductFormModel model, [Product? variant]) async {
    final photoUrls = await _uploadPhotos(model);
    final user = ref.read(authUserProvider)!.id;
    final sortProposalId = productRepository.collection.doc().id;
    final product = Product(
      id: model.id,
      name: model.name,
      keywords: {...model.keywords},
      photo: photoUrls[0],
      photoSmall: photoUrls[1],
      symbols: [...(variant != null ? variant.symbols : model.symbols)],
      sortProposals: variant != null
          ? {...variant.sortProposals}
          : {
              if (model.elements.isNotEmpty)
                sortProposalId: Sort(
                  id: sortProposalId,
                  user: user,
                  elements: model.elements.values.flattened.toList(),
                  voteBalance: 0,
                  votes: {},
                ),
            },
      user: user,
      addedDate: FirestoreDateTime.serverTimestamp(),
      verifiedBy: variant?.verifiedBy,
      sort: variant?.sort,
      variants: variant != null ? [...(variant.variants), variant.id] : [],
    );
    final batch = ref.read(firebaseFirestoreProvider).batch();
    batch.set(productRepository.getDoc(product.id), product);
    if (variant != null) {
      for (var id in product.variants) {
        batch.update(
          productRepository.getDoc(id),
          {
            'variants': FieldValue.arrayUnion([product.id])
          },
        );
      }
    }
    await batch.commit();
    return product;
  }

  Future<List<String>> _uploadPhotos(ProductFormModel model) async {
    final imageUploadService = ref.read(imageUploadServiceProvider);
    final photosPath = 'products/${model.id}';
    final photoUrls = await Future.wait<String>(
      [
        imageUploadService.uploadWithFile(model.photo!, '$photosPath/original.png', width: 500, height: 500),
        imageUploadService.uploadWithFile(model.photo!, '$photosPath/small.png', width: 80, height: 80),
      ],
    );
    return photoUrls;
  }

  Future<void> updateFromModel(ProductFormModel model) async {
    final photoUrls = model.photo != null ? await _uploadPhotos(model) : null;
    final updateData = {
      'name': model.name,
      'keywords': [...model.keywords],
      if (photoUrls != null) ...{
        'photo': photoUrls[0],
        'photoSmall': photoUrls[1],
      },
      if (model.product?.sort != null)
        'sort': model.product!.sort!.copyWith(elements: model.elements.values.flattened.toList()).toJson(),
      'symbols': [...model.symbols],
    };
    final newProduct = model.product!.copyWith(
      name: model.name,
      keywords: {...model.keywords},
      photo: photoUrls?[0] ?? model.product!.photo,
      photoSmall: photoUrls?[1] ?? model.product!.photoSmall,
      sort: model.product!.sort?.copyWith(elements: model.elements.values.flattened.toList()),
      symbols: [...model.symbols],
    );
    await productRepository.update(model.id, updateData, newProduct);
  }

  Future<Product?> findVariant(Set<String> keywords) async {
    final results = await productRepository.fetchNext(
      filters: [QueryFilter('keywords', FilterOperator.arrayContainsAny, keywords.toList())],
      batchSize: 3,
    );
    results.sort((a, b) => b.keywords.intersection(keywords).length - a.keywords.intersection(keywords).length);
    return results.firstOrNull;
  }

  List<QueryFilter> _mapFilters(List<dynamic> filters) {
    final nestedFilterList = filters.map((filter) {
      if (filter is ProductSortFilters) {
        return filter.toQueryFilters();
      }

      if (filter is ProductContainerFilters) {
        return filter.toQueryFilters();
      }

      throw UnsupportedError('${filter.runtimeType} is not supported as a Product filter');
    });
    return nestedFilterList.flattened.toList();
  }

  Future<List<Product>> fetchNextForCustomFilters({
    List<dynamic> filters = const [],
    DocumentSnapshot? startAfterDocument,
  }) async {
    return productRepository.fetchNext(filters: _mapFilters(filters), startAfterDocument: startAfterDocument);
  }

  Future<List<Product>> search(String value) {
    return productRepository.search('searchName', value);
  }

  Future<List<Product>> fetchNextVerifiedSortProposalsForUser({
    required AppUser user,
    DocumentSnapshot? startAfterDocument,
    int? batchSize,
  }) {
    return productRepository.fetchNext(
      filters: [QueryFilter('sort.user', FilterOperator.isEqualTo, user.id)],
      startAfterDocument: startAfterDocument,
      batchSize: batchSize ?? Repository.batchSize,
    );
  }

  Future<int> countVerifiedSortProposalsForUser(AppUser user) {
    return productRepository.count(filters: [QueryFilter('sort.user', FilterOperator.isEqualTo, user.id)]);
  }

  Future<List<Product>> fetchNextProductsAddedByUser({
    required AppUser user,
    DocumentSnapshot? startAfterDocument,
    int? batchSize,
  }) {
    return productRepository.fetchNext(
      filters: [QueryFilter('user', FilterOperator.isEqualTo, user.id)],
      startAfterDocument: startAfterDocument,
      batchSize: batchSize ?? Repository.batchSize,
    );
  }

  Future<int> countProductsAddedByUser(AppUser user) {
    return productRepository.count(filters: [QueryFilter('user', FilterOperator.isEqualTo, user.id)]);
  }

  Future<void> addSortProposal(Product product, SortElements elements) async {
    final flatElements = elements.values.flattened.toList();
    if (flatElements.isEmpty) {
      throw EmptySortProposalException();
    }

    final user = ref.read(authUserProvider)!.id;
    final sortProposalId = productRepository.collection.doc().id;
    final sort = Sort(
      id: sortProposalId,
      user: user,
      elements: flatElements,
      voteBalance: 0,
      votes: {},
    );

    final newProduct = product.copyWith(sortProposals: {...product.sortProposals, sortProposalId: sort});
    final updateData = {'sortProposals.$sortProposalId': sort.toJson()};
    await productRepository.update(product.id, updateData, newProduct);
  }

  Future<void> verifySortProposal(Product product, String sortProposalId) async {
    final user = ref.read(authUserProvider)!.id;
    final sortProposal = product.sortProposals[sortProposalId]!;
    final newProduct = product.copyWith(
      sort: Sort.verified(user: sortProposal.user, elements: sortProposal.elements.map((e) => e.copyWith()).toList()),
      sortProposals: {},
      verifiedBy: user,
    );
    final updateData = newProduct.toJson()
      ..removeWhere((key, value) => !['sort', 'sortProposals', 'verifiedBy'].contains(key));

    await productRepository.update(product.id, updateData, newProduct);
  }

  Future<void> deleteSortProposal(Product product, String sortProposalId) async {
    final newProduct = product.copyWith(sortProposals: {...product.sortProposals}..remove(sortProposalId));
    final updateData = {'sortProposals.$sortProposalId': FieldValue.delete()};

    await productRepository.update(product.id, updateData, newProduct);
  }
}
