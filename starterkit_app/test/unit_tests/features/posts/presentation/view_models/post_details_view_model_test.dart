import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/infrastructure/logging/logger.dart';
import 'package:starterkit_app/core/presentation/navigation/navigation_router.gr.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/domain/services/post_service.dart';
import 'package:starterkit_app/features/post/presentation/view_models/post_details_view_model.dart';

import 'post_details_view_model_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Logger>(),
  MockSpec<PostService>(),
])
void main() {
  group(PostDetailsViewModel, () {
    late MockPostService mockPostService;

    setUp(() {
      mockPostService = MockPostService();
      provideDummy<Result<PostEntity>>(Failure<PostEntity>(Exception()));
    });

    PostDetailsViewModel createUnitToTest() {
      return PostDetailsViewModel(mockPostService);
    }

    group('onInitialize', () {
      test('should get post when result is success', () async {
        final PostDetailsViewModel unit = createUnitToTest();
        const PostEntity expectedPost = PostEntity.empty;
        final int expectedPostId = expectedPost.id;
        when(mockPostService.getPost(expectedPostId)).thenAnswer((_) async => const Success<PostEntity>(expectedPost));

        await unit.onInitialize(PostDetailsViewRouteArgs(postId: expectedPostId));

        verify(mockPostService.getPost(expectedPostId)).called(1);
        expect(unit.post.value, equals(expectedPost));
      });

      test('should set post to empty when result is failure', () async {
        final PostDetailsViewModel unit = createUnitToTest();
        const int expectedPostId = 1;
        when(mockPostService.getPost(expectedPostId)).thenAnswer((_) async => Failure<PostEntity>(Exception()));

        await unit.onInitialize(const PostDetailsViewRouteArgs(postId: expectedPostId));

        verify(mockPostService.getPost(expectedPostId)).called(1);
        expect(unit.post.value, equals(PostEntity.empty));
      });
    });
  });
}
