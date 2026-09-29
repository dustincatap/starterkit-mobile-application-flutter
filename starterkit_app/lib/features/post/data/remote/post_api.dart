// coverage:ignore-file

import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:starterkit_app/core/data/api/dio_provider.dart';
import 'package:starterkit_app/features/post/domain/models/post_data_contract.dart';

part 'post_api.g.dart';

@lazySingleton
@RestApi()
abstract interface class PostApi {
  @factoryMethod
  factory PostApi(DioProvider dioProvider) => _PostApi(dioProvider.create<PostApi>());

  @GET('/posts')
  @jsonContentType
  Future<List<PostDataContract>> getPosts();

  @GET('/posts/{id}')
  @jsonContentType
  Future<PostDataContract> getPost(@Path('id') int id);
}
