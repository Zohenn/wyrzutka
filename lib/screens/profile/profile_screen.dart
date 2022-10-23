import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/screens/profile/profile_saved_products.dart';
import 'package:inzynierka/screens/profile/profile_sort_proposals.dart';
import 'package:inzynierka/screens/profile/profile_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/custom_stepper.dart';
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
    final step = useState(0);

    final List<String> steps = ['Profil', 'Produkty', 'Segregacja'];
    final List<Widget> pages = [
      ProfileUser(
        user: user,
        onNextPressed: () => step.value = 1,
      ),
      ProfileSavedProducts(
        user: user,
        onNextPressed: () => step.value = 2,
      ),
      ProfileSortProposals(
        user: user,
        onNextPressed: () => step.value = 0,
      ),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GutterColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomStepper(steps: steps, step: step.value),
            PageTransitionSwitcher(
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
              child: pages[step.value],
            ),
          ],
        ),
      ),
    );
  }
}
