import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExportController extends GetxController {
  Future<File> get _localFile async {
    final path = await _localPath;
    final String today =
        DateFormat.yMd().format(DateTime.now()).toString().replaceAll('/', '_');
    return File('$path/scuba_export_$today.csv');
  }

  Future<String> get _localPath async {
    final directory = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Choose Export Location');

    return directory ?? '';
  }

  Future<File> exportSearch(List<List<String>> chats) async {
    final file = await _localFile;
    const ListToCsvConverter converter = ListToCsvConverter();

    return file.writeAsString(converter.convert(chats));
  }
}
