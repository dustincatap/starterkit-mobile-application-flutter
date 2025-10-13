import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/core/presentation/view_models/initializable.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/domain/services/post_service.dart';

@injectable
class PostDetailsViewModel implements Initializable<PostDetailsViewRouteArgs> {
  final PostService _postService;

  PostDetailsViewModel(this._postService);

  final ValueNotifier<PostEntity> _post = ValueNotifier<PostEntity>(PostEntity.empty);
  ValueListenable<PostEntity> get post => _post;

  @override
  Future<void> onInitialize(PostDetailsViewRouteArgs? args) async {
    if (args == null) {
      return;
    }

    final Result<PostEntity> getPostResult = await _postService.getPost(args.postId);

    switch (getPostResult) {
      case Success<PostEntity>():
        _post.value = getPostResult.value;

      case Failure<PostEntity>():
        _post.value = PostEntity.empty;
    }
  }
}
