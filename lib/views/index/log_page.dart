import 'package:flutter/material.dart';
import 'package:punch_in/widget/custom_divider.dart';

class LogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('更新日志'),),
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
          title: Text('2020-06-12 beta-2.1.1'),
          subtitle: Text('抓到一个当打卡失败时按钮一直转圈圈的小虫纸\n'
              '把更新日志搬到 App 上\n'
              '添加常见问题\n'
              '细节优化'),
        ),
        CustomDivider(),
        ListTile(
          title: Text('2020-05-23 beta-2.0.0'),
          subtitle: Text('移除 SQLite 支持\n'
              '完整的打卡选项（beta）\n'
              '新的下拉刷新动画\n'
              '添加手动刷新历史记录后的提示\n'
              '重新设置打卡页面为登录后默认显示的页面\n'
              '连接超时从 5000 ms 延长到 15000 ms（不能再多了\n'
              '请求过程禁止输入\n'
              '添加联系信息\n'
              '取消强制禁止熬夜打卡\n'
              '添加熬夜打卡的提醒\n'
              '添加 beta 功能未经测试的提醒\n'
              '添加自动填充提醒\n'
              '添加各种失败的提醒\n'),
        ),
        CustomDivider(),
        ListTile(
          title: Text('2020-05-22 release-1.1.1'),
          subtitle: Text('修复 SharedPreferences 对 SQLite 兼容的问题\n'
              '细节优化'),
        ),
        CustomDivider(),
        ListTile(
          title: Text('2020-05-22 beta-1.1.1'),
          subtitle: Text('修复部分机型无法自动登录的问题\n'
              '添加新的数据持久化机制：SharedPreferences（感谢重围鸽鸽和俊粒师弟的建议）\n'
              '细节优化'),
        ),
        CustomDivider(),
        ListTile(
          title: Text('2020-05-21 release-1.0.1'),
          subtitle: Text('禁止重复打卡的代码忘记取消注释了……'),
        ),
        CustomDivider(),
        ListTile(
          title: Text('2020-05-21 release-1.0.0'),
          subtitle: Text('首次发布'),
        )
      ],
    );
  }
}

