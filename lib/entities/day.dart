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
        return DayOfWeek(name: "Lundi", letterAbbreviation: "L");
      case 2:
        return DayOfWeek(name: "Mardi", letterAbbreviation: "M");
      case 3:
        return DayOfWeek(name: "Mercredi", letterAbbreviation: "M");
      case 4:
        return DayOfWeek(name: "Jeudi", letterAbbreviation: "J");
      case 5:
        return DayOfWeek(name: "Vendredi", letterAbbreviation: "V");
      case 6:
        return DayOfWeek(name: "Samedi", letterAbbreviation: "S");
      case 7:
        return DayOfWeek(name: "Dimanche", letterAbbreviation: "D");
    }

    return DayOfWeek(name: "Dimanche", letterAbbreviation: "D");
  }
}