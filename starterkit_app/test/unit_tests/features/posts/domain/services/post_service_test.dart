import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:starterkit_app/core/data/database/app_database.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/infrastructure/logging/logger.dart';
import 'package:starterkit_app/core/infrastructure/platform/connectivity_service.dart';
import 'package:starterkit_app/features/post/data/local/post_repository.dart';
import 'package:starterkit_app/features/post/data/remote/post_api.dart';
import 'package:starterkit_app/features/post/domain/models/post_data_contract.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';
import 'package:starterkit_app/features/post/domain/services/post_service.dart';

import '../../../../../test_matchers.dart';
import 'post_service_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<Logger>(),
  MockSpec<PostApi>(),
  MockSpec<PostRepository>(),
  MockSpec<ConnectivityService>(),
])
void main() {
  group(PostService, () {
    late MockPostApi mockPostApi;
    late MockPostRepository mockPostRepository;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      mockPostApi = MockPostApi();
      mockPostRepository = MockPostRepository();
      mockConnectivityService = MockConnectivityService();
      provideDummy(
        const PostDataObject(
          id: 'abc',
          postId: 0,
          userId: 1,
          title: '',
          body: '',
        ),
      );
      provideDummy(PostEntity.empty);
    });

    PostService createUnitToTest() {
      return PostService(
        MockLogger(),
        mockPostApi,
        mockPostRepository,
        mockConnectivityService,
      );
    }

    group('getPosts', () {
      test('should return posts from api when internet is connected', () async {
        const Iterable<PostDataContract> expectedContracts = <PostDataContract>[
          PostDataContract(userId: 1, id: 1, title: '', body: ''),
        ];
        const Iterable<PostEntity> expectedEntities = <PostEntity>[
          PostEntity(userId: 1, id: 1, title: '', body: ''),
        ];
        final Iterable<PostDataObject> expectedObjects = <PostDataObject>[
          const PostDataObject(id: 'abc', postId: 1, userId: 1, title: '', body: ''),
        ];

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPosts()).thenAnswer((_) async => expectedContracts.toList());
        when(mockPostRepository.getAll()).thenAnswer((_) async => expectedObjects);

        final PostService unit = createUnitToTest();
        final Success<Iterable<PostEntity>> result = await unit.getPosts() as Success<Iterable<PostEntity>>;

        verify(mockPostApi.getPosts()).called(1);
        expect(result.value, equals(expectedEntities));
      });

      test('should add new posts to repository when internet is connected', () async {
        const Iterable<PostDataContract> expectedContracts = <PostDataContract>[
          PostDataContract(userId: 1, id: 1, title: '', body: ''),
        ];

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPosts()).thenAnswer((_) async => expectedContracts.toList());

        final PostService unit = createUnitToTest();
        await unit.getPosts();

        verify(mockPostRepository.addOrUpdateAll(anyInstanceOf<Iterable<PostDataObject>>())).called(1);
      });

      test('should remove existing posts from repository when internet is connected', () async {
        const Iterable<PostDataContract> expectedContracts = <PostDataContract>[
          PostDataContract(userId: 1, id: 1, title: '', body: ''),
        ];
        final Iterable<PostDataObject> expectedObjects = <PostDataObject>[
          const PostDataObject(id: 'abc', postId: 1, userId: 1, title: '', body: ''),
        ];

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPosts()).thenAnswer((_) async => expectedContracts.toList());
        when(mockPostRepository.getAll()).thenAnswer((_) async => expectedObjects);

        final PostService unit = createUnitToTest();
        await unit.getPosts();

        verify(mockPostRepository.removeAll(anyInstanceOf<Iterable<Object>>())).called(1);
      });

      test('should return posts from repository when internet is not connected', () async {
        final Iterable<PostDataObject> expectedObjects = <PostDataObject>[
          const PostDataObject(id: 'abc', postId: 1, userId: 1, title: '', body: ''),
        ];
        const Iterable<PostEntity> expectedEntities = <PostEntity>[
          PostEntity(userId: 1, id: 1, title: '', body: ''),
        ];

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);
        when(mockPostRepository.getAll()).thenAnswer((_) async => expectedObjects);

        final PostService unit = createUnitToTest();
        final Success<Iterable<PostEntity>> successResult = await unit.getPosts() as Success<Iterable<PostEntity>>;

        verifyNever(mockPostApi.getPosts());
        verify(mockPostRepository.getAll()).called(1);
        expect(successResult.value, equals(expectedEntities));
      });

      test('should return failure when get posts fails', () async {
        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPosts()).thenThrow(Exception());

        final PostService unit = createUnitToTest();
        final Result<Iterable<PostEntity>> result = await unit.getPosts();

        verify(mockPostApi.getPosts()).called(1);
        expect(result.isSuccess, isFalse);
      });
    });

    group('getPost', () {
      test('should return post from api when internet is connected', () async {
        const int expectedPostId = 1;
        const PostDataContract expectedContract = PostDataContract(userId: 1, id: expectedPostId, title: '', body: '');
        const PostEntity expectedEntity = PostEntity(userId: 1, id: expectedPostId, title: '', body: '');
        const PostDataObject expectedObject = PostDataObject(
          id: 'abc',
          postId: expectedPostId,
          userId: 1,
          title: '',
          body: '',
        );

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPost(expectedPostId)).thenAnswer((_) async => expectedContract);
        when(mockPostRepository.getPost(expectedPostId)).thenAnswer((_) async => expectedObject);

        final PostService unit = createUnitToTest();
        final Success<PostEntity> successResult = await unit.getPost(expectedPostId) as Success<PostEntity>;

        verify(mockPostApi.getPost(expectedPostId)).called(1);
        expect(successResult.value, equals(expectedEntity));
      });

      test('should add new post to repository when internet is connected', () async {
        const int expectedId = 1;
        const PostDataContract expectedContract = PostDataContract(userId: 1, id: expectedId, title: '', body: '');

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPost(expectedId)).thenAnswer((_) async => expectedContract);
        when(
          mockPostRepository.getPost(expectedId),
        ).thenAnswer((_) async => const PostDataObject(id: 'abc', postId: expectedId, userId: 1, title: '', body: ''));

        final PostService unit = createUnitToTest();
        await unit.getPost(expectedId);

        verify(mockPostRepository.deletePost(expectedId)).called(1);
        verify(mockPostRepository.addOrUpdate(anyInstanceOf<PostDataObject>())).called(1);
      });

      test('should return post from repository when internet is not connected', () async {
        const int expectedId = 1;
        const PostDataObject expectedObject = PostDataObject(
          id: 'abc',
          postId: expectedId,
          userId: 1,
          title: '',
          body: '',
        );
        const PostEntity expectedEntity = PostEntity(userId: 1, id: expectedId, title: '', body: '');

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);
        when(mockPostRepository.getPost(expectedId)).thenAnswer((_) async => expectedObject);

        final PostService unit = createUnitToTest();
        final Success<PostEntity> successResult = await unit.getPost(expectedId) as Success<PostEntity>;

        verifyNever(mockPostApi.getPost(expectedId));
        verify(mockPostRepository.getPost(expectedId)).called(1);
        expect(successResult.value, equals(expectedEntity));
      });

      test('should return failure when get post fails', () async {
        const int expectedId = 1;

        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
        when(mockPostApi.getPost(expectedId)).thenThrow(Exception());

        final PostService unit = createUnitToTest();
        final Result<PostEntity> result = await unit.getPost(expectedId);

        verify(mockPostApi.getPost(expectedId)).called(1);
        expect(result.isSuccess, isFalse);
      });
    });
  });
}
