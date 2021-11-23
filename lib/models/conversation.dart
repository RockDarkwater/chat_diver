import 'package:chat_diver/models/interaction.dart';

class Conversation {
  final String primaryInteractionID;
  int handleTime = 0;
  Map<String, Interaction> interactions = {};

  Conversation(this.primaryInteractionID, Map<String, dynamic> dataMap);
}
