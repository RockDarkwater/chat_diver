import 'package:chat_diver/components/message_bubble.dart';
import 'package:chat_diver/models/message.dart';
import 'package:flutter/material.dart';
import 'package:chat_diver/models/interaction.dart';

//widget that displays each interaction in the conversation
class InteractionSegment extends StatelessWidget {
  final Interaction interaction;

  const InteractionSegment(this.interaction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (interaction.messages.values
        .where((element) => element.messageType == 'ending')
        .toList()
        .isEmpty) {
      closeInteraction();
    }

    // debugPrint('building Interaction ${interaction.interactionID}');
    return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 4 / 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: ListView.builder(
            itemCount: interaction.messages.length,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: MessageBubble(interaction
                    .messages[interaction.messages.keys.toList()[index]]!),
                contentPadding: const EdgeInsets.only(
                    left: 1.0, right: 1.0, top: 15.0, bottom: 0.0),
              );
            }));
  }

  // create the end of chat disposition message
  void closeInteraction() {
    Map<String, dynamic> map = {};
    String key = UniqueKey().toString();
    String msgText = 'Dispositioned By: ${interaction.agentName}\n\nTopic: ';
    msgText +=
        '${interaction.supportTopic1}|${interaction.supportTopic2}|${interaction.supportTopic3}';
    msgText += '\nStatus: ${interaction.status}';
    msgText += '\nNote: ${interaction.statusNote}';

    map['ACTUAL_MESSAGE'] = msgText;
    map['SENDER_TYPE'] = 'agent';
    map['TYPE'] = 'ending';
    map['SOURCE_URL'] = interaction.messages.values.last.sourceURL;
    map['ASSIGNED_AGENT_FULL_NAME'] = interaction.agentName;

    map['ASSIGNED_AGENT_DEPARTMENT_CODE'] = interaction.agentDepartment;
    map['ASSIGNED_AGENT_PERSON_UUID'] = interaction.agentID;
    map['CREATED_AT_DATETIME'] = interaction.messages.values.last.date
        .add(const Duration(seconds: 30))
        .toString();
    map['DEVICE_TYPE'] = 'Desktop';
    map['MESSAGE_NUMBER'] =
        '${interaction.messages.values.last.messageNumber + 1}';
    map['RATING'] = interaction.messages.values.last.csatRating;

    interaction.messages[key] = Message(key, map);
  }
}
