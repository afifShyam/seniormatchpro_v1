import 'package:flutter/material.dart';

class HirePage extends StatefulWidget {
  const HirePage({Key? key});

  @override
  _HirePageState createState() => _HirePageState();
}

class _HirePageState extends State<HirePage> {
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _jobNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Request',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_jobNameController, 'Job Name'),
            const SizedBox(height: 20),
            _buildTextField(_locationController, 'Location'),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String jobName = _jobNameController.text;
                String location = _locationController.text;
                String email = _emailController.text;
                // Send request logic goes here
              },
              child: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
