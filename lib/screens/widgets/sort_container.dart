import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/models/sort.dart';

class SortContainer extends StatelessWidget {
  final Sort sort;
  final bool verified;

  Map<ElementContainer, List<SortElement>> get elements {
    return groupBy([...sort.elements], (SortElement element) => element.container);
  }

  const SortContainer({Key? key, required this.sort, required this.verified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var key in elements.keys) SortContainerGroup(container: key, elements: elements[key]!),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ConditionalBuilder(
              condition: verified,
              ifTrue: () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.done, color: AppColors.positive),
                      const SizedBox(width: 8),
                      Text(
                        'Zweryfikowano',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black),
                      )
                    ],
                  ),
                  // TODO add user provider
                  const AvatarIcon(user: AppUser(email: '', surname: '', name: '', id: '')),
                ],
              ),
              // TODO not verified version
              ifFalse: () => const Text('TODO'),
            ),
          ),
        ],
      ),
    );
  }
}

class SortContainerGroup extends StatelessWidget {
  final ElementContainer container;
  final List<SortElement> elements;

  const SortContainerGroup({
    Key? key,
    required this.container,
    required this.elements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: container.containerColor,
                child: Icon(container.icon, color: container.iconColor),
              ),
              const SizedBox(width: 16),
              Text(
                container.containerName,
                style: Theme.of(context).textTheme.titleMedium!,
              ),
            ],
          ),
        ),
        for (var element in elements) ...[
          Padding(
            padding: const EdgeInsets.all(16),
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
          const Divider(color: Color(0xffE0E0E0), thickness: 1, height: 1),
        ],
      ],
    );
  }
}
