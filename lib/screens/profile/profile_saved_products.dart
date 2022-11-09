import 'package:flutter/material.dart';

class SavedProductsTitle extends StatelessWidget {
  const SavedProductsTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('Zapisane produkty', style: Theme.of(context).textTheme.titleMedium);
  }
}

class SavedProductsError extends StatelessWidget {
  const SavedProductsError({
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
              Text('Brak zapisanych produktów', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
