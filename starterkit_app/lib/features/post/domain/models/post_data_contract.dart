import 'package:starterkit_app/core/data/database/app_database.dart';
import 'package:starterkit_app/core/domain/models/json_serializable_object.dart';
import 'package:uuid/uuid.dart';

part 'post_data_contract.g.dart';

@JsonSerializable()
class PostDataContract extends JsonSerializableObject {
  final int userId;

  final int id;

  final String title;

  final String body;

  const PostDataContract({required this.userId, required this.id, required this.title, required this.body});

  factory PostDataContract.fromJson(Map<String, dynamic> json) => _$PostDataContractFromJson(json);
}

extension PostDataContractExtension on PostDataContract {
  PostDataObject toDataObject() {
    return PostDataObject(
      id: const Uuid().v4(),
      postId: id,
      userId: userId,
      title: title,
      body: body,
    );
  }
}
