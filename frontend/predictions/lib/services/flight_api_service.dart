import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_prediction.dart';

class FlightApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000'; // Use localhost for Android emulator

  Future<List<FlightPrediction>> getPredictionsByDate(DateTime date) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predictions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'date': date.toIso8601String().substring(0, 10), // Send only the date part (YYYY-MM-DD)
      }),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => FlightPrediction.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load predictions: ${response.statusCode}');
    }
  }
}
