import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product/sort.dart';
import 'package:wyrzutka/models/product/sort_element.dart';
import 'package:wyrzutka/providers/firebase_provider.dart';
import 'package:wyrzutka/repositories/product_repository.dart';

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
  final sortProposalWithHighBalance = Sort(
    id: '3',
    user: 'user',
    elements: [SortElement(container: ElementContainer.plastic, name: 'name')],
    voteBalance: 49,
    votes: {
      for (var i = 2; i < 51; i++) '$i': true,
    },
  );
  final product = Product(
    id: '1',
    name: 'name',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
    sortProposals: {
      '1': sortProposalWithoutVotes,
      '2': sortProposalWithVotes,
      '3': sortProposalWithHighBalance,
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

    test('Should mark sort as verified if balance reaches 50', () async {
      final updatedProduct = await repository.updateVote(product, sortProposalWithHighBalance, user, true);

      final newProduct = await getProductFromDatabase();

      for (var product in [updatedProduct, newProduct]) {
        expect(product.sortProposals, {});
        expect(
          product.sort,
          isA<Sort>()
              .having((p0) => p0.user, 'user', sortProposalWithHighBalance.user)
              .having((p0) => p0.elements, 'elements', sortProposalWithHighBalance.elements),
        );
      }
    });
  });
}
