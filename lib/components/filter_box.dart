import 'package:chat_diver/controllers/app_controller.dart';
import 'package:chat_diver/controllers/filter_controller.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropDownFilterBox extends StatelessWidget {
  final AppController appController = Get.find();
  final FilterController filterController = Get.find();
  final String header;

  DropDownFilterBox(this.header, {Key? key}) : super(key: key);

  String _readableHeader(String dataHeader) {
    //Translate Data headers to colloquial strings
    switch (dataHeader) {
      case 'RATING':
        return 'CSAT';
      case 'ASSIGNED_AGENT_FULL_NAME':
        return 'Agent Name';
      case 'IS_INITIATED_WITH_CATI':
        return 'CATI Interaction';
      case 'SUPPORT_TOPIC_LEVEL_1	':
        return 'Topic 1';
      case 'SUPPORT_TOPIC_LEVEL_2	':
        return 'Topic 2';
      case 'SUPPORT_TOPIC_LEVEL_3	':
        return 'Topic 3';
      case 'START_DATETIME	':
        return 'Date';
      case 'ASSIGNED_AGENT_MANAGER_FULL_NAME':
        return 'Manager';
      case 'PRIMARY_OUTSIDER_COMPANY_NAME':
        return 'Company';
      case 'ASSIGNED_AGENT_DEPARTMENT_CODE':
        return 'Department';
      default:
        return dataHeader;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DropdownSearch<String>.multiSelection(
        selectedItems: filterController.appliedFilters[header] ?? [],
        popupBarrierColor: Colors.white,
        popupBackgroundColor: Colors.white,
        mode: Mode.DIALOG,
        dialogMaxWidth: MediaQuery.of(context).size.width / 3,
        showSearchBox: true,
        showSelectedItems: true,
        showClearButton: true,
        items: filterController.filterOptions[header],
        popupSelectionWidget: (cnt, String item, bool isSelected) {
          return isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green[500],
                )
              : Container();
        },
        onChanged: (choices) {
          // when filter options are changed, reset the applied filters array in the controller
          debugPrint('${header.camelCase} choices: $choices');
          (choices.isEmpty)
              ? filterController.appliedFilters.remove(header)
              : filterController.appliedFilters[header] =
                  List<String>.from(choices.toList());
          // reset dynamic filter options
          filterController.assembleOptions(header);
        },
        clearButtonSplashRadius: 20,
        dropdownSearchDecoration: InputDecoration(
          labelText: _readableHeader(header),
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
          border: const OutlineInputBorder(),
        ),
      );
    });
  }
}
