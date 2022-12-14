import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/models/product/product.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/screens/sort_proposal_form.dart';
import 'package:wyrzutka/screens/widgets/sort_container.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wyrzutka/widgets/gutter_column.dart';

class ProductSort extends ConsumerWidget {
  const ProductSort({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    final canAddProposal = authUser != null &&
        product.sortProposals.length < 5 &&
        !product.sortProposals.values.any((element) => element.user == authUser.id);

    return ConditionalBuilder(
      condition: product.sort != null,
      ifTrue: () => SortContainer(product: product, sort: product.sort!, verified: true),
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
                GutterColumn(
                  children: [
                    for (var sortProposal in product.sortProposals.values)
                      SortContainer(product: product, sort: sortProposal, verified: false),
                  ],
                ),
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
                      'Brak wskaz??wek dotycz??cych segregacji',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (canAddProposal) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () =>
                    showDefaultBottomSheet(context: context, builder: (context) => SortProposalForm(product: product)),
                child: const Text('Dodaj swoj?? propozycj??'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
