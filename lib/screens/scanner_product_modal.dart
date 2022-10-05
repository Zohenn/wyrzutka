import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/product_provider.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/product_modal/product_modal.dart';
import 'package:inzynierka/screens/product_modal/product_sort.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/gutter_row.dart';
import 'package:inzynierka/widgets/progress_indicator_button.dart';

class ScannerProductModal extends HookConsumerWidget {
  const ScannerProductModal({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);

    final isSaved = useState(authUser == null ? false : authUser.savedProducts.contains(id));
    final isSaving = useState(false);

    final future = useInitFuture<Product?>(() => ref.read(productRepositoryProvider).fetchId(id));
    final product = ref.watch(productProvider(id));

    final activeTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
          backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
        );
    final inactiveTabStyle = Theme.of(context).outlinedButtonTheme.style!.copyWith(
          backgroundColor: const MaterialStatePropertyAll(Colors.white),
        );

    return FutureHandler(
      future: future,
      loading: () => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          heightFactor: 1.0,
          child: CircularProgressIndicator(),
        ),
      ),
      data: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: GutterColumn(
                children: [
                  _ProductName(product: product, id: id),
                  ConditionalBuilder(
                    condition: product == null,
                    ifTrue: () => const _UnknownProductInfo(),
                    ifFalse: () => ProductSort(product: product!),
                  ),
                ],
              ),
            ),
          ),
          ConditionalBuilder(
            condition: product != null,
            ifTrue: () => Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                  child: GutterRow(
                    children: [
                      ConditionalBuilder(
                        condition: authUser != null,
                        ifTrue: () => Expanded(
                          child: AnimatedTheme(
                            data: Theme.of(context).copyWith(
                              outlinedButtonTheme:
                                  OutlinedButtonThemeData(style: isSaved.value ? activeTabStyle : inactiveTabStyle),
                            ),
                            child: ProgressIndicatorButton(
                              isLoading: isSaving.value,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                final userRepository = ref.watch(userRepositoryProvider);
                                isSaving.value = true;
                                asyncCall(context, () async {
                                  if (!isSaved.value) {
                                    final user = await userRepository.saveProduct(authUser!, id);
                                    ref.read(authUserProvider.notifier).state = user;
                                    isSaved.value = true;
                                  } else {
                                    final user = await userRepository.removeProduct(authUser!, id);
                                    ref.read(authUserProvider.notifier).state = user;
                                    isSaved.value = false;
                                  }
                                });
                                isSaving.value = false;
                              },
                              child: !isSaved.value ? const Text('Zapisz na liście') : const Text("Zapisano na liście"),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDefaultBottomSheet(
                              context: context,
                              builder: (context) => ProductModal(id: product!.id),
                            );
                          },
                          child: const Text('Więcej informacji'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnknownProductInfo extends StatelessWidget {
  const _UnknownProductInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GutterColumn(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Brak informacji dotyczacych produktu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('Uzupełnij informacje'),
          ),
        ),
      ],
    );
  }
}

class _ProductName extends StatelessWidget {
  const _ProductName({
    Key? key,
    required this.product,
    required this.id,
  }) : super(key: key);

  final Product? product;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: Theme.of(context).disabledColor),
          ),
          child: Center(
            child: ProductPhoto(product: product),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product?.name ?? 'Nieznany produkt',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              product?.id.toString() ?? id,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ],
    );
  }
}
