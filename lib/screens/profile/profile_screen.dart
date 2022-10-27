import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/product_form/product_form.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/screens/profile/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals.dart';
import 'package:inzynierka/screens/profile/profile_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/gutter_column.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({
    Key? key,
    this.user,
    this.isMainUser = false,
  }) : super(key: key);

  final AppUser? user;
  final bool isMainUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDefaultBottomSheet(
          context: context,
          fullScreen: true,
          builder: (context) => ProductForm(id: '5901501001181'),
        );
      });
      return null;
    }, []);
    return ConditionalBuilder(
      condition: user != null || authUser != null,
      ifTrue: () => ConditionalBuilder(
        condition: user != null,
        ifTrue: () => ProfileScreenContent(user: user!),
        ifFalse: () => ProfileScreenContent(user: authUser!, isMainUser: isMainUser),
      ),
      ifFalse: () => const ProfileFeaturesScreen(),
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

  Widget wrapPage(Widget child, ValueKey<int> key) {
    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(0);

    List<Widget> pages = [
      GutterColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        gutterSize: 24.0,
        children: [
          ProfileUser(
            user: user,
            isMainUser: isMainUser,
          ),
          ProfileSavedProducts(
            user: user,
            count: 2,
            onNextPressed: () => step.value = 1,
          ),
          ProfileSortProposals(
            user: user,
            count: 2,
            onNextPressed: () => step.value = 2,
          ),
        ],
      ),
      ProfileSavedProducts(
        user: user,
        onNextPressed: () => step.value = 1,
      ),
      ProfileSortProposals(
        user: user,
        onNextPressed: () => step.value = 2,
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (step.value > 0) {
          step.value--;
          return false;
        }
        return true;
      },
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
        child: [
          for (int i=0; i<pages.length; i++) ...[
            wrapPage(
              pages[i],
              ValueKey<int>(i),
            ),
          ]
        ][step.value],
      ),
    );
  }
}
