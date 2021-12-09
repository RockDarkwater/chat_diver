import 'dart:convert';

import 'package:chat_diver/controllers/export_controller.dart';
import 'package:chat_diver/controllers/filter_controller.dart';
import 'package:chat_diver/models/conversation.dart';
import 'package:chat_diver/models/interaction.dart';
import 'package:chat_diver/models/message.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final List<Map<String, dynamic>> data = [];
  Map<String, int> handleTimes = {};
  bool imported = false;
  RxBool loading = false.obs;
  RxMap<String, Conversation> chats = <String, Conversation>{}.obs;
  RxBool needImport = true.obs;
  RxInt conversationToShow = 0.obs;

  void constrictWindow() async {
    await DesktopWindow.setFullScreen(true);
    await DesktopWindow.setMinWindowSize(const Size(750, 600));
  }

  //controls the chat navigation in conversation view
  void increment() => conversationToShow.value++;

  void decrement() => conversationToShow.value--;

  bool parseRawData() {
    FilterController filterController = Get.find();
    Map<String, Conversation> l = {};
    String conversationID;
    String interactionID;
    String messageID;
    List<Map<String, dynamic>> filteredData = filterController.filterData();
    //for each map in data, create a conversation (if it doesn't exist),
    //  then an interaction (iide), then create the message.

    if (filteredData.isNotEmpty) {
      // reset chat array
      chats.clear();
      conversationToShow.value = 0;

      // build conversations from message granularity import
      for (var map in filteredData) {
        conversationID = map['PRIMARY_INTERACTION_UUID'];
        interactionID = map['INTERACTION_UUID'];
        messageID = map['INTERACTION_PART_ID'] ?? 'null';

        // check if conversation exists
        if (l.containsKey(conversationID)) {
          // conversation exists, check if interaction exists
          if (l[conversationID]?.interactions.containsKey(interactionID) ??
              false) {
            // interaction exists, create message
            l[conversationID]!
                .interactions[interactionID]!
                .messages[messageID] = Message(messageID, map);
          } else {
            // create interaction and then initial message
            l[conversationID]!.interactions[interactionID] =
                Interaction(interactionID, map);

            l[conversationID]!
                .interactions[interactionID]!
                .messages[messageID] = Message(messageID, map);
          }
        } else {
          // create conversation, interaction, and message

          l[conversationID] = Conversation(conversationID, map);

          l[conversationID]!.interactions[interactionID] =
              Interaction(interactionID, map);

          l[conversationID]!.interactions[interactionID]!.messages[messageID] =
              Message(messageID, map);
        }
      }
      if (l.isNotEmpty) {
        chats.addAll(l);
        return true;
      }
    }
    return false;
  }

  // pull in data based on given date parameters.
  Future<bool> import() async {
    // SQL query from Snowflake (1 Dec 2021)
    //select mi.primary_interaction_uuid
//   , fip.interaction_uuid
//   , fip.INTERACTION_PART_ID
//   , fip.created_at_datetime
//   , replace(replace(replace(replace(replace(replace(replace(fip.message, '<p>', ''), '<br>', ''), '</p>', ''), '</br>', ''), ',','`'), '\n',''), '\r','') as actual_message
//   , fip.message_number
//   , fip.sender_type
//   , fip.sender_person_uuid
//   , fip.type
//   , mi.assigned_agent_person_uuid
//   , replace(mi.assigned_agent_full_name, ',', '`') as assigned_agent_full_name
//   , mi.primary_outsider_person_uuid
//   , replace(mi.primary_outsider_full_name, ',','`') as primary_outsider_full_name
//   , p.email primary_outsider_email
//   , mi.support_topic_level_1
//   , mi.support_topic_level_2
//   , mi.support_topic_level_3
//   , source_url
//   , mi.rating
//   , replace(replace(replace(replace(replace(replace(replace(mi.rating_remark, '<p>', ''), '<br>', ''), '</p>', ''), '</br>', ''), ',','`'), '\n',''), '\r','') as rating_remark
//   , mi.device_type
//   , mi.disposition_status
//   , replace(replace(replace(replace(replace(replace(replace(mi.DISPOSITION_NOTE, '<p>', ''), '<br>', ''), '</p>', ''), '</br>', ''), ',','`'), '\n',''), '\r','') as DISPOSITION_NOTE
//   , mi.IS_INITIATED_WITH_CATI
//   , mi.ASSIGNED_AGENT_MANAGER_FULL_NAME
//   , replace(mi.PRIMARY_OUTSIDER_COMPANY_NAME, ',','`') as PRIMARY_OUTSIDER_COMPANY_NAME
//   , mi.ASSIGNED_AGENT_DEPARTMENT_CODE
//   , mi.HANDLE_TIME

// from data_warehouse.fact_interaction_part fip

//     join "DWH"."MART_SUPPORT"."INTERACTIONS" mi
//       on mi.interaction_uuid = fip.interaction_uuid
//     join "DWH"."DATA_WAREHOUSE"."DIM_PERSON" p
//         on mi.PRIMARY_OUTSIDER_PERSON_UUID = p.PERSON_UUID

// where mi.start_datetime >= '2021-11-30'
// and mi.start_datetime < '2021-12-6'
// and mi.type = 'CHAT'
// and mi.is_valid = true
// order by Day(mi.start_datetime) desc,1 , 2, 6 asc

    if (needImport.value) {
      FilterController filterController = Get.find();

      //Load raw data from csv asset files
      String? str = '';
      str += await rootBundle.loadString('assets/nov_chats_1_to_4.csv');
      str += '\n' + await rootBundle.loadString('assets/nov_chats_5_to_9.csv');
      str +=
          '\n' + await rootBundle.loadString('assets/nov_chats_10_to_14.csv');
      str +=
          '\n' + await rootBundle.loadString('assets/nov_chats_15_to_18.csv');
      str +=
          '\n' + await rootBundle.loadString('assets/nov_chats_19_to_23.csv');
      str +=
          '\n' + await rootBundle.loadString('assets/nov_chats_24_to_29.csv');
      str += '\n' +
          await rootBundle.loadString('assets/nov_dec_chats_30_to_3.csv');

      // parse raw data into a map of header:value pairs
      List<String> lines = const LineSplitter().convert(str);
      String rawHeaders = lines[0];

      lines.removeWhere((element) => element.substring(0, 5) == 'PRIMA');
      lines.insert(0, rawHeaders);

      int importCount = 0;

      //set headers from first line
      List<String> headers = lines[0].split(',').toList();
      Map<String, dynamic> map = {};

      // iterate through each split line, adding a map of header: line_value to parent data list
      for (var i = 1; i < lines.length - 1; i++) {
        var values = lines[i].split(',').toList();
        //test date before import
        DateTime lineDate =
            DateTime.parse(values[headers.indexOf('CREATED_AT_DATETIME')]);
        if (lineDate.isBefore(filterController.maxDateTime.value) &&
            lineDate.isAfter(filterController.minDateTime.value)) {
          //convert line to map
          for (var j = 0; j < values.length; j++) {
            //header column is key, current line is value
            map[headers[j]] = values[j];
          }

          //compile Handle Times for all conversations in the date range.
          String id = map['PRIMARY_INTERACTION_UUID'];
          (handleTimes.containsKey(id))
              ? handleTimes[id] = handleTimes[id]! +
                  (int.tryParse(map['HANDLE_TIME'])?.toInt() ?? 0)
              : handleTimes[id] =
                  int.tryParse(map['HANDLE_TIME'])?.toInt() ?? 0;

          //add mapped line to aggregated list of maps
          data.add(Map.of(map));
          importCount++;
        }
      }
      debugPrint('total lines imported: $importCount');
      needImport.value = false;
      //assess minmax handle times
      filterController.setInitialHandleTimeParameters();
      //build dynamic filter options
      filterController.assembleOptions();
      return true;
    }
    return false;
  }

  void exportInteractions({bool interactionLevel = false}) async {
    //compile each interaction with associated details, pulling from message level if needed.
    ExportController exportController = Get.put(ExportController());
    List<List<String>> l = [];
    List<String> interactionIDs = [];
    List<String> headers = data[0].keys.toList();
    const List<String> messageHeaders = [
      'INTERACTION_PART_ID',
      'ACTUAL_MESSAGE',
      'MESSAGE_NUMBER',
      'SENDER_TYPE',
      'TYPE',
    ];
    headers.removeWhere((element) => messageHeaders.contains(element));
    l.add(headers);

    for (var line in data) {
      List<String> interactionData = [];
      //check if line is in filtered chats
      if (chats.keys.toList().contains(line['PRIMARY_INTERACTION_UUID'])) {
        //check if interaction has already been added
        if (!interactionIDs.contains(line['INTERACTION_UUID'])) {
          //add line of data
          if (line['INTERACTION_UUID'] == line['PRIMARY_INTERACTION_UUID'] ||
              interactionLevel) {
            line.forEach((key, value) {
              if (!messageHeaders.contains(key)) {
                interactionData.add(value);
              }
            });

            l.add(interactionData);
            interactionIDs.add(line['INTERACTION_UUID']);
          }
        }
      }
    }
    try {
      // pass data to be exported
      await exportController.exportSearch(l);
    } catch (e) {
      debugPrint('$e');
    }
    debugPrint('prepped ${l.length - 1} interactions for export');
  }
}
