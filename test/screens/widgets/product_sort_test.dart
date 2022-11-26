import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/firestore_date_time.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/product_repository.dart';
import 'package:inzynierka/screens/widgets/product_sort.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils.dart';
import 'product_sort_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductRepository>()])
void main() {
  var baseProduct = Product(
    id: '1',
    name: 'Product name',
    user: 'user',
    addedDate: FirestoreDateTime.serverTimestamp(),
  );
  var verifiedProduct = baseProduct.copyWith(
    sort: Sort.verified(
      user: 'user',
      elements: [
        SortElement(container: ElementContainer.plastic, name: 'Plastic name', description: 'Plastic description'),
        SortElement(container: ElementContainer.plastic, name: 'Plastic name2', description: 'Plastic description2'),
        SortElement(container: ElementContainer.paper, name: 'Paper name', description: 'Paper description'),
      ],
    ),
  );
  var productWithProposalByUser = baseProduct.copyWith(sortProposals: {
    '1': Sort(
      id: '1',
      user: 'user',
      elements: [SortElement(container: ElementContainer.plastic, name: 'Proposal 1')],
      voteBalance: 0,
      votes: {},
    ),
  });
  var productWithProposals = baseProduct.copyWith(
    sortProposals: {
      'sort1': Sort(
        id: 'sort1',
        user: 'user1',
        elements: [SortElement(container: ElementContainer.plastic, name: 'Proposal 1')],
        voteBalance: 0,
        votes: {},
      ),
      'sort2': Sort(
        id: 'sort2',
        user: 'user2',
        elements: [SortElement(container: ElementContainer.paper, name: 'Proposal 2')],
        voteBalance: 0,
        votes: {},
      ),
    },
  );
  var productWithManyProposals = baseProduct.copyWith(
    sortProposals: {
      for (var e in List.generate(
        5,
        (index) => Sort(
          id: 'sort$index',
          user: 'user$index',
          elements: [
            SortElement(
                container: index % 2 == 0 ? ElementContainer.plastic : ElementContainer.paper, name: 'Proposal $index')
          ],
          voteBalance: 0,
          votes: {},
        ),
      ))
        e.id: e
    },
  );
  var product = baseProduct;
  AppUser user = AppUser(
    id: 'user',
    email: 'email',
    name: 'name',
    surname: 'surname',
    role: Role.user,
    signUpDate: FirestoreDateTime.serverTimestamp(),
  );
  AppUser? authUser;
  late MockProductRepository mockProductRepository;

  final proposalButtonFinder = find.text('Dodaj swoją propozycję');
  final goodProposalButtonFinder = find.byTooltip('Dobra propozycja segregacji');
  final badProposalButtonFinder = find.byTooltip('Słaba propozycja segregacji');

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTesting(
        SingleChildScrollView(child: ProductSort(product: product)),
        overrides: [
          authUserProvider.overrideWith((ref) => authUser),
          productRepositoryProvider.overrideWithValue(mockProductRepository),
        ],
      ),
    );
  }

  setUp(() {
    product = baseProduct;
    authUser = user;
    mockProductRepository = MockProductRepository();
  });

  testWidgets('Should not show proposal button if user is not logged in', (tester) async {
    authUser = null;
    await buildWidget(tester);

    expect(proposalButtonFinder, findsNothing);
  });

  testWidgets('Should not show proposal button if product has 5 proposals or more', (tester) async {
    product = productWithManyProposals;
    await buildWidget(tester);

    expect(proposalButtonFinder, findsNothing);
  });

  testWidgets('Should not show proposal button if product has logged in user\'s proposal', (tester) async {
    product = productWithProposalByUser;
    await buildWidget(tester);

    expect(proposalButtonFinder, findsNothing);
  });

  testWidgets('Should not show proposal button if product has verified sort proposal', (tester) async {
    product = verifiedProduct;
    await buildWidget(tester);

    expect(proposalButtonFinder, findsNothing);
  });

  testWidgets('Should show proposal button if product has less then 5 proposals', (tester) async {
    product = productWithProposals;
    await buildWidget(tester);

    expect(proposalButtonFinder, findsOneWidget);
  });

  testWidgets('Should show proposal button if product has no proposals', (tester) async {
    await buildWidget(tester);

    expect(proposalButtonFinder, findsOneWidget);
  });

  testWidgets('Should open sort proposal form on tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, proposalButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Dodaj propozycję'), findsOneWidget);
  });

  group('verified sort', () {
    setUp(() {
      product = verifiedProduct;
    });

    testWidgets('Should show verified sort', (tester) async {
      await buildWidget(tester);

      for (var element in product.sort!.elements) {
        expect(find.text(element.container.containerName), findsOneWidget);
        expect(find.text(element.name), findsOneWidget);
        expect(find.text(element.description!), findsOneWidget);
      }
    });

    testWidgets('Should not show vote buttons', (tester) async {
      await buildWidget(tester);

      expect(goodProposalButtonFinder, findsNothing);
      expect(badProposalButtonFinder, findsNothing);
    });

    testWidgets('Should not open sort proposal delete dialog on long press', (tester) async {
      authUser = user.copyWith(role: Role.mod);
      await buildWidget(tester);

      await tester.longPress(find.text(product.sort!.elements.first.name));
      await tester.pumpAndSettle();

      expect(find.text('Usuń propozycję'), findsNothing);
    });
  });

  group('sort proposals', () {
    setUp(() {
      product = productWithProposals;
    });

    testWidgets('Should not show vote buttons if user has sort proposal', (tester) async {
      product = productWithProposalByUser;
      await buildWidget(tester);

      expect(goodProposalButtonFinder, findsNothing);
      expect(badProposalButtonFinder, findsNothing);
    });

    testWidgets('Should not update vote if user is not logged in', (tester) async {
      authUser = null;
      await buildWidget(tester);

      await scrollToAndTap(tester, goodProposalButtonFinder.first);
      await tester.pumpAndSettle();

      verifyNever(mockProductRepository.updateVote(any, any, any, any));
    });

    testWidgets('Should update vote on good proposal tap', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, goodProposalButtonFinder.first);
      await tester.pumpAndSettle();

      verify(mockProductRepository.updateVote(product, product.sortProposals.values.first, authUser, true));
    });

    testWidgets('Should update vote on bad proposal tap', (tester) async {
      await buildWidget(tester);

      await scrollToAndTap(tester, badProposalButtonFinder.first);
      await tester.pumpAndSettle();

      verify(mockProductRepository.updateVote(product, product.sortProposals.values.first, authUser, false));
    });
    
    testWidgets('Should not open sort proposal delete dialog if user is not logged in', (tester) async {
      authUser = null;
      await buildWidget(tester);

      await tester.longPress(find.text(product.sortProposals.values.first.elements.first.name));
      await tester.pumpAndSettle();

      expect(find.text('Usuń propozycję'), findsNothing);
    });

    testWidgets('Should not open sort proposal delete dialog if user is regular user', (tester) async {
      await buildWidget(tester);

      await tester.longPress(find.text(product.sortProposals.values.first.elements.first.name));
      await tester.pumpAndSettle();

      expect(find.text('Usuń propozycję'), findsNothing);
    });

    for(var role in [Role.mod, Role.admin]){
      testWidgets('Should open sort proposal delete dialog if user is ${role.name}', (tester) async {
        authUser = authUser!.copyWith(role: role);
        await buildWidget(tester);

        await tester.longPress(find.text(product.sortProposals.values.first.elements.first.name));
        await tester.pumpAndSettle();

        expect(find.text('Usuń propozycję'), findsOneWidget);
        expect(find.textContaining(product.sortProposals.values.first.id), findsNWidgets(2));
      });
    }
  });
}
