import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/utils/validators.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProductFormInformation extends StatelessWidget {
  const ProductFormInformation({
    Key? key,
    required this.model,
    required this.onNameChanged,
    required this.onKeywordsChanged,
    required this.onPhotoChanged,
    required this.onNextPressed,
  }) : super(key: key);

  final ProductFormModel model;
  final void Function(String) onNameChanged;
  final void Function(String) onKeywordsChanged;
  final void Function(XFile) onPhotoChanged;
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
                                    onPhotoChanged(image);
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
                  initialValue: model.keywords,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Słowa kluczowe',
                  ),
                  onChanged: onKeywordsChanged,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: isStepValid ? onNextPressed : null,
              child: const Text('Następny krok'),
            ),
          ],
        ),
      ),
    );
  }
}
