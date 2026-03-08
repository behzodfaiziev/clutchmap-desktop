import 'package:flutter/material.dart';

class MetricDeltaRow extends StatelessWidget {
  final String label;
  final int valueA;
  final int valueB;

  const MetricDeltaRow({
    super.key,
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  @override
  Widget build(BuildContext context) {
    final delta = valueB - valueA;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            "$valueA → $valueB",
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: delta > 0
                  ? Colors.green.withOpacity(0.2)
                  : delta < 0
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              delta > 0 ? "+$delta" : "$delta",
              style: TextStyle(
                color: delta > 0
                    ? Colors.green
                    : delta < 0
                        ? Colors.red
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


