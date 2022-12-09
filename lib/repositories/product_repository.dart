import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/data/static_data.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product/sort.dart';
import 'package:wyrzutka/repositories/repository.dart';
import 'package:wyrzutka/providers/cache_notifier.dart';
import 'package:wyrzutka/providers/firebase_provider.dart';

Future saveExampleProductData(WidgetRef ref) async {
  return Future.wait(productsList.map((e) {
    final doc = ref.read(productRepositoryProvider).collection.doc(e.id);
    return doc.set(e);
  }));
}

final productsFutureProvider = Provider((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final products = await repository.fetchNext();
  return products;
});

final _productCacheProvider = createCacheProvider<Product>();

final productProvider = createCacheItemProvider(_productCacheProvider);
final productsProvider = createCacheItemsProvider(_productCacheProvider);

final productRepositoryProvider = Provider((ref) => ProductRepository(ref));

class ProductAlreadyVerifiedException implements Exception {}

class ProductRepository extends Repository<Product> {
  ProductRepository(this.ref);

  @override
  final Ref ref;

  @override
  CacheNotifier<Product> get cache => ref.read(_productCacheProvider.notifier);

  FirebaseFirestore get firestore => ref.read(firebaseFirestoreProvider);

  @override
  late final CollectionReference<Product> collection = firestore.collection('products').withConverter(
        fromFirestore: Product.fromFirestore,
        toFirestore: Product.toFirestore,
      );

  Future<Product> updateVote(Product product, Sort sort, AppUser user, bool value) async {
    final productDoc = collection.doc(product.id);

    final newProduct = await firestore.runTransaction<Product>((transaction) async {
      final _product = (await productDoc.get()).data()!;
      if(_product.sort != null){
        throw ProductAlreadyVerifiedException();
      }

      final _sort = _product.sortProposals[sort.id]!;
      final previousVote = _sort.votes[user.id];

      final sortProposalPath = 'sortProposals.${sort.id}';
      final fullVotePath = '$sortProposalPath.votes.${user.id}';

      Map<String, bool> newVotes;
      Map<String, dynamic> updateData = {};
      if (previousVote == value) {
        // vote cancellation
        updateData[fullVotePath] = FieldValue.delete();
        newVotes = {..._sort.votes}..remove(user.id);
      } else {
        updateData[fullVotePath] = value;
        newVotes = {..._sort.votes, user.id: value};
      }

      final newBalance = newVotes.values.fold<int>(0, (previousValue, element) => previousValue + (element ? 1 : -1));

      if (newBalance >= 50) {
        final verifiedSort = Sort.verified(user: sort.user, elements: sort.elements.map((e) => e.copyWith()).toList());
        transaction.update(
          productDoc,
          {
            'sort': verifiedSort.toJson(),
            'sortProposals': FieldValue.delete(),
          },
        );
        return _product.copyWith(sort: verifiedSort, sortProposals: {});
      }

      updateData['$sortProposalPath.voteBalance'] = newBalance;
      transaction.update(
        productDoc,
        updateData,
      );
      return _product.copyWith(
        sortProposals: {
          ..._product.sortProposals,
          sort.id: sort.copyWith(voteBalance: newBalance, votes: {...newVotes}),
        },
      );
    });

    addToCache(newProduct.id, newProduct);

    return newProduct;
  }
}
