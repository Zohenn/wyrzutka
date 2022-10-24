import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/widgets/size_animation_helper.dart';

enum SavingState { saving, done, error }

class ProductFormSave extends HookWidget {
  const ProductFormSave({Key? key, required this.model}) : super(key: key);

  final ProductFormModel model;

  @override
  Widget build(BuildContext context) {
    final state = useState(SavingState.saving);
    final animationController = useAnimationController(duration: const Duration(milliseconds: 400));
    final animation = useRef(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

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
                      child: Image.file(File(model.photo!.path)),
                    ),
                  ),
                ),
                if (state.value == SavingState.saving)
                  const Positioned.fill(
                    child: CircularProgressIndicator(color: AppColors.primaryDarker),
                  ),
                Positioned(
                  bottom: 16,
                  child: FadeTransition(
                    opacity: animation.value,
                    child: Icon(
                      Icons.check,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                      shadows: const [Shadow(color: Colors.black45, blurRadius: 12.0, offset: Offset(0, 2.0))],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      state.value = state.value == SavingState.saving ? SavingState.done : SavingState.saving;
                      state.value == SavingState.done
                          ? animationController.forward(from: 0)
                          : animationController.reverse(from: 1);
                    },
                  ),
                ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Zapisano produkt!', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    'Listę dodanych przez Ciebie produktów znajdziesz w swoim profilu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 16.0),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Center(child: Text('Super!')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
