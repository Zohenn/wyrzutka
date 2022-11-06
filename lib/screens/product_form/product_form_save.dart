import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/services/product_service.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/size_animation_helper.dart';

enum SavingState { saving, done, error }

class ProductFormSave extends HookConsumerWidget {
  const ProductFormSave({
    Key? key,
    required this.model,
    required this.variant,
  }) : super(key: key);

  final ProductFormModel model;
  final Product? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productService = ref.watch(productServiceProvider);
    final state = useState(SavingState.saving);
    final previousState = usePrevious(state.value);
    final animationController = useAnimationController(duration: const Duration(milliseconds: 400));
    final animation = useRef(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    final retryTrigger = useState(0);

    useEffect(() {
      state.value = SavingState.saving;
      animationController.reverse();
      final future = model.product == null
          ? productService.createFromModel(model, variant)
          : productService.updateFromModel(model);
      future.then((value) {
        return state.value = SavingState.done;
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        debugPrintStack(stackTrace: stackTrace);
        return state.value = SavingState.error;
      }).whenComplete(() => animationController.forward());

      return null;
    }, [retryTrigger.value]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animation.value,
              builder: (context, child) => SizeAnimationHelper(
                value: 1 - animation.value.value,
                child: child!,
              ),
              child: Column(
                children: [
                  Text('Zapisywanie produktu', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Stack(
              alignment: Alignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: ConditionalBuilder(
                        condition: model.product == null,
                        ifTrue: () => Image.file(File(model.photo!.path)),
                        ifFalse: () => Image.network(model.product!.photo!),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    color: state.value == SavingState.error ? AppColors.negative : AppColors.primaryDarker,
                    value: state.value == SavingState.saving ? null : 1,
                  ),
                ),
                // Positioned.fill(
                //   child: GestureDetector(
                //     onTap: () {
                //       state.value = SavingState.error;
                //       // state.value = state.value == SavingState.saving ? SavingState.done : SavingState.saving;
                //       // state.value == SavingState.done
                //       //     ? animationController.forward(from: 0)
                //       //     : animationController.reverse(from: 1);
                //       // state.value = state.value == SavingState.saving ? SavingState.error : SavingState.saving;
                //       // state.value == SavingState.error
                //       //     ? animationController.forward(from: 0)
                //       //     : animationController.reverse(from: 1);
                //     },
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(model.name, style: Theme.of(context).textTheme.titleLarge),
            Text(model.id, style: const TextStyle(color: AppColors.primaryDarker)),
            const SizedBox(height: 36.0),
            AnimatedBuilder(
              animation: animation.value,
              builder: (context, child) => SizeAnimationHelper(
                value: animation.value.value,
                child: child!,
              ),
              child: ConditionalBuilder(
                condition: state.value == SavingState.error ||
                    (state.value == SavingState.saving && previousState == SavingState.error),
                ifTrue: () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ups...', style: Theme.of(context).textTheme.titleLarge),
                    Text('Przy zapisywaniu produktu wystąpił błąd.', style: Theme.of(context).textTheme.bodyLarge),
                    Text(
                      'Spróbuj ponownie lub wróć za jakiś czas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => retryTrigger.value++,
                      child: const Center(child: Text('Spróbuj ponownie')),
                    ),
                  ],
                ),
                ifFalse: () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Zapisano produkt!', style: Theme.of(context).textTheme.titleLarge),
                    ConditionalBuilder(
                      condition: model.product == null,
                      ifTrue: () => Text(
                        'Listę dodanych przez Ciebie produktów znajdziesz w swoim profilu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Center(child: Text('Super!')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
