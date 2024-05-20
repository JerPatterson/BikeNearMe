import 'package:bike_near_me/entities/system.dart';
import 'package:firebase_database/firebase_database.dart';


class SystemsData {
  SystemsData({required this.database}) {
    database.ref('systems').get().then((snapshot) {
      for (var system in _systemsFromJson(snapshot.value)) {
        systems.add(system);
        _systemsById.putIfAbsent(system.id, () => system);
      }
    });
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
