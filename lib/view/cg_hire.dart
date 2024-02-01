import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class HirePage extends StatefulWidget {
  const HirePage({
    Key? key,
    required this.id,
    required this.name,
    required this.jobIdUser,
  }) : super(key: key);

  final String id;
  final String name;
  final String jobIdUser;

  @override
  State<HirePage> createState() => _HirePageState();
}

class _HirePageState extends State<HirePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('job_requests');
  DateTime? _selectedPerformDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Job Request',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your job request details for ${widget.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildFormField(_jobNameController, 'Job Name'),
              const SizedBox(height: 20),
              _buildFormField(_locationController, 'Location'),
              const SizedBox(height: 20),
              _buildPriceFormField(_priceController),
              const SizedBox(height: 20),
              _buildFormField(_emailController, 'Email'),
              const SizedBox(height: 20),
              _buildDurationFormField(),
              const SizedBox(height: 20),
              _buildPerformDateFormField(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _sendJobRequest(
                      widget.id,
                      _jobNameController.text,
                      _locationController.text,
                      _emailController.text,
                      _priceController.text,
                      _durationController.text,
                      _selectedPerformDate ?? DateTime.now(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text('Send Request'),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPriceFormField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the price per hour';
        }

        double price = double.tryParse(value) ?? 0;

        if (price < 30) {
          return 'Minimum price per hour is RM30';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: 'Price per Hour (RM)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDurationFormField() {
    return TextFormField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the duration in hours';
        }

        double duration = double.tryParse(value) ?? 0;

        if (duration <= 0) {
          return 'Duration must be greater than 0';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: 'Duration (hours)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPerformDateFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );

            if (pickedDate != null && pickedDate != _selectedPerformDate) {
              setState(() {
                _selectedPerformDate = pickedDate;
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _selectedPerformDate != null
                    ? DateFormat('dd-MM-yyyy').format(_selectedPerformDate!)
                    : '',
              ),
              validator: (value) {
                if (_selectedPerformDate == null) {
                  return 'Please pick a performing date';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Performing Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              setState(() {
                _selectedPerformDate = DateTime(
                  _selectedPerformDate!.year,
                  _selectedPerformDate!.month,
                  _selectedPerformDate!.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _selectedPerformDate != null
                    ? DateFormat('hh:mm a').format(_selectedPerformDate!)
                    : '',
              ),
              validator: (value) {
                if (_selectedPerformDate == null) {
                  return 'Please pick a performing time';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Performing Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _sendJobRequest(String id, String jobName, String location, String email,
      String price, String duration, DateTime performDate) {
    String requestId = _databaseReference.push().key ?? '';

    double durationValue = double.tryParse(duration) ?? 0;
    double priceValue = double.tryParse(price) ?? 0;
    double total = durationValue * priceValue;

    _databaseReference.child(requestId).set({
      'id': id,
      'jobId': widget.jobIdUser,
      'jobName': jobName,
      'pricePerHour': price,
      'duration': duration,
      'totalPrice': total.toString(),
      'location': location,
      'email': email,
      'status': 'pending',
      'performingDate': performDate.toLocal().millisecondsSinceEpoch,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Sent'),
          content: const Text('Your job request has been sent successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
