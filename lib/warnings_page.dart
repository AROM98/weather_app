import 'package:flutter/material.dart';
import 'warning.dart';
import 'city.dart';
import 'color_utils.dart';

class WarningsPage extends StatelessWidget {
  final List<Warning> warnings;
  final List<City> cities;

  WarningsPage({required this.warnings, required this.cities});

  String _getCityName(String areaId) {
    final city = cities.firstWhere(
      (city) => city.areaId == areaId,
      orElse: () => City(areaId: 'Unknown', globalId: -1, name: 'Localidade Desconhecida'),
    );
    return city.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todos os Avisos')),
      body: warnings.isEmpty
          ? Center(child: Text('Não há avisos.'))
          : ListView.builder(
              itemCount: warnings.length,
              itemBuilder: (context, index) {
                return Card(
                  color: getCardColor(warnings[index].awarenessLevel),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      '${warnings[index].awarenessTypeName} - ${_getCityName(warnings[index].areaId)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Start Time: ${warnings[index].startTime} \nEnd Time: ${warnings[index].endTime}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
    );
  }

}
