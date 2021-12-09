import 'package:chat_diver/components/slider_filter.dart';
import 'package:chat_diver/components/text_filter.dart';
import 'package:chat_diver/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'date_picker.dart';
import 'filter_box.dart';

//Filter popup that bridges the main upload screen and the chat scanning screen.
class FilterPopUp extends StatelessWidget {
  final AppController appController = Get.find();
  FilterPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back)),
          const SelectableText('Filter Inbound Data'),
          const Spacer(),
          const SelectableText('Date Range: '),
          DatePicker()
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {
              (appController.parseRawData())
                  ? Get.back()
                  : Get.dialog(AlertDialog(
                      title: Container(
                      color: Colors.white,
                      child: const SelectableText(
                          'Search produced no results. Please use different filters'),
                    )));
            },
            icon: const Icon(Icons.arrow_forward))
      ],
      content: Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 2,
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child:
                            DropDownFilterBox('ASSIGNED_AGENT_DEPARTMENT_CODE'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DropDownFilterBox(
                            'ASSIGNED_AGENT_MANAGER_FULL_NAME'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DropDownFilterBox('ASSIGNED_AGENT_FULL_NAME'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DropDownFilterBox('RATING'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child:
                            DropDownFilterBox('PRIMARY_OUTSIDER_COMPANY_NAME'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DropDownFilterBox('SUPPORT_TOPIC_LEVEL_1'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DropDownFilterBox('SUPPORT_TOPIC_LEVEL_2'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: DropDownFilterBox('SUPPORT_TOPIC_LEVEL_3'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(flex: 1),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: DropDownFilterBox('IS_INITIATED_WITH_CATI'),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: SliderFilter(),
            ),
            Expanded(child: TextFilter()),
          ],
        ),
      ),
    );
  }
}
