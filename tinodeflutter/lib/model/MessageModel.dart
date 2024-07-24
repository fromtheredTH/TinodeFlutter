
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:tinodeflutter/helpers/bind_json.dart';
import 'package:tinodeflutter/model/userModel.dart';



class MessageModel {
  int id;
  String? unsended_at;
  String? contents;
  int room_id;
  String sender_id;
  int type;
  int parent_id;
  String? created_at;
  String? updated_at;
  String? deleted_at;
  UserModel? sender;
  int? chat_idx;
  MessageModel? parent_chat;
  int? unread_count;
  List<File> file = [];
  int? fileProgress;
  int? totalProgress;
  int? audioTime;
  bool? isPlayAudio;


    MessageModel(
      {required this.id,
      this.unsended_at,
      this.contents,
      required this.room_id,
      required this.sender_id,
      required this.type,
      required this.parent_id,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.sender,
      this.chat_idx,
      this.parent_chat,
      this.unread_count,
      this.audioTime,
      this.isPlayAudio});

  MessageModel.fromJson(Map<String, dynamic> json)
      :  
      id= json['id'],
      unsended_at= json['unsended_at'] as String?,
      contents= json['contents'] as String?,
      room_id= json['room_id'],
      sender_id= json['sender_id'],
      type= json['type'],
      parent_id= json['parent_id'],
      created_at= json['created_at'] as String?,
      updated_at= json['updated_at'] as String?,
      deleted_at= json['deleted_at'] as String?,
      sender= json['sender'] == null ? null: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      chat_idx= json['chat_idx'] ==null ? 0 : 0,
      parent_chat= json['parent_chat'] == null ? null: MessageModel.fromJson(json['parent_chat'] as Map<String, dynamic>),
      unread_count= json['unread_count'],
      audioTime= json['audioTime'] as int?,
      isPlayAudio= json['isPlayAudio'] as bool?;

  Map<String, dynamic> toJson() =>
      {
       'id': id,
      'unsended_at': unsended_at,
      'contents': contents,
      'room_id': room_id,
      'sender_id': sender_id,
      'type':type,
      'parent_id': parent_id,
      'created_at': created_at,
      'updated_at': updated_at,
      'deleted_at': deleted_at,
      'sender': sender,
      'chat_idx': (chat_idx),
      'parent_chat': parent_chat,
      'unread_count': (unread_count),
      'audioTime': audioTime,
      'isPlayAudio': isPlayAudio,
      };

}