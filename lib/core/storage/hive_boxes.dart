import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const conversations = 'conversations';
  static const settings = 'settings';
  static const memories = 'memories';

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox<dynamic>(conversations),
      Hive.openBox<dynamic>(settings),
      Hive.openBox<dynamic>(memories),
    ]);
  }
}
