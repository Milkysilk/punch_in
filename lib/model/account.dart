import 'package:punch_in/common/global.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  final int id;
  final String studentId;
  final String password;

  Account({this.id, this.studentId, this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      Global.studentId: studentId,
      Global.password: password,
    };
  }

  static Future<void> insertAccount(Account account) async {
    final Database db = await Global.getDatabase();
    await db.insert(
      Global.accountTable,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Account>> accounts() async {
    final Database db = await Global.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(Global.accountTable);
    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'],
        studentId: maps[i][Global.studentId],
        password: maps[i][Global.password],
      );
    });
  }
}