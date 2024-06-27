import '../../../tinode/src/database/model.dart';
import '../../../tinode/src/models/topic-subscription.dart';
import '../../../tinode/src/models/delete-transaction.dart';
import '../../../tinode/src/models/topic-description.dart';
import '../../../tinode/src/models/access-mode.dart';
import '../../../tinode/src/models/credential.dart';
import '../../../tinode/src/services/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';

class ServerMessage {
  final CtrlMessage? ctrl;
  final MetaMessage? meta;
  final DataMessage? data;
  final PresMessage? pres;
  final InfoMessage? info;

  ServerMessage({this.ctrl, this.meta, this.data, this.pres, this.info});

  static ServerMessage fromMessage(Map<String, dynamic> msg) {
    // LoggerService _loggerService = GetIt.I.get<LoggerService>();
    // _loggerService.log("debug:: meta = ${msg['sub']} - = $msg");

    return ServerMessage(
      ctrl: msg['ctrl'] != null ? CtrlMessage.fromMessage(msg['ctrl']) : null,
      meta: msg['meta'] != null ? MetaMessage.fromMessage(msg['meta']) : null,
      data: msg['data'] != null ? DataMessage.fromMessage(msg['data']) : null,
      pres: msg['pres'] != null ? PresMessage.fromMessage(msg['pres']) : null,
      info: msg['info'] != null ? InfoMessage.fromMessage(msg['info']) : null,
    );
  }
}

class CtrlMessage {
  /// Message Id
  final String? id;

  /// Related topic
  final String? topic;

  /// Message code
  final int? code;

  /// Message text
  final String? text;

  /// Message timestamp
  final DateTime? ts;

  final dynamic params;

  CtrlMessage({
    this.id,
    this.topic,
    this.code,
    this.text,
    this.ts,
    this.params,
  });

  static CtrlMessage fromMessage(Map<String, dynamic> msg) {
    return CtrlMessage(
      id: msg['id'],
      code: msg['code'],
      text: msg['text'],
      topic: msg['topic'],
      params: msg['params'],
      ts: msg['ts'],
    );
  }
}

class MetaMessage {
  /// Message Id
  final String? id;

  /// Related topic
  final String? topic;

  /// Message timestamp
  final DateTime? ts;

  /// Topic description, optional
  final TopicDescription? desc;

  ///  topic subscribers or user's subscriptions, optional
  final List<TopicSubscription>? sub;

  /// Array of tags that the topic or user (in case of "me" topic) is indexed by
  final List<String>? tags;

  /// Array of user's credentials
  final List<Credential>? cred;

  /// Latest applicable 'delete' transaction
  final DeleteTransaction? del;

  MetaMessage(
      {this.id,
      this.topic,
      this.ts,
      this.desc,
      this.sub,
      this.tags,
      this.cred,
      this.del});

  static MetaMessage fromMessage(Map<String, dynamic> msg) {
    List<dynamic>? sub = msg['sub'];

    return MetaMessage(
      id: msg['id'],
      topic: msg['topic'],
      ts: msg['ts'],
      desc: msg['desc'] != null
          ? TopicDescription.fromMessage(msg['desc'])
          : null,
      sub: sub != null && sub.length != null
          ? sub.map((sub) => TopicSubscription.fromMessage(sub)).toList()
          : [],
      tags: msg['tags']?.cast<String>(),
      cred: msg['cred'] != null && msg['cred'].length > 0
          ? msg['cred']
              .map((dynamic cred) => Credential.fromMessage(cred))
              .toList()
              .cast<Credential>()
          : [],
      del:
          msg['del'] != null ? DeleteTransaction.fromMessage(msg['del']) : null,
    );
  }
}

enum DataMessageType {
  text,
  question,
  sticker,
  reply_text,
  reply_sticker,
  reply_voice,
  reaction,
  voice,
  fun_question,
  photo,
  group_photo
}

extension DataMessageTypeExtension on DataMessageType {
  String get value {
    switch (this) {
      case DataMessageType.text:
        return 'text';
      case DataMessageType.question:
        return 'question';
      case DataMessageType.sticker:
        return 'sticker';
      case DataMessageType.voice:
        return 'voice';
      case DataMessageType.reply_text:
        return 'reply_text';
      case DataMessageType.reply_sticker:
        return 'reply_sticker';
      case DataMessageType.reply_voice:
        return 'reply_voice';
      case DataMessageType.reaction:
        return 'reaction';
      case DataMessageType.fun_question:
        return 'fun_question';
      case DataMessageType.photo:
        return 'photo';
      case DataMessageType.group_photo:
        return 'group_photo';
      default:
        return '';
    }
  }

