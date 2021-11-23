import 'package:chat_diver/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SliderFilter extends StatelessWidget {
  final FilterController filterController = Get.find();
  SliderFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all()),
        child: Obx(
          () {
            return Column(
              children: [
                Text(
                    'Handle Time: ${(filterController.ahtValues.value.start / 3600).round()} to ${(filterController.ahtValues.value.end / 3600).round()} minutes.'),
                RangeSlider(
                  min: filterController.getMinMaxHandleTime().start,
                  max: filterController.getMinMaxHandleTime().end,
                  values: filterController.ahtValues.value,
                  onChanged: (values) {
                    filterController.ahtValues.value = values;
                  },
                  onChangeEnd: (values) {
                    filterController.ahtValues.value = values;

                    filterController.assembleOptions('HANDLE_TIME');
                  },
                ),
              ],
            );
          },
        ));
  }
}
