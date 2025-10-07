import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final String customerName;
  final String flavors;
  final Map<String, int> quantities;
  final DateTime date;
  final TimeOfDay time;
  final double total;

  const PaymentScreen({
    super.key,
    required this.customerName,
    required this.flavors,
    required this.quantities,
    required this.date,
    required this.time,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Cash', 'GCash', 'ATM/Bank Transfer'];

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Confirmed!'),
          content: Text('Your cake order has been placed successfully!\n\n'
              'Customer: ${widget.customerName}\n'
              'Pickup: ${DateFormat('MMM dd, yyyy').format(widget.date)} at ${widget.time.format(context)}\n'
              'Payment Method: ${_selectedPaymentMethod}\n'
              'Total: ₱${widget.total.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and go back to order screen to order again
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to order screen
              },
              child: const Text('Order Again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format quantities for display
    String quantitiesText = widget.quantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Order Summary
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 12),
                      Text('Customer: ${widget.customerName}'),
                      Text('Flavors: ${widget.flavors}'),
                      Text('Quantities: $quantitiesText'),
                      Text(
                          'Pickup Date: ${DateFormat('MMM dd, yyyy').format(widget.date)}'),
                      Text('Pickup Time: ${widget.time.format(context)}'),
                      const SizedBox(height: 8),
                      const Divider(),
                      Text(
                        'Total: ₱${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Payment Information',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const SizedBox(height: 16),

              // Payment Method Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _paymentMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete Order',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
