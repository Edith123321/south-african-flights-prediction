class FlightPrediction {
  final double price;
  final String currency;
  final DateTime? departureTime;
  final String? airline;

  FlightPrediction({
    required this.price,
    this.currency = 'ZAR',
    this.departureTime,
    this.airline,
  });

  factory FlightPrediction.fromJson(Map<String, dynamic> json) {
    return FlightPrediction(
      price: json['predicted_price']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'ZAR',
    );
  }
}