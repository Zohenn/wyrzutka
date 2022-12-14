import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/models/product/sort_element.dart';
import 'package:wyrzutka/models/product/sort_element_template.dart';
import 'package:wyrzutka/repositories/sort_element_template_repository.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/utils/validators.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/future_handler.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';
import 'package:wyrzutka/widgets/gutter_row.dart';

typedef SortElements = Map<ElementContainer, List<SortElement>>;

class SortElementsField extends StatelessWidget {
  const SortElementsField({
    Key? key,
    required this.elements,
    required this.onElementsChanged,
    required this.required,
  }) : super(key: key);

  final SortElements elements;
  final void Function(SortElements) onElementsChanged;
  final bool required;

  Iterable<ElementContainer> get selectedContainers => elements.keys;

  SortElements copyElements(SortElements elements) => elements.map((key, value) => MapEntry(key, [...value]));

  void toggleContainer(ElementContainer container) {
    final elementsCopy = copyElements(elements);
    if (!selectedContainers.contains(container)) {
      elementsCopy[container] = [];
    } else {
      elementsCopy.remove(container);
    }
    onElementsChanged(elementsCopy);
  }

  void addElement(ElementContainer container, SortElement element) {
    final elementsCopy = copyElements(elements);
    elementsCopy[container]!.add(element);
    onElementsChanged(elementsCopy);
  }

  void editElement(ElementContainer container, SortElement previousElement, SortElement newElement) {
    final elementsCopy = copyElements(elements);
    final index = elementsCopy[container]!.indexWhere((element) => element == previousElement);
    elementsCopy[container]![index] = newElement;
    onElementsChanged(elementsCopy);
  }

  void deleteElement(ElementContainer container, SortElement element) {
    final elementsCopy = copyElements(elements);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wybierz pojemniki',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8.0),
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
        const SizedBox(height: 24.0),
        ConditionalBuilder(
          condition: selectedContainers.isNotEmpty,
          ifTrue: () => GutterColumn(
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
                                  onEditPressed: () async {
                                    final newElement = await showDefaultBottomSheet<ElementModel>(
                                      context: context,
                                      closeModals: false,
                                      builder: (context) => _ElementSheet(container: container, editedElement: element),
                                    );

                                    if (newElement != null) {
                                      editElement(
                                        container,
                                        element,
                                        newElement.toSortElement(container),
                                      );
                                    }
                                  },
                                  onDeletePressed: () => deleteElement(container, element),
                                ),
                                if (element != elements[container]!.last)
                                  const Divider(color: Color(0xffE0E0E0), thickness: 1, height: 1),
                              ],
                            ],
                          ),
                          ifFalse: () => const SizedBox(height: 16.0),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final newElement = await showDefaultBottomSheet<ElementModel>(
                              context: context,
                              closeModals: false,
                              builder: (context) => _ElementSheet(container: container),
                            );

                            if (newElement != null) {
                              addElement(
                                container,
                                newElement.toSortElement(container),
                              );
                            }
                          },
                          style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                                backgroundColor: const MaterialStatePropertyAll(Colors.white),
                                side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
                              ),
                          child: const Text('Dodaj element'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ifFalse: () => _EmptySortCard(required: required),
        ),
      ],
    );
  }
}

class _ElementItem extends StatelessWidget {
  const _ElementItem({
    Key? key,
    required this.element,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  final SortElement element;
  final VoidCallback onEditPressed;
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
            const SizedBox(width: 16.0),
            IconButton(
              onPressed: onEditPressed,
              style: IconButton.styleFrom(foregroundColor: Colors.black).copyWith(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              tooltip: 'Edytuj element',
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: onDeletePressed,
              style: IconButton.styleFrom(foregroundColor: AppColors.negative).copyWith(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              tooltip: 'Usu?? element',
              icon: const Icon(Icons.close),
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
    return Semantics(
      container: true,
      selected: selected,
      label: container.containerName,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.white,
          shape: StadiumBorder(
            side: BorderSide(color: selected ? AppColors.primaryDarker : Colors.black),
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
                        : const Icon(Icons.check, key: Key('selected'), size: 20, color: AppColors.primaryDarker),
                  ),
                  const SizedBox(width: 12.0),
                  Text(container.containerName, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySortCard extends StatelessWidget {
  const _EmptySortCard({
    Key? key,
    required this.required,
  }) : super(key: key);

  final bool required;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                radius: 30,
                child: Icon(Icons.delete_forever, size: 30),
              ),
              const SizedBox(height: 16.0),
              Text('Pusta propozycja segregacji', style: Theme.of(context).textTheme.titleMedium),
              Text(
                required
                    ? 'Wybierz pojemniki i uzupe??nij elementy, aby m??c doda?? swoj?? propozycj??.'
                    : 'Zako??cz dodawanie produktu, a propozycje uzupe??ni?? inni.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElementModel {
  ElementModel(this.name, this.desc);

  String name;
  String desc;

  SortElement toSortElement(ElementContainer container) => SortElement(
        container: container,
        name: name,
        description: desc.isEmpty ? null : desc,
      );
}

class _ElementSheet extends HookConsumerWidget {
  const _ElementSheet({
    Key? key,
    required this.container,
    this.editedElement,
  }) : super(key: key);

  final ElementContainer container;
  final SortElement? editedElement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortElementTemplateRepository = ref.watch(sortElementTemplateRepositoryProvider);
    final initFuture = useInitFuture(() => sortElementTemplateRepository.fetchAll());
    final templates = ref.watch(
      allSortElementTemplatesProvider.select(
        (value) => value.where(
          (element) => element.container == container,
        ),
      ),
    );
    final templateItems = useMemoized(
      () => templates.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
      [templates],
    );
    final formKey = useRef(GlobalKey<FormState>());
    final element = useState(ElementModel(editedElement?.name ?? '', editedElement?.description ?? ''));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0 + MediaQuery.of(context).viewInsets.bottom),
      child: FutureHandler(
        future: initFuture,
        data: () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editedElement == null ? 'Nowy element' : 'Edycja elementu',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16.0),
            Form(
              key: formKey.value,
              child: GutterColumn(
                children: [
                  TextFormField(
                    initialValue: element.value.name,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa',
                    ),
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.required('Uzupe??nij nazw??'),
                    onChanged: (value) => element.value = ElementModel(value.trim(), element.value.desc),
                  ),
                  TextFormField(
                    initialValue: element.value.desc,
                    decoration: const InputDecoration(
                      labelText: 'Dodatkowe informacje',
                    ),
                    onChanged: (value) => element.value = ElementModel(element.value.name, value.trim()),
                  ),
                  if (editedElement == null) ...[
                    Center(
                      child: Text(
                        'Lub',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    DropdownButtonFormField<SortElementTemplate>(
                      hint: const Text('Wybierz z listy'),
                      items: templateItems,
                      onChanged: (v) {
                        if (v != null) {
                          Navigator.of(context).pop(ElementModel(v.name, v.description ?? ''));
                        }
                      },
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Cofnij'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (formKey.value.currentState?.validate() != true) {
                            return;
                          }

                          Navigator.of(context).pop(element.value);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryDarker,
                        ),
                        child: const Text('Zapisz element'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
