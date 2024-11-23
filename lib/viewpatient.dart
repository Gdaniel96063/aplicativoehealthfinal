import 'package:flutter/material.dart';

class ViewPatient extends StatefulWidget {
  final String name;
  final String phone;
  final String state;
  final String email;

  const ViewPatient({
    super.key,
    required this.name,
    required this.phone,
    required this.state,
    required this.email,
  });

  @override
  ViewPatientState createState() => ViewPatientState();
}

class ViewPatientState extends State<ViewPatient> {
  String? selectedState;

  @override
  void initState() {
    super.initState();
    selectedState = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Paciente", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailField("Nombre", widget.name, Icons.person, Colors.lightBlue),
              const SizedBox(height: 16),

              _buildDetailField("Teléfono", widget.phone, Icons.phone, Colors.blueAccent),
              const SizedBox(height: 16),

              _buildDropdownField("Estado", selectedState, Icons.accessibility, Colors.green),
              const SizedBox(height: 16),

              _buildDetailField("Correo Electrónico", widget.email, Icons.email, Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, IconData icon, Color iconColor) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor, size: 24),
        labelText: label,
        labelStyle: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: iconColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: iconColor, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue, IconData icon, Color iconColor) {
    return InputDecorator(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor, size: 24),
        labelText: label,
        labelStyle: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: iconColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: iconColor, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: (String? newState) {
            setState(() {
              selectedState = newState;
            });
          },
          isExpanded: true,
          hint: const Text('Seleccionar estado'),
          items: const [
            DropdownMenuItem<String>(
              value: 'InCuenta Activa',
              child: Text('Cuenta Activa'),
            ),
            DropdownMenuItem<String>(
              value: 'Cuenta Inactiva',
              child: Text('Cuenta Inactiva'),
            ),
          ],
        ),
      ),
    );
  }
}
