import 'package:demoji/demoji.dart';

class Message {
  final String messageID; // INTERACTION_PART_ID
  String sourceURL = '';
  String messageText = '';
  String senderType = '';
  String senderName = '';
  String senderID = '';
  String messageType = '';
  String csatRating = '';
  String platform = '';
  DateTime date = DateTime(2000);
  int messageNumber = 0;
  String language = '';
  bool cati = false;

  Message(this.messageID, Map<String, dynamic> dataMap) {
    final csatList = [
      Demoji.rage,
      Demoji.slightly_frowning_face,
      Demoji.neutral_face,
      Demoji.blush,
      Demoji.star_struck,
    ];

    messageText = dataMap['ACTUAL_MESSAGE'].toString().replaceAll("`", ",");
    sourceURL = dataMap['SOURCE_URL'] ?? '';
    senderType = dataMap['SENDER_TYPE'];
    messageType = dataMap['TYPE'];
    messageNumber = int.parse(dataMap['MESSAGE_NUMBER']);
    date = DateTime.parse(dataMap['CREATED_AT_DATETIME']);
    platform = dataMap['DEVICE_TYPE'];
    csatRating = double.tryParse(dataMap['RATING'])?.toInt().toString() ?? '';
    senderID;
    senderName;

    //compile CSAT message
    if (messageText.isEmpty &&
        messageType == 'csat' &&
        dataMap['RATING'].toString().isNotEmpty) {
      messageText =
          'Conversation Rating: ${csatList[(double.tryParse(dataMap['RATING'])?.toInt() ?? 1) - 1]}';
      if (dataMap['RATING_REMARK'].toString().isNotEmpty) {
        messageText +=
            '\n\n${dataMap['RATING_REMARK'].toString().replaceAll("`", ",")}';
      }
    }

    if (senderType == 'agent') {
      senderName =
          dataMap['ASSIGNED_AGENT_FULL_NAME'].toString().replaceAll("`", ",");
      senderID = dataMap['ASSIGNED_AGENT_PERSON_UUID'];
    } else {
      senderName =
          dataMap['PRIMARY_OUTSIDER_FULL_NAME'].toString().replaceAll("`", ",");
      senderID = dataMap['PRIMARY_OUTSIDER_PERSON_UUID'];
    }

    //adjust for CATI messages
    if (senderType == 'outsider' && dataMap['SENDER_PERSON_UUID'] == '') {
      senderType = 'agent';
      senderName = 'Trip Actions';
      senderID = dataMap['ASSIGNED_AGENT_PERSON_UUID'];
      messageType = 'text';
      cati = true;
    }
  }
}
