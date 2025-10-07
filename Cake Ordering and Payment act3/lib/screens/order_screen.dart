import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_screen.dart';
import 'login_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  // Quantity controllers for each size
  final TextEditingController _smallQuantityController =
      TextEditingController(text: '0');
  final TextEditingController _mediumQuantityController =
      TextEditingController(text: '0');
  final TextEditingController _largeQuantityController =
      TextEditingController(text: '0');

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Checkbox values for cake sizes
  bool _smallChecked = false;
  bool _mediumChecked = false;
  bool _largeChecked = false;

  // Switch values
  bool _urgentDelivery = false;
  bool _includeCandles = true;
  bool _includeMessage = false;

  // Data storage for submitted orders
  final List<Map<String, dynamic>> _submittedOrders = [];

  // List of available flavors with checkboxes
  final List<Map<String, dynamic>> _flavors = [
    {'name': 'Chocolate', 'checked': false},
    {'name': 'Vanilla', 'checked': false},
    {'name': 'Strawberry', 'checked': false},
    {'name': 'Red Velvet', 'checked': false},
    {'name': 'Carrot Cake', 'checked': false},
  ];

  bool _isFlavorsDropdownOpen = false;

  void _clearForm() {
    setState(() {
      _customerNameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _specialInstructionsController.clear();

      _smallQuantityController.text = '0';
      _mediumQuantityController.text = '0';
      _largeQuantityController.text = '0';

      _selectedDate = null;
      _selectedTime = null;

      // Reset all flavor checkboxes
      for (var flavor in _flavors) {
        flavor['checked'] = false;
      }

      _smallChecked = false;
      _mediumChecked = false;
      _largeChecked = false;

      _urgentDelivery = false;
      _includeCandles = true;
      _includeMessage = false;
    });

    // Reset form validation
    _formKey.currentState?.reset();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _updateQuantity(String size, int change) {
    setState(() {
      switch (size) {
        case 'small':
          int current = int.tryParse(_smallQuantityController.text) ?? 0;
          int newValue = current + change;
          if (newValue >= 0) {
            _smallQuantityController.text = newValue.toString();
            if (newValue > 0 && !_smallChecked) {
              _smallChecked = true;
            } else if (newValue == 0 && _smallChecked) {
              _smallChecked = false;
            }
          }
          break;
        case 'medium':
          int current = int.tryParse(_mediumQuantityController.text) ?? 0;
          int newValue = current + change;
          if (newValue >= 0) {
            _mediumQuantityController.text = newValue.toString();
            if (newValue > 0 && !_mediumChecked) {
              _mediumChecked = true;
            } else if (newValue == 0 && _mediumChecked) {
              _mediumChecked = false;
            }
          }
          break;
        case 'large':
          int current = int.tryParse(_largeQuantityController.text) ?? 0;
          int newValue = current + change;
          if (newValue >= 0) {
            _largeQuantityController.text = newValue.toString();
            if (newValue > 0 && !_largeChecked) {
              _largeChecked = true;
            } else if (newValue == 0 && _largeChecked) {
              _largeChecked = false;
            }
          }
          break;
      }
    });
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Get selected flavors
      List<String> selectedFlavors = [];
      for (var flavor in _flavors) {
        if (flavor['checked'] == true) {
          selectedFlavors.add(flavor['name'] as String);
        }
      }

      // Get quantities for each size
      Map<String, int> quantities = {
        'Small': int.tryParse(_smallQuantityController.text) ?? 0,
        'Medium': int.tryParse(_mediumQuantityController.text) ?? 0,
        'Large': int.tryParse(_largeQuantityController.text) ?? 0,
      };

      // Save to local list
      setState(() {
        _submittedOrders.add({
          'customerName': _customerNameController.text,
          'flavors': selectedFlavors,
          'quantities': quantities,
          'date': _selectedDate!,
          'time': _selectedTime!,
          'urgent': _urgentDelivery,
          'candles': _includeCandles,
          'message': _includeMessage,
          'instructions': _specialInstructionsController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'submittedAt': DateTime.now(),
          'total': _calculateTotal(),
        });
      });

      // Navigate to payment with actual customer name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            customerName: _customerNameController.text,
            flavors: selectedFlavors.join(', '),
            quantities: quantities,
            date: _selectedDate!,
            time: _selectedTime!,
            total: _calculateTotal(),
          ),
        ),
      ).then((_) {
        // This callback runs when returning from payment screen
        // Clear the form for a new order
        _clearForm();
      });
    }
  }

  double _calculateTotal() {
    double total = 0.0;

    // Size prices with quantities
    int smallQty = int.tryParse(_smallQuantityController.text) ?? 0;
    int mediumQty = int.tryParse(_mediumQuantityController.text) ?? 0;
    int largeQty = int.tryParse(_largeQuantityController.text) ?? 0;

    total += smallQty * 300.00;
    total += mediumQty * 500.00;
    total += largeQty * 800.00;

    // Additional charges
    if (_urgentDelivery) total += 100.00;
    if (_includeMessage) total += 50.00;

    return total;
  }

  Widget _buildSizeWithQuantity(String size, String price, bool isChecked,
      VoidCallback onCheckChanged, TextEditingController quantityController) {
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double priceValue = double.parse(price.replaceAll('₱', ''));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    onCheckChanged();
                    if (value == true && quantity == 0) {
                      _updateQuantity(size.toLowerCase(), 1);
                    } else if (value == false) {
                      _updateQuantity(size.toLowerCase(), -quantity);
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    '$size - $price',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (isChecked) ...[
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quantity:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: () {
                          _updateQuantity(size.toLowerCase(), -1);
                        },
                      ),
                      Container(
                        width: 50,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            quantityController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          _updateQuantity(size.toLowerCase(), 1);
                        },
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Subtotal:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '₱${(quantity * priceValue).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get selected flavors for display
    List<String> selectedFlavors = [];
    for (var flavor in _flavors) {
      if (flavor['checked'] == true) {
        selectedFlavors.add(flavor['name'] as String);
      }
    }
    String selectedFlavorsText = selectedFlavors.isEmpty
        ? 'No flavors selected'
        : selectedFlavors.join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        title: const Text('Cake Order'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to login screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Place Your Cake Order',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 16),

                      // Customer Name - TextField
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number - TextField
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address - TextField
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cake Flavors - Dropdown with Checkboxes
                      const Text(
                        'Select Cake Flavors:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: ExpansionTile(
                          title: Text(
                            selectedFlavorsText,
                            style: TextStyle(
                              color: selectedFlavors.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            _isFlavorsDropdownOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Colors.deepPurple,
                          ),
                          onExpansionChanged: (bool expanded) {
                            setState(() {
                              _isFlavorsDropdownOpen = expanded;
                            });
                          },
                          children: _flavors.map((flavor) {
                            return CheckboxListTile(
                              title: Text(flavor['name'] as String),
                              value: flavor['checked'] as bool,
                              onChanged: (bool? value) {
                                setState(() {
                                  flavor['checked'] = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cake Sizes with Quantities
                      const Text(
                        'Select Cake Sizes & Quantities:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      _buildSizeWithQuantity(
                        'Small',
                        '₱300',
                        _smallChecked,
                        () {
                          setState(() {
                            _smallChecked = !_smallChecked;
                          });
                        },
                        _smallQuantityController,
                      ),

                      _buildSizeWithQuantity(
                        'Medium',
                        '₱500',
                        _mediumChecked,
                        () {
                          setState(() {
                            _mediumChecked = !_mediumChecked;
                          });
                        },
                        _mediumQuantityController,
                      ),

                      _buildSizeWithQuantity(
                        'Large',
                        '₱800',
                        _largeChecked,
                        () {
                          setState(() {
                            _largeChecked = !_largeChecked;
                          });
                        },
                        _largeQuantityController,
                      ),
                      const SizedBox(height: 16),

                      // Date and Time Pickers
                      const Text(
                        'Pickup Date & Time:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Date Picker
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectDate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(_selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_selectedDate!)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectTime,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(_selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context)),
                            ),
                          ),
                        ],
                      ),

                      // Display selected date and time
                      if (_selectedDate != null || _selectedTime != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.deepPurple),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedDate == null
                                          ? 'No date selected'
                                          : DateFormat('MMM dd, yyyy')
                                              .format(_selectedDate!),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16, color: Colors.deepPurple),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedTime == null
                                          ? 'No time selected'
                                          : _selectedTime!.format(context),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Switches
                      const Text(
                        'Additional Options:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        title: const Text('Urgent Preparation (+ ₱100)'),
                        value: _urgentDelivery,
                        onChanged: (bool value) {
                          setState(() {
                            _urgentDelivery = value;
                          });
                        },
                      ),

                      SwitchListTile(
                        title: const Text('Include Candles'),
                        value: _includeCandles,
                        onChanged: (bool value) {
                          setState(() {
                            _includeCandles = value;
                          });
                        },
                      ),

                      SwitchListTile(
                        title: const Text('Include Message (+ ₱50)'),
                        value: _includeMessage,
                        onChanged: (bool value) {
                          setState(() {
                            _includeMessage = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Special Instructions - TextField
                      TextFormField(
                        controller: _specialInstructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Special Instructions',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Total Price
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.deepPurple),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₱${_calculateTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Order Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Proceed to Payment',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Previous Orders List
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Previous Orders',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 10),
                    _submittedOrders.isEmpty
                        ? const Text('No orders submitted yet',
                            style: TextStyle(color: Colors.grey))
                        : Column(
                            children: _submittedOrders.map((order) {
                              Map<String, int> quantities = order['quantities'];
                              String quantitiesText = quantities.entries
                                  .where((entry) => entry.value > 0)
                                  .map(
                                      (entry) => '${entry.key}: ${entry.value}')
                                  .join(', ');

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer: ${order['customerName']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        'Flavors: ${order['flavors'].join(', ')}'),
                                    Text('Quantities: $quantitiesText'),
                                    Text(
                                        'Date: ${DateFormat('MMM dd, yyyy').format(order['date'])}'),
                                    Text(
                                        'Time: ${order['time'].format(context)}'),
                                    Text(
                                        'Total: ₱${order['total'].toStringAsFixed(2)}'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialInstructionsController.dispose();
    _smallQuantityController.dispose();
    _mediumQuantityController.dispose();
    _largeQuantityController.dispose();
    super.dispose();
  }
}
