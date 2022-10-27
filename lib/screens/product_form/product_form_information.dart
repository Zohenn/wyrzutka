import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/product/product.dart';
import 'package:inzynierka/screens/image_crop_modal.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/widgets/product_photo.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/utils/text_overflow_ellipsis_fix.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/gutter_row.dart';

class ProductFormInformation extends HookWidget {
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

  bool get isStepValid => model.name.isNotEmpty && model.keywords.isNotEmpty && model.photo != null;

  @override
  Widget build(BuildContext context) {
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
                  constraints: BoxConstraints(maxHeight: 250),
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
                            condition: model.photo == null,
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
                            ifFalse: () => Image.file(File(model.photo!.path)),
                          ),
                          Positioned.fill(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                  if (image != null) {
                                    // todo: crop image to square
                                    final croppedImage = await showDefaultBottomSheet<File>(
                                      context: context,
                                      fullScreen: true,
                                      builder: (context) => ImageCropModal(image: File(image.path)),
                                    );
                                    print(croppedImage);
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
                  onChanged: onNameChanged,
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
                    value.split(' ').map((e) => e.toLowerCase()).toList()..removeWhere((element) => element.isEmpty),
                  ),
                ),
              ],
            ),
            ConditionalBuilder(
              condition: confirmedVariant != null || variant != null,
              ifTrue: () => Column(
                children: [
                  SizedBox(height: 16.0),
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
            ElevatedButton(
              onPressed: isStepValid ? onNextPressed : null,
              child: const Text('Następny krok'),
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
                SizedBox(width: 16.0),
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
                    key: Key('variant_cancel'),
                    onPressed: onVariantCanceled,
                    child: Text('Cofnij'),
                  ),
                if (!confirmed) ...[
                  OutlinedButton(
                    key: Key('variant_dismiss'),
                    onPressed: onVariantDismissed,
                    child: Text('Nie'),
                  ),
                  ElevatedButton(
                    key: Key('variant_confirm'),
                    onPressed: onVariantConfirmed,
                    child: Text('Tak'),
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
