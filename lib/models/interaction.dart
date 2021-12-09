import 'package:chat_diver/models/message.dart';

// Interactions match TA definition with agent and traveler info, and a list of messages
class Interaction {
  String interactionID = '';
  String agentName = '';
  String agentID = '';
  String agentManager = '';
  String agentDepartment = '';
  String travelerName = '';
  String travelerID = '';
  String travelerEmail = '';
  String travelerCompany = '';
  String supportTopic1 = '';
  String supportTopic2 = '';
  String supportTopic3 = '';
  String status = '';
  String statusNote = '';
  int? handleTime;
  String? csatRemark = '';
  Map<String, Message> messages = {};

  Interaction(this.interactionID, Map<String, dynamic> dataMap) {
    agentName =
        dataMap['ASSIGNED_AGENT_FULL_NAME'].toString().replaceAll("`", ",");
    agentID = dataMap['ASSIGNED_AGENT_PERSON_UUID'];
    agentManager = dataMap['ASSIGNED_AGENT_MANAGER_FULL_NAME'];
    agentDepartment = dataMap['ASSIGNED_AGENT_DEPARTMENT_CODE'];
    travelerID = dataMap['PRIMARY_OUTSIDER_PERSON_UUID'];
    travelerName =
        dataMap['PRIMARY_OUTSIDER_FULL_NAME'].toString().replaceAll("`", ",");
    travelerCompany = dataMap['PRIMARY_OUTSIDER_COMPANY_NAME']
        .toString()
        .replaceAll("`", ",");
    travelerEmail = dataMap['PRIMARY_OUTSIDER_EMAIL'];
    supportTopic1 = dataMap['SUPPORT_TOPIC_LEVEL_1'] ?? '';
    supportTopic2 = dataMap['SUPPORT_TOPIC_LEVEL_2'] ?? '';
    supportTopic3 = dataMap['SUPPORT_TOPIC_LEVEL_3'] ?? '';
    status = dataMap['DISPOSITION_STATUS'];
    statusNote = dataMap['DISPOSITION_NOTE'].toString().replaceAll("`", ",");
    handleTime = int.tryParse(dataMap['HANDLE_TIME']);
  }
}
