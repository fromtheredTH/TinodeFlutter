import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import '../../../tinode/src/database/model.dart';

import '../../../tinode/src/models/message-status.dart' as message_status;
import '../../../tinode/src/models/packet-types.dart' as packet_types;
import '../../../tinode/src/services/packet-generator.dart';
import '../../../tinode/src/models/server-messages.dart';
import '../../../tinode/src/models/packet-data.dart';
import '../../../tinode/src/models/packet.dart';

class Message {
  bool echo;
  int? _status;
  DateTime? ts;
  String? from;
  bool? cancelled;
  dynamic content;
  Map<String, dynamic>? head;
  String? topicName;
  bool? noForwarding;

  late PacketGenerator _packetGenerator;

  PublishSubject<int> onStatusChange = PublishSubject<int>();

  Message(this.topicName, this.content, this.echo, {this.head}) {
    _status = message_status.NONE;
    _packetGenerator = GetIt.I.get<PacketGenerator>();
  }

  Packet asPubPacket({Map<String, List<String>> ? extra=null}) {
    var packet = _packetGenerator.generate(packet_types.Pub, topicName, extra:extra);
    var data = packet.data as PubPacketData;
    data.content = content;
    data.noecho = !echo;
    if(head != null) {
      data.head = head;
    }
    packet.data = data;
    return packet;
  }

  DataMessage asDataMessage(String from, int seq) {
    return DataMessage(
      content: content,
      from: from,
      noForwarding: false,
      head: head ?? {},
      hi: null,
      topic: topicName,
      seq: seq,
      ts: ts,
      combinedId: '${topicName}_$seq'
    );
  }

  void setStatus(int status) {
    _status = status;
    onStatusChange.add(status);
  }

  int? getStatus() {
    return _status;
  }

  void resetLocalValues() {
    ts = null;
    setStatus(message_status.NONE);
  }
}
