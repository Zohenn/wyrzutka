import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';

class LoadMoreListView extends HookWidget {
  const LoadMoreListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoad,
    this.loadingBuilder = _defaultLoadingBuilder,
    this.padding = EdgeInsets.zero,
    this.showLoading = false,
    this.canLoad = true,
    this.targetExtent = 50.0,
    this.gutterSize = 16,
  }) : super(key: key);

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext) loadingBuilder;
  final Future Function() onLoad;
  final EdgeInsets padding;
  final bool showLoading;
  final bool canLoad;
  final double targetExtent;
  final double gutterSize;

  static Widget _defaultLoadingBuilder(BuildContext context) => const Center(child: CircularProgressIndicator());

  @override
  Widget build(BuildContext context) {
    final isFetchingMore = useState(false);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < targetExtent && canLoad && !isFetchingMore.value) {
          isFetchingMore.value = true;
          onLoad().whenComplete(
            () => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => isFetchingMore.value = false),
          );
        }

        return false;
      },
      child: ListView.separated(
        padding: padding,
        itemCount: isFetchingMore.value || showLoading ? itemCount + 1 : itemCount,
        separatorBuilder: (BuildContext context, int index) => SizedBox(height: gutterSize),
        itemBuilder: (BuildContext context, int index) => ConditionalBuilder(
          condition: index < itemCount,
          ifTrue: () => itemBuilder(context, index),
          ifFalse: () => loadingBuilder(context),
        ),
      ),
    );
  }
}
