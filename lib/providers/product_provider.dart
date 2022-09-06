import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/models/product.dart';

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

  // Future<List<Product>> fetchMore() async {
  //
  // }
}


