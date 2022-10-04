import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/product_filters.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/vote.dart';
import 'package:inzynierka/providers/cache_notifier.dart';

final _productsCollection = FirebaseFirestore.instance.collection('products').withConverter(
      fromFirestore: Product.fromFirestore,
      toFirestore: Product.toFirestore,
    );

Future saveExampleProductData() async {
  return Future.wait(productsList.map((e) {
    final doc = _productsCollection.doc(e.id);
    return doc.set(e);
  }));
}

final productsListProvider = StateProvider<List<Product>>((ref) => <Product>[]);

final productsFutureProvider = Provider((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final products = await repository.fetchMore();
  ref.read(productsListProvider.notifier).state = products;
  return products;
});

final _productCacheProvider = createCacheProvider<Product>();

final productProvider = createCacheItemProvider(_productCacheProvider);
final productsProvider = createCacheItemsProvider(_productCacheProvider);

final productRepositoryProvider = Provider((ref) => ProductRepository(ref));

class ProductRepository with CacheNotifierMixin<Product> {
  ProductRepository(this.ref);

  @override
  final Ref ref;

  @override
  CacheNotifier<Product> get cache => ref.read(_productCacheProvider.notifier);

  @override
  CollectionReference<Product> get collection => _productsCollection;

  static const int batchSize = 10;

  Future<List<Product>> fetchMore({
    Map<String, dynamic> filters = const {},
    DocumentSnapshot? startAfterDocument,
  }) async {
    Query<Product> query = _productsCollection.limit(batchSize);
    if (filters[ProductSortFilters.groupKey] != null) {
      final filter = filters[ProductSortFilters.groupKey] as ProductSortFilters;
      switch (filter) {
        case ProductSortFilters.verified:
          query = query.where('sort', isNull: false).orderBy('sort').orderBy(FieldPath.documentId);
          break;
        case ProductSortFilters.unverified:
          query = query
              .where('sort', isNull: true)
              .where('sortProposals', isNotEqualTo: [])
              .orderBy('sortProposals')
              .orderBy(FieldPath.documentId);
          break;
        case ProductSortFilters.noProposals:
          query = query.where('sort', isNull: true).where('sortProposals', isEqualTo: []).orderBy(FieldPath.documentId);
          break;
      }
    }

    if (filters[ProductContainerFilters.groupKey] != null) {
      final filter = filters[ProductContainerFilters.groupKey] as ProductContainerFilters;
      if (filter != ProductContainerFilters.many) {
        query = query.where('containers', arrayContains: filter.name);
      } else {
        query = query.where('containerCount', isGreaterThan: 1);
      }
    }

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    final querySnapshot = await query.get();
    return mapDocs(querySnapshot, startAfterDocument == null);
  }

  Future<List<Product>> search(String value) async {
    value = value.toLowerCase();
    final querySnapshot =
        await _productsCollection.orderBy('searchName').startAt([value]).endAt(['$value\uf8ff']).limit(5).get();
    return mapDocs(querySnapshot);
  }

  // todo: mark as verified if voteBalance >= 50
  Future<Product> updateVote(Product product, Sort sort, AppUser user, bool value) async {
    final vote = Vote(user: user.id, value: value);
    final productDoc = _productsCollection.doc(product.id);

    final transactionData = await FirebaseFirestore.instance.runTransaction<Map<String, dynamic>>((transaction) async {
      final _product = (await productDoc.get()).data()!;
      final _sort = _product.sortProposals[sort.id]!;
      final previousVote = _sort.votes.firstWhereOrNull((vote) => vote.user == user.id);
      List<Vote> newVotes;
      if (previousVote == null) {
        newVotes = [..._sort.votes, vote];
      } else if (previousVote.value == value) {
        newVotes = [..._sort.votes]..remove(previousVote);
      } else {
        newVotes = [..._sort.votes, vote]..remove(previousVote);
      }
      final newBalance = newVotes.fold<int>(0, (previousValue, element) => previousValue + (element.value ? 1 : -1));
      transaction.update(
        productDoc,
        {
          'sortProposals.${sort.id}.votes': newVotes.map((e) => e.toJson()).toList(),
          'sortProposals.${sort.id}.voteBalance': newBalance,
        },
      );
      return {
        'votes': newVotes,
        'balance': newBalance,
      };
    });

    final newProduct = product.copyWith(
      sortProposals: {
        ...product.sortProposals,
        sort.id: sort.copyWith(voteBalance: transactionData['balance'], votes: transactionData['votes']),
      },
    );
    addToCache(newProduct.id, newProduct);

    return newProduct;
  }
}
