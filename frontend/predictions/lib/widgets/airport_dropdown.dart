import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AirportDropdown extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final String? value;

  const AirportDropdown({
    super.key,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Arrival Airport',
        border: OutlineInputBorder(),
      ),
      items: AppConstants.airports
          .map((airport) => DropdownMenuItem(
                value: airport,
                child: Text(airport),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}