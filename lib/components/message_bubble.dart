import 'package:chat_diver/models/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Message msg;
  Color? backgroundColor = Colors.white;
  Color? outlineColor;
  Color? personBubbleColor;
  Color? personBubbleTextColor;
  String? personBubbleLink;
  MainAxisAlignment? messageAlignmentVert;
  CrossAxisAlignment? messageAlignmentHoriz;
  bool csatMsg = false;

  //widget that displays the message, formatted based on source and context
  MessageBubble(this.msg, {Key? key}) : super(key: key) {
    // Color Logic

    if (msg.messageType == 'text' || msg.messageType == 'message') {
      if (msg.senderType == 'agent') {
        //Agent message
        backgroundColor = Colors.white;
        outlineColor = Colors.grey[300];
        personBubbleColor = Colors.grey[400];
        personBubbleTextColor = Colors.grey[800];
        personBubbleLink = msg.sourceURL;
        messageAlignmentHoriz = CrossAxisAlignment.end;
        messageAlignmentVert = MainAxisAlignment.end;
      } else if (msg.senderType == 'outsider') {
        //Traveler message
        backgroundColor = Colors.grey[300];
        outlineColor = Colors.grey[300];
        personBubbleColor = const Color.fromRGBO(2, 146, 254, 1);
        personBubbleTextColor = Colors.white;
        personBubbleLink =
            'https://app.tripactions.com/app/travelxen/agent/users/${msg.senderID}/trips';
        messageAlignmentHoriz = CrossAxisAlignment.start;
        messageAlignmentVert = MainAxisAlignment.start;
      } else {
        debugPrint('Sender type: ${msg.senderType}');
      }
    } else if (msg.messageType == 'joined_agent' ||
        msg.messageType == 'change_agent' ||
        msg.messageType == 'custom' ||
        msg.messageType == 'option') {
      // System Message (SYSTEM)
      backgroundColor = const Color.fromRGBO(255, 242, 204, 1);
      outlineColor = Colors.grey[300];
      messageAlignmentHoriz = CrossAxisAlignment.center;
      messageAlignmentVert = MainAxisAlignment.center;
    } else if (msg.messageType.contains('_error') ||
        msg.messageType == 'context_button') {
      // System Message (TRAVELER)
      backgroundColor = Colors.grey[300];
      outlineColor = Colors.grey[300];
      personBubbleColor = Colors.white;
      personBubbleTextColor = Colors.grey[800];
      personBubbleLink = '';
      messageAlignmentHoriz = CrossAxisAlignment.start;
      messageAlignmentVert = MainAxisAlignment.start;
    } else if (msg.messageType == 'csat') {
      // CSAT message
      backgroundColor = Colors.white;
      outlineColor = Colors.grey[800];
      messageAlignmentHoriz = CrossAxisAlignment.center;
      messageAlignmentVert = MainAxisAlignment.center;
    } else {
      // debugPrint('Message type: ${msg.messageType}');
      backgroundColor = const Color.fromRGBO(255, 242, 204, 1);
      outlineColor = Colors.grey[400];
      personBubbleColor = Colors.grey[400];
      personBubbleTextColor = Colors.grey[800];
      personBubbleLink = msg.sourceURL;
      messageAlignmentHoriz = CrossAxisAlignment.end;
      messageAlignmentVert = MainAxisAlignment.end;
    }
  }

  // Convert Name to Initials
  String chatterInitials(String chatterName) {
    List<String> initials = [];
    initials.add(chatterName.split(' ').toList().first.substring(0, 1));
    initials.add(chatterName.split(' ').toList().last.substring(0, 1));
    return initials.join();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('building message ${msg.messageID}');
    Widget message = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: messageAlignmentHoriz!,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 1 / 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: outlineColor!,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 15.0, right: 10.0),
            child: SelectableText(
              msg.messageText,
              style: TextStyle(fontSize: (msg.messageType != 'csat') ? 15 : 20),
              textAlign: (msg.messageType == 'csat')
                  ? TextAlign.center
                  : TextAlign.start,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0),
          child: Row(
            mainAxisAlignment: messageAlignmentVert!,
            children: [
              Text(
                DateFormat.yMd().add_jm().format(msg.date),
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
              if (msg.senderType == 'outsider')
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Tooltip(
                    message: msg.platform,
                    child: Icon(
                      Icons.devices,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    // prep person bubble widget
    Widget personBubble = Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Tooltip(
        message: msg.senderName,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            primary: personBubbleColor,
          ),
          onPressed: () async {
            if (personBubbleLink != '') await launch(personBubbleLink!);
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Text(
              chatterInitials(msg.senderName),
              style: TextStyle(
                color: personBubbleTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    //return message row with correct alignment
    if (messageAlignmentVert == MainAxisAlignment.start) {
      return Row(
        mainAxisAlignment: messageAlignmentVert!,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [personBubble, message],
      );
    } else if (messageAlignmentVert == MainAxisAlignment.end) {
      return Row(
        mainAxisAlignment: messageAlignmentVert!,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [message, personBubble],
      );
    } else {
      return message;
    }
  }
}
