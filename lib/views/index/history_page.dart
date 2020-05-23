import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:punch_in/common/global.dart';
import 'package:punch_in/common/http_request.dart';
import 'package:punch_in/common/log.dart';

class HistoryPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HistoryState();
}

class HistoryState extends State<HistoryPage> {
  var list = Set<String>();

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final Response response = await HttpRequest.request('/opt_rc_jkdkcx.aspx', params: {
      'key': Global.key,
      'fid': '20',
    });
    if (response != null && response.statusCode == 200 && response.data.toString().indexOf('最近健康打卡记录') != -1) {
      Log.log('正在获取历史记录 成功', name: '历史');
      final document = parse(response.data);
      final trs = document.querySelectorAll('tr[class="tr0"], tr[class="tr1"]');
      var list = Set<String>();
      trs.forEach((tr) {
        var str = tr.querySelectorAll('td')[0].text;
        str = str.replaceAll(RegExp(r'/\d*/'), '/' + RegExp(r'/(\d*)/').firstMatch(str).group(1).padLeft(2, '0') + '/');
        str = str.replaceAll(RegExp(r'/\d*$'), '/' + RegExp(r'/(\d*)$').firstMatch(str).group(1).padLeft(2, '0'));
        list.add(str);
      });
      setState(() {
        this.list = list;
      });
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('历史记录获取失败，请稍后重试'),));
      Log.log('正在获取历史记录 失败', name: '历史');
    }
  }

  List<Widget> getListWidgets() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    var currentDate = DateTime.parse(Global.startDate);
    var widgetList = List<Widget>();
    while (currentDate != tomorrow) {
      ListTile lt;
      final str = currentDate.toString().substring(0, 10).replaceFirst('-', ' 年 ').replaceFirst('-', ' 月 ') + ' 日';
      if (list.contains(currentDate.toString().substring(0, 10).replaceAll('-', '/'))) {
        lt = ListTile(leading: Icon(Icons.check_box), title: Text(str),);
        if (kReleaseMode) {
          if (currentDate == today) {
            Global.checked = true;
          }
        }
      } else {
        lt = ListTile(leading: Icon(Icons.check_box_outline_blank), title: Text(str),);
      }
      widgetList.insert(0, lt);
      currentDate = currentDate.add(Duration(days: 1));
    }
     return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadHistory,
        child: ListView(
          children: getListWidgets(),
        ),
      ),
    );
  }
}
