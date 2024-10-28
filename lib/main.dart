import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// entry point of app
void main() {
  runApp(const MyApp());
}

// root widget of app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// home page widget
class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  // Initial state values
  String _cityData = "Press the button to load city data";
  String _warningData = "Press the button to load warning data";

  List<City> _cities = [];
  List<Warning> _warnings = [];

  // http requests
  Future<void> fetchCityCodes() async {
    final String url = 'https://api.ipma.pt/open-data/distrits-islands.json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Manually decode the response body using UTF-8
        var utf8DecodedBody = utf8.decode(response.bodyBytes);
        var data = json.decode(utf8DecodedBody);

        print(data);
        var cityList =
            data['data'] as List; // extracting the list from the map.
        List<City> loadedCities =
            cityList.map((json) => City.fromJson(json)).toList();

        // dar sort alfabeticamente
        loadedCities.sort((a, b) => a.name.compareTo(b.name));

        setState(() {
          _cities = loadedCities;
        });
        print(_cityData);
        //print(data); // Printing the data to inspect the structure
      } else {
        throw Exception('Failed to load city codes');
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        _cityData = 'Error loading city from data: $e';
      });
    }
  }

  Future<void> fetchWeatherWarnings() async {
    final String url =
        'https://api.ipma.pt/open-data/forecast/warnings/warnings_www.json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Manually decode the response body using UTF-8
        var utf8DecodedBody = utf8.decode(response.bodyBytes);
        var data = json.decode(utf8DecodedBody);

        print(data);
        var warningList = data as List;
        List<Warning> loadedWarnings =
            warningList.map((json) => Warning.fromJson(json)).toList();

        // dar sort alfabeticamente
        loadedWarnings.sort((a, b) => a.startTime.compareTo(b.startTime));

        setState(() {
          _warnings = loadedWarnings;
        });
        print(_warnings);
        print(_warningData);
      } else {
        throw Exception('Failed to load weather warnings');
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        _cityData = 'Error loading weather warnings from data: $e';
      });
    }
  }

  String _getCityName(String areaId) {
  final city = _cities.firstWhere(
    (city) => city.areaId == areaId,
    orElse: () => City(areaId: 'Unknown', globalId: -1, name: 'Unknown'),
  );
  return city.name;
  }

  @override
  void initState() {
    super.initState();
    fetchCityCodes();
    fetchWeatherWarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Cidades'),
                onTap: () {
                  // AINDA PARA ADICIONAR PAGINA DE CIDADES
                }),
            ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Avisos'),
                onTap: () {
                  // AINDA PARA ADICIONAR PAGINA DE AVISOS
                }),
            ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favoritos'),
                onTap: () {
                  // AINDA PARA ADICIONAR PAGINA DE FAVORITOS
                }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Warnings'),
            _warnings.isEmpty
                ? const Text(
                    'Click the button to fetch city data.') // show message if no data is loaded yet
                : Expanded(
                    // wrap the ListView in an Expanded widget to avoid overflow
                    child: ListView.builder(
                        itemCount: _warnings.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: _getCardColor(_warnings[index]
                                .awarenessLevel), //sets card color based on warning
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              title: Text(
                                '${_warnings[index].awarenessTypeName} - ${_getCityName(_warnings[index].areaId)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                'Start Time: ${_warnings[index].startTime} \nEnd Time: ${_warnings[index].endTime}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }
}

//class para cidades
class City {
  final int globalId;
  final String areaId;
  final String name;

  City({required this.globalId, required this.areaId, required this.name});

  factory City.fromJson(Map<String, dynamic> json_file) {
    return City(
        globalId: json_file['globalIdLocal'],
        areaId: json_file['idAreaAviso'],
        name: json_file['local']);
  }
}

//class para warnings
class Warning {
  final String awarenessTypeName;
  final String areaId;
  final String awarenessLevel;
  final String startTime;
  final String endTime;

  Warning({
    required this.awarenessTypeName,
    required this.areaId,
    required this.awarenessLevel,
    required this.startTime,
    required this.endTime,
  });

  factory Warning.fromJson(Map<String, dynamic> json_file) {
    return Warning(
      awarenessTypeName: json_file['awarenessTypeName'] ?? 'Unknown',
      areaId: json_file['idAreaAviso'] ?? 'Unknown',
      awarenessLevel: json_file['awarenessLevelID'] ?? 'Unknown',
      startTime: json_file['startTime'] ?? 'Unknown',
      endTime: json_file['endTime'] ?? 'Unknown',
    );
  }
}

Color _getCardColor(String awarenessLevel) {
  switch (awarenessLevel.toLowerCase()) {
    case 'green':
      return Colors.green[300]!;
    case 'yellow':
      return Colors.yellow[300]!;
    case 'orange':
      return Colors.orange[300]!;
    case 'red':
      return Colors.red[300]!;
    default:
      return Colors.grey[300]!;
  }
}


void debugWarningsParsing(List data) {
  for (var item in data) {
    print(item['awarenessTypeName']);
    print(item['idAreaAviso']);
    print(item['awarenessLevelID']);
    print(item['startTime']);
    print(item['endTime']);
  }
}
