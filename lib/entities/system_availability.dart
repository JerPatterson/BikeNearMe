import 'package:bike_near_me/entities/availibility.dart';

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
  SystemAvailability({
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  final Map<String, dynamic> sunday;
  final Map<String, dynamic> monday;
  final Map<String, dynamic> tuesday;
  final Map<String, dynamic> wednesday;
  final Map<String, dynamic> thursday;
  final Map<String, dynamic> friday;
  final Map<String, dynamic> saturday;

  factory SystemAvailability.fromJson(Map<String, dynamic> json) => SystemAvailability(
    sunday: Map<String, dynamic>.from(json['"sunday"'] as Map),
    monday: Map<String, dynamic>.from(json['"monday"'] as Map),
    tuesday: Map<String, dynamic>.from(json['"tuesday"'] as Map),
    wednesday: Map<String, dynamic>.from(json['"wednesday"'] as Map),
    thursday: Map<String, dynamic>.from(json['"thursday"'] as Map),
    friday: Map<String, dynamic>.from(json['"friday"'] as Map),
    saturday: Map<String, dynamic>.from(json['"saturday"'] as Map),
  );


  Map<String, Map<String, Availability>>? getStationAvailability(String id) {
    Map<String, Map<String, Availability>> availabilityByDay = {};
    for (String day in daysOfTheWeek) {
      availabilityByDay.putIfAbsent(day, () {
        Map<String, Availability> availabilityByHour = {};
        for (String hour in (sunday['"$id"'] as Map).keys) {
          availabilityByHour.putIfAbsent(hour.replaceAll('"', ''), () {
            try {
              return Availability.fromJson(Map<String, dynamic>.from(sunday['"$id"'] as Map)[hour]);
            } catch (_) {
              return Availability(bikesAvailable: 0, docksAvailable: 0, electricBikesFromAvailable: 0);
            }
            
          });
        }

        return {...availabilityByHour};
      });
    }
    
    return {...availabilityByDay};
  }
}