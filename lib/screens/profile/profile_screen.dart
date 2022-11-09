import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/screens/profile/profile_page.dart';
import 'package:inzynierka/screens/profile/profile_list_page.dart';
import 'package:inzynierka/screens/profile/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

enum ProfileScreenPages {
  profile,
  savedProducts,
  sortProposals,
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

    Future<bool> returnToProfile() async {
      if (visiblePage.value != ProfileScreenPages.profile) {
        visiblePage.value = ProfileScreenPages.profile;
        return false;
      }
      return true;
    }

    return Scaffold(
      body: WillPopScope(
        onWillPop: returnToProfile,
        child: PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) => SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.white,
            child: child,
          ),
          layoutBuilder: (entries) => Stack(
            alignment: Alignment.topCenter,
            children: entries,
          ),
          reverse: previousPage != null && previousPage != ProfileScreenPages.profile,
          child: {
            ProfileScreenPages.profile: ProfilePage(
              user: user,
              onPageChanged: (page) => visiblePage.value = page,
            ),
            ProfileScreenPages.savedProducts: ProfileListPage(
              productsIds: user.savedProducts,
              title: const SavedProductsTitle(),
            ),
            ProfileScreenPages.sortProposals: ProfileListPage(
              productsIds: user.verifiedSortProposals,
              title: const SortProposalsTitle(),
            ),
          }[visiblePage.value],
        ),
      ),
    );
  }
}
