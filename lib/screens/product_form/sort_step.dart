import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/utils/deep_copy.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/gutter_row.dart';

typedef _Elements = Map<ElementContainer, List<SortElement>>;

class SortStep extends HookWidget {
  const SortStep({
    Key? key,
    required this.model,
    required this.onElementsChanged,
    required this.onSubmitPressed,
  }) : super(key: key);

  final ProductFormModel model;
  final void Function(_Elements) onElementsChanged;
  final VoidCallback onSubmitPressed;

  _Elements get elements => model.elements;

  Iterable<ElementContainer> get selectedContainers => elements.keys;

  void toggleContainer(ElementContainer container) {
    final elementsCopy = deepCopy(elements);
    if (!selectedContainers.contains(container)) {
      elementsCopy[container] = [];
    } else {
      elementsCopy.remove(container);
    }
    onElementsChanged(elementsCopy);
  }

  void addElement(ElementContainer container, _ElementModel element) {
    final elementsCopy = deepCopy(elements);
    elementsCopy[container] ??= [];
    elementsCopy[container]!.add(
      SortElement(
        container: container,
        name: element.name,
        description: element.desc.isEmpty ? null : element.desc,
      ),
    );
    onElementsChanged(elementsCopy);
  }

  void deleteElement(ElementContainer container, SortElement element) {
    final elementsCopy = deepCopy(elements);
    elementsCopy[container]!.remove(element);
    onElementsChanged(elementsCopy);
  }

  @override
  Widget build(BuildContext context) {
    final containerGroups = [
      [ElementContainer.plastic],
      [ElementContainer.paper, ElementContainer.bio],
      [ElementContainer.mixed, ElementContainer.glass]
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Segregacja',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Text(
              'Wybierz pojemniki',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8.0),
            GutterColumn(
              gutterSize: 8.0,
              children: [
                for (var containers in containerGroups)
                  GutterRow(
                    gutterSize: 8.0,
                    children: [
                      for (var container in containers)
                        Expanded(
                          child: _ContainerChip(
                            container: container,
                            selected: selectedContainers.contains(container),
                            onPressed: () => toggleContainer(container),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 24.0),
            GutterColumn(
              children: [
                for (var container in selectedContainers)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                foregroundColor: container.iconColor,
                                backgroundColor: container.containerColor,
                                child: Icon(container.icon),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                container.containerName,
                                style: Theme.of(context).textTheme.titleMedium!,
                              ),
                            ],
                          ),
                          ConditionalBuilder(
                            condition: elements[container]!.isNotEmpty,
                            ifTrue: () => Column(
                              children: [
                                for (var element in elements[container]!) ...[
                                  _ElementItem(
                                    element: element,
                                    onDeletePressed: () => deleteElement(container, element),
                                  ),
                                  if (element != elements[container]!.last)
                                    const Divider(color: Color(0xffE0E0E0), thickness: 1, height: 1),
                                ],
                              ],
                            ),
                            ifFalse: () => SizedBox(height: 16.0),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final element = await showDefaultBottomSheet<_ElementModel>(
                                context: context,
                                builder: (context) => _ElementSheet(),
                              );

                              if (element != null) {
                                addElement(container, element);
                              }
                            },
                            style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                                  backgroundColor: const MaterialStatePropertyAll(Colors.white),
                                  side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
                                ),
                            child: Text('Dodaj element'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContainerChip extends StatelessWidget {
  const _ContainerChip({
    Key? key,
    required this.container,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  final ElementContainer container;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primaryDarker : Colors.black,
          width: 1.2, // yep, 1.2
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: kThemeChangeDuration,
                child: !selected
                    ? Icon(container.icon, key: ValueKey(container), size: 20)
                    : Icon(Icons.check, key: Key('selected'), size: 20, color: AppColors.primaryDarker),
              ),
              SizedBox(width: 12.0),
              Text(container.containerName, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElementItem extends StatelessWidget {
  const _ElementItem({
    Key? key,
    required this.element,
    required this.onDeletePressed,
  }) : super(key: key);

  final SortElement element;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    element.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  ConditionalBuilder(
                    condition: element.description != null,
                    ifTrue: () => Text(
                      element.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.0),
            IconButton(
              onPressed: onDeletePressed,
              style: IconButton.styleFrom(foregroundColor: AppColors.negative).copyWith(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElementModel {
  _ElementModel(this.name, this.desc);

  String name;
  String desc;
}

class _ElementSheet extends HookWidget {
  const _ElementSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final element = useRef(_ElementModel('', ''));
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nowy element',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16.0),
          GutterColumn(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nazwa',
                ),
                textInputAction: TextInputAction.next,
                validator: Validators.required('Uzupełnij nazwę'),
                onChanged: (value) => element.value.name = value,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Dodatkowe informacje',
                ),
                onChanged: (value) => element.value.desc = value,
              ),
              Center(
                child: Text(
                  'Lub',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              DropdownButtonFormField<dynamic>(
                hint: Text('Wybierz z listy'),
                items: [],
                onChanged: (v) {},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Cofnij'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(element.value),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDarker,
                    ),
                    child: Text('Zapisz'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
