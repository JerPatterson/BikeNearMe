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
      instance._systemById.putIfAbsent(
        system.id, () => system
      );
      instance._systemAvailabilityById.putIfAbsent(
        system.id, () => SystemAvailability.create(system.id, database)
      );
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

  SystemAvailability? getSystemAvailabilityById(String id) {
    return _systemAvailabilityById[id];
  }

  List<System> _systemsFromJson(list) => List<System>.from(
    list.map((x) => System.fromJson(Map<String, dynamic>.from(x as Map)))
  );
}
