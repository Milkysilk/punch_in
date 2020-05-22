import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:punch_in/common/global.dart';
import 'package:punch_in/common/http_request.dart';
import 'package:punch_in/common/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final title;

  LoginPage({Key key, this.title}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Content(),
    );
  }
}

class Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Login()
        ],
      ),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  final _loginFormKey = GlobalKey<FormState>();
//  String _account;
//  String _password;
  bool _isHidden = true;

  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();

  void _toggleVisibility () {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  // Login
  void login() async {
    if (_loginFormKey.currentState.validate()) {
      if (await loginLogic(_accountController.text, _passwordController.text)) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  // Auto login
  void autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(Global.accountData) != null) {
      _accountController.text = prefs.getString(Global.account);
      _passwordController.text = prefs.getString(Global.password);
      login();
    }
  }

  // Login process
  Future<bool> loginLogic(String username, String password) async {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('登录中')));
    var flag = false;
    Response loginPageResponse = await HttpRequest.request('/login.aspx');
    if (loginPageResponse.statusCode == 200) {
      Log.log('正在获取数据 成功', name: '登录');

      // Get data
      var document = parse(loginPageResponse.data);
      var inputs = document.querySelectorAll('input[type=hidden]');
      var data = Map<String, dynamic>();
      for (var input in inputs) {
        var attrs = input.attributes;
        data.addAll({attrs['id']: attrs['value']});
      }
      data.addAll({'__EVENTTARGET': 'logon', '__EVENTARGUMENT': '', 'log_username': username, 'log_password': password});

      // Login
      await HttpRequest.request('/login.aspx', method: 'post', data: data, contentType: Headers.formUrlEncodedContentType);
      final Response defaultPageResponse = await HttpRequest.request('/default.aspx');
      if (defaultPageResponse.statusCode == 200 && defaultPageResponse.data.indexOf(username) != -1) {
        Log.log('正在登录 成功', name: '登录');
        flag = true;

        // Save form data
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(Global.account, username);
        prefs.setString(Global.password, password);
        prefs.setString(Global.accountData, '');
        final document = parse(defaultPageResponse.data);
        var str = document.querySelector('.bdpink > a').attributes['href'];
        Global.key = str.substring(str.indexOf('=') + 1, str.indexOf('&'));

      } else {
        Log.log('正在登录 失败', name: '登录');
      }
    } else {
      Log.log('正在获取数据 失败', name: '登录');
    }
    if (!flag) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('登录失败')));
    }
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(17.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _accountController,
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: "学号",
              ),
              maxLength: 10,
              keyboardType: TextInputType.number,
//              onSaved: (value) {
//                this._account = value;
//              },
              validator: (value) {
                if (value.isEmpty) {
                  return "学号不能为空";
                } else if (value.length != 10) {
                  return "学号为 10 位数字";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: _isHidden,
              decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: "密码",
                  suffixIcon: IconButton(
                    icon: _isHidden ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    onPressed: _toggleVisibility,
                  )
              ),
              maxLength: 20,
//              onSaved: (value) {
//                this._password = value;
//              },
              validator: (value) {
                if (value.isEmpty) {
                  return "密码不能为空";
                }
                return null;
              },
            ),
            Container(
              width: double.infinity,
              height: 44,
              child: RaisedButton(
                color: Colors.blueAccent,
                child: Text("登录", ),
                onPressed: login,
              ),
            )
          ],
        ),
      ),
    );
  }
}
