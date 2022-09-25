import 'package:flutter/material.dart';
import 'package:inzynierka/models/product.dart';
import 'package:inzynierka/screens/widgets/sort_container.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductSort extends StatelessWidget {
  final Product product;

  const ProductSort({
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
