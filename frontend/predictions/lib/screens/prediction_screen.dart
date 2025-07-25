import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_prediction.dart' show FlightPrediction;
import '../services/flight_api_service.dart';
import '../widgets/airport_dropdown.dart';
import '../utils/constants.dart';
import '../models/flight_prediction.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  DateTime? _departureTime;
  String? _selectedAirline;
  String? _selectedAirport;
  int _stops = 0;
  double _flightDuration = 2.0;
  bool _isLoading = false;
  FlightPrediction? _prediction;

  final FlightApiService _apiService = FlightApiService();

  Future<void> _predictPrice() async {
    if (_departureTime == null || _selectedAirline == null || _selectedAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prediction = await _apiService.FlightPrediction(
        departureTime: _departureTime!,
        airline: _selectedAirline!,
        arrivalAirport: _selectedAirport!,
        stops: _stops,
        flightDuration: _flightDuration,
      );
      setState(() => _prediction = prediction);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Price Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Departure Time Picker
              ListTile(
                title: Text(
                  _departureTime == null
                      ? 'Select Departure Time'
                      : DateFormat('yyyy-MM-dd HH:mm').format(_departureTime!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _departureTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // Airline Dropdown
              DropdownButtonFormField<String>(
                value: _selectedAirline,
                decoration: const InputDecoration(
                  labelText: 'Airline',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.airlines
                    .map((airline) => DropdownMenuItem(
                          value: airline,
                          child: Text(airline),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedAirline = value),
              ),
              const SizedBox(height: 20),

              // Airport Dropdown
              AirportDropdown(
                value: _selectedAirport,
                onChanged: (value) => setState(() => _selectedAirport = value),
              ),
              const SizedBox(height: 20),

              // Stops Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Number of Stops',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    setState(() => _stops = int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 20),

              // Flight Duration
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Flight Duration (hours)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: '2.0',
                onChanged: (value) =>
                    setState(() => _flightDuration = double.tryParse(value) ?? 2.0),
              ),
              const SizedBox(height: 30),

              // Predict Button
              ElevatedButton(
                onPressed: _isLoading ? null : _predictPrice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('PREDICT PRICE', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 30),

              // Results
              if (_prediction != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Predicted Price',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ZAR ${_prediction!.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}