
import 'package:json_annotation/json_annotation.dart';
import 'package:tinodeflutter/helpers/bind_json.dart';
import 'package:tinodeflutter/model/MessageModel.dart';
import 'package:tinodeflutter/model/userModel.dart';
import 'package:tinodeflutter/tinode/src/models/topic-subscription.dart';



class MessageRoomModel {
  late String id; 
  late String? creator_id;
  late String? name;
  late String description;
  late List<UserModel>? userList;
  late bool is_group_room;
  late bool is_my_room;
  late String? created_at;
  late String? updated_at;
  late String? deleted_at;
  late String? touched_at;
  late MessageModel? last_message;
  String? last_chat_at;
  late int unread_count;
  int? read;
  int? recv;
  int? seq;
  TopicSubscription? topicSubscription;

   MessageRoomModel(
      {required this.id,
      required this.is_group_room,
      required this.is_my_room,
      required this.unread_count,
      this.name,
      this.creator_id,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.last_message,
      this.last_chat_at,
      this.touched_at,
      this.read,
      this.recv,
      this.seq,
      this.topicSubscription,
      this.userList});


  MessageRoomModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        creator_id = json['creator_id'] ?? "",
        name = json['name'] ?? "",
        unread_count = json['unread_count'] ?? 0,
        is_group_room = json['is_group_room']?? false,
        is_my_room = json['is_my_room']?? false,
        description = json['description'] ?? "",
        created_at = json['created_at'] ?? "",
        updated_at = json['updated_at'] ?? "",
        deleted_at = json["deleted_at"] ?? "",
        last_chat_at = json["last_chat_at"] ?? "",
        last_message = json["last_message"] ?? "";

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'channel_id': id,
        'name': name,
        "creator_id": creator_id,
        "description": description,
        "unread_count": unread_count,
        "is_group_room": is_group_room,
        "is_my_room": is_my_room,
        "created_at": created_at,
        "updated_at": updated_at,
        "deleted_at": deleted_at,
        "last_chat_at": last_chat_at,
        "last_message": last_message,
      };
}