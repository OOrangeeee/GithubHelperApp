import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DirectoryHelper {
  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/githubhelper');

    if (!await appDir.exists()) {
      await appDir.create();
    }

    return appDir.path;
  }
}
