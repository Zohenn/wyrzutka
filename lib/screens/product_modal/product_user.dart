import 'package:flutter/material.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/screens/widgets/avatar_icon.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';

class ProductUser extends StatelessWidget {
  const ProductUser({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConditionalBuilder(
          condition: user != null,
          ifTrue: () => Row(
            children: [
              AvatarIcon(
                user: user!,
                openProfileOnTap: true,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produkt dodany przez',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    user!.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
          ifFalse: () => Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.warning_amber, color: AppColors.warning),
              ),
              SizedBox(width: 16.0),
              Flexible(
                child: Text('Nie udało się załadować użytkownika'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
