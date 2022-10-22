import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/screens/profile/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals.dart';
import 'package:inzynierka/screens/profile/profile_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key, this.user}) : super(key: key);

  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    return ConditionalBuilder(
      condition: user != null,
      ifTrue: () => ProfileScreenContent(user: user!),
      ifFalse: () => ConditionalBuilder(
        condition: authUser != null,
        ifTrue: () => ProfileScreenContent(user: authUser!),
        ifFalse: () => const ProfileFeaturesScreen(),
      ),
    );
  }
}

class ProfileScreenContent extends HookConsumerWidget {
  const ProfileScreenContent({Key? key, required this.user}) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileUser(user: user),
            ProfileSavedProducts(user: user),
            ProfileSortProposals(user: user),
          ],
        ),
      ),
    );
  }
}
