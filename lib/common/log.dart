import 'dart:developer' as dev;
import 'dart:io';

import 'package:punch_in/common/global.dart';

class Log {
  static void log (
      String message, {
      String name = '',
  }) async {
    var logFile = File('${await Global.localPath}/punch_in.log');
    final str = '${name.length == 0 ? '' : '[$name] '}${DateTime.now()} $message';
    logFile.writeAsStringSync('$str\n', mode: FileMode.append);
    dev.log(str);
  }
}
