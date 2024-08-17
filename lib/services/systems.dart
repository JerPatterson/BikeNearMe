import 'package:bike_near_me/entities/system.dart';
import 'package:bike_near_me/entities/system_availability.dart';
import 'package:firebase_database/firebase_database.dart';


class Systems {
  Systems._create({required this.database});

  static Future<Systems> create(FirebaseDatabase database) async {
    var instance = Systems._create(database: database);

    var snapshot = await database.ref('systems').get();
    for (var system in instance._systemsFromJson(snapshot.value)) {
      instance.systems.add(system);
      instance._systemById.putIfAbsent(system.id, () => system);
    }

    return instance;
  }

  final FirebaseDatabase database;
  final List<System> systems = [];
  final Map<String, System> _systemById = {};
  final Map<String, SystemAvailability> _systemAvailabilityById = {};


  System? getSystemById(String id) {
    return _systemById[id];
  }

  Future<SystemAvailability?> getSystemAvailabilityById(String id) async {
    try {
      DataSnapshot? snapshot;
      if (!_systemAvailabilityById.containsKey(id)) {
        snapshot = await database.ref(id).get();
      }
      return _systemAvailabilityById.putIfAbsent(id, () {
        return SystemAvailability.fromJson(Map<String, dynamic>.from(snapshot!.value as Map));
      });
    } catch (_) {
      return null;
    }
  }

  List<System> _systemsFromJson(list) => List<System>.from(
    list.map((x) => System.fromJson(Map<String, dynamic>.from(x as Map)))
  );
}
