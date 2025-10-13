import 'package:auto_route/auto_route.dart';
import 'package:context_plus/context_plus.dart';
import 'package:flutter/material.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/core/presentation/views/view_model_builder.dart';
import 'package:starterkit_app/core/presentation/views/view_model_provider.dart';
import 'package:starterkit_app/core/presentation/widgets/build_context_extensions.dart';
import 'package:starterkit_app/core/presentation/widgets/infinite_list_view.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/domain/models/posts_list_state.dart';
import 'package:starterkit_app/features/post/presentation/view_models/posts_view_model.dart';

@RoutePage()
class PostsView extends StatelessWidget {
  const PostsView() : super(key: const Key(PostsViewRoute.name));

  @override
  Widget build(BuildContext context) {
    return AutoViewModelBuilder<PostsViewModel>(
      builder: (BuildContext context, PostsViewModel viewModel) {
        return const _PostsView();
      },
    );
  }
}

class _PostsView extends StatelessWidget {
  const _PostsView();

  @override
  Widget build(BuildContext context) {
    final PostsViewModel viewModel = context.viewModel<PostsViewModel>();
    final PostsListState postsState = viewModel.postsState.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.il8n.posts),
      ),
      body: switch (postsState) {
        PostsListLoadingState _ => const Center(child: CircularProgressIndicator()),
        PostsListLoadedState _ => _PostsListView(
          posts: postsState.posts.toList(),
          onTap: viewModel.onPostSelected,
          onScrollEnd: viewModel.onGetPosts,
        ),
        PostsListErrorState _ => Center(child: Text(postsState.message)),
      },
    );
  }
}

class _PostsListView extends StatelessWidget {
  const _PostsListView({
    required this.posts,
    required this.onTap,
    required this.onScrollEnd,
  });

  final List<PostEntity> posts;
  final void Function(PostEntity entity) onTap;
  final VoidCallback onScrollEnd;

  @override
  Widget build(BuildContext context) {
    return InfiniteListView(
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        Widget? listWidget;
        final PostEntity? post = posts.elementAtOrNull(index);

        if (post != null) {
          listWidget = ListTile(
            key: Key(post.id.toString()),
            title: Text(post.title),
            subtitle: Text(post.body),
            onTap: () => onTap(post),
          );
        }

        return listWidget;
      },
      onScrollEnd: onScrollEnd,
    );
  }
}
