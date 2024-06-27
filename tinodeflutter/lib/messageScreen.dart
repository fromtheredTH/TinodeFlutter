
import 'package:flutter/material.dart';
import 'tinode/tinode.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:http/http.dart';



class MessageRoomScreen extends StatefulWidget {
  const MessageRoomScreen({super.key});

  @override
  State<MessageRoomScreen> createState() => _MessageRoomScreenState();
}

class _MessageRoomScreenState extends State<MessageRoomScreen> {

late Tinode tinode;
Future<void> chatList(Tinode tinode) async
{
  
  var me = tinode.getMeTopic();
  me.onSubsUpdated.listen((value) {
    for (var item in value) {
      print('Subscription[' + item.topic.toString() + ']: ' + item.public['fn'] + ' - Unread Messages:' + item.unread.toString());
    }
  });
  await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);

  var grp = tinode.getTopic('grpWAFkncfrJtc');
  grp.onData.listen((value) {
    if (value != null) {
      print('DataMessage: ' + value.content);
    }
  });

  await grp.subscribe(MetaGetBuilder(tinode.getTopic('grpWAFkncfrJtc')).withLaterSub(null).withLaterData(null).build(), null);
  var msg = grp.createMessage('This is cool', true);
  await grp.publishMessage(msg);

}


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}