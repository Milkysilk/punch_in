import 'package:flutter/material.dart';
import 'package:punch_in/views/index.dart';
import 'package:punch_in/views/login_page.dart';

void main() => runApp(App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "打我的卡",
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
//        highlightColor: Colors.transparent,
//        splashColor: Colors.transparent,
      ),
      routes: {
        "/": (context) => LoginPage(title: "登录",),
        "/home": (context) => StackPage(),
      },
      initialRoute: "/",
    );
  }
}
