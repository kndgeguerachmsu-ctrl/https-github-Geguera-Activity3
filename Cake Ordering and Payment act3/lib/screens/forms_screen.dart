import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormsDemoScreen extends StatefulWidget {
  const FormsDemoScreen({super.key});

  @override
  State<FormsDemoScreen> createState() => _FormsDemoScreenState();
}

class _FormsDemoScreenState extends State<FormsDemoScreen> {
  // Instruction 1: Simple form with username
  final TextEditingController _usernameController = TextEditingController();

  // Instruction 5: Different input types
  final TextEditingController _textFieldController = TextEditingController();
  bool _checkboxValue = false;
  bool _switchValue = false;

  // Instruction 8: Date and time picker
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Instruction 9: Controller to capture and display text
  final TextEditingController _captureController = TextEditingController();
  String _capturedText = '';

  // Instruction 10: Form that saves data to local list
  final List<Map<String, dynamic>> _submittedData = [];
  final TextEditingController _dataNameController = TextEditingController();
  final TextEditingController _dataEmailController = TextEditingController();

  // Venue reservation specific
  String? _selectedVenue;
  final List<String> _venues = [
    'Grand Ballroom',
    'Conference Hall',
    'Garden Pavilion'
  ];
  final TextEditingController _detailsController = TextEditingController();

  // Payment
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Instruction 1: Show simple username form
  void _showSimpleForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simple Username Form'),
        content: TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_usernameController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Username: ${_usernameController.text}')),
                );
                Navigator.pop(context);
                _usernameController.clear();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Instruction 8: Date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Instruction 8: Time picker
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Instruction 9: Capture text
  void _captureText() {
    setState(() {
      _capturedText = _captureController.text;
    });
  }

  // Instruction 10: Submit data to local list
  void _submitDataForm() {
    if (_dataNameController.text.isNotEmpty &&
        _dataEmailController.text.isNotEmpty) {
      setState(() {
        _submittedData.add({
          'name': _dataNameController.text,
          'email': _dataEmailController.text,
        });
      });
      _dataNameController.clear();
      _dataEmailController.clear();
    }
  }

  // Venue reservation
  void _submitVenueReservation() {
    if (_selectedVenue != null &&
        _detailsController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null) {
      // Navigate to payment
      _showPaymentDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all venue reservation fields')),
      );
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment'),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(labelText: 'Expiry Date'),
              ),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_cardNumberController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Successful!')),
                );
                Navigator.pop(context);
                _cardNumberController.clear();
                _expiryController.clear();
                _cvvController.clear();
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forms Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction 1: Simple username form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Simple Username Form',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _showSimpleForm,
                      child: const Text('Open Username Form'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruction 5: Different input types
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '5. Different Input Types',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _textFieldController,
                      decoration: const InputDecoration(
                        labelText: 'Regular TextField',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _checkboxValue,
                          onChanged: (bool? value) {
                            setState(() {
                              _checkboxValue = value ?? false;
                            });
                          },
                        ),
                        const Text('Checkbox'),
                      ],
                    ),
                    Row(
                      children: [
                        Switch(
                          value: _switchValue,
                          onChanged: (bool value) {
                            setState(() {
                              _switchValue = value;
                            });
                          },
                        ),
                        const Text('Switch'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruction 8: Date and Time Picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '8. Date & Time Picker',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectDate,
                          child: const Text('Select Date'),
                        ),
                        const SizedBox(width: 10),
                        Text(_selectedDate == null
                            ? 'No date selected'
                            : DateFormat('MMM dd, yyyy')
                                .format(_selectedDate!)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectTime,
                          child: const Text('Select Time'),
                        ),
                        const SizedBox(width: 10),
                        Text(_selectedTime == null
                            ? 'No time selected'
                            : _selectedTime!.format(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruction 9: Text Capture with Controller
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '9. Text Capture with Controller',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _captureController,
                      decoration: const InputDecoration(
                        labelText: 'Enter text to capture',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _captureText,
                      child: const Text('Capture Text'),
                    ),
                    const SizedBox(height: 10),
                    Text('Captured Text: $_capturedText'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruction 10: Form with Data Storage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '10. Form with Data Storage',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dataNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dataEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submitDataForm,
                      child: const Text('Submit Data'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Submitted Data:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._submittedData
                        .map((data) => ListTile(
                              title: Text(data['name']),
                              subtitle: Text(data['email']),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Venue Reservation Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Venue Reservation',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Venue selection
                    DropdownButtonFormField<String>(
                      value: _selectedVenue,
                      decoration: const InputDecoration(
                        labelText: 'Select Venue',
                        border: OutlineInputBorder(),
                      ),
                      items: _venues.map((String venue) {
                        return DropdownMenuItem<String>(
                          value: venue,
                          child: Text(venue),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedVenue = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Details
                    TextField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Event Details',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),

                    // Date and Time (reusing from instruction 8)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectDate,
                          child: const Text('Select Date'),
                        ),
                        const SizedBox(width: 10),
                        Text(_selectedDate == null
                            ? 'No date selected'
                            : DateFormat('MMM dd, yyyy')
                                .format(_selectedDate!)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectTime,
                          child: const Text('Select Time'),
                        ),
                        const SizedBox(width: 10),
                        Text(_selectedTime == null
                            ? 'No time selected'
                            : _selectedTime!.format(context)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: _submitVenueReservation,
                      child: const Text('Proceed to Payment'),
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
    _usernameController.dispose();
    _textFieldController.dispose();
    _captureController.dispose();
    _dataNameController.dispose();
    _dataEmailController.dispose();
    _detailsController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}
