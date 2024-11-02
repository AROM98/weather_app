import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cities_page.dart';
import 'warnings_page.dart';
import 'city.dart';
import 'warning.dart';
import 'color_utils.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const WeatherHomePage(),
        //'/cities': (context) => CitiesPage(),
        // Adicionaremos as outras rotas depois
      },
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

// fetching (specific) city weather data
Future<List<Map<String, dynamic>>> fetchWeatherData(String cityCode) async {
  final String url =
      'http://api.ipma.pt/open-data/forecast/meteorology/cities/daily/$cityCode.json';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load weather data for city $cityCode');
    }
  } catch (e) {
    print('Error fetching weather data: $e');
    return [];
  }
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  // Initial state values
  String _cityData = "Press the button to load city data";
  String _warningData = "Press the button to load warning data";

  List<City> _cities = [];
  List<Warning> _warnings = [];
  List<Warning> displayedWarnings = [];
  List<String> _favoriteCities = [];

  // http requests
  Future<void> fetchCityCodes() async {
    const String url = 'https://api.ipma.pt/open-data/distrits-islands.json';

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
    const String url =
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
        loadedWarnings.sort((a, b) => b.startTime.compareTo(a.startTime));

        setState(() {
          _warnings = loadedWarnings;
          // Limitar a 10 avisos
          displayedWarnings = loadedWarnings.take(10).toList();
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

  Future<void> fetchWeatherForFavoriteCities() async {
    for (String cityName in _favoriteCities) {
      // Get city code based on city name (you should have a way to map name to code)
      final city = _cities.firstWhere((city) => city.name == cityName,
          orElse: () => City(name: '', areaId: '', globalId: -1));
      if (city.globalId != -1) {
        List<Map<String, dynamic>> weatherData =
            await fetchWeatherData(city.globalId.toString());
        // Process and store the weather data as needed
        print('Weather data for $cityName: $weatherData');
      }
    }
  }

  Widget buildWeatherReports() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // Full width for all elements
    children: _favoriteCities.map((cityName) {
      final city = _cities.firstWhere((city) => city.name == cityName,
          orElse: () => City(name: '', areaId: '', globalId: -1));
      if (city.globalId != -1) {
        return Column(
          children: [
            Text(
              cityName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchWeatherData(city.globalId.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No weather data available for $cityName'));
                } else {
                  return Column(
                    children: snapshot.data!.map((weather) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          width: double.infinity, // Ensure card takes full width
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // Center text
                            children: [
                              Text(
                                'Date: ${weather['forecastDate']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Temp Min: ${weather['tMin']}°C',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Temp Max: ${weather['tMax']}°C',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Precipitation: ${weather['precipitaProb']}%',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    }).toList(),
  );
}






  String _getCityName(String areaId) {
    final city = _cities.firstWhere(
      (city) => city.areaId == areaId,
      orElse: () => City(
          areaId: 'Unknown',
          globalId: -1,
          name: 'Localidade Desconhecida (maybe bug)'),
    );
    return city.name;
  }

  void _updateFavoriteCities(List<String> updatedFavorites) {
    setState(() {
      _favoriteCities = updatedFavorites;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCityCodes();
    fetchWeatherWarnings();
  }

  @override
  Widget build(BuildContext context) {
    List<Warning> filteredWarnings = displayedWarnings.where((warning) {
      bool isYellowOrRed = warning.awarenessLevel.toLowerCase() == 'yellow' ||
          warning.awarenessLevel.toLowerCase() == 'red';
      bool isInFavoriteCities =
          _favoriteCities.contains(_getCityName(warning.areaId));
      return isYellowOrRed && isInFavoriteCities;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
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
                  // Only navigate if cities are loaded
                  if (_cities.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CitiesPage(
                          cities: _cities,
                          favoriteCities: _favoriteCities,
                          onFavoritesUpdated: _updateFavoriteCities,
                        ), // Passed callback here
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Aguarde, carregando dados das cidades...')),
                    );
                  }
                }),
            ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Avisos'),
                onTap: () {
                  // Only navigate if cities are loaded
                  if (_warnings.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WarningsPage(
                          warnings: _warnings, // Pass the list of warnings
                          cities: _cities, // Pass the list of cities
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Aguarde, carregando dados dos avisos...')),
                    );
                  }
                }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (filteredWarnings.isNotEmpty)
            Center(
              child: Text(
                'Avisos Meteorológicos Importantes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (filteredWarnings.isNotEmpty)
              ...filteredWarnings.map((warning) {
                return Card(
                  color: getCardColor(warning.awarenessLevel),
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      '${warning.awarenessTypeName} - ${_getCityName(warning.areaId)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center, // Center the text
                    ),
                    subtitle: Text(
                      'Start Time: ${warning.startTime} \nEnd Time: ${warning.endTime}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center, // Center the text
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 16), // Space before weather reports section
            if (_favoriteCities.isNotEmpty)
              buildWeatherReports(), // Include the weather report section here
          ],
        ),
      ),
    );
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
