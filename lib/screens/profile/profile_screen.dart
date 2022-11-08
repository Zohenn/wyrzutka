import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/screens/profile/profile_page.dart';
import 'package:inzynierka/screens/profile/profile_saved_products_page.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals_page.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

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
        ifTrue: () => ProfileScreenContent(user: authUser!, isMainUser: true),
        ifFalse: () => const ProfileFeaturesScreen(),
      ),
    );
  }
}

class ProfileScreenContent extends HookConsumerWidget {
  const ProfileScreenContent({
    Key? key,
    required this.user,
    this.isMainUser = false,
  }) : super(key: key);

  final AppUser user;
  final bool isMainUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(0);

    Future<bool> returnToProfile() async {
      step.value = 0;
      return false;
    }

    return Scaffold(
      body: PageTransitionSwitcher(
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
          child: [
            ProfilePage(user: user, isMainUser: isMainUser, pageStep: step),
            WillPopScope(
              onWillPop: returnToProfile,
              child: ProfileSavedProductsPage(user: user),
            ),
            WillPopScope(
              onWillPop: returnToProfile,
              child: ProfileSortProposalsPage(user: user),
            ),
          ][step.value],
        ),
    );
  }
}