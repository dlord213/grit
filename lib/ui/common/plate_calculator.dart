import 'package:flutter/material.dart';
import '../theme.dart';

class PlateCalculatorModal extends StatefulWidget {
  final double defaultTargetWeight;
  const PlateCalculatorModal({super.key, required this.defaultTargetWeight});

  @override
  State<PlateCalculatorModal> createState() => _PlateCalculatorModalState();
}

class _PlateCalculatorModalState extends State<PlateCalculatorModal> {
  late TextEditingController _weightController;
  double _barWeight = 45.0;
  bool _isLbs = true;

  final List<double> _lbsPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];
  final List<double> _kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.defaultTargetWeight > 0
          ? widget.defaultTargetWeight.toStringAsFixed(1)
          : '135.0',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Map<double, int> _calculatePlates(double target, double bar, List<double> plates) {
    if (target <= bar) return {};
    double remaining = (target - bar) / 2;
    Map<double, int> result = {};

    for (final plate in plates) {
      if (remaining >= plate) {
        int count = (remaining / plate).floor();
        result[plate] = count;
        remaining -= count * plate;
        remaining = double.parse(remaining.toStringAsFixed(3)); // Avoid float precision issues
      }
    }
    return result;
  }

  Color _getPlateColor(double plate) {
    if (_isLbs) {
      if (plate >= 45) return Colors.redAccent;
      if (plate >= 35) return Colors.blueAccent;
      if (plate >= 25) return Colors.yellow.shade700;
      if (plate >= 10) return Colors.greenAccent.shade700;
      if (plate >= 5) return Colors.orangeAccent;
      return Colors.white54;
    } else {
      if (plate >= 25) return Colors.redAccent;
      if (plate >= 20) return Colors.blueAccent;
      if (plate >= 15) return Colors.yellow.shade700;
      if (plate >= 10) return Colors.greenAccent.shade700;
      if (plate >= 5) return Colors.orangeAccent;
      return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = double.tryParse(_weightController.text) ?? 0.0;
    final plates = _isLbs ? _lbsPlates : _kgPlates;
    final calculated = _calculatePlates(target, _barWeight, plates);

    // List of plates sorted from largest to smallest to render on the sleeve
    final List<double> visualPlates = [];
    calculated.forEach((plate, count) {
      for (int i = 0; i < count; i++) {
        visualPlates.add(plate);
      }
    });

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: const BoxDecoration(
        color: GritTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plate Calculator',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: GritTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Target Weight',
                    suffixText: _isLbs ? 'lbs' : 'kg',
                  ),
                  onChanged: (val) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unit', style: TextStyle(color: GritTheme.textSecondary, fontSize: 12)),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('LBS'),
                        selected: _isLbs,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isLbs = true;
                              _barWeight = 45.0;
                              final cur = double.tryParse(_weightController.text) ?? 0;
                              _weightController.text = (cur * 2.20462).toStringAsFixed(1);
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('KG'),
                        selected: !_isLbs,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isLbs = false;
                              _barWeight = 20.0;
                              final cur = double.tryParse(_weightController.text) ?? 0;
                              _weightController.text = (cur / 2.20462).toStringAsFixed(1);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Barbell Weight', style: TextStyle(color: GritTheme.textSecondary)),
              DropdownButton<double>(
                dropdownColor: GritTheme.surface,
                value: _barWeight,
                items: (_isLbs ? [45.0, 35.0, 15.0] : [20.0, 15.0, 10.0])
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text('$val ${_isLbs ? "lbs" : "kg"}'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _barWeight = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (target <= _barWeight)
            const Center(
              child: Text(
                'Enter a weight higher than the bar weight.',
                style: TextStyle(color: Colors.redAccent),
              ),
            )
          else ...[
            Text(
              'Per Side: ${((target - _barWeight) / 2).toStringAsFixed(2)} ${_isLbs ? "lbs" : "kg"}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: GritTheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            // Barbell visualizer
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: GritTheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GritTheme.divider, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Barbell sleeve (grey bar in center)
                  Positioned(
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 12,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                  // Collar stop
                  Positioned(
                    left: 40,
                    child: Container(
                      width: 14,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // The stacked plates on one side
                  Positioned(
                    left: 58,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: visualPlates.map((plate) {
                        // Height proportional to weight
                        double height = 40 + (plate * 0.8);
                        if (height > 90) height = 90;
                        double width = 14;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                            color: _getPlateColor(plate),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.black45, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              plate.toString().replaceAll('.0', ''),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Plate breakdown text list
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: calculated.entries.map((entry) {
                return Chip(
                  backgroundColor: _getPlateColor(entry.key).withValues(alpha: 0.15),
                  side: BorderSide(color: _getPlateColor(entry.key), width: 1),
                  avatar: CircleAvatar(
                    backgroundColor: _getPlateColor(entry.key),
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  label: Text('${entry.key} ${_isLbs ? "lbs" : "kg"}'),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
