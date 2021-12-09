import 'package:chat_diver/controllers/app_controller.dart';
import 'package:chat_diver/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//filter widget for text based values
class TextFilter extends StatelessWidget {
  final AppController appController = Get.find();
  final FilterController filterController = Get.find();
  TextFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          filterController.assembleOptions();
          debugPrint('Focus Changed, Options Updated.');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: TextField(
          decoration: const InputDecoration(
              labelText: 'Search Terms (delineate with a \'; \')',
              icon: Icon(Icons.search),
              contentPadding: EdgeInsets.only(left: 8.0)),
          controller: filterController.textFilterController.value,
          onChanged: (content) {
            if (content.isNotEmpty) {
              filterController.appliedFilters['ACTUAL_MESSAGE'] =
                  content.split('; ').toList();
            } else {
              filterController.appliedFilters.remove('ACTUAL_MESSAGE');
            }
          },
          onSubmitted: (content) {
            if (content.isNotEmpty) {
              filterController.appliedFilters['ACTUAL_MESSAGE'] =
                  content.split('; ').toList();
              appController.chats.clear();
            } else {
              filterController.appliedFilters.remove('ACTUAL_MESSAGE');
            }
          },
        ),
      ),
    );
  }
}
