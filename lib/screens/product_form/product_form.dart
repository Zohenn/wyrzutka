import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/widgets/custom_stepper.dart';
import 'package:inzynierka/widgets/gutter_column.dart';
import 'package:inzynierka/widgets/gutter_row.dart';

class ProductForm extends StatelessWidget {
  const ProductForm({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
                CustomStepper(steps: const ['Informacje', 'Oznaczenia', 'Segregacja'], step: 0),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
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
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: (Theme.of(context).cardTheme.shape as RoundedRectangleBorder).borderRadius,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Icon(Icons.add_a_photo_outlined, size: 48),
                                        const SizedBox(height: 4.0),
                                        Text('Dodaj zdjęcie produktu', style: Theme.of(context).textTheme.titleMedium),
                                      ],
                                    ),
                                  ),
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
                            initialValue: id,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Kod kreskowy',
                              // fillColor: Color(0xfffafafa),
                            ),
                            style: const TextStyle(color: AppColors.primaryDarker),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nazwa produktu',
                            ),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Słowa kluczowe',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Następny krok'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
