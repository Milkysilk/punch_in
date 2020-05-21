import 'package:flutter/material.dart';
import 'package:punch_in/views/index/about_page.dart';
import 'package:punch_in/views/index/history_page.dart';
import 'package:punch_in/views/index/punch_page.dart';

class StackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StackPageState();
}

class StackPageState extends State<StackPage> {
  var _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("打我的卡"),),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          PunchPage(),
          HistoryPage(),
          AboutPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 28,
        unselectedFontSize: 14,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            title: Text("打卡")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text("历史")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text("关于")
          )
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

