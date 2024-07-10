import '../../../tinode/src/models/packet-data.dart';

class Packet {
  String? id;
  String? name;
  PacketData? data;
  Map<String, List<String>> ? extra;

  bool? failed;
  bool? sending;
  bool? cancelled;
  bool? noForwarding;

  Packet(String name, PacketData data, String? id , Map<String, List<String>> ? extra) {
    this.name = name;
    this.data = data;
    this.id = id;
    this.extra = extra;
    
    failed = false;
    sending = false;
  }

  Map<String, dynamic> toMap() {
    return data?.toMap() ?? {};
  }
}
