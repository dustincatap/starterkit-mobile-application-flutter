import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:starterkit_app/common/localization/generated/l10n.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_service.dart';
import 'package:starterkit_app/core/presentation/view_models/initializable.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/domain/models/posts_list_state.dart';
import 'package:starterkit_app/features/post/domain/services/post_service.dart';

@injectable
class PostsViewModel implements Initializable {
  final NavigationService _navigationService;
  final PostService _postService;

  PostsViewModel(this._navigationService, this._postService);

  final ValueNotifier<PostsListState> _postsState = ValueNotifier<PostsListState>(const PostsListLoadingState());
  ValueListenable<PostsListState> get postsState => _postsState;

  @override
  Future<void> onInitialize(Object? parameter) async {
    await onGetPosts();
  }

  Future<void> onGetPosts() async {
    final Result<Iterable<PostEntity>> getPostsResult = await _postService.getPosts();

    switch (getPostsResult) {
      case Success<Iterable<PostEntity>>(value: final Iterable<PostEntity> postsToBeAdded):
        _onAddNewPosts(postsToBeAdded);

      case Failure<Iterable<PostEntity>>():
        _postsState.value = PostsListErrorState(Il8n.current.failedToGetPosts);
    }
  }

  Future<void> onPostSelected(PostEntity post) async {
    await _navigationService.push(PostDetailsViewRoute(postId: post.id));
  }

  void _onAddNewPosts(Iterable<PostEntity> postsToBeAdded) {
    final List<PostEntity> newPosts = <PostEntity>[];

    if (_postsState.value case PostsListLoadedState(posts: final Iterable<PostEntity> currentPosts)) {
      newPosts.addAll(currentPosts);
    }

    newPosts.addAll(postsToBeAdded);

    _postsState.value = PostsListLoadedState(newPosts);
  }
}
