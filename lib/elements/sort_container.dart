import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/sortElement.dart';
import '../models/sort.dart';

class SortContainer extends StatelessWidget {
  final Sort sort;
  final String? verified;

  Map<String, List<SortElement>> get elements {
    return groupBy([...sort.elements], (SortElement element) => element.name);
  }

  String getFullContainerName(String name) {
    switch(name) {
      case 'plastic': return 'Metale i tworzywa sztuczne';
      case 'paper': return 'Papier';
      case 'bio': return 'Bytowe';
      case 'mixed': return 'Zmieszane';
      case 'glass': return 'Szkło';
    }
    return 'Brak';
  }

  const SortContainer({Key? key, required this.sort, this.verified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < elements.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: getContainerColor(context, elements.keys.elementAt(i))),
                    child: Icon(Icons.question_mark, color: getContainerIconColor(elements.keys.elementAt(i))),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    getFullContainerName(elements.keys.elementAt(i)),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ThemeData.light().colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            for (int j = 0; j < elements.values.elementAt(i).length; j++) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      elements.values.elementAt(i).elementAt(j).container,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: ThemeData.light().colorScheme.onSurface,
                          ),
                    ),
                    if (elements.values.elementAt(i).elementAt(j).description != null)
                      Text(
                        elements.values.elementAt(i).elementAt(j).description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: ThemeData.light().colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              const Divider(color: Color(0xffE0E0E0), thickness: 2),
            ],
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: verified != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.done, color: AppColors.positive),
                      const SizedBox(width: 8),
                      Text(
                        "Zweryfikowano",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black),
                      )
                    ],
                  )
                : const Text("TODO"),
          ),
        ],
      ),
    );
  }
}
