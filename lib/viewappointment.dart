import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewAppointment extends StatefulWidget {
  final String code;
  final String dni;
  final String state;
  final String date;
  final String topic;

  const ViewAppointment({
    super.key,
    required this.code,
    required this.dni,
    required this.state,
    required this.date,
    required this.topic,
  });

  @override
  ViewAppointmentState createState() => ViewAppointmentState();
}

class ViewAppointmentState extends State<ViewAppointment> {
  List<Map<String, dynamic>> doctors = [];
  Map<String, dynamic>? selectedDoctor;
  String? selectedState;

  @override
  void initState() {
    super.initState();
    selectedState = widget.state == 'Aprobado' || widget.state == 'En Revisión'
        ? widget.state
        : 'Aprobado';
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('PersonalMedico')
          .where('Especialidad', isEqualTo: widget.topic)
          .get();

      List<Map<String, dynamic>> loadedDoctors = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        doctors = loadedDoctors;

        if (doctors.isNotEmpty) {
          selectedDoctor = doctors[0];
        } else {
          selectedDoctor = null;
        }
      });
    } catch (e) {
      setState(() {
        doctors = [];
        selectedDoctor = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de Cita", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Código
              TextFormField(
                controller: TextEditingController(text: widget.code),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Código',
                  prefixIcon: const Icon(Icons.code, color: Colors.lightBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: TextEditingController(text: widget.dni),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'DNI',
                  prefixIcon: const Icon(Icons.perm_identity, color: Colors.lightBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Estado
              const Text(
                'Estado:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.cyan.shade300),
                  color: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: selectedState,
                  onChanged: (String? newState) {
                    setState(() {
                      selectedState = newState;
                    });
                  },
                  isExpanded: true,
                  hint: const Text('Seleccionar estado'),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Aprobado',
                      child: Text('Aprobado'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'En Revisión',
                      child: Text('En Revisión'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Fecha de Cita
              TextFormField(
                controller: TextEditingController(text: widget.date),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha de Cita',
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.lightBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              if (doctors.isNotEmpty) ...[
                Text(
                  'Seleccionar Médico:\n(Especialidad ${widget.topic})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.lightBlue.shade300),
                    color: Colors.white,
                  ),
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedDoctor,
                    hint: const Text('Seleccionar médico'),
                    onChanged: (Map<String, dynamic>? newDoctor) {
                      setState(() {
                        selectedDoctor = newDoctor;
                      });
                    },
                    isExpanded: true,
                    items: doctors.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> doctor) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: doctor,
                        child: Text(doctor['nombre'] ?? 'No disponible'),
                      );
                    }).toList(),
                  ),
                ),
              ],

              if (doctors.isEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'No hay médicos disponibles para esta especialidad.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
