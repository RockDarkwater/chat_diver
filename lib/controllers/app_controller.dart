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

  void constrictWindow() async {
    await DesktopWindow.setFullScreen(true);
    await DesktopWindow.setMinWindowSize(const Size(750, 600));
  }

  var conversationToShow = 0.obs;

  void increment() => conversationToShow.value++;

  void decrement() => conversationToShow.value--;

  bool parseRawData() {
    FilterController filterController = Get.find();
    Map<String, Conversation> l = {};
    String conversationID;
    String interactionID;
    String messageID;
    List<Map<String, dynamic>> filteredData = filterController.filterData();
    //for each map in data, create a conversation (if it doesn't exist), then an interaction (iide), then create the message.

    if (filteredData.isNotEmpty) {
      chats.clear();
      conversationToShow.value = 0;
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

  Future<bool> import() async {
    if (needImport.value) {
      FilterController filterController = Get.find();
      String? str = '';
      str += await rootBundle.loadString('assets/nov_chats_1_to_4.csv');
      str += '\n' + await rootBundle.loadString('assets/nov_chats_5_to_9.csv');
      str +=
          '\n' + await rootBundle.loadString('assets/nov_chats_10_to_14.csv');
      str +=
          '\n' + await rootBundle.loadString('assets/nov_chats_15_to_19.csv');

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
      filterController.setInitialHandleTimeParameters();
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

    await exportController.exportSearch(l);
    debugPrint('prepped ${l.length - 1} interactions for export');
  }
}
