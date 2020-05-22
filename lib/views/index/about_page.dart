import 'package:flutter/material.dart';

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
          leading: Icon(Icons.bug_report),
          title: Text('联系 || 虫子反馈'),
          subtitle: Text('为什么不问问神奇海螺呢'),
        )
      ],
    );
  }
}

