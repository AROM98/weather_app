import 'package:flutter/material.dart';
import 'city.dart';

class CitiesPage extends StatefulWidget {
  final List<City> cities;
  final List<String> favoriteCities;
  final Function(List<String>) onFavoritesUpdated; // Add callback parameter

  CitiesPage({required this.cities, required this.favoriteCities, required this.onFavoritesUpdated});

  @override
  _CitiesPageState createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cidades')),
      body: ListView.builder(
        itemCount: widget.cities.length,
        itemBuilder: (context, index) {
          String cityName = widget.cities[index].name;
          bool isFavorite = widget.favoriteCities.contains(cityName);

          return ListTile(
            title: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cityName,
                    style: TextStyle(
                      color: isFavorite ? Colors.green : Colors.white, // Text color logic
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.delete : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.pink,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFavorite) {
                          widget.favoriteCities.remove(cityName);
                        } else {
                          widget.favoriteCities.add(cityName);
                        }
                        widget.onFavoritesUpdated(widget.favoriteCities); // Notify parent
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
