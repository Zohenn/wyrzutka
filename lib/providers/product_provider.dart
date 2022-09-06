import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product.dart';

enum ProductSortFilters {
  verified,
  unverified,
  noProposals;

  static String get groupKey => 'sort';

  static String get groupName => 'Segregacja';

  String get filterName {
    switch(this) {
      case ProductSortFilters.verified:
        return 'Zweryfikowano';
      case ProductSortFilters.unverified:
        return 'Niezweryfikowano';
      case ProductSortFilters.noProposals:
        return 'Brak propozycji';
    }
  }
}

final _productsCollection = FirebaseFirestore.instance.collection('products').withConverter(
  fromFirestore: Product.fromFirestore,
  toFirestore: Product.toFirestore,
);

Future saveExampleData() async {
  return Future.wait(productsList.map((e) {
    final doc = _productsCollection.doc(e.id);
    return doc.set(e);
  }));
}

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier(): super([]);

  // todo: check for duplicates
  void addProduct(Product product) {
    state = [...state, product];
  }

  void addProducts(Iterable<Product> products) {
    state = [...state, ...products];
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) => ProductsNotifier());

final productsFutureProvider = FutureProvider((ref) async {
  final querySnapshot = await _productsCollection.limit(10).get();
  final products = querySnapshot.docs.map((e) => e.data()).toList();
  ref.read(productsProvider.notifier).addProducts(products);
  return products;
});

final productRepositoryProvider = Provider((ref) => ProductRepository(ref));

class ProductRepository {
  const ProductRepository(this.ref);

  final Ref ref;

  Future<List<Product>> fetchMore(Map<String, dynamic> filters) async {
    Query<Product> query = _productsCollection.limit(10);
    if(filters[ProductSortFilters.groupKey] != null){
      final filter = filters[ProductSortFilters.groupKey] as ProductSortFilters;
      switch(filter){
        case ProductSortFilters.verified:
          query = query.where('sort', isNull: false);
          break;
        case ProductSortFilters.unverified:
          query = query.where('sort', isNull: true).where('sortProposals', isNotEqualTo: []);
          break;
        case ProductSortFilters.noProposals:
          query = query.where('sort', isNull: true).where('sortProposals', isEqualTo: []);
          break;
      }
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((e) => e.data()).toList();
  }
}


