import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/widgets/progress_indicator_icon_button.dart';

enum _UpdateVoteState { none, up, down }

class SortContainer extends HookConsumerWidget {
  const SortContainer({
    Key? key,
    required this.product,
    required this.sort,
    required this.verified,
  }) : super(key: key);

  final Product product;
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
    final user = ref.watch(userProvider(sort.user));
    final updateVoteState = useState(_UpdateVoteState.none);
    final disableButtons =
        updateVoteState.value != _UpdateVoteState.none || authUser == null || authUser.id == sort.user;
    final userVote = sort.votes.firstWhereOrNull((element) => element.user == authUser?.id);

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
                      const SizedBox(width: 12),
                      Text(
                        'Zweryfikowano',
                        style: Theme.of(context).textTheme.labelLarge,
                      )
                    ],
                  ),
                  AvatarIcon(
                    user: user,
                    profileLoading: true,
                  ),
                ],
              ),
            ),
            ifFalse: () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    sort.voteBalance.toString(),
                    style: TextStyle(color: balanceColor(sort.voteBalance)),
                  ),
                  const SizedBox(width: 8.0),
                  if (sort.user == authUser?.id) ...[
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Twoja propozycja',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.primaryDarker),
                      ),
                    ),
                  ],
                  if (sort.user != authUser?.id) ...[
                    ProgressIndicatorIconButton(
                      isLoading: updateVoteState.value == _UpdateVoteState.up,
                      spinnerColor: AppColors.positive,
                      onPressed: disableButtons
                          ? null
                          : () async {
                              updateVoteState.value = _UpdateVoteState.up;
                              await asyncCall(
                                  context, () => productRepository.updateVote(product, sort, authUser, true));
                              updateVoteState.value = _UpdateVoteState.none;
                            },
                      color: userVote?.value == true ? AppColors.positive : null,
                      icon: const Icon(Icons.expand_less),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    ProgressIndicatorIconButton(
                      isLoading: updateVoteState.value == _UpdateVoteState.down,
                      spinnerColor: AppColors.negative,
                      onPressed: disableButtons
                          ? null
                          : () async {
                              updateVoteState.value = _UpdateVoteState.down;
                              await asyncCall(
                                  context, () => productRepository.updateVote(product, sort, authUser, false));
                              updateVoteState.value = _UpdateVoteState.none;
                            },
                      color: userVote?.value == false ? AppColors.negative : null,
                      icon: const Icon(Icons.expand_more),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                  AvatarIcon(user: user),
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
