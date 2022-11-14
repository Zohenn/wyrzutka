import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/hooks/init_future.dart';
import 'package:inzynierka/repositories/base_repository.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/screens/users/user_item.dart';
import 'package:inzynierka/services/user_service.dart';
import 'package:inzynierka/utils/async_call.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/future_handler.dart';
import 'package:inzynierka/widgets/load_more_list_view.dart';

class UsersScreen extends HookConsumerWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.read(userServiceProvider);

    final moderationIds = useState<List<String>>([]);
    final moderation = ref.read(usersProvider(moderationIds.value));
    final initFuture = useInitFuture(
      () => userService.fetchNextModeration().then((value) => moderationIds.value = value.map((e) => e.id).toList()),
    );

    final isMounted = useIsMounted();
    final fetchedAll = useState(false);

    return SafeArea(
      child: FutureHandler(
        future: initFuture,
        data: () => NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: Text('Search')),
          ],
          body: LoadMoreListView(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            itemCount: moderation.length,
            itemBuilder: (context, index) => UserItem(
              user: moderation[index],
              onTap: () => showDefaultBottomSheet(
                context: context,
                builder: (context) => ProfileScreenContent(user: moderation[index]),
              ),
            ),
            canLoad: moderationIds.value.length >= BaseRepository.batchSize && !fetchedAll.value,
            onLoad: () => asyncCall(
              context,
              () => userService.fetchNextModeration(moderation.last.snapshot).then((value) {
                if (isMounted()) {
                  moderationIds.value = [...moderationIds.value, ...value.map((user) => user.id)];
                  fetchedAll.value = value.length < BaseRepository.batchSize;
                }
              }),
            ),
          ),
        ),
      ),
    );
  }
}
