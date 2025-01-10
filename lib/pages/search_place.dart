import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SearchPlacePage extends StatefulWidget {
  const SearchPlacePage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<SearchPlacePage> createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  List<String> _placeSuggestions = [];
  Timer? _inputChangedCallbackTimer;

  @override
  void initState() {
    super.initState();
  }


  void updateSuggestionsWithInput(String input) {
    _inputChangedCallbackTimer?.cancel();

      _inputChangedCallbackTimer = Timer(Duration(milliseconds: 800), () async {
        try {
          var url = Uri.parse("https://photon.komoot.io/api/?q=$input&lat=${widget.latitude}&lon=${widget.longitude}&limit=5");
          var res = await http.get(url);
          Map<String, dynamic> json = jsonDecode(res.body);
          _placeSuggestions.clear();
          for (var feature in json["features"]) {
            _placeSuggestions.add(feature["properties"]["name"]);
          }

          setState(() {
            _placeSuggestions = _placeSuggestions;
          });
        } catch (_) {
          return;
        }
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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

          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 16.0),
            child: const Text(
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
            color: Color(0x40000000),
            thickness: 1.0,
            indent: 18.0,
            endIndent: 18.0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placeSuggestions.length,
              itemBuilder: (context, index) {
                return Padding(
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
                              _placeSuggestions[index],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _placeSuggestions[index],
                              style: const TextStyle(
                                color: Color(0xF0000000),
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (index != _placeSuggestions.length - 1) Divider(
                              height: 1.0,
                              color: Color(0x40000000),
                              thickness: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