  static DataMessageType from(String text) {
    switch (text) {
      case 'text':
        return DataMessageType.text;
      case 'question':
        return DataMessageType.question;
      case 'sticker':
        return DataMessageType.sticker;
      case 'voice':
        return DataMessageType.voice;
      case 'reply_text':
        return DataMessageType.reply_text;
      case 'reply_sticker':
        return DataMessageType.reply_sticker;
      case 'reply_voice':
        return DataMessageType.reply_voice;
      case 'reaction':
        return DataMessageType.reaction;
      case 'fun_question':
        return DataMessageType.fun_question;
      case 'photo':
        return DataMessageType.photo;
      case 'group_photo':
        return DataMessageType.group_photo;
      default:
        return DataMessageType.text;
    }
  }
}

class Reaction extends Equatable {
  final String? emoji;
  final String? reactor;

  Reaction({this.emoji, this.reactor});

  static Reaction from(Map<String, dynamic> value) {
    print("Reaction::from # $value");
    return Reaction(
      emoji: value['emoji'],
      reactor: value['reactor'] as String,
    );
  }

  @override
  List<Object?> get props => [emoji, reactor];
}

class ReplyMessage extends Equatable {
  final int? messageSeq;
  final String? replierId;
  final DataMessage? snapshot;

  ReplyMessage({this.messageSeq, this.replierId, this.snapshot});

  static ReplyMessage from(Map<String, dynamic> value) {
    return ReplyMessage(
        messageSeq: value['message_seq'] as int,
        replierId: value['replier_id'] as String,
        snapshot: DataMessage.fromMessage(value['snapshot']));
  }

  @override
  List<Object?> get props => [messageSeq, replierId, snapshot];
}

class PresMessage {
  /// Topic which receives the notification, always present
  final String? topic;

  /// Topic or user affected by the change, always present
  final String? src;

  /// what's changed, always present
  final String? what;

  /// "what" is "msg", a server-issued Id of the message, optional
  int? seq;

  /// "what" is "del", an update to the delete transaction Id.
  final int? clear;

  /// Array of ranges, "what" is "del", ranges of Ids of deleted messages, optional
  final List<DeleteTransactionRange>? delseq;

  /// A User Agent string identifying client
  final String? ua;

  /// User who performed the action, optional
  final String? act;

  /// User affected by the action, optional
  final String? tgt;

  /// Changes to access mode, "what" is "acs", optional
  final AccessMode? acs;

  final AccessMode? dacs;

  PresMessage({
    this.topic,
    this.src,
    this.what,
    this.seq,
    this.clear,
    this.delseq,
    this.ua,
    this.act,
    this.tgt,
    this.acs,
    this.dacs,
  });

  static PresMessage fromMessage(Map<String, dynamic> msg) {
    return PresMessage(
      topic: msg['msg'],
      src: msg['src'],
      what: msg['what'],
      seq: msg['seq'],
      clear: msg['clear'],
      delseq: msg['delseq'] != null && msg['delseq'].length != null
          ? msg['delseq']
              .map((seq) => DeleteTransactionRange.fromMessage(seq))
              .toList()
          : [],
      ua: msg['ua'],
      act: msg['act'],
      tgt: msg['tgt'],
      acs: msg['acs'] != null ? AccessMode(msg['acs']) : null,
      dacs: msg['dacs'] != null ? AccessMode(msg['dacs']) : null,
    );
  }
}

class InfoMessage {
  /// topic affected, always present
  final String? topic;

  /// id of the user who published the message, always present
  final String? from;

  /// string, one of "kp", "recv", "read", see client-side {note},
  final String? what;

  /// ID of the message that client has acknowledged,
  /// guaranteed 0 < read <= recv <= {ctrl.params.seq}; present for rcpt & read
  final int? seq;

  InfoMessage({
    this.topic,
    this.from,
    this.what,
    this.seq,
  });

  static InfoMessage fromMessage(Map<String, dynamic> msg) {
    return InfoMessage(
      topic: msg['topic'],
      from: msg['from'],
      what: msg['what'],
      seq: msg['seq'],
    );
  }
}
