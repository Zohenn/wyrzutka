import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/models/sort.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/models/vote.dart';

enum ProductSortFilters {
  verified,
  unverified,
  noProposals;

  static String get groupKey => 'sort';

  static String get groupName => 'Segregacja';

  String get filterName {
    switch (this) {
      case ProductSortFilters.verified:
        return 'Zweryfikowano';
      case ProductSortFilters.unverified:
        return 'Niezweryfikowano';
      case ProductSortFilters.noProposals:
        return 'Brak propozycji';
    }
  }
}

enum ProductContainerFilters {
  plastic,
  paper,
  bio,
  mixed,
  glass,
  many;

  static String get groupKey => 'containers';

  static String get groupName => 'Pojemniki';

  String get filterName {
    switch (this) {
      case ProductContainerFilters.plastic:
        return ElementContainer.plastic.containerName;
      case ProductContainerFilters.paper:
        return ElementContainer.paper.containerName;
      case ProductContainerFilters.bio:
        return ElementContainer.bio.containerName;
      case ProductContainerFilters.mixed:
        return ElementContainer.mixed.containerName;
      case ProductContainerFilters.glass:
        return ElementContainer.glass.containerName;
      case ProductContainerFilters.many:
        return 'Wiele pojemników';
    }
  }
}

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

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]);

  // todo: check for duplicates
  void addProduct(Product product) {
    state = [...state, product];
  }

  void addProducts(Iterable<Product> products) {
    state = [...state, ...products];
  }

  void assignProducts(Iterable<Product> products) {
    state = [...products];
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) => ProductsNotifier());

final productsFutureProvider = FutureProvider((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final products = await repository.fetchMore();
  ref.read(productsProvider.notifier).addProducts(products);
  return products;
});

class CacheNotifier<K, V> extends StateNotifier<Map<K, V>> {
  CacheNotifier() : super({});

  void add(K key, V value) {
    state = {
      ...state,
      key: value,
    };
  }

  void clear() {
    state = {};
  }

  V? operator [](K key) {
    return state[key];
  }

  void operator []=(K key, V value) {
    add(key, value);
  }
}

typedef ProductCache = CacheNotifier<String, Product>;

final _productCacheProvider =
    StateNotifierProvider<ProductCache, Map<String, Product>>((ref) => CacheNotifier<String, Product>());

final productProvider = Provider.family<Product?, String>((ref, id) {
  final cache = ref.watch(_productCacheProvider);
  return cache[id];
});

final productRepositoryProvider = Provider((ref) => ProductRepository(ref));

class ProductRepository {
  ProductRepository(this.ref);

  final Ref ref;

  ProductCache get _cache => ref.read(_productCacheProvider.notifier);

  static const int batchSize = 10;

  Future<Product?> fetchId(String id, [bool skipCache = false]) async {
    if (!skipCache && _cache[id] != null) {
      return _cache[id];
    }
    final snapshot = await _productsCollection.doc(id).get();
    final product = snapshot.data();
    _addToCache(product);
    return product;
  }

  Future<List<Product>> fetchIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final querySnapshot = await _productsCollection.where(FieldPath.documentId, whereIn: ids).get();
    return _mapDocs(querySnapshot);
  }

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
    return _mapDocs(querySnapshot, startAfterDocument == null);
  }

  Future<List<Product>> search(String value) async {
    value = value.toLowerCase();
    final querySnapshot =
        await _productsCollection.orderBy('searchName').startAt([value]).endAt(['$value\uf8ff']).limit(5).get();
    return _mapDocs(querySnapshot);
  }

  // todo: mark as verified if voteBalance > 0
  Future<Product> updateVote(Product product, Sort sort, AppUser user, bool value) async {
    // if(sort.votes)
    final vote = Vote(user: user.id, value: value);
    final remove = sort.votes.any((element) => element.user == user.id && element.value == value);
    final productDoc = _productsCollection.doc(product.id);

    final newVotes = await FirebaseFirestore.instance.runTransaction((transaction) async {
      final _product = (await productDoc.get()).data()!;
      final _sort = _product.sortProposals[sort.id]!;
      final previousVote = _sort.votes.firstWhereOrNull((vote) => vote.user == user.id);
      List<Vote> newVotes;
      if (previousVote == null) {
        newVotes = [..._sort.votes, vote];
        // transaction.update(productDoc, {
        //   'sortProposals': {
        //     sort.id: {
        //       'votes': FieldValue.arrayUnion([vote]),
        //     }
        //   }
        // });
      } else if (previousVote.value == value) {
        newVotes = [..._sort.votes]..remove(previousVote);
        // transaction.update(productDoc, {
        //   'sortProposals': {
        //     sort.id: {
        //       'votes': FieldValue.arrayRemove([vote]),
        //     }
        //   }
        // });
      } else {
        newVotes = [..._sort.votes, vote]..remove(previousVote);
      }
      transaction.update(
        productDoc,
        {
          'sortProposals.${sort.id}.votes': newVotes.map((e) => Vote.toFirestore(e)).toList(),
        },
      );
      return newVotes;
    });

    final newProduct = product.copyWith(
      sortProposals: {
        ...product.sortProposals,
        sort.id:
            Sort(id: sort.id, user: sort.user, elements: sort.elements, voteBalance: sort.voteBalance, votes: newVotes),
      },
    );
    _addToCache(newProduct);

    return newProduct;

    // await _productsCollection.doc(product.id).update({
    //   'sortProposals': {
    //     sort.id: {
    //       'votes': remove ? FieldValue.arrayRemove([vote]) : FieldValue.arrayUnion([vote]),
    //     }
    //   },
    // });
    // if (remove) {
    //   sort.votes.removeWhere((element) => element.user == user.id);
    // } else {
    //   sort.votes.add(vote);
    // }
  }

  List<Product> _mapDocs(QuerySnapshot<Product> querySnapshot, [bool clearCache = false]) {
    if (clearCache) {
      _cache.clear();
    }

    return querySnapshot.docs.map((snapshot) {
      final data = snapshot.data();
      _addToCache(data);
      return data;
    }).toList();
  }

  void _addToCache(Product? product) {
    if (product != null) {
      _cache[product.id] = product;
    }
  }
}
