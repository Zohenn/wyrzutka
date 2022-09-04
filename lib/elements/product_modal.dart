import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/elements/sort_container.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/models/symbol.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

final symbols = [
  const Symbol(id: "1", name: "Tektura", photo: "", description: "Opakowanie wykonane z tektury"),
  const Symbol(id: "2", name: "Dbaj o czystość", photo: "", description: "Opakowanie wyrzuć do kosza"),
];

IconData getIconByString(String symbol) {
  switch (symbol) {
    default:
      return Icons.question_mark;
  }
}

Symbol? getSymbol(String name) {
  return symbols.firstWhereOrNull((element) => element.id == name);
}

class ProductModal extends StatelessWidget {
  final Product product;
  final AppUser? user;

  void addSortProposal() {
    // TODO
    print("Button action");
  }

  const ProductModal({Key? key, required this.product, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        height: 56,
                        width: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Center(
                          child: product.photo != ""
                              ? Image.asset("assets/images/${product.photo}.png")
                              : const Icon(Icons.question_mark),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.id.toString(),
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: ThemeData.dark().colorScheme.surfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (product.verifiedBy != null) ...[
                  SortContainer(sort: product.sort!, verified: product.verifiedBy!),
                ] else ...[
                  if (product.sortProposals.isNotEmpty) ...[
                    Container(
                      //margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(10),
                      child: Text("Propozycje segregacji", style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    for (int i = 0; i < product.sortProposals.length; i++) ...[
                      SortContainer(sort: product.sortProposals[i]),
                    ],
                  ],
                ],
                if (product.verifiedBy == null)
                  Center(
                    child: ElevatedButton(
                      onPressed: addSortProposal,
                      child: const Text("Dodaj swoją propozycję"),
                    ),
                  ),
                if (product.symbols.isNotEmpty) ...[
                  Text("Oznaczenia", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  for (String symbol in product.symbols) ...[
                    if (getSymbol(symbol) != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: AppColors.gray,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: Icon(getIconByString(getSymbol(symbol)!.name), color: Colors.black),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getSymbol(symbol)!.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                if (getSymbol(symbol)!.description != null)
                                  Text(
                                    getSymbol(symbol)!.description!,
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                          color: ThemeData.light().colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
                ConditionalBuilder(
                  condition: user != null,
                  ifTrue: () => _ProductUser(user: user!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductUser extends StatelessWidget {
  const _ProductUser({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
              child: Center(
                child: Text(
                  user.name[0].toUpperCase() + user.surname[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Produkt dodany przez",
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  "${user.name} ${user.surname}",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
