import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

class Global {
  static bool checked = false;
  static const baseUrl = 'http://eswis.gdpu.edu.cn';
  static const timeout = 5000;
  static Map<String, String> headers = {'Cookie': ''};
  static CookieJar cookieJar = CookieJar();
  static String key;
  static String startDate = '2020-05-14';

  static const studentId = 'student_id';
  static const account = 'account';
  static const password = 'password';
  static const atSchool = 'at_school';
  static const location = 'location';
  static const observation = 'observation';
  static const health = 'health';
  static const temperature = 'temperature';
  static const extra = 'extra';
  static const description = 'description';
  static const accountData = 'account_data';
  static const punchData = 'punch_data';

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}