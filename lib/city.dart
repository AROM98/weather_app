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