import 'dart:async';
import 'dart:convert';
import 'package:bike_near_me/entities/place_item.dart';
import 'package:bike_near_me/entities/system.dart';
import 'package:bike_near_me/icons/bike_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class SearchPlacePage extends StatefulWidget {
  const SearchPlacePage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.systems,
  });

  final double latitude;
  final double longitude;
  final List<System> systems;

  @override
  State<SearchPlacePage> createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  List<System> _systemsSuggestions = [];
  List<PlaceItem> _placeSuggestions = [];
  Timer? _inputChangedCallbackTimer;

  late SharedPreferences prefs;
  List<PlaceItem> _recentSearchSuggestions = [];


  @override
  void initState() {
    super.initState();
    initRecentSearchSuggestions();
    _systemsSuggestions = widget.systems.sublist(0, 3);
  }


  initRecentSearchSuggestions() async {
    prefs = await SharedPreferences.getInstance();
    var recentSearches = prefs.getStringList("recentSearches") ?? [];
    _recentSearchSuggestions = recentSearches.map((item) => PlaceItem.fromJson(jsonDecode(item))).toList();

    setState(() {
      _recentSearchSuggestions = _recentSearchSuggestions;
    });
  }

  updateRecentSearch(PlaceItem placeItem) {
    if (_recentSearchSuggestions.contains(placeItem)) {
      _recentSearchSuggestions.remove(placeItem);
    }

    _recentSearchSuggestions.insert(0, placeItem);
    if (_recentSearchSuggestions.length > 15) {
      _recentSearchSuggestions.removeLast();
    }

    prefs.setStringList("recentSearches", _recentSearchSuggestions.map((item) => jsonEncode(PlaceItem.toMap(item))).toList());
  }

  void updateSuggestionsWithInput(String input) {
    _inputChangedCallbackTimer?.cancel();
    updateSystemsSuggestions(input);

      _inputChangedCallbackTimer = Timer(Duration(milliseconds: 800), () async {
        try {
          var url = Uri.parse("https://photon.komoot.io/api/?q=$input&lat=${widget.latitude}&lon=${widget.longitude}&limit=5");
          var res = await http.get(url);
          Map<String, dynamic> json = jsonDecode(res.body);
          _placeSuggestions.clear();
          for (var item in json["features"]) {
            _placeSuggestions.add(PlaceItem.fromJson(item));
          }

          setState(() {
            _placeSuggestions = _placeSuggestions;
          });
        } catch (_) {
          return;
        }
      });
  }

  updateSystemsSuggestions(String input) {
    if (input.isEmpty) {
      setState(() {
        _systemsSuggestions = widget.systems.sublist(0, 3);
      });
      return;
    }

    var listFilterFromInput = widget.systems.where((element) {
      return element.name.toLowerCase().contains(input.toLowerCase())
        || element.locationName.toLowerCase().contains(input.toLowerCase());
    }).toList();

    setState(() {
      _systemsSuggestions = listFilterFromInput.length > 3 
        ? listFilterFromInput.sublist(0,  3) : listFilterFromInput;
    });
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => {
                            updateSuggestionsWithInput(value)
                          },
                          autofocus: true,
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Endroit ou système",
                            hintStyle: TextStyle(color: Color(0xC0FFFFFF)),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 16.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  ),
                  Column(
                    children: _systemsSuggestions.map((system) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 18.0, 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(system);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: system.color,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12.0),
                                Text(
                                  String.fromCharCode(BikeShare.bike.codePoint),
                                  style: TextStyle(
                                    color: system.textColor,
                                    fontSize: 30.0,
                                    fontFamily: BikeShare.bike.fontFamily,
                                    package: BikeShare.bike.fontPackage,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8.0),
                                      Text(
                                        system.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: system.textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        system.locationName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: system.textColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
          
              if (_placeSuggestions.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 18.0, top: 16.0),
                  child: Text(
                    "RÉSULTATS DE RECHERCHE",
                    style: TextStyle(
                      color: Color(0xF0000000),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Divider(
                  height: 9.0,
                  color: const Color(0x40000000),
                  thickness: 1.0,
                  indent: 18.0,
                  endIndent: 18.0,
                ),
                Column(
                  children: _placeSuggestions.map((place) {
                    return InkWell(
                      onTap: () {
                        updateRecentSearch(place);
                        Navigator.of(context).pop(place);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 18.0, 0.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 24.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8.0),
                                  Text(
                                    place.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    place.subName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xF0000000),
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  if (place != _placeSuggestions.last)
                                    Divider(
                                      height: 1.0,
                                      color: const Color(0x40000000),
                                      thickness: 1.0,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
          
              if (_recentSearchSuggestions.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 18.0, top: 16.0),
                  child: Text(
                    "RECHERCHES RÉCENTES",
                    style: TextStyle(
                      color: Color(0xF0000000),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Divider(
                  height: 9.0,
                  color: const Color(0x40000000),
                  thickness: 1.0,
                  indent: 18.0,
                  endIndent: 18.0,
                ),
                Column(
                  children: _recentSearchSuggestions.map((recent) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop(recent);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 18.0, 0.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 24.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8.0),
                                  Text(
                                    recent.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    recent.subName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xF0000000),
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  if (recent != _recentSearchSuggestions.last)
                                    Divider(
                                      height: 1.0,
                                      color: const Color(0x40000000),
                                      thickness: 1.0,
                                    ),
                                  if (recent == _recentSearchSuggestions.last)
                                    const SizedBox(height: 16.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
