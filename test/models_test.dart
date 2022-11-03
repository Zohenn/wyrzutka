import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/models/product/sort_element_template.dart';
import 'package:inzynierka/models/product_symbol/product_symbol.dart';
import 'package:inzynierka/models/firestore_date_time.dart';

void main() {
  var firestore = FakeFirebaseFirestore();

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('AppUser', () {
    final user = AppUser(
      id: 'id',
      email: 'email',
      name: 'name',
      surname: 'surname',
      role: Role.user,
      signUpDate: FirestoreDateTime.serverTimestamp(),
    );

    test('Should set id from snapshot', () async {
      final doc = firestore
          .collection('users')
          .withConverter(fromFirestore: AppUser.fromFirestore, toFirestore: AppUser.toFirestore)
          .doc();
      await doc.set(user);

      final _user = (await doc.get()).data()!;

      expect(_user.id, equals(doc.id));
    });

    test('Should not have id field in output json', () {
      expect(AppUser.toFirestore(user, null), isNot(contains('id')));
    });
  });

  group('Product', () {
    final product = Product(
      id: 'id',
      name: 'name',
      user: 'user',
      sort: Sort(
        id: 'id',
        user: 'user',
        elements: [SortElement(container: ElementContainer.plastic, name: 'name')],
        voteBalance: 0,
        votes: [],
      ),
      addedDate: FirestoreDateTime.serverTimestamp(),
    );

    test('Should set id from snapshot', () async {
      final doc = firestore
          .collection('products')
          .withConverter(fromFirestore: Product.fromFirestore, toFirestore: Product.toFirestore)
          .doc();
      await doc.set(product);

      final _product = (await doc.get()).data()!;

      expect(_product.id, equals(doc.id));
    });

    test('Should have containers field in output json', () {
      final json = Product.toFirestore(product, null);
      expect(json, contains('containers'));
      expect(json['containers'], equals(product.containers));
    });

    test('Should have searchName field in output json', () {
      final json = Product.toFirestore(product, null);
      expect(json, contains('searchName'));
      expect(json['searchName'], equals(product.name.toLowerCase()));
    });

    test('Should not have id field in output json', () {
      expect(Product.toFirestore(product, null), isNot(contains('id')));
    });
  });

  group('ProductSymbol', () {
    final symbol = ProductSymbol(id: 'id', name: 'name', photo: 'photo');

    test('Should set id from snapshot', () async {
      final doc = firestore
          .collection('symbols')
          .withConverter(fromFirestore: ProductSymbol.fromFirestore, toFirestore: ProductSymbol.toFirestore)
          .doc();
      await doc.set(symbol);

      final _symbol = (await doc.get()).data()!;

      expect(_symbol.id, equals(doc.id));
    });

    test('Should not have id field in output json', () {
      expect(ProductSymbol.toFirestore(symbol, null), isNot(contains('id')));
    });
  });

  group('SortElementTemplate', () {
    final sortElementTemplate = SortElementTemplate(id: 'id', container: ElementContainer.plastic, name: 'name');

    test('Should set id from snapshot', () async {
      final doc = firestore
          .collection('sortElementTemplates')
          .withConverter(fromFirestore: SortElementTemplate.fromFirestore, toFirestore: SortElementTemplate.toFirestore)
          .doc();
      await doc.set(sortElementTemplate);

      final _sortElementTemplate = (await doc.get()).data()!;

      expect(_sortElementTemplate.id, equals(doc.id));
    });

    test('Should not have id field in output json', () {
      expect(SortElementTemplate.toFirestore(sortElementTemplate, null), isNot(contains('id')));
    });
  });
}
