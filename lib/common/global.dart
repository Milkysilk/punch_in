import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

class Global {
  static bool checked = false;
  static const baseUrl = 'http://eswis.gdpu.edu.cn';
  static const timeout = 5000;
  static CookieJar cookieJar = CookieJar();
  static String key;
  static String startDate = '2020-05-14';

  static const accountData = 'account_data';
  static const account = 'account';
  static const password = 'password';

  static const punchData = 'punch_data';
  static const atSchool = 'at_school';
  static const location = 'location';
  static const observation = 'observation';
  static const health = 'health';
  static const temperature = 'temperature';
  static const description = 'description';
  static const changed = 'changed';
  static const study = 'study';
  static const address = 'address';
  static const date = 'date';
  static const history1 = 'history1';
  static const city = 'city';
  static const history2 = 'history2';
  static const touchDescription = 'touch_description';

  static const List<String> atSchoolStrings = ['是', '否'];
  static const List<String> observationStrings = ['无下列情况', '居家观察', '集中观察',
    '解除医学观察', '异常临床表现', '被列为疑似病例', '解除疑似病例',
    '是确诊病例', '确诊但已治愈'];
  static const List<String> healthStrings = ['无不适', '发烧', '咳嗽', '气促',
    '乏力 / 肌肉酸痛', '其它症状'];
  static const List<String> studyStrings = ['正常', '休学 / 停学中',
    '境内交换学习中', '境外交换学习中'];
  static const List<String> historyStrings1 = ['在穗（佛）未外出', '武汉', '湖北（不含武汉）',
    '温州', '中国境内其他省市', '中国港澳台地区', '国外'];
  static const List<String> historyStrings2 = ['无接触', '本人目前在【湖北】',
    '本人目前在【温州】', '本人 14 天内从【湖北 / 温州】返粤',
    '14 日内密切接触近期有【湖北 / 温州】旅居史者', '自我感觉 14 日内【曾与】患者接触'];

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}