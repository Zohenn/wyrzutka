import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wyrzutka/hooks/init_future.dart';
import 'package:wyrzutka/repositories/repository.dart';
import 'package:wyrzutka/repositories/user_repository.dart';
import 'package:wyrzutka/screens/profile/profile_screen.dart';
import 'package:wyrzutka/screens/users/user_item.dart';
import 'package:wyrzutka/screens/widgets/search_input.dart';
import 'package:wyrzutka/services/user_service.dart';
import 'package:wyrzutka/utils/async_call.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:wyrzutka/widgets/future_handler.dart';
import 'package:wyrzutka/widgets/load_more_list_view.dart';

class UsersScreen extends HookConsumerWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.read(userServiceProvider);

    final searchText = useState('');
    final moderationIds = useState<List<String>>([]);
    final searchIds = useState<List<String>>([]);
    final users = ref.read(usersProvider(searchText.value.isEmpty ? moderationIds.value : searchIds.value));

    final initFuture = useInitFuture(
      () => userService.fetchNextModeration().then((value) => moderationIds.value = value.map((e) => e.id).toList()),
    );
    final searchFuture = useState<Future?>(null);
    final fetchedAll = useState(false);

    final isMounted = useIsMounted();

    useEffect(() {
      if (searchText.value.isNotEmpty) {
        searchFuture.value = userService.search(searchText.value).then((value) async {
          searchIds.value = value.map((user) => user.id).toList();
        });
      }

      return null;
    }, [searchText.value]);

    return SafeArea(
      child: FutureHandler(
        future: initFuture,
        data: () => NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchInput(
                  onSearch: (value) => searchText.value = value,
                  hintText: 'Wyszukaj użytkowników',
                ),
              ),
            ),
          ],
          body: FutureHandler(
            future: searchFuture.value,
            data: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConditionalBuilder(
                  condition: searchText.value.isEmpty,
                  ifTrue: () => Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text('Moderacja', style: Theme.of(context).textTheme.titleLarge),
                  ),
                ),
                Expanded(
                  child: LoadMoreListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    itemCount: users.length,
                    itemBuilder: (context, index) => UserItem(
                      key: Key(users[index].id),
                      user: users[index],
                      onTap: () => showDefaultBottomSheet(
                        context: context,
                        builder: (context) => ProfileScreenContent(userId: users[index].id),
                      ),
                    ),
                    canLoad: moderationIds.value.length >= Repository.batchSize &&
                        searchText.value.isEmpty &&
                        !fetchedAll.value,
                    onLoad: () => asyncCall(
                      context,
                      () => userService.fetchNextModeration(users.last.snapshot).then((value) {
                        if (isMounted()) {
                          moderationIds.value = [...moderationIds.value, ...value.map((user) => user.id)];
                          fetchedAll.value = value.length < Repository.batchSize;
                        }
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
