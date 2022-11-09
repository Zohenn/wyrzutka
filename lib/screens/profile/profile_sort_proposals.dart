import 'package:flutter/material.dart';

class SortProposalsTitle extends StatelessWidget {
  const SortProposalsTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Propozycje segregacji',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'Zweryfikowane przez system',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class SortProposalsError extends StatelessWidget {
  const SortProposalsError({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                child: Icon(Icons.star_half),
              ),
              const SizedBox(width: 16.0),
              Text(
                'Brak zweryfikowanych propozycji',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
