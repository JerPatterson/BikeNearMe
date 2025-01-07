import 'package:bike_near_me/entities/availibility.dart';
import 'package:firebase_database/firebase_database.dart';

const daysOfTheWeek = [
  "sunday",
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
];


class SystemAvailability {
  SystemAvailability._create({
    required this.systemId,
    required this.database
  });

  static SystemAvailability create(String systemId, FirebaseDatabase database) {
    var instance = SystemAvailability._create(systemId: systemId, database: database);

    return instance;
  }

  final String systemId;
  final FirebaseDatabase database;


  Future<Map<String, Map<String, Availability>>?> getStationAvailability(String stationId) async {
    try {
      Map<String, Map<String, Availability>> availabilityByDay = {};
      for (String day in daysOfTheWeek) {
        DataSnapshot snapshot = await database.ref("$systemId/$day/_$stationId").get();
        availabilityByDay.putIfAbsent(day, () {
          Map<String, dynamic> dataOfDay = Map<String, dynamic>.from(snapshot.value as Map);
          Map<String, Availability> availabilityByHour = {};        
          for (String hour in (dataOfDay as Map).keys) {
            availabilityByHour.putIfAbsent(hour, () {
              try {
                return Availability.fromJson(Map<String, dynamic>.from(Map<String, dynamic>.from(dataOfDay as Map)[hour] as Map));
              } catch (_) {
                return Availability(bikesAvailable: 0, docksAvailable: 0, electricBikesFromAvailable: 0);
              }
            });
          }

          return {...availabilityByHour};
        });
      }

      return {...availabilityByDay};
    } catch (_) {
      return null;
    }
  }
}
