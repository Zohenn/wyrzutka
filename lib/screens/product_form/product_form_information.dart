import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/providers/image_picker_provider.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/image_crop_modal.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/utils/image_error_builder.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/text_overflow_ellipsis_fix.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/gutter_row.dart';

class ProductFormInformation extends HookConsumerWidget {
  const ProductFormInformation({
    Key? key,
    required this.model,
    required this.variant,
    required this.confirmedVariant,
    required this.onNameChanged,
    required this.onKeywordsChanged,
    required this.onPhotoChanged,
    required this.onVariantDismissed,
    required this.onVariantConfirmed,
    required this.onVariantCanceled,
    required this.onNextPressed,
    required this.onSubmitPressed,
  }) : super(key: key);

  final ProductFormModel model;
  final Product? variant;
  final Product? confirmedVariant;
  final void Function(String) onNameChanged;
  final void Function(List<String>) onKeywordsChanged;
  final void Function(File) onPhotoChanged;
  final VoidCallback onVariantDismissed;
  final VoidCallback onVariantConfirmed;
  final VoidCallback onVariantCanceled;
  final VoidCallback onNextPressed;
  final VoidCallback onSubmitPressed;

  bool get isStepValid =>
      model.name.isNotEmpty && model.keywords.isNotEmpty && (model.photo != null || model.product != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Podstawowe informacje',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Przed rozpoczęciem zweryfikuj, czy kod kreskowy jest zgodny z kodem z opakowania.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryDarker),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36.0),
            Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ConditionalBuilder(
                            condition: model.photo == null && model.product == null,
                            ifTrue: () => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo_outlined, size: 48),
                                  const SizedBox(height: 4.0),
                                  Text('Dodaj zdjęcie produktu', style: Theme.of(context).textTheme.titleMedium),
                                ],
                              ),
                            ),
                            ifFalse: () => ConditionalBuilder(
                              condition: model.photo != null,
                              ifTrue: () => Image.file(File(model.photo!.path)),
                              ifFalse: () => Image.network(
                                model.product!.photo ?? 'localhost',
                                errorBuilder: imageErrorBuilder,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () async {
                                  final picker = ref.read(imagePickerProvider);
                                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                  if (image != null) {
                                    final croppedImage = await showDefaultBottomSheet<File>(
                                      context: context,
                                      fullScreen: true,
                                      closeModals: false,
                                      builder: (context) => ImageCropModal(image: File(image.path)),
                                    );
                                    if (croppedImage != null) {
                                      onPhotoChanged(croppedImage);
                                    }
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Zadbaj, aby zdjęcie było wyraźne i przedstawiało cały produkt.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 36.0),
            GutterColumn(
              children: [
                TextFormField(
                  initialValue: model.id,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Kod kreskowy',
                  ),
                  style: const TextStyle(color: AppColors.primaryDarker),
                ),
                TextFormField(
                  initialValue: model.name,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa produktu',
                  ),
                  onChanged: (value) => onNameChanged(value.trim()),
                  validator: Validators.required('Uzupełnij nazwę produktu'),
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  initialValue: model.keywords.join(' '),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Słowa kluczowe',
                  ),
                  onChanged: (value) => onKeywordsChanged(
                    value.split(' ').map((e) => e.toLowerCase().trim()).toList()
                      ..removeWhere((element) => element.isEmpty),
                  ),
                ),
              ],
            ),
            ConditionalBuilder(
              condition: confirmedVariant != null || variant != null,
              ifTrue: () => Column(
                children: [
                  const SizedBox(height: 16.0),
                  _VariantItem(
                    variant: confirmedVariant ?? variant!,
                    onVariantDismissed: onVariantDismissed,
                    onVariantConfirmed: onVariantConfirmed,
                    onVariantCanceled: onVariantCanceled,
                    confirmed: confirmedVariant != null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ConditionalBuilder(
              condition: confirmedVariant == null,
              ifTrue: () => ElevatedButton(
                onPressed: isStepValid ? onNextPressed : null,
                child: const Text('Następny krok'),
              ),
              ifFalse: () => Column(
                children: [
                  Text(
                    'Ponieważ oznaczono produkt jako wariant, to pozostałe dane zostaną uzupełnione na podstawie bazowego produktu.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: isStepValid ? onSubmitPressed : null,
                    child: const Center(
                      child: Text('Zapisz produkt'),
                    ),
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

class _VariantItem extends StatelessWidget {
  const _VariantItem({
    Key? key,
    required this.variant,
    required this.onVariantDismissed,
    required this.onVariantConfirmed,
    required this.onVariantCanceled,
    required this.confirmed,
  }) : super(key: key);

  final Product variant;
  final VoidCallback onVariantDismissed;
  final VoidCallback onVariantConfirmed;
  final VoidCallback onVariantCanceled;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              confirmed ? 'Oznaczono jako wariant produktu' : 'Czy jest to wariant tego produktu?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                ProductPhoto(product: variant),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    variant.name.overflowFix,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            GutterRow(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (confirmed)
                  OutlinedButton(
                    key: const Key('variant_cancel'),
                    onPressed: onVariantCanceled,
                    child: const Text('Cofnij'),
                  ),
                if (!confirmed) ...[
                  OutlinedButton(
                    key: const Key('variant_dismiss'),
                    onPressed: onVariantDismissed,
                    child: const Text('Nie'),
                  ),
                  ElevatedButton(
                    key: const Key('variant_confirm'),
                    onPressed: onVariantConfirmed,
                    child: const Text('Tak'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
