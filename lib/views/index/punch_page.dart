import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:punch_in/common/global.dart';
import 'package:punch_in/common/http_request.dart';
import 'package:punch_in/common/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PunchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Content(),
    );
  }
}

class Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final _punchInKey = GlobalKey<FormState>();

  final _locationController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _position = ['是', '否'];
  List<String> _observationStrings = ['无下列情况', '居家观察', '集中观察', '解除医学观察', '异常临床表现', '被列为疑似病例', '解除疑似病例', '是确诊病例', '确诊但已治愈'];
  List<String> _healthStrings = ['无不适', '发烧', '咳嗽', '气促', '乏力 / 肌肉酸痛', '其它症状'];
  Map<String, dynamic> _data = {
    Global.atSchool: '',
    Global.observation: '',
    Global.health: Set<String>(),
  };
  
  @override
  void initState() {
    super.initState();
    loadFormData();
  }

  void loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(Global.punchData) != null) {
      setState(() {
        _data[Global.atSchool] = prefs.getString(Global.atSchool) ?? '';
        _data[Global.observation] = prefs.getString(Global.observation) ?? '';
        _data[Global.health] = prefs.getString(Global.health) != null ? Set.from(prefs.getString(Global.health).split(',')) : Set<String>();
      });
      _locationController.text = prefs.getString(Global.location) ?? '';
      _temperatureController.text = prefs.getString(Global.temperature) ?? '';
      _descriptionController.text = prefs.getString(Global.description) ?? '';
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('已自动填入上回数据，若情况有变切记修改'),));
    }
  }

  void punchIn() async {
    if (Global.checked) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('今天的卡已打，请明早再来'),));
      return;
    }

    if (DateTime.now().hour < 5 || DateTime.now().hour > 22) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('🙅🏻‍️🙅🏻禁止对服务器 DDoS，请早睡早起打卡'),));
      return;
    }

    final params = {
      'key': Global.key,
      'fid': 20,
    };

    if (_punchInKey.currentState.validate() && _data['atSchool'] != '' && _data['observation'] != '' && _data['health'].length > 0) {

      final url = '/opt_rc_jkdk.aspx';
      final Response reminderPageResponse = await HttpRequest.request(url, params: params);
      if (reminderPageResponse.statusCode == 200 && reminderPageResponse.data.indexOf('重要提醒') != -1) {
        Log.log('获取数据第一阶段 成功', name: '打卡');
        final document = parse(reminderPageResponse.data);
        final inputs = document.querySelectorAll('input[type=hidden]');
        var promiseData = Map<String, String>();
        inputs.forEach((input) {
          final attrs = input.attributes;
          promiseData.addAll({attrs['id']: attrs['value']});
        });
        promiseData.addAll({
          '__EVENTTARGET': '',
          '__EVENTARGUMENT': '',
          'ctl00\$cph_right\$e_ok': 'on',
          'ctl00\$cph_right\$ok_submit': '开始填报'
        });

        final Response punchPageResponse = await HttpRequest.request(url, params: params, method: 'post', data: promiseData, contentType: Headers.formUrlEncodedContentType);
        if (punchPageResponse.statusCode == 200 && punchPageResponse.data.indexOf('提交保存') != -1) {
          Log.log('获取数据第二阶段 成功', name: '打卡');
          final document = parse(punchPageResponse.data);
          final inputs1 = document.querySelectorAll('input[type=hidden]');
          var punchData = Map<String, String>();
          inputs1.forEach((input) {
            final attrs = input.attributes;
            punchData.addAll({attrs['id']: attrs['value']});
          });
          punchData.addAll({
            '__EVENTTARGET': '',
            '__EVENTARGUMENT': '',
            '__LASTFOCUS': '',
            'ctl00\$cph_right\$e_atschool': _data[Global.atSchool],
            'ctl00\$cph_right\$e_location': _locationController.text,
            'ctl00\$cph_right\$e_observation': _data[Global.observation],
            'ctl00\$cph_right\$e_temp': _temperatureController.text,
            'ctl00\$cph_right\$e_describe': _descriptionController.text,
            'ctl00\$cph_right\$e_submit': '提交保存'
          });
          _data[Global.health].forEach((element) {
            punchData.addAll({'ctl00\$cph_right\$e_health\$${_healthStrings.indexOf(element)}': 'on'});
          });

          final Response punchPostResponse = await HttpRequest.request(url, params: params, method: 'post', data: punchData, contentType: Headers.formUrlEncodedContentType);
          final position = punchPostResponse.data.indexOf('打卡成功');
          if (punchPostResponse.statusCode == 200 && position != -1) {
            Log.log('正在打卡 成功', name: '打卡');
            Scaffold.of(context).showSnackBar(SnackBar(content: Text('打卡成功'),));

            // Save form data
            final prefs = await SharedPreferences.getInstance();
            <String, String>{
              Global.atSchool: _data[Global.atSchool],
              Global.atSchool: _data[Global.atSchool],
              Global.location: _locationController.text,
              Global.observation: _data[Global.observation],
              Global.health: _data[Global.health].join(','),
              Global.temperature: _temperatureController.text,
              Global.description: _descriptionController.text,
            }.forEach((k, v) {
              prefs.setString(k, v);
            });
            prefs.setString(Global.punchData, '');

            // Clear form
            setState(() {
              _data[Global.atSchool] = '';
              _data[Global.observation] = '';
              _data[Global.health].clear();
            });
            _locationController.text = '';
            _temperatureController.text = '';
            _descriptionController.text = '';

          } else {
            Log.log('正在打卡 失败', name: '打卡');
          }
        } else {
          Log.log('获取数据第二阶段 失败', name: '打卡');
        }
      } else {
        Log.log('获取数据第一阶段 失败', name: '打卡');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(17.0),
        child: Form(
          key: _punchInKey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("当天是否在校", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Row(
                children: <Widget>[
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 3.0,
                    children: getWidgets(strings: _position, type: Global.atSchool),
                  ),
                ],
              ),
              CustomDivider(),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "当天所在地",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  hintText: "__省__市__县（区）",
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "不能为空";
                  }
                  return null;
                },
              ),
