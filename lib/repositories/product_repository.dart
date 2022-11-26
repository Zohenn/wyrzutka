import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/repositories/base_repository.dart';
import 'package:inzynierka/providers/cache_notifier.dart';
import 'package:inzynierka/providers/firebase_provider.dart';

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

class UpdateVoteDto {
  UpdateVoteDto(this.votes, this.balance);

  Map<String, bool> votes;
  int balance;
}

class ProductRepository extends BaseRepository<Product> {
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

  // todo: mark as verified if voteBalance >= 50
  Future<Product> updateVote(Product product, Sort sort, AppUser user, bool value) async {
    final productDoc = collection.doc(product.id);

    final transactionData = await firestore.runTransaction<UpdateVoteDto>((transaction) async {
      final _product = (await productDoc.get()).data()!;
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
        newVotes = {..._sort.votes, user.id: value};
        updateData[fullVotePath] = value;
      }
      final newBalance = newVotes.values.fold<int>(0, (previousValue, element) => previousValue + (element ? 1 : -1));
      updateData['$sortProposalPath.voteBalance'] = newBalance;
      transaction.update(
        productDoc,
        updateData,
      );
      return UpdateVoteDto(newVotes, newBalance);
    });

    final newProduct = product.copyWith(
      sortProposals: {
        ...product.sortProposals,
        sort.id: sort.copyWith(voteBalance: transactionData.balance, votes: {...transactionData.votes}),
      },
    );
    addToCache(newProduct.id, newProduct);

    return newProduct;
  }
}
