import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _cityController = TextEditingController();
  final _touchDescriptionController = TextEditingController();

  Map<String, dynamic> _data = {
    Global.atSchool: '',
    Global.observation: '',
    Global.health: Set<String>(),
    Global.study: '',
    Global.history1: Set<String>(),
    Global.history2: '',
  };
  bool _changed = false;
  bool _loading = false;

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
        _data[Global.health] = prefs.getString(Global.health) != null ?
          Set.from(prefs.getString(Global.health).split(',')) : Set<String>();
        _changed = prefs.getBool(Global.changed);
        if (_changed) {
          _data[Global.study] = prefs.getString(Global.study) ?? '';
          _data[Global.history1] = prefs.getString(Global.history1) != null ?
            Set.from(prefs.getString(Global.history1).split(',')) : Set<String>();
          _data[Global.history2] = prefs.getString(Global.history2) ?? '';
        }
      });
      _locationController.text = prefs.getString(Global.location) ?? '';
      _temperatureController.text = prefs.getString(Global.temperature) ?? '';
      _descriptionController.text = prefs.getString(Global.description) ?? '';
      if (_changed) {
        _addressController.text = prefs.getString(Global.address) ?? '';
        _dateController.text = prefs.getString(Global.date) ?? '';
        _cityController.text = prefs.getString(Global.city) ?? '';
        _touchDescriptionController.text = prefs.getString(Global.touchDescription) ?? '';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('提醒'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('已自动填入上回数据'),
                  Text('若有变化请修改'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('好的'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
    }
  }

  void punchIn() async {
    if (Global.checked) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('今天的卡已打，请明早再来'),));
      return;
    }

    // Validate
    if (!_punchInKey.currentState.validate() || _data[Global.atSchool] == '' ||
        _data[Global.observation] == '' || _data[Global.health].length == 0 ||
        _changed && (_data[Global.study] == '' ||
            _data[Global.history1].length == 0 ||
            _data[Global.history2] == '')) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('有必填项未填写'),));
      return;
    }

    bool _flag = false;
    setState(() {
      _loading = true;
    });

    final params = {
      'key': Global.key,
      'fid': 20,
    };

    final url = '/opt_rc_jkdk.aspx';
    final Response reminderPageResponse = await HttpRequest.request(url, params: params);
    if (reminderPageResponse.statusCode == 200 && reminderPageResponse.data.indexOf('重要提醒') != -1) {
      Log.log('获取数据第一阶段 成功', name: '打卡');
      final document1 = parse(reminderPageResponse.data);
      final inputs1 = document1.querySelectorAll('input[type=hidden]');
      var promiseData = Map<String, String>();
      inputs1.forEach((input) {
        final attrs = input.attributes;
        promiseData.addAll({attrs['id']: attrs['value']});
      });
      promiseData.addAll({
//        '__EVENTTARGET': '',
//        '__EVENTARGUMENT': '',
        'ctl00\$cph_right\$e_ok': 'on',
        'ctl00\$cph_right\$ok_submit': '开始填报'
      });

      final Response punchPageResponse = await HttpRequest.request(url,
          params: params, method: 'post', data: promiseData,
          contentType: Headers.formUrlEncodedContentType);
      if (punchPageResponse.statusCode == 200 &&
          punchPageResponse.data.indexOf('提交保存') != -1) {
        Log.log('获取数据第二阶段 成功', name: '打卡');
        final document2 = parse(punchPageResponse.data);
        final inputs2 = document2.querySelectorAll('input[type=hidden]');
        var punchData = Map<String, String>();
        inputs2.forEach((input) {
          final attrs = input.attributes;
          punchData.addAll({attrs['id']: attrs['value']});
        });
        punchData.addAll({r'ctl00$cph_right$e_changed': 'on'});

        final Response detailPunchPageResponse = await HttpRequest.request(url,
            params: params, method: 'post', data: punchData,
            contentType: Headers.formUrlEncodedContentType);
        if (detailPunchPageResponse.statusCode == 200 &&
            detailPunchPageResponse.data.indexOf('学籍学业') != -1) {
          Log.log('获取数据第三阶段 成功', name: '打卡');
          final document3 = parse(detailPunchPageResponse.data);
          final inputs3 = document3.querySelectorAll('input[type=hidden]');
          var detailPunchData = Map<String, String>();
          inputs3.forEach((input) {
            final attrs = input.attributes;
            detailPunchData.addAll({attrs['id']: attrs['value']});
          });
          detailPunchData.addAll({
            r'ctl00$cph_right$e_atschool': _data[Global.atSchool],
            r'ctl00$cph_right$e_location': _locationController.text,
            r'ctl00$cph_right$e_observation': _data[Global.observation],
            r'ctl00$cph_right$e_temp': _temperatureController.text,
            r'ctl00$cph_right$e_describe': _descriptionController.text,
            r'ctl00$cph_right$e_submit': '提交保存'
          });
          _data[Global.health].forEach((element) {
            detailPunchData.addAll({'ctl00\$cph_right\$e_health\$${Global.healthStrings.indexOf(element)}': 'on'});
          });
          if (_changed) {
            detailPunchData.addAll({
              r'ctl00$cph_right$e_changed': 'on',
              r'ctl00$cph_right$e_xjzt': _data[Global.study],
              r'ctl00$cph_right$e_gfczd': _addressController.text,
              r'ctl00$cph_right$e_arvdate': _dateController.text,
              r'ctl00$cph_right$e_city': _cityController.text,
              r'ctl00$cph_right$e_touch': _data[Global.history2],
              r'ctl00$cph_right$e_tchdescribe': _touchDescriptionController.text,
            });
            _data[Global.history1].forEach((element) {
              detailPunchData.addAll({'ctl00\$cph_right\$e_history\$${Global.historyStrings1.indexOf(element)}': 'on'});
            });
          }

          final Response punchPostResponse = await HttpRequest.request(url,
              params: params, method: 'post', data: detailPunchData,
              contentType: Headers.formUrlEncodedContentType);
          final position = punchPostResponse.data.indexOf('打卡成功');

          if (punchPostResponse.statusCode == 200 && position != -1) {
            _flag = true;
            Global.checked = true;
            Log.log('正在打卡 成功', name: '打卡');
            Scaffold.of(context).showSnackBar(SnackBar(content: Text('打卡成功'),));

            // Save form data
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool(Global.changed, _changed);
            Map<String, String> map = <String, String>{
              Global.atSchool: _data[Global.atSchool],
              Global.location: _locationController.text,
              Global.observation: _data[Global.observation],
              Global.health: _data[Global.health].join(','),
              Global.temperature: _temperatureController.text,
              Global.description: _descriptionController.text,
            };
            if (_changed) {
              map.addAll({
                Global.study: _data[Global.study],
                Global.address: _addressController.text,
                Global.date: _dateController.text,
                Global.history1: _data[Global.history1].join(','),
                Global.city: _cityController.text,
                Global.history2: _data[Global.history2],
                Global.touchDescription: _touchDescriptionController.text,
              });
            }
            map.forEach((k, v) {
              prefs.setString(k, v);
            });
            prefs.setString(Global.punchData, '');

            // Clear form
            setState(() {
              _data[Global.atSchool] = '';
              _data[Global.observation] = '';
              _data[Global.health].clear();
              _data[Global.study] = '';
              _data[Global.history1].clear();
              _data[Global.history2] = '';

            });
            _locationController.text = '';
            _temperatureController.text = '';
            _descriptionController.text = '';
            _addressController.text = '';
            _dateController.text = '';
            _cityController.text = '';
            _touchDescriptionController.text = '';
          } else {
            Log.log('正在打卡 失败', name: '打卡');
          }
        } else {
          Log.log('获取数据第三阶段 失败', name: '打卡');
        }
      } else {
        Log.log('获取数据第二阶段 失败', name: '打卡');
      }
    } else {
      Log.log('获取数据第一阶段 失败', name: '打卡');
    }
    setState(() {
      _loading = false;
    });
    if (!_flag) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('打卡失败，请稍后重试'),));
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
                  Text("当天是否在校 *", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Row(
                children: <Widget>[
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 3.0,
                    children: getWidgets(strings: Global.atSchoolStrings, type: Global.atSchool),
                  ),
                ],
              ),
              CustomDivider(),

              TextFormField(
                enabled: !_loading,
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "当天所在地 *",
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

              Row(
                children: <Widget>[
                  Text("医学观察情况 *", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 3.0,
                children: getWidgets(strings: Global.observationStrings, type: Global.observation),
              ),
              CustomDivider(),

              Row(
                children: <Widget>[
                  Text("当天健康情况 *", style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 3.0,
                children: getWidgets(
                  strings: Global.healthStrings,
                  type: Global.health,
                  multiple: true,
                ),
              ),
              CustomDivider(),

              TextFormField(
                enabled: !_loading,
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: "当天实测额温 *",
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

              TextFormField(
                enabled: !_loading,
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "症状、就诊及特殊情况说明",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  hintText: "“无不适”情况可留空，其它情况请详细说明",
                ),
              ),

              CheckboxListTile(
                title: Text('旅居 / 接触史有否变化'),
                subtitle: Text('有则勾选展开，无则不需理会'),
                value: _changed,
                onChanged: _loading ? null : (bool value) {
                  if (value) {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('提醒'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('此部分未进行测试（毕竟不能乱填），请知悉'),
                              Text('若用时遇到 bug 请联系开发者，谢谢'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('好的'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                  }
                  setState(() {
                    _changed = value;
                  });
                },
              ),
              CustomDivider(),

              Column(
                children: detailWidgets(),
              ),

              Container(
                margin: EdgeInsets.only(top: 10.0),
                width: double.infinity,
                height: 44,
                child: RaisedButton(
                  child: _loading ?
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                      ): Text('提交'),
                  color: Colors.blueAccent,
                  onPressed: _loading ? null : punchIn,
                ),
              )
            ],
          )
        )
      ),
    ],);
  }
  
  List<Widget> detailWidgets() {
    var widgetList = List<Widget>();
    if (_changed) {
      widgetList.add(Row(children: <Widget>[
        Text("学籍学业状态 *", style: TextStyle(fontWeight: FontWeight.bold),)
      ],));
      widgetList.add(Wrap(
        spacing: 5.0,
        runSpacing: 3.0,
        children: getWidgets(strings: Global.studyStrings, type: Global.study),
      ));
      widgetList.add(CustomDivider());

      widgetList.add(TextFormField(
        enabled: !_loading,
        controller: _addressController,
        decoration: InputDecoration(
          labelText: "穗（佛）常住地址 *",
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          hintText: "__市__区及详细地址 / 无穗（佛）常住地请写“无”",
        ),
        validator: (value) {
          if (_changed && value.isEmpty) {
            return "不能为空";
          }
          return null;
        },
      ));

      widgetList.add(TextFormField(
        enabled: !_loading,
        controller: _dateController,
        decoration: InputDecoration(
          labelText: "抵穗（佛）日期",
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          hintText: "日期格式：2020/5/22，未返回者不填写",
        ),
      ));

      widgetList.add(Row(children: <Widget>[
        Text("一个月内旅 / 居史 *", style: TextStyle(fontWeight: FontWeight.bold),)
      ],));
      widgetList.add(Wrap(
        spacing: 5.0,
        runSpacing: 3.0,
        children: getWidgets(strings: Global.historyStrings1, type: Global.history1, multiple: true),
      ));
      widgetList.add(CustomDivider());

      widgetList.add(TextFormField(
        enabled: !_loading,
        controller: _cityController,
        decoration: InputDecoration(
          labelText: "一个月内旅 / 居城市 *",
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          hintText: "__市__区__县（区），未外出即填写本地",
        ),
        validator: (value) {
          if (_changed && value.isEmpty) {
            return "不能为空";
          }
          return null;
        },
      ));

      widgetList.add(Row(children: <Widget>[
        Text("近期旅居 / 接触史 *", style: TextStyle(fontWeight: FontWeight.bold),)
      ],));
      widgetList.add(Wrap(
        spacing: 5.0,
        runSpacing: 3.0,
        children: getWidgets(strings: Global.historyStrings2, type: Global.history2),
      ));
      widgetList.add(CustomDivider());

      widgetList.add(TextFormField(
        enabled: !_loading,
        controller: _touchDescriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "接触日期及具体情况",
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          hintText: "“无接触”情况可留空，其它情况请详细说明日期、车次航班、接触人员、具体情况",
        ),
      ),);
    }
    return widgetList;
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
        onSelected: _loading ? null : (bool selected) {
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
