import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/page/profile_added_products.dart';
import 'package:inzynierka/screens/profile/page/profile_page.dart';
import 'package:inzynierka/screens/profile/page/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/page/profile_sort_proposals.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/utils/shared_axis_transition_builder.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

enum ProfileScreenPages {
  profile,
  savedProducts,
  sortProposals,
  addedProducts,
}

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    // useEffect(() {
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     showDefaultBottomSheet(
    //       context: context,
    //       fullScreen: true,
    //       builder: (context) => ProductForm(id: '5901501001182'),
    //     );
    //   });
    //   return null;
    // }, []);
    return SafeArea(
      child: ConditionalBuilder(
        condition: authUser != null,
        ifTrue: () => ProfileScreenContent(userId: authUser!.id),
        ifFalse: () => const ProfileFeaturesScreen(),
      ),
    );
  }
}

class ProfileScreenContent extends HookConsumerWidget {
  const ProfileScreenContent({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visiblePage = useState(ProfileScreenPages.profile);
    final previousPage = usePrevious(visiblePage.value);

    final user = ref.watch(userProvider(userId));

    return WillPopScope(
      onWillPop: () async {
        if (visiblePage.value != ProfileScreenPages.profile) {
          visiblePage.value = ProfileScreenPages.profile;
          return false;
        }
        return true;
      },
      child: PageTransitionSwitcher(
        transitionBuilder: sharedAxisTransitionBuilder,
        layoutBuilder: (entries) => Stack(
          alignment: Alignment.topCenter,
          children: entries,
        ),
        reverse: previousPage != null && previousPage != ProfileScreenPages.profile,
        child: {
          ProfileScreenPages.profile: ProfilePage(
            user: user!,
            onPageChanged: (page) => visiblePage.value = page,
          ),
          ProfileScreenPages.savedProducts: ProfileSavedProductsPage(user: user),
          ProfileScreenPages.sortProposals: ProfileVerifiedSortProposalsPage(user: user),
          ProfileScreenPages.addedProducts: ProfileAddedProductsPage(user: user),
        }[visiblePage.value],
      ),
    );
  }
}
