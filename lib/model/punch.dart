import 'package:punch_in/common/global.dart';
import 'package:sqflite/sqflite.dart';

class Punch {
  final int id;
  final String atSchool;
  final String location;
  final String observation;
  final String health;
  final String temperature;
  final String extra;

  Punch({this.id, this.atSchool, this.location, this.observation, this.health, this.temperature, this.extra});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      Global.atSchool: atSchool,
      Global.location: location,
      Global.observation: observation,
      Global.health: health,
      Global.temperature: temperature,
      Global.extra: extra,
    };
  }

  static Future<void> insertPunch(Punch punch) async {
    final Database db = await Global.getDatabase();
    await db.insert(
      Global.punchTable,
      punch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Punch>> punches() async {
    final Database db = await Global.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(Global.punchTable);
    return List.generate(maps.length, (i) {
      return Punch(
        id: maps[i]['id'],
        atSchool: maps[i][Global.atSchool],
        location: maps[i][Global.location],
        observation: maps[i][Global.observation],
        health: maps[i][Global.health],
        temperature: maps[i][Global.temperature],
        extra: maps[i][Global.extra],
      );
    });
  }

}