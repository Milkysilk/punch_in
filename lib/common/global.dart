import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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

  static const accountTable = 'account';
  static const punchTable = 'punch';
  static const studentId = 'student_id';
  static const password = 'password';
  static const atSchool = 'at_school';
  static const location = 'location';
  static const observation = 'observation';
  static const health = 'health';
  static const temperature = 'temperature';
  static const extra = 'extra';

  static Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'punch_in.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $accountTable (
          id INTEGER PRIMARY KEY,
          $studentId TEXT,
          $password INTEGER);
          ''');
        await db.execute(''' 
          CREATE TABLE $punchTable (
          id INTEGER PRIMARY KEY,
          $atSchool TEXT,
          $location TEXT,
          $observation TEXT,
          $health TEXT,
          $temperature TEXT,
          $extra TEXT);
          ''');
      },
      version: 1,
    );
  }

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}