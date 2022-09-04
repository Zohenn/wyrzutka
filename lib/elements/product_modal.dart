import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:inzynierka/elements/sort_container.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../data/static_data.dart';

class ProductModal extends HookWidget {
  final Product product;
  final AppUser? user;

  const ProductModal({Key? key, required this.product, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = useTabController(initialLength: 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: _ProductName(product: product),
        ),
        Flexible(
          child: TabBarView(

            controller: _controller,
            children: [
              _ProductPage(product: product, user: user),
              _VariantPage(product: product),
            ],
          ),
        ),
        Column(
          children: [
            Divider(
              thickness: 1,
              height: 1,
              color: Theme.of(context).primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).primaryColorLight,
                      ),
                      //indicatorSize: TabBarIndicatorSize.label,
                      controller: _controller,
                      splashFactory: NoSplash.splashFactory,
                      tabs: const [
                        Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24), child: Text("Segregacja")),
                        Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24), child: Text("Warianty")),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Void, icon: const Icon(Icons.more_vert)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VariantPage extends StatelessWidget {
  final Product product;

  const _VariantPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (String variant in product.variants) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                child: Row(
                  children: [
                    Container(
                        clipBehavior: Clip.hardEdge,
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: ConditionalBuilder(
                            condition: product.photo != null,
                            ifTrue: () => Image.asset("assets/images/${product.photo}.png"),
                            ifFalse: () => const Icon(Icons.question_mark),
                          ),
                        )),
                    const SizedBox(width: 16),
                    Text(variant, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ProductPage extends StatelessWidget {
  final Product product;
  final AppUser? user;

  const _ProductPage({
    Key? key,
    required this.product,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProductSort(product: product),
          const SizedBox(height: 16),
          ConditionalBuilder(
            condition: product.symbols.isNotEmpty,
            ifTrue: () => Column(
              children: [
                _ProductSymbols(product: product),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ConditionalBuilder(
            condition: user != null,
            ifTrue: () => _ProductUser(user: user!),
          ),
        ],
      ),
    );
  }
}

class _ProductSymbols extends StatelessWidget {
  final Product product;

  const _ProductSymbols({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Oznaczenia", style: Theme.of(context).textTheme.headlineSmall),
        for (String symbol in product.symbols) ...[
          ConditionalBuilder(
            condition: getSymbol(symbol) != null,
            ifTrue: () => Card(
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      child: Icon(getIconByString(getSymbol(symbol)!.name)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getSymbol(symbol)!.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ConditionalBuilder(
                          condition: getSymbol(symbol)!.description != null,
                          ifTrue: () => Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                getSymbol(symbol)!.description!,
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                      color: ThemeData.light().colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductSort extends StatelessWidget {
  final Product product;

  const _ProductSort({
    Key? key,
    required this.product,
  }) : super(key: key);

  void addSortProposal() {
    // TODO
    print("Button action");
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: product.sort != null,
      ifTrue: () => SortContainer(sort: product.sort!, verified: true),
      ifFalse: () => Column(
        children: [
          ConditionalBuilder(
            condition: product.sortProposals.isNotEmpty,
            ifTrue: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Propozycje segregacji", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                for (int i = 0; i < product.sortProposals.length; i++) ...[
                  SortContainer(sort: product.sortProposals[i], verified: false),
                ],
              ],
            ),
            ifFalse: () => Card(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                child: Center(
                    child:
                        Text("Brak wskazówek dotyczących segregacji", style: Theme.of(context).textTheme.titleMedium)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: addSortProposal,
              child: const Text("Dodaj swoją propozycję"),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductName extends StatelessWidget {
  const _ProductName({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: ConditionalBuilder(
                condition: product.photo != null,
                ifTrue: () => Image.asset("assets/images/${product.photo}.png"),
                ifFalse: () => const Icon(Icons.help_outline),
              ),
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
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
