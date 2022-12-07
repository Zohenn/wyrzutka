import 'package:flutter_test/flutter_test.dart';
import 'package:wyrzutka/models/product/product_filters.dart';
import 'package:wyrzutka/repositories/query_filter.dart';

void main() {
  group('ProductSortFilters', () {
    test('Should correctly map verified to query filters', () {
      expect(ProductSortFilters.verified.toQueryFilters(), [QueryFilter('sort', FilterOperator.isNull, false)]);
    });

    test('Should correctly map unverified to query filters', () {
      expect(
        ProductSortFilters.unverified.toQueryFilters(),
        [
          QueryFilter('sort', FilterOperator.isNull, true),
          QueryFilter('sortProposals', FilterOperator.isNotEqualTo, {})
        ],
      );
    });

    test('Should correctly map noProposals to query filters', () {
      expect(
        ProductSortFilters.noProposals.toQueryFilters(),
        [QueryFilter('sort', FilterOperator.isNull, true), QueryFilter('sortProposals', FilterOperator.isEqualTo, {})],
      );
    });
  });

  group('ProductContainerFilters', () {
    for (var filter in ProductContainerFilters.values.where((element) => element != ProductContainerFilters.many)) {
      test('Should correctly map ${filter.name} to queryFilters', () {
        expect(filter.toQueryFilters(), [QueryFilter('containers', FilterOperator.arrayContains, filter.name)]);
      });
    }

    test('Should correctly map many to query filters', () {
      expect(
        ProductContainerFilters.many.toQueryFilters(),
        [QueryFilter('containerCount', FilterOperator.isGreaterThan, 1)],
      );
    });
  });
}
