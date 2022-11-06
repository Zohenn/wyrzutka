import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/product_filters.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/services/image_upload_service.dart';
import 'package:inzynierka/repositories/product_provider.dart';
import 'package:inzynierka/repositories/query_filter.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/widgets/sort_elements_input.dart';

final productServiceProvider = Provider(ProductService.new);

class ProductService {
  ProductService(this.ref);

  final Ref ref;

  Future<Product> createFromModel(ProductFormModel model, [Product? variant]) async {
    final productRepository = ref.read(productRepositoryProvider);
    final photoUrls = await _uploadPhotos(model);
    final user = ref.read(authUserProvider)!.id;
    final sortProposalId = productRepository.collection.doc().id;
    final product = Product(
      id: model.id,
      name: model.name,
      keywords: [...model.keywords],
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
    batch.set(productRepository.collection.doc(product.id), product);
    if (variant != null) {
      for (var id in product.variants) {
        batch.update(
          productRepository.collection.doc(id),
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
    final productRepository = ref.read(productRepositoryProvider);
    final photoUrls = model.photo != null ? await _uploadPhotos(model) : null;
    final updateData = {
      'name': model.name,
      'keywords': [...model.keywords],
      if (photoUrls != null) ...{
        'photo': photoUrls[0],
        'photoSmall': photoUrls[1],
      },
      'symbols': [...model.symbols],
    };
    final newProduct = model.product!.copyWith(
      name: model.name,
      keywords: [...model.keywords],
      photo: photoUrls?[0] ?? model.product!.photo,
      photoSmall: photoUrls?[1] ?? model.product!.photoSmall,
      symbols: [...model.symbols],
    );
    await productRepository.update(model.id, updateData, newProduct);
  }

  Future<Product?> findVariant(List<String> keywords) async {
    final productRepository = ref.read(productRepositoryProvider);
    final query = productRepository.collection.where('keywords', arrayContainsAny: keywords).limit(1);
    final snapshot = await query.get();
    return snapshot.docs.firstOrNull?.data();
  }

  List<QueryFilter> _mapFilters(List<dynamic> filters) {
    final nestedFilterList = filters.map((filter) {
      if (filter is ProductSortFilters) {
        switch (filter) {
          case ProductSortFilters.verified:
            return [QueryFilter('sort', FilterOperator.isNull, false)];
          case ProductSortFilters.unverified:
            return [
              QueryFilter('sort', FilterOperator.isNull, true),
              QueryFilter('sortProposals', FilterOperator.isNotEqualTo, {})
            ];
          case ProductSortFilters.noProposals:
            return [
              QueryFilter('sort', FilterOperator.isNull, true),
              QueryFilter('sortProposals', FilterOperator.isEqualTo, {})
            ];
        }
      }

      if (filter is ProductContainerFilters) {
        if (filter != ProductContainerFilters.many) {
          return [QueryFilter('containers', FilterOperator.arrayContains, filter.name)];
        } else {
          return [QueryFilter('containerCount', FilterOperator.isGreaterThan, 1)];
        }
      }

      throw UnsupportedError('${filter.runtimeType} is not supported as a Product filter');
    });
    return nestedFilterList.flattened.toList();
  }

  Future<List<Product>> fetchNext({
    List<dynamic> filters = const [],
    DocumentSnapshot? startAfterDocument,
  }) async {
    final productRepository = ref.read(productRepositoryProvider);
    return productRepository.fetchNext(filters: _mapFilters(filters), startAfterDocument: startAfterDocument);
  }

  Future<List<Product>> search(String value) {
    final productRepository = ref.read(productRepositoryProvider);
    return productRepository.search('searchName', value);
  }

  Future<void> addSortProposal(Product product, SortElements elements) async {
    final productRepository = ref.read(productRepositoryProvider);
    final user = ref.read(authUserProvider)!.id;
    final sortProposalId = productRepository.collection.doc().id;
    final sort = Sort(
      id: sortProposalId,
      user: user,
      elements: elements.values.flattened.toList(),
      voteBalance: 0,
      votes: {},
    );
    final newProduct = product.copyWith(sortProposals: {...product.sortProposals, sortProposalId: sort});
    final updateData = {'sortProposals.$sortProposalId': sort.toJson()};
    await productRepository.update(product.id, updateData, newProduct);
  }

  Future<void> deleteSortProposal(Product product, String sortProposalId) async {
    final productRepository = ref.read(productRepositoryProvider);
    final newProduct = product.copyWith(sortProposals: {...product.sortProposals}..remove(sortProposalId));
    final updateData = {'sortProposals.$sortProposalId': FieldValue.delete()};
    await productRepository.update(product.id, updateData, newProduct);
  }
}
