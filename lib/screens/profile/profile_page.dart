import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/screens/profile/profile_list_container.dart';
import 'package:inzynierka/screens/profile/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals.dart';
import 'package:inzynierka/screens/profile/profile_user.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({
    Key? key,
    required this.user,
    required this.onPageChanged,
  }) : super(key: key);

  final AppUser user;
  final void Function(ProfileScreenPages) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          children: [
            ProfileUser(user: user),
            ProfileListContainer(
              productsIds: user.savedProducts,
              onPageChanged: onPageChanged,
              destination: ProfileScreenPages.savedProducts,
              title: const SavedProductsTitle(),
              error: const SavedProductsError(),
            ),
            ProfileListContainer(
              productsIds: user.verifiedSortProposals,
              onPageChanged: onPageChanged,
              destination: ProfileScreenPages.sortProposals,
              title: const SortProposalsTitle(),
              error: const SortProposalsError(),
            ),
          ],
        ),
      ),
    );
  }
}
