import 'package:chat_diver/controllers/app_controller.dart';
import 'package:chat_diver/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePicker extends StatelessWidget {
  final FilterController filterController = Get.find();
  DatePicker({Key? key}) : super(key: key);

  void _onSelectionChanged(Object args) async {
    AppController appController = Get.find();
    DateTime start;
    DateTime end;

    if (args is PickerDateRange) {
      start = args.startDate!;
      end = args.endDate ?? args.startDate!;
    } else if (args is DateTime) {
      start = end = args;
    } else {
      debugPrint('Bad Date: ${args.toString()}');
      return;
    }

    //shift to beginning of start and end of end day
    filterController.maxDateTime.value =
        DateTime(end.year, end.month, end.day + 1, 0, 0, 0, 0, -1);
    filterController.minDateTime.value =
        DateTime(start.year, start.month, start.day);
    debugPrint('First: ${filterController.minDateTime.value.toString()}');
    debugPrint('Last: ${filterController.maxDateTime.value.toString()}');
    appController.needImport.value = true;
    await appController.import();
    filterController.assembleOptions();
    debugPrint(
        'Filters after date change: ${filterController.appliedFilters.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Click to change and requery',
      child: TextButton(
          onPressed: () {
            Get.dialog(AlertDialog(
              content: Container(
                constraints:
                    BoxConstraints.tight(MediaQuery.of(context).size / 2),
                child: SfDateRangePicker(
                  showActionButtons: true,
                  onCancel: () => Get.back(),
                  onSubmit: (object) {
                    _onSelectionChanged(object);

                    Get.back();
                  },
                  selectionMode: DateRangePickerSelectionMode.range,
                ),
              ),
            ));
          },
          child: Obx(
            () => Text(
                '${DateFormat('d-MMM').format(filterController.minDateTime.value)} and ${DateFormat('d-MMM').format(filterController.maxDateTime.value)}'),
          )),
    );
  }
}
