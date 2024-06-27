import 'package:logger/logger.dart';
import '../../../tinode/src/database/objectbox.g.dart';

import 'model.dart';

class ObjectBox {
  static const int DEFAULT_MESSAGE_LIMIT = 50;

  static const int DEFAULT_MESSAGE_THRESHOLD_IN_TOPIC = 3000000;

  late final Store store;

  final _logger = Logger();

  List<DataMessage> getMessagesWith(String topic, {int? offset, int? limit}) {
    final msgBox = store.box<DataMessage>();
    final builder = msgBox.query(DataMessage_.topic.equals(topic))
      ..order(DataMessage_.seq, flags: Order.descending);
    final query = builder.build()
      ..offset = offset ?? 0
      ..limit = limit ?? DEFAULT_MESSAGE_LIMIT;
    final res = query.find();
    query.close();
    return res;
  }

  void updateMessage(String topic, DataMessage data) {
    final topicBox = store.box<LocalTopic>();
    final msgBox = store.box<DataMessage>();
    final query = topicBox.query(LocalTopic_.name.equals(topic)).build();
    try {
      var localTopic = query.findFirst();
      int topicId;
      if (localTopic == null) {
        localTopic ??= LocalTopic(topic);
        topicId = topicBox.put(localTopic);
      } else {
        topicId = localTopic.id;
      }
      final headData = data.head;
      if (headData != null) {
        if (headData.containsKey('reaction_to') &&
            headData.containsKey('reaction')) {
          final updatedId = headData['reaction_to'];
          final reactions = headData['reaction'];
          final id =
              topicId * DEFAULT_MESSAGE_THRESHOLD_IN_TOPIC + updatedId as int;
          final msg = msgBox.get(id);
          if (msg != null) {
            msg.head?['reaction'] = reactions;
            msgBox.put(msg);
          }
        }
        if (headData.containsKey('answer_to') &&
            headData.containsKey('answers')) {
          final updatedId = headData['answer_to'];
          final answers = headData['answers'];
          final id =
              topicId * DEFAULT_MESSAGE_THRESHOLD_IN_TOPIC + updatedId as int;
          final msg = msgBox.get(id);
          if (msg != null) {
            if (msg.head?.containsKey('data') == true) {
              msg.head?['data']['answers'] = answers;
            }
            msgBox.put(msg);
          }
        }
        if (headData.containsKey('censor_to') &&
            headData.containsKey('is_censored')) {
          final updatedId = headData['censor_to'];
          final isCensored = headData['is_censored'];
          final id =
              topicId * DEFAULT_MESSAGE_THRESHOLD_IN_TOPIC + updatedId as int;
          final msg = msgBox.get(id);
          if (msg != null) {
            if (msg.head?.containsKey('data') == true) {
              msg.head?['data']['is_censored'][msg.from] = isCensored;
            }
            msgBox.put(msg);
          }
        }
      }
    } catch (e) {
      _logger.i('ObjectBox#Error Update Message = ${e.toString()}');
    } finally {
      query.close();
    }
  }

  void addDataMessage(DataMessage message) {
    final dataMessageBox = Box<DataMessage>(store);
    final topic = message.topic ?? '';
    final seq = message.seq ?? 0;
    final combinedId = '${topic}_$seq';

    final query = dataMessageBox
        .query(DataMessage_.combinedId.equals(combinedId))
        .build();
    final existingMsg = query.findFirst();

    if (existingMsg == null) {
      store.runInTransactionAsync(TxMode.write, _addDataMessageInTx, message);
    }
  }

  static void _addDataMessageInTx(Store store, DataMessage data) {
    store.box<DataMessage>().put(data);
  }

  Future<void> addDataMessages(List<DataMessage> messages,
      {int? offset}) async {
    if (messages.isEmpty) return;
    final topic = messages[0].topic ?? '';
    final topicBox = store.box<LocalTopic>();
    final msgBox = store.box<DataMessage>();
    final query2 = topicBox.query(LocalTopic_.name.equals(topic)).build();
    try {
      var localTopic = query2.findFirst();
      int topicId;
      if (localTopic == null) {
        localTopic ??= LocalTopic(topic);
        topicId = topicBox.put(localTopic);
      } else {
        topicId = localTopic.id;
      }

      for (final msg in messages) {
        msg.id = topicId * DEFAULT_MESSAGE_THRESHOLD_IN_TOPIC + (msg.seq ?? 0);
        msgBox.put(msg);
        // Then can safely add target Object to ToMany
        localTopic.messages.add(msg);
      }
      topicBox.put(localTopic);
    } catch (e) {
      _logger.i('ObjectBox#Error Add Batch = ${e.toString()}');
    } finally {
      query2.close();
    }
  }

  void clearAll() {
    final dataMessageBox = Box<DataMessage>(store);
    final topicBox = Box<LocalTopic>(store);
    dataMessageBox.removeAll();
    topicBox.removeAll();
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  ObjectBox._create(this.store);
}
