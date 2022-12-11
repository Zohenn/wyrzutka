import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/models/product/sort.dart';
import 'package:wyrzutka/models/product/sort_element.dart';
import 'package:wyrzutka/models/product/sort_element_template.dart';
import 'package:wyrzutka/models/product_symbol/product_symbol.dart';
import 'package:wyrzutka/models/firestore_date_time.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('Entities', () {
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

      test('Should not include id field in serialized data', () {
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
          votes: {},
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

      test('Should have containers field in serialized data', () {
        final json = Product.toFirestore(product, null);
        expect(json, contains('containers'));
        expect(json['containers'], equals(product.containers));
      });

      test('Should have searchName field in serialized data', () {
        final json = Product.toFirestore(product, null);
        expect(json, contains('searchName'));
        expect(json['searchName'], equals(product.name.toLowerCase()));
      });

      test('Should not have id field in serialized data', () {
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

      test('Should not have id field in serialized data', () {
        expect(ProductSymbol.toFirestore(symbol, null), isNot(contains('id')));
      });
    });

    group('SortElementTemplate', () {
      final sortElementTemplate = SortElementTemplate(id: 'id', container: ElementContainer.plastic, name: 'name');

      test('Should set id from snapshot', () async {
        final doc = firestore
            .collection('sortElementTemplates')
            .withConverter(
                fromFirestore: SortElementTemplate.fromFirestore, toFirestore: SortElementTemplate.toFirestore)
            .doc();
        await doc.set(sortElementTemplate);

        final _sortElementTemplate = (await doc.get()).data()!;

        expect(_sortElementTemplate.id, equals(doc.id));
      });

      test('Should not have id field in serialized data', () {
        expect(SortElementTemplate.toFirestore(sortElementTemplate, null), isNot(contains('id')));
      });
    });
  });

  group('FirestoreDateTime', () {
    test('Should return FieldValue.serverTimestamp on serialization with serverTimestamp variant', () {
      final date = FirestoreDateTime.serverTimestamp();
      expect(FirestoreDateTime.toFirestore(date), isA<FieldValue>());
    });

    test('Should return Timestamp on serialization with dateTime variant', () {
      final baseDate = DateTime(2022, 11, 3);
      final date = FirestoreDateTime.fromDateTime(baseDate);
      expect(FirestoreDateTime.toFirestore(date), equals(Timestamp.fromDate(baseDate)));
    });
  });
}
