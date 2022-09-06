import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inzynierka/data/static_data.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/screens/widgets/sort_container.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductPage extends StatelessWidget {
  final Product product;
  final AppUser? user;

  const ProductPage({
    Key? key,
    required this.product,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GutterColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProductSort(product: product),
          if (product.symbols.isNotEmpty) _ProductSymbols(product: product),
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
        Text('Oznaczenia', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8.0),
        GutterColumn(
          children: [
            for (String symbol in product.symbols) ...[
              ConditionalBuilder(
                condition: getSymbol(symbol) != null,
                ifTrue: () => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          child: Image.asset('assets/images/symbols/$symbol.png'),
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
                                  Text(
                                    getSymbol(symbol)!.description!,
                                    style: Theme.of(context).textTheme.labelSmall,
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
            ]
          ],
        ),
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
    print('Button action');
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
                Text('Propozycje segregacji', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                for (int i = 0; i < product.sortProposals.length; i++) ...[
                  SortContainer(sort: product.sortProposals[i], verified: false),
                ],
              ],
            ),
            ifFalse: () => Card(
              color: Colors.white,
              child: Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/no_data.svg',
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'Brak wskazówek dotyczących segregacji',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: addSortProposal,
              child: const Text('Dodaj swoją propozycję'),
            ),
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
        padding: const EdgeInsets.all(16.0),
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
                  'Produkt dodany przez',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  '${user.name} ${user.surname}',
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