import 'package:equatable/equatable.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';

sealed class PostsListState {
  const PostsListState();
}

final class PostsListLoadingState extends PostsListState {
  const PostsListLoadingState();
}

final class PostsListLoadedState extends PostsListState with Equatable {
  const PostsListLoadedState(this.posts);

  final Iterable<PostEntity> posts;

  @override
  List<Object?> get props => <Object?>[posts];
}

final class PostsListErrorState extends PostsListState with Equatable {
  const PostsListErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
