import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/filter_bottom_sheet.dart';

import '../../utils.dart';

void main() {
  late List<FilterGroup> groups;
  late Filters selectedFilters;
  late Future<Filters?> filterFuture;

  buildWidget(WidgetTester tester) async {
    await tester.pumpWidget(wrapForTesting(Container()));

    final context = getContext(tester);
    filterFuture = showDefaultBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(groups: groups, selectedFilters: selectedFilters),
    );
    await tester.pumpAndSettle();
  }

  toggleFilter(WidgetTester tester, Filter filter) async {
    await scrollToAndTap(tester, find.text(filter.name));
    await tester.pumpAndSettle();
  }

  setUp(() {
    groups = [
      FilterGroup('a', 'Group A', [Filter('AA', 'aa'), Filter('AB', 'ab')]),
      FilterGroup('b', 'Group B', [Filter('BA', 'ba'), Filter('BB', 'bb')]),
    ];
    selectedFilters = {};
  });

  testWidgets('Should show each group and filter', (tester) async {
    await buildWidget(tester);

    for (var group in groups) {
      expect(find.text(group.name), findsOneWidget);
      for (var filter in group.filters) {
        expect(find.text(filter.name), findsOneWidget);
      }
    }
  });

  testWidgets('Should select filter on tap', (tester) async {
    await buildWidget(tester);

    final filter = groups.first.filters.first;
    await toggleFilter(tester, filter);

    expect(
      tester.getSemantics(find.text(filter.name)),
      matchesSemantics(isSelected: true, isFocusable: true, hasTapAction: true),
    );
  });

  testWidgets('Should deselect filter on tap', (tester) async {
    await buildWidget(tester);

    final filter = groups.first.filters.first;
    await toggleFilter(tester, filter);
    await toggleFilter(tester, filter);

    expect(
      tester.getSemantics(find.text(filter.name)),
      matchesSemantics(isSelected: false, isFocusable: true, hasTapAction: true),
    );
  });

  testWidgets('Should select initially selected filters', (tester) async {
    final selectedFilter = groups.first.filters.first;
    selectedFilters = {groups.first.key: selectedFilter.value};
    await buildWidget(tester);

    expect(
      tester.getSemantics(find.text(selectedFilter.name)),
      matchesSemantics(isSelected: true, isFocusable: true, hasTapAction: true),
    );
  });

  testWidgets('Should return empty filters on clear tap', (tester) async {
    await buildWidget(tester);

    await scrollToAndTap(tester, find.text('Wyczyść'));
    await tester.pumpAndSettle();

    expect(await filterFuture, {});
  });

  testWidgets('Should return selected filters on accept tap', (tester) async {
    await buildWidget(tester);

    final filter = groups.first.filters.first;
    await toggleFilter(tester, filter);
    await scrollToAndTap(tester, find.text('Zastosuj'));
    await tester.pumpAndSettle();

    expect(await filterFuture, {groups.first.key: filter.value});
  });
}
