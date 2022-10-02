import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/sort_element.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/models/sort.dart';

class SortContainer extends ConsumerWidget {
  const SortContainer({
    Key? key,
    required this.sort,
    required this.verified,
  }) : super(key: key);

  final Sort sort;
  final bool verified;

  Map<ElementContainer, List<SortElement>> get elements {
    return groupBy([...sort.elements], (SortElement element) => element.container);
  }

  Color balanceColor(int balance) {
    if (balance > 0) {
      return AppColors.positive;
    } else if (balance < 0) {
      return AppColors.negative;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productRepositoryProvider);
    final authUser = ref.watch(authUserProvider);
    final disableButtons = authUser == null || authUser.id == sort.user;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var key in elements.keys) SortContainerGroup(container: key, elements: elements[key]!),
          ConditionalBuilder(
            condition: verified,
            ifTrue: () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
            ),
            // TODO not verified version
            ifFalse: () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    sort.voteBalance.toString(),
                    style: TextStyle(color: balanceColor(sort.voteBalance)),
                  ),
                  SizedBox(width: 8.0),
                  IconButton(
                    onPressed: disableButtons ? null : () {},
                    color: AppColors.positive,
                    icon: Icon(Icons.expand_less),
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  IconButton(
                    onPressed: disableButtons ? null : () {},
                    icon: Icon(Icons.expand_more),
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  const AvatarIcon(user: AppUser(email: '', surname: '', name: '', id: '')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SortContainerGroup extends StatelessWidget {
  const SortContainerGroup({
    Key? key,
    required this.container,
    required this.elements,
  }) : super(key: key);
  final ElementContainer container;
  final List<SortElement> elements;

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
