import 'package:chat_diver/components/interaction_segment.dart';
import 'package:chat_diver/models/conversation.dart';
import 'package:chat_diver/models/interaction.dart';
import 'package:chat_diver/models/message.dart';
import 'package:flutter/material.dart';

//The widget that displays the contents of a conversation model
class ConversationView extends StatelessWidget {
  final Conversation conversation;
  final ScrollController controller = ScrollController();

  ConversationView(this.conversation, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    sortConversation();
    conversation.handleTime = totalHandleTime();
    // debugPrint('building Conversation ${conversation.primaryInteractionID}');
    return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 4 / 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: ListView.builder(
            controller: controller,
            itemCount: conversation.interactions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: InteractionSegment(conversation.interactions[
                    conversation.interactions.keys.toList()[index]]!),
              );
            }));
  }

  // sort the interactions within a conversation by date and then message ID
  void sortConversation() {
    List<Message> msgs;
    List<Interaction> ints = conversation.interactions.values.toList();
    //sort messages by messageID
    for (var interaction in ints) {
      msgs = interaction.messages.values.toList();
      msgs.sort((a, b) {
        int cmp = a.date.compareTo(b.date);
        if (cmp != 0) {
          return cmp;
        }
        return a.messageID.compareTo(b.messageID);
      });

      interaction.messages = {for (var msg in msgs) msg.messageID: msg};
    }
    ints.sort((a, b) =>
        a.messages.values.first.date.compareTo(b.messages.values.first.date));
    conversation.interactions = {for (var int in ints) int.interactionID: int};
  }

  // Calculate the total handle time of the displayed conversation
  int totalHandleTime() {
    int total = 0;
    conversation.interactions.forEach((key, value) {
      total += (value.handleTime ?? 0);
    });
    // debugPrint(
    // 'Total Handle Time for ${conversation.interactions.entries.first.value.agentName}\'s interaction: $total seconds');
    return total;
  }
}
