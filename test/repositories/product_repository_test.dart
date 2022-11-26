import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late ProductRepository repository;
  final sortProposalWithoutVotes = Sort(id: '1', user: 'user', elements: [], voteBalance: 0, votes: {});
  getSortProposalWithVotes(bool value) => Sort(
        id: '2',
        user: 'user',
        elements: [],
        voteBalance: value ? 2 : -2,
        votes: {'1': value, '2': value},
      );
  final sortProposalWithVotes = getSortProposalWithVotes(true);
  final product = Product(
    id: '1',
    name: 'name',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    sortProposals: {
      '1': sortProposalWithoutVotes,
      '2': sortProposalWithVotes,
    },
  );
  final user = AppUser(
    id: '1',
    email: 'email',
    name: 'name',
    surname: 'surname',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );

  createContainer() {
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
      ],
    );
  }

  getProductFromDatabase() async => (await repository.getDoc(product.id).get()).data()!;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    createContainer();
    repository = container.read(productRepositoryProvider);
    await repository.getDoc(product.id).set(product);
  });

  tearDown(() {
    container.dispose();
  });

  group('updateVote', () {
    final voteValues = {'positive': true, 'negative': false};

    for (var entry in voteValues.entries) {
      final label = entry.key;
      final value = entry.value;

      group('$label vote', () {
        final sortProposalWithVotes = getSortProposalWithVotes(value);
        final product = Product(
            id: '1',
            name: 'name',
            user: 'user',
            addedDate: FirestoreDateTime.serverTimestamp(),
            sortProposals: {
              '1': sortProposalWithoutVotes,
              '2': sortProposalWithVotes,
            });

        setUp(() async {
          await repository.getDoc(product.id).set(product);
        });

        test('Should add new $label vote', () async {
          final updatedProduct = await repository.updateVote(product, sortProposalWithoutVotes, user, value);

          final newProduct = await getProductFromDatabase();

          for (var product in [updatedProduct, newProduct]) {
            expect(product.sortProposals[sortProposalWithVotes.id], sortProposalWithVotes);
            expect(
              product.sortProposals[sortProposalWithoutVotes.id],
              isA<Sort>()
                  .having(
                      (p0) => p0.voteBalance, 'voteBalance', sortProposalWithoutVotes.voteBalance + (value ? 1 : -1))
                  .having((p0) => p0.votes, 'votes', {user.id: value}),
            );
          }
        });

        test('Should remove $label vote if already has $label vote', () async {
          final updatedProduct = await repository.updateVote(product, sortProposalWithVotes, user, value);

          final newProduct = await getProductFromDatabase();

          for (var product in [updatedProduct, newProduct]) {
            expect(product.sortProposals[sortProposalWithoutVotes.id], sortProposalWithoutVotes);
            expect(
              product.sortProposals[sortProposalWithVotes.id],
              isA<Sort>()
                  .having((p0) => p0.voteBalance, 'voteBalance', sortProposalWithVotes.voteBalance - (value ? 1 : -1))
                  .having((p0) => p0.votes, 'votes', {...sortProposalWithVotes.votes}..remove(user.id)),
            );
          }
        });

        test('Should change $label vote to the opposite one', () async {
          final updatedProduct = await repository.updateVote(product, sortProposalWithVotes, user, !value);

          final newProduct = await getProductFromDatabase();

          for (var product in [updatedProduct, newProduct]) {
            expect(product.sortProposals[sortProposalWithoutVotes.id], sortProposalWithoutVotes);
            expect(
              product.sortProposals[sortProposalWithVotes.id],
              isA<Sort>()
                  .having((p0) => p0.voteBalance, 'voteBalance', sortProposalWithVotes.voteBalance - (value ? 2 : -2))
                  .having((p0) => p0.votes, 'votes', {...sortProposalWithVotes.votes, user.id: !value}),
            );
          }
        });
      });
    }
  });
}
