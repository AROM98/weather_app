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