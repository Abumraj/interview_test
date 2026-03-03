import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class QuantityTotalCard extends StatefulWidget {
  final int initialQuantity;
  final int minQuantity;
  final double unitPrice;
  final ValueChanged<int>? onQuantityChanged;
  final Color backgroundColor;
  final Color accentColor;

  const QuantityTotalCard({
    super.key,
    this.initialQuantity = 1,
    this.minQuantity = 1,
    required this.unitPrice,
    this.onQuantityChanged,
    this.backgroundColor = const Color(0xFF0B2F44),
    this.accentColor = const Color(0xFF1E88E5),
  });

  @override
  State<QuantityTotalCard> createState() => _QuantityTotalCardState();
}

class _QuantityTotalCardState extends State<QuantityTotalCard> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged?.call(_quantity);
  }

  void _decrement() {
    if (_quantity <= widget.minQuantity) return;
    setState(() {
      _quantity--;
    });
    widget.onQuantityChanged?.call(_quantity);
  }

  String get _formattedTotal {
    final total = _quantity * widget.unitPrice;
    return NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    ).format(total);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          /// Quantity Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quantity:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              _Stepper(
                quantity: _quantity,
                onIncrement: _increment,
                onDecrement: _decrement,
                accentColor: widget.accentColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Divider
          Divider(color: Colors.white.withOpacity(0.15), height: 1),

          const SizedBox(height: 12),

          /// Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total (VAT inclusive):',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                _formattedTotal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color accentColor;

  const _Stepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: onDecrement,
            accentColor: accentColor,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrement,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: double.infinity,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: accentColor),
      ),
    );
  }
}
