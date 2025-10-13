import 'package:injectable/injectable.dart';
import 'package:starterkit_app/core/data/database/app_database.dart';
import 'package:starterkit_app/core/domain/models/result.dart';
import 'package:starterkit_app/core/infrastructure/logging/logger.dart';
import 'package:starterkit_app/core/infrastructure/platform/connectivity_service.dart';
import 'package:starterkit_app/features/post/data/local/post_repository.dart';
import 'package:starterkit_app/features/post/data/remote/post_api.dart';
import 'package:starterkit_app/features/post/domain/exceptions/get_post_exception.dart';
import 'package:starterkit_app/features/post/domain/exceptions/get_posts_exception.dart';
import 'package:starterkit_app/features/post/domain/models/post_data_contract.dart';
import 'package:starterkit_app/features/post/domain/models/post_data_table.dart';
import 'package:starterkit_app/features/post/domain/models/post_entity.dart';

@lazySingleton
class PostService {
  final Logger _logger;
  final PostApi _postApi;
  final PostRepository _postRepository;
  final ConnectivityService _connectivityService;

  PostService(
    this._logger,
    this._postApi,
    this._postRepository,
    this._connectivityService,
  ) {
    _logger.logFor<PostService>();
  }

  Future<Result<Iterable<PostEntity>>> getPosts() async {
    try {
      _logger.log(LogLevel.info, 'Getting posts');

      final bool isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        final List<PostDataContract> contracts = await _postApi.getPosts();
        final List<PostDataObject> dataObjects = contracts.map((PostDataContract c) => c.toDataObject()).toList();
        final Iterable<PostDataObject> existingDataObjects = await _postRepository.getAll();

        if (existingDataObjects.isNotEmpty) {
          await _postRepository.removeAll(existingDataObjects.map((PostDataObject dataObject) => dataObject.id));
        }

        await _postRepository.addOrUpdateAll(dataObjects);
      }

      final Iterable<PostDataObject> dataObjects = await _postRepository.getAll();
      final Iterable<PostEntity> entities = dataObjects.map((PostDataObject d) => d.toEntity());

      _logger.log(LogLevel.info, '${entities.length} posts loaded');

      return Success<Iterable<PostEntity>>(entities);
    } catch (e, st) {
      _logger.log(LogLevel.error, 'Error getting posts', e, st);
      return Failure<Iterable<PostEntity>>(GetPostsException('Error getting posts', e, st));
    }
  }

  Future<Result<PostEntity>> getPost(int postId) async {
    try {
      _logger.log(LogLevel.info, 'Getting post with ID: $postId');

      final bool isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        final PostDataContract contract = await _postApi.getPost(postId);
        final PostDataObject dataObject = contract.toDataObject();
        await _postRepository.deletePost(dataObject.postId);
        await _postRepository.addOrUpdate(dataObject);
      }

      final PostDataObject? dataObject = await _postRepository.getPost(postId);

      if (dataObject == null) {
        return const Failure<PostEntity>(GetPostException('Post not found'));
      }

      final PostEntity entity = dataObject.toEntity();

      _logger.log(LogLevel.info, 'Post with ID: $postId loaded successfully');

      return Success<PostEntity>(entity);
    } catch (e, st) {
      _logger.log(LogLevel.error, 'Error getting post', e, st);
      return Failure<PostEntity>(GetPostException('Error getting post', e, st));
    }
  }
}
