import 'package:chat_diver/controllers/app_controller.dart';
import 'package:chat_diver/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterButton extends StatelessWidget {
  final AppController appController = Get.find();
  final FilterController filterController = Get.find();

  FilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          filterController.launchFilterDialog(context);
        });
  }
}
