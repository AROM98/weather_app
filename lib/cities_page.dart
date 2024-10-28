import 'package:flutter/material.dart';
import 'city.dart';

class CitiesPage extends StatelessWidget {
   final List<City> cities;

  CitiesPage({required this.cities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cidades')),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cities[index].name),
          );
        },
      ),
    );
  }
}
