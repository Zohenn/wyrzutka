import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/screens/product_form/information_step.dart';
import 'package:inzynierka/screens/product_form/sort_step.dart';
import 'package:inzynierka/screens/product_form/symbols_step.dart';
import 'package:inzynierka/widgets/custom_stepper.dart';

part 'product_form.freezed.dart';

@freezed
class ProductFormModel with _$ProductFormModel {
  const factory ProductFormModel({
    required String id,
    @Default('') String name,
    @Default('') String keywords,
    XFile? photo,
  }) = _ProductFormModel;
}

class ProductForm extends HookWidget {
  const ProductForm({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    final model = useState(ProductFormModel(id: id));
    final step = useState(0);
    final previousStep = usePrevious(step.value);

    return Scaffold(
      body: WillPopScope(
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
                    Text('Nowy produkt', style: Theme.of(context).textTheme.titleLarge),
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
                    transitionBuilder: (child, primaryAnimation, secondaryAnimation) => SharedAxisTransition(
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: Colors.white,
                      child: child,
                    ),
                    reverse: previousStep != null && previousStep > step.value,
                    child: [
                      InformationStep(
                        model: model.value,
                        onNameChanged: (name) => model.value = model.value.copyWith(name: name),
                        onKeywordsChanged: (keywords) => model.value = model.value.copyWith(keywords: keywords),
                        onPhotoChanged: (photo) => model.value = model.value.copyWith(photo: photo),
                        onNextPressed: () => step.value = 1,
                      ),
                      SymbolsStep(),
                      SortStep(),
                    ][step.value],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
