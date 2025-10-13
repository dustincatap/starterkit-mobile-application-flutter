import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:starterkit_app/common/localization/generated/l10n.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/infrastructure/logging/logger.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_service.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/domain/models/posts_list_state.dart';
import 'package:starterkit_app/features/post/domain/services/post_service.dart';
import 'package:starterkit_app/features/post/presentation/view_models/posts_view_model.dart';

import '../../../../../test_utils.dart';
import 'posts_view_model_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Logger>(),
  MockSpec<NavigationService>(),
  MockSpec<PostService>(),
])
void main() {
  group(PostsViewModel, () {
    late MockNavigationService mockNavigationService;
    late MockPostService mockPostService;
    late Il8n il8n;

    setUp(() async {
      mockNavigationService = MockNavigationService();
      mockPostService = MockPostService();
      il8n = await setupLocale();

      provideDummy<Result<Iterable<PostEntity>>>(Failure<Iterable<PostEntity>>(Exception()));
    });

    PostsViewModel createUnitToTest() {
      return PostsViewModel(mockNavigationService, mockPostService);
    }

    group('onInitialize', () {
      test('should get posts when called', () async {
        const List<PostEntity> expectedPostEntities = <PostEntity>[PostEntity.empty];
        const PostsListLoadedState expectedPostState = PostsListLoadedState(expectedPostEntities);
        when(mockPostService.getPosts()).thenAnswer((_) async => const Success<List<PostEntity>>(expectedPostEntities));

        final PostsViewModel unit = createUnitToTest();
        await unit.onInitialize(null);

        verify(mockPostService.getPosts()).called(1);
        await expectLater(unit.postsState.value, equals(expectedPostState));
      });

      test('should log error when get posts fails', () async {
        final PostsListErrorState expectedPostState = PostsListErrorState(il8n.failedToGetPosts);
        when(mockPostService.getPosts()).thenAnswer((_) async => Failure<List<PostEntity>>(Exception()));

        final PostsViewModel unit = createUnitToTest();
        await unit.onInitialize(null);

        verify(mockPostService.getPosts()).called(1);
        await expectLater(unit.postsState.value, equals(expectedPostState));
      });
    });

    group('onGetPosts', () {
      test('should add previous posts to new posts when called', () async {
        const List<PostEntity> expectedPostEntities = <PostEntity>[PostEntity.empty, PostEntity.empty];
        const PostsListLoadedState expectedPostState = PostsListLoadedState(expectedPostEntities);
        when(
          mockPostService.getPosts(),
        ).thenAnswer((_) async => const Success<List<PostEntity>>(<PostEntity>[PostEntity.empty]));

        final PostsViewModel unit = createUnitToTest();
        await unit.onInitialize(null);
        await unit.onGetPosts();

        verify(mockPostService.getPosts()).called(2);
        expect(unit.postsState.value, equals(expectedPostState));
      });
    });

    group('onPostSelected', () {
      test('should push post details view when called', () async {
        const PostEntity expectedPostEntity = PostEntity.empty;

        final PostsViewModel unit = createUnitToTest();
        await unit.onPostSelected(expectedPostEntity);

        verify(mockNavigationService.push(PostDetailsViewRoute(postId: expectedPostEntity.id))).called(1);
      });
    });
  });
}
