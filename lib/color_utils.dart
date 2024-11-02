// color_utils.dart
import 'package:flutter/material.dart';

Color getCardColor(String awarenessLevel) {
  switch (awarenessLevel.toLowerCase()) {
    case 'green':
      return Colors.green[700]!;
    case 'yellow':
      return Colors.yellow[700]!; // Darker yellow for better readability
    case 'orange':
      return Colors.orange[700]!;
    case 'red':
      return Colors.red[700]!;
    default:
      return Colors.grey[700]!;
  }
}
