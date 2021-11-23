import 'package:chat_diver/components/filter_popup.dart';
import 'package:chat_diver/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  RxMap<String, List<String>> appliedFilters = <String, List<String>>{}.obs;
  RxMap<String, List<String>> filterOptions = <String, List<String>>{}.obs;
  Rx<TextEditingController> textFilterController = TextEditingController().obs;
  Rx<RangeValues> ahtValues = const RangeValues(5, 5).obs;

  List<String> currentFilters = [
    'RATING',
    'ASSIGNED_AGENT_FULL_NAME',
    'IS_INITIATED_WITH_CATI',
    'SUPPORT_TOPIC_LEVEL_1',
    'SUPPORT_TOPIC_LEVEL_2',
    'SUPPORT_TOPIC_LEVEL_3',
    'ASSIGNED_AGENT_MANAGER_FULL_NAME',
    'PRIMARY_OUTSIDER_COMPANY_NAME',
    'ASSIGNED_AGENT_DEPARTMENT_CODE',
    'HANDLE_TIME'
  ];

  Rx<DateTime> minDateTime =
      DateTime.now().subtract(const Duration(days: 7)).obs;
  Rx<DateTime> maxDateTime = DateTime.now().obs;
  bool? isCATI;

  void launchFilterDialog(BuildContext context) {
    // assembleOptions();
    Get.dialog(FilterPopUp());
  }

  void resetFilters() {
    AppController appController = Get.find();
    appController.chats.clear();
    appliedFilters.clear();
    textFilterController.value.text = '';
    setInitialHandleTimeParameters();
    assembleOptions();

    debugPrint('Filters reset');
  }

  RangeValues getMinMaxHandleTime() {
    AppController appController = Get.find();
    List<int> hTimes = appController.handleTimes.values.toList();
    hTimes.sort();
    return RangeValues(double.tryParse(filterOptions['HANDLE_TIME']![0])!,
        double.tryParse(filterOptions['HANDLE_TIME']![1])!);
  }

  void setInitialHandleTimeParameters() {
    AppController appController = Get.find();
    List<int> hTimes = appController.handleTimes.values.toList();
    hTimes.sort();
    filterOptions['HANDLE_TIME'] = [
      (hTimes[0]).toDouble().round().toString(),
      (hTimes[hTimes.length - 1]).toDouble().round().toString(),
    ];

    ahtValues.value = RangeValues(
        double.tryParse(filterOptions['HANDLE_TIME']![0])!,
        double.tryParse(filterOptions['HANDLE_TIME']![1])!);
  }

  void assembleOptions([String? skipHeader]) {
    AppController appController = Get.find();
    if (skipHeader != null) {
      List<String> saveHeaders = filterOptions[skipHeader]!;
      filterOptions.clear();
      filterOptions[skipHeader] = saveHeaders;
    } else {
      filterOptions.clear();
    }
    int maxAHT = 0;
    int minAHT = 9000;

    for (var line in appController.data) {
      bool addLine = true;

      //Date Filter
      DateTime lineDate = DateTime.parse(line['CREATED_AT_DATETIME']);
      if (lineDate.isAfter(maxDateTime.value) ||
          lineDate.isBefore(minDateTime.value)) {
        addLine = false;
      }

      //Handle Time Filter
      if (ahtValues.value.start != 0 && ahtValues.value.end != 0) {
        if (appController.handleTimes
            .containsKey(line['PRIMARY_INTERACTION_UUID'])) {
          int testVal =
              appController.handleTimes[line['PRIMARY_INTERACTION_UUID']]!;
          if (testVal < ahtValues.value.start ||
              testVal > ahtValues.value.end) {
            addLine = false;
          }
        }
      }

      //test line against active filters
      appliedFilters.forEach((key, value) {
        if (key == 'RATING') {
          if (!value
              .contains(double.tryParse(line[key])?.toInt().toString() ?? '')) {
            addLine = false;
          }
        } else if (key == 'ACTUAL_MESSAGE') {
          bool textFound = false;
          for (var searchTerm in value) {
            if (line[key].toString().contains(searchTerm)) {
              textFound = true;
            }
          }
          if (!textFound) addLine = false;
        } else {
          if (!value.contains(line[key])) {
            addLine = false;
          }
        }
      });

      //if line passes, cycle headers to add to options
      if (addLine) {
        for (var header in currentFilters) {
          dynamic optionValue = line[header].toString();

          (header == 'RATING')
              ? optionValue =
                  double.tryParse(line[header])?.toInt().toString() ?? ''
              : optionValue = line[header].toString();
          //set min/max handle times based on active filters
          if (header == 'HANDLE_TIME') {
            if (header != skipHeader) {
              int handleTime =
                  appController.handleTimes[line['PRIMARY_INTERACTION_UUID']] ??
                      0;
              handleTime = (handleTime).round();
              if (handleTime > maxAHT) {
                maxAHT = handleTime;
              }
              if (handleTime < minAHT) {
                minAHT = handleTime;
              }
            }
            optionValue = '';
          }

          if (header == skipHeader ||
              (optionValue != null && optionValue != '')) {
            if (filterOptions.containsKey(header)) {
              if (!filterOptions[header]!.contains(optionValue)) {
                filterOptions[header]!.add(optionValue);
              }
            } else {
              filterOptions[header] = [optionValue];
            }
          }
        }
      }
    }

    if (skipHeader != 'HANDLE_TIME') {
      filterOptions['HANDLE_TIME'] = ['$minAHT', '$maxAHT'];
      ahtValues.value = RangeValues(minAHT.toDouble(), maxAHT.toDouble());
    }

    filterOptions.forEach((key, value) {
      if (key != 'HANDLE_TIME') {
        value.sort();
      }
    });
    debugPrint('Options Updated');
  }

  List<Map<String, dynamic>> filterData() {
    AppController appController = Get.find();
    List<Map<String, dynamic>> l = [];
    List<String> primaryInteractions = [];

    // set date filters
    if (minDateTime.value.isAfter(DateTime.now())) {
      minDateTime.value = DateTime.now();
    }

    if (maxDateTime.value.isBefore(minDateTime.value)) {
      maxDateTime.value = minDateTime.value;
    }

    // find primary interactions that meet the filtered criteria
    for (var dataLine in appController.data) {
      dynamic testValue;
      //check if already included
      if (!primaryInteractions.contains(dataLine['PRIMARY_INTERACTION_UUID'])) {
        DateTime lineDate = DateTime.parse(dataLine['CREATED_AT_DATETIME']);
        bool passesFilter = true;

        //Date Filter
        if (lineDate.isAfter(maxDateTime.value) ||
            lineDate.isBefore(minDateTime.value)) {
          passesFilter = false;
        }

        //Handle Time filter
        if (ahtValues.value.start != 0 && ahtValues.value.end != 0) {
          if (appController.handleTimes
              .containsKey(dataLine['PRIMARY_INTERACTION_UUID'])) {
            int testVal = appController
                .handleTimes[dataLine['PRIMARY_INTERACTION_UUID']]!;
            if (testVal < ahtValues.value.start ||
                testVal > ahtValues.value.end) {
              passesFilter = false;
            }
          }
        }

        //String Comparison Filters
        appliedFilters.forEach((key, value) {
          if (key == 'RATING') {
            testValue =
                double.tryParse(dataLine[key])?.toInt().toString() ?? '';
          } else if (key == 'ACTUAL_MESSAGE') {
            bool containsText = false;
            for (var searchTerm in appliedFilters['ACTUAL_MESSAGE']!) {
              if (dataLine['ACTUAL_MESSAGE']
                  .replaceAll("`", ",")
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase())) {
                testValue = searchTerm;
                containsText = true;
              }

              if (!containsText) passesFilter = false;
            }
          } else {
            testValue = dataLine[key];
          }

          if (!value.contains(testValue)) {
            passesFilter = false;
          }
        });

        if (passesFilter) {
          primaryInteractions.add(dataLine['PRIMARY_INTERACTION_UUID']);
        }
      }
    }

    for (var line in appController.data) {
      if (primaryInteractions.contains(line['PRIMARY_INTERACTION_UUID'])) {
        l.add(line);
      }
    }

    debugPrint(
        'filters applied: ${appliedFilters.toString()}, resulting in ${l.length} lines');
    return l;
  }
}
