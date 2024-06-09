import 'package:bike_near_me/entities/system.dart';
import 'package:firebase_database/firebase_database.dart';


class SystemsData {
  SystemsData._create({required this.database}) {
    database.ref('systems').get().then((snapshot) {
      for (var system in _systemsFromJson(snapshot.value)) {
        systems.add(system);
        _systemsById.putIfAbsent(system.id, () => system);
      }
    });
  }

  static Future<SystemsData> create(FirebaseDatabase database) async {
    var instance = SystemsData._create(database: database);

    var snapshot = await database.ref('systems').get();
    for (var system in instance._systemsFromJson(snapshot.value)) {
      instance.systems.add(system);
      instance._systemsById.putIfAbsent(system.id, () => system);
    }

    return instance;
  }

  final FirebaseDatabase database;
  final List<System> systems = [];
  final Map<String, System> _systemsById = {};


  System? getSystemById(String id) {
    return _systemsById[id];
  }

  List<System> _systemsFromJson(list) => List<System>.from(
    list.map((x) => System.fromJson(Map<String, dynamic>.from(x as Map)))
  );
}
