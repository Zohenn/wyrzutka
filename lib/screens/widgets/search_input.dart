import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wyrzutka/hooks/debounce.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/custom_color_selection_handle.dart';

class SearchInput extends HookWidget {
  const SearchInput({
    Key? key,
    required this.onSearch,
    this.readOnly = false,
    this.hintText = 'Wyszukaj',
    this.trailingBuilder,
  }) : super(key: key);

  final void Function(String) onSearch;
  final bool readOnly;
  final String hintText;
  final Widget Function(BuildContext)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchText = useState('');
    final debounce = useDebounceHook<String>(onEmit: (value) => onSearch(value));

    return TextField(
      readOnly: readOnly,
      controller: searchController,
      cursorColor: Colors.black,
      onChanged: (value) {
        debounce.onChanged(value);
        searchText.value = value;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).hintColor),
        // fillColor: Theme.of(context).primaryColorLight,
        fillColor: !readOnly ? Theme.of(context).primaryColorLight : Theme.of(context).dividerColor,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder!.copyWith(
              borderSide: BorderSide.none,
            ),
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder!.copyWith(
              borderSide: BorderSide.none,
            ),
        prefixIcon: const Icon(Icons.search, color: Colors.black),
        suffixIcon: ConditionalBuilder(
          condition: searchText.value.isEmpty,
          ifTrue: () => trailingBuilder?.call(context) ?? const SizedBox.shrink(),
          ifFalse: () => IconButton(
            key: const Key('close_search'),
            onPressed: () {
              debounce.cancel();
              searchText.value = '';
              searchController.text = '';
              onSearch('');
              FocusManager.instance.primaryFocus?.unfocus();
            },
            icon: const Icon(Icons.close),
          ),
        ),
      ),
      selectionControls: CustomColorSelectionHandle(Colors.black),
    );
  }
}
