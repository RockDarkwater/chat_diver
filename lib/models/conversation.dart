import 'package:chat_diver/models/interaction.dart';

class Conversation {
  // Conversations are the grouping of interactions that share a primary interaction UUID
  // AHT filter is calculated based on the aggregated handle time of all child interactions.
  final String primaryInteractionID;
  int handleTime = 0;
  Map<String, Interaction> interactions = {};

  Conversation(this.primaryInteractionID, Map<String, dynamic> dataMap);
}
