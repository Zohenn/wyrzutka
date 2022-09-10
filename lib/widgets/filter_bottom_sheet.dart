import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

typedef Filters = Map<String, dynamic>;

class FilterGroup<T> {
  const FilterGroup(this.key, this.name, this.filters);

  final String key;
  final String name;
  final List<Filter<T>> filters;
}

class Filter<T> {
  const Filter(this.name, this.value);

  final String name;
  final T value;
}

class FilterBottomSheet extends HookWidget {
  const FilterBottomSheet({
    Key? key,
    required this.groups,
    required this.selectedFilters,
  }) : super(key: key);

  final List<FilterGroup> groups;
  final Filters selectedFilters;

  @override
  Widget build(BuildContext context) {
    final localFilters = useState(selectedFilters);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).primaryColorLight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 16.0),
              Text(
                'Wybierz filtry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GutterColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var group in groups)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Wrap(
                      runSpacing: 8.0,
                      spacing: 8.0,
                      children: [
                        for (var filter in group.filters)
                          CustomFilterChip(
                            filter: filter,
                            selected: localFilters.value[group.key] == filter.value,
                            onSelected: () {
                              final newFilters = {
                                ...localFilters.value,
                                group.key: filter.value,
                              };

                              if (localFilters.value[group.key] == filter.value) {
                                newFilters.remove(group.key);
                              }

                              localFilters.value = newFilters;
                            },
                          ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).primaryColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(<String, dynamic>{}),
                style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
                      backgroundColor: const MaterialStatePropertyAll(Colors.white),
                      side: MaterialStatePropertyAll(
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                child: const Text('Wyczyść'),
              ),
              const SizedBox(width: 8.0),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(localFilters.value),
                child: const Text('Zastosuj'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  const CustomFilterChip({
    Key? key,
    required this.filter,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  final Filter filter;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(filter.name),
          ),
        ),
      ),
    );
  }
}