//              CustomDivider(),

              Row(
                children: <Widget>[
                  Text("医学观察情况", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 3.0,
                children: getWidgets(strings: _observationStrings, type: Global.observation),
              ),
              CustomDivider(),

              Row(
                children: <Widget>[
                  Text("当天健康情况", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 3.0,
                children: getWidgets(
                  strings: _healthStrings,
                  type: Global.health,
                  multiple: true,
                ),
              ),
              CustomDivider(),

              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: "当天实测额温",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  hintText: "如果测量值为腋温，减 0.5 填报即可",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return "不能为空";
                  }
                  return null;
                },
              ),
//              CustomDivider(),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "症状、就诊及特殊情况说明",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  hintText: "“无不适”情况可留空，其它情况请详细说明",
                ),
              ),
//              CustomDivider(),

              Container(
                child: Text(
                  "// TODO（“旅居 / 接触史有否变化”有点长，有空再做；有变化的请上系统打）",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              CustomDivider(),

              Container(
                width: double.infinity,
                height: 44,
                child: RaisedButton(
                  child: Text('提交'),
                  color: Colors.blueAccent,
                  onPressed: punchIn,
                ),
              )
            ],
          )
        )
      ),
    ],);
  }

  List<Widget> getWidgets({
    @required List<String> strings,
    @required String type,
    bool multiple = false,
  }) {
    var widgetList = List<Widget>();
    for (var i = 0; i < strings.length; i++) {
      widgetList.add(FilterChip(
        label: Text(strings[i]),
        selected: multiple ? _data[type].contains(strings[i]) : _data[type] == strings[i],
        selectedColor: Color(0xffeadffd),
        backgroundColor: Color(0xffededed),
        onSelected: (bool selected) {
          setState(() {
            if (multiple) {
              selected ? (() {
                strings[i] == '无不适' ? _data[type].clear() : _data[type].remove('无不适');
                _data[type].add(strings[i]);
              })() : _data[type].remove(strings[i]);
            } else {
              if (selected) {
                _data[type] = strings[i];
              }
            }
          });
        },
      ));
    }
    return widgetList;
  }
}

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 15.0,
      thickness: 1.0,
      color: Colors.blueGrey,
    );
  }
}
