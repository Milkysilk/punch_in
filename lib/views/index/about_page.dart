import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:punch_in/common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Content(),
    );
  }
}

class Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.developer_mode),
          title: Text('开发者'),
          subtitle: Text('外包 16 的'),
        ),
        ListTile(
          leading: Icon(Icons.event_note),
          title: Text('更新日志'),
          subtitle: Text('CHANGES'),
          onTap: () {
            Navigator.pushNamed(context, '/log');
          },
        ),
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('常见问题'),
          subtitle: Text('FAQ'),
          onTap: () {
            Navigator.pushNamed(context, '/faq');
          },
        ),
        ListTile(
          leading: Icon(Icons.bug_report),
          title: Text('联系 && 反馈', style: TextStyle(color: Colors.blue),),
          subtitle: Text('打开 QQ', style: TextStyle(color: Colors.blue),),
          onTap: () async {
            String url = '';
            if (Platform.isAndroid) {
              url = 'mqqwpa://im/chat?chat_type=wpa&uin=${Global.qq}';
            }

            if (await canLaunch(url)) {
              await launch(url);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('无法启动 QQ'),));
            }
          },
        )
      ],
    );
  }
}
