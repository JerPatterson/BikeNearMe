class DayOfWeek {
  DayOfWeek({
    required this.name,
    required this.letterAbbreviation,
  });

  final String name;
  final String letterAbbreviation;

  static DayOfWeek create(int weekday) {
    switch (weekday) {
      case 1:
        return DayOfWeek(name: "monday", letterAbbreviation: "L");
      case 2:
        return DayOfWeek(name: "tuesday", letterAbbreviation: "M");
      case 3:
        return DayOfWeek(name: "wednesday", letterAbbreviation: "M");
      case 4:
        return DayOfWeek(name: "thursday", letterAbbreviation: "J");
      case 5:
        return DayOfWeek(name: "friday", letterAbbreviation: "V");
      case 6:
        return DayOfWeek(name: "saturday", letterAbbreviation: "S");
      case 7:
        return DayOfWeek(name: "sunday", letterAbbreviation: "D");
    }

    return DayOfWeek(name: "sunday", letterAbbreviation: "D");
  }
}