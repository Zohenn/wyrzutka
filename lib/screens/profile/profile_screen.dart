import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
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
import 'package:inzynierka/widgets/future_handler.dart';

enum ProfileScreenPages {
  profile,
  savedProducts,
  sortProposals,
  addedProducts,
}

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  final AppUser? user;

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
        ifTrue: () => ProfileScreenContent(user: authUser!),
        ifFalse: () => const ProfileFeaturesScreen(),
      ),
    );
  }
}

class ProfileScreenContent extends HookConsumerWidget {
  const ProfileScreenContent({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visiblePage = useState(ProfileScreenPages.profile);
    final previousPage = usePrevious(visiblePage.value);

    final authUser = ref.watch(authUserProvider);
    final _user = authUser != user ? ref.watch(userProvider(user.id)) : user;

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
            user: _user!,
            onPageChanged: (page) => visiblePage.value = page,
          ),
          ProfileScreenPages.savedProducts: ProfileSavedProductsPage(user: _user),
          ProfileScreenPages.sortProposals: ProfileVerifiedSortProposalsPage(user: _user),
          ProfileScreenPages.addedProducts: ProfileAddedProductsPage(user: _user),
        }[visiblePage.value],
      ),
    );
  }
}
