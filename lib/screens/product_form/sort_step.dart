import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class SortStep extends HookWidget {
  const SortStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containers = ElementContainer.values.where((element) => element != ElementContainer.empty);
    final selectedContainers = useState(<ElementContainer>{});
    final elements = useState(<ElementContainer, List<SortElement>>{});

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
              'Wybierz pojemniki, do których powinien trafić produkt.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  for (var container in containers)
                    Material(
                      color:
                          selectedContainers.value.contains(container) ? Theme.of(context).primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: selectedContainers.value.contains(container) ? AppColors.primaryDarker : Colors.black,
                          width: 1.2, // yep, 1.2
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          if (!selectedContainers.value.contains(container)) {
                            selectedContainers.value.add(container);
                            elements.value[container] = [];
                          } else {
                            selectedContainers.value.remove(container);
                            elements.value.remove(container);
                          }
                          selectedContainers.value = Set.from(selectedContainers.value);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          child: Text(container.containerName, style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            GutterColumn(
              children: [
                for (var container in selectedContainers.value)
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
                          for (var element in elements.value[container]!) ...[
                            Align(
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
                                      onPressed: () {},
                                      style: IconButton.styleFrom(foregroundColor: AppColors.negative).copyWith(
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      icon: Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (element != elements.value[container]!.last)
                              const Divider(color: Color(0xffE0E0E0), thickness: 1, height: 1),
                          ],
                          OutlinedButton(
                            onPressed: () async {
                              final element = await showDefaultBottomSheet<_ElementModel>(
                                context: context,
                                builder: (context) => _ElementSheet(),
                              );

                              if (element != null) {
                                elements.value[container] ??= [];
                                elements.value[container]!.add(
                                  SortElement(
                                    container: container,
                                    name: element.name,
                                    description: element.desc.isEmpty ? null : element.desc,
                                  ),
                                );
                                elements.value = {...elements.value};
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
                textInputAction: TextInputAction.next,
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
