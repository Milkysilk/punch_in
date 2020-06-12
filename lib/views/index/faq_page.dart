import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('常见问题'),),
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
          title: Text('Q: 这个 App 安全吗？会不会泄露个人隐私？'),
          subtitle: Text('A: 好吧这个问题是我自己提的。答案是不知道，不会。安不安全看自己呀。App 只把信息存储在本地，除了系统的服务器外，不存在任何第三方服务器。此外，已经强调了 ∞ 次，不放心可以先上系统修改密码，建议使用浏览器或第三方密码管理器生成随机密码。最后，App 只申请了网络权限。'),
        ),
        ListTile(
          title: Text('Q: 可以自动登录吗？'),
          subtitle: Text('A: 亲，可以的'),
        ),
        ListTile(
          title: Text('Q: 可以自动填入上次所填的吗？'),
          subtitle: Text('A: 可以的，亲'),
        ),
        ListTile(
          title: Text('Q: （beta-2.0.0）修复了 12 点后不能打卡的 bug？'),
          subtitle: Text('A: （非杠，是 23 点）额，可能是大家听从了我的建议……吧，都早起早睡健康打卡了，服务器不那么拥挤了，那就取消强制禁止夜间打卡改为提醒早睡咯'),
        ),
        ListTile(
          title: Text('Q: 修复了 12 点后可以打卡的 bug？'),
          subtitle: Text('A: toast(\'网站崩了，雨我无瓜\')  // 技术指导：重围鸽鸽'),
        )
      ],
    );
  }
}
