import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:wyrzutka/routing/router.dart';
import 'package:wyrzutka/theme/colors.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/screens/profile/profile_screen.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/default_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({
    Key? key,
    required this.user,
    this.radius = 20.0,
    this.openProfileOnTap = false,
  }) : super(key: key);

  final AppUser? user;
  final double radius;
  final bool openProfileOnTap;

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: user != null,
      ifTrue: () => CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: InkWell(
            onTap: openProfileOnTap
                ? () {
                    if (openProfileOnTap) {
                      showDefaultBottomSheet(
                        context: context,
                        builder: (context) => DefaultBottomSheet(
                          child: ProfileScreenContent(userId: user!.id),
                        ),
                      );
                    }
                  }
                : null,
            child: Center(
              child: Text(
                user!.name[0].toUpperCase() + user!.surname[0].toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ),
      ifFalse: () => Tooltip(
        message: 'Nie udało się załadować użytkownika',
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: const Icon(Icons.warning_amber, color: AppColors.warning),
        ),
      ),
    );
  }
}
