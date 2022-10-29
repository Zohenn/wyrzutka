import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/hooks/debounce.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/models/product/sort.dart';
import 'package:inzynierka/models/product/sort_element.dart';
import 'package:inzynierka/providers/product_service_provider.dart';
import 'package:inzynierka/screens/product_form/product_form_information.dart';
import 'package:inzynierka/screens/product_form/product_form_save.dart';
import 'package:inzynierka/screens/product_form/product_form_sort.dart';
import 'package:inzynierka/screens/product_form/product_form_symbols.dart';
import 'package:inzynierka/widgets/custom_stepper.dart';

part 'product_form.freezed.dart';

Widget sharedAxisTransitionBuilder(
        Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) =>
    SharedAxisTransition(
      animation: primaryAnimation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      fillColor: Colors.white,
      child: child,
    );

@freezed
class ProductFormModel with _$ProductFormModel {
  const factory ProductFormModel({
    required String id,
    @Default('') String name,
    @Default([]) List<String> keywords,
    File? photo,
    @Default([]) List<String> symbols,
    @Default({}) Map<ElementContainer, List<SortElement>> elements,
    Product? product,
  }) = _ProductFormModel;

  factory ProductFormModel.fromProduct(Product product) => ProductFormModel(
        id: product.id,
        name: product.name,
        keywords: [...product.keywords],
        symbols: [...product.symbols],
        product: product,
      );
}

class ProductForm extends HookConsumerWidget {
  const ProductForm({
    Key? key,
    required String this.id,
  })  : editedProduct = null,
        super(key: key);

  const ProductForm.edit({
    Key? key,
    required Product product,
  })  : id = null,
        editedProduct = product,
        super(key: key);

  final String? id;
  final Product? editedProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productService = ref.watch(productServiceProvider);
    final variant = useState<Product?>(null);
    final confirmedVariant = useState<Product?>(null);
    final model = useState(id != null ? ProductFormModel(id: id!) : ProductFormModel.fromProduct(editedProduct!));
    final step = useState(0);
    final previousStep = usePrevious(step.value);
    final debounce = useDebounceHook<List<String>>(
      onEmit: (keywords) {
        if (editedProduct == null) {
          productService.findVariant(keywords).then((value) => variant.value = value);
        }
      },
    );
    final isSaving = useState(false);

    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: sharedAxisTransitionBuilder,
        layoutBuilder: (entries) => Stack(
          alignment: Alignment.topCenter,
          children: entries,
        ),
        child: !isSaving.value
            ? WillPopScope(
                onWillPop: () async {
                  if (step.value > 0) {
                    step.value--;
                    return false;
                  }

                  return true;
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              editedProduct == null ? 'Nowy produkt' : 'Edycja produktu',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16.0),
                            CustomStepper(steps: const ['Informacje', 'Oznaczenia', 'Segregacja'], step: step.value),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: PageTransitionSwitcher(
                            transitionBuilder: sharedAxisTransitionBuilder,
                            layoutBuilder: (entries) => Stack(
                              alignment: Alignment.topCenter,
                              children: entries,
                            ),
                            reverse: previousStep != null && previousStep > step.value,
                            child: [
                              ProductFormInformation(
                                model: model.value,
                                variant: variant.value,
                                confirmedVariant: confirmedVariant.value,
                                onNameChanged: (name) => model.value = model.value.copyWith(name: name),
                                onKeywordsChanged: (keywords) {
                                  model.value = model.value.copyWith(keywords: keywords);
                                  if (confirmedVariant.value == null && variant.value == null) {
                                    debounce.onChanged(keywords);
                                  }
                                },
                                onPhotoChanged: (photo) => model.value = model.value.copyWith(photo: photo),
                                onVariantDismissed: () => variant.value = null,
                                onVariantConfirmed: () => confirmedVariant.value = variant.value,
                                onVariantCanceled: () => confirmedVariant.value = null,
                                onNextPressed: () => step.value = 1,
                                onSubmitPressed: () => isSaving.value = true,
                              ),
                              ProductFormSymbols(
                                model: model.value,
                                onSymbolsChanged: (symbols) => model.value = model.value.copyWith(symbols: symbols),
                                onNextPressed: () => step.value = 2,
                              ),
                              ProductFormSort(
                                model: model.value,
                                onElementsChanged: (elements) => model.value = model.value.copyWith(elements: elements),
                                onSubmitPressed: () => isSaving.value = true,
                              ),
                            ][step.value],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ProductFormSave(
                model: model.value,
                variant: confirmedVariant.value,
              ),
      ),
    );
  }
}
