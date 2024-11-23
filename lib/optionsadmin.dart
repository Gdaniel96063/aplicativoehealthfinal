import 'package:aplicativoehealth/apidniservice.dart';
import 'package:aplicativoehealth/viewappointment.dart';
import 'package:aplicativoehealth/viewpatient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class OptionsAdmin extends StatefulWidget {
  final String title;

  const OptionsAdmin({super.key, required this.title});

  @override
  OptionsAdminState createState() => OptionsAdminState();
}
class OptionsAdminState extends State<OptionsAdmin> {
  final String token = 'apis-token-11318.g9mI92LSxEnTqzAvDPUytMmSRRQvs5qv';
  final TextEditingController dniController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController specialityContoller = TextEditingController();
  String userName = '';
  String userPaternalSurname = '';
  String userMaternalSurname = '';
  String email = '';
  String phone = '';
  String specialty = '';
  String errorMessage = '';
  String searchQuery = '';
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  List<String> _specialities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchSpecialities();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } else {
      setState(() {
        selectedLocation = const LatLng(-34.0, 151.0);
      });
    }
  }

  Future<String> _getImageUrl(String image) async {
    final ref = FirebaseStorage.instance.ref().child(image);
    return await ref.getDownloadURL();
  }

  Future<int> countDocuments(String collectionPath) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionPath).get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _fetchSpecialities() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('EspecialidadesMedicas').get();

      setState(() {
        _specialities = snapshot.docs.map((doc) => doc.id).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (widget.title) {
      case "Listado Citas Médicas":
        content = _buildOption1Content(context);
        break;
      case "Listado Pacientes":
        content = _buildOption2Content();
        break;
      case "Listado Personal Medico":
        content = _buildOption3Content();
        break;
      case "Registro Pacientes":
        content = _buildOption4Content(context);
        break;
      case "Registro Personal Medico":
        content = _buildOption5Content(context);
        break;
      default:
        content = _buildDefaultContent();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 5.0,
                color: Color(0x55000000),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(1, 5),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  Widget _buildOption1Content(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar Cita Médica...',
              hintText: 'Ingrese el estado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2.5,
                ),
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.blueAccent,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: _listViewApoimment(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOption2Content() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar Paciente...',
              hintText: 'Ingrese sus nombres o apellidos',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2.0,
                ),
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
              filled: true,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.blueAccent,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _listViewPatient(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOption3Content() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar Médico...',
              hintText: 'Ingrese sus nombres o apellidos',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2.0,
                ),
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
              filled: true,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.blueAccent,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _listViewMedico(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOption4Content(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10.0),
            const Text(
              "Ingrese el DNI del Paciente",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            _inputDNI(context),
            _textViewNames(),
            _textViewPaternalSurname(),
            _textViewMaternalSurname(),
            _email(context),
            _phone(context),
            _inputMap(context),
            _dateOfBirth(context),
            _buttonLoadPatient(context),
            if (errorMessage.isNotEmpty) ...[
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption5Content(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10.0),
            const Text(
              "Ingrese el DNI del Personal Médico",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            _inputDNI(context),
            _textViewNames(),
            _textViewPaternalSurname(),
            _textViewMaternalSurname(),
            _email(context),
            _phone(context),
            _inputMap(context),
            _dateOfBirth(context),
            _speciality(context),
            _buttonLoadMedicalStaff(context),
            if (errorMessage.isNotEmpty) ...[
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return const Center(child: Text("Contenido no disponible"));
  }

  Widget _inputDNI(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 20.0),
        Expanded(
          child: TextField(
            controller: dniController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'DNI',
              hintText: 'Ingrese su DNI',
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
        ),
        const SizedBox(width: 20.0),
        _buttonLoadDNI(context),
      ],
    );
  }

  Widget _textViewNames() {
    return _buildReadOnlyField("Nombres del Paciente", userName);
  }

  Widget _textViewPaternalSurname() {
    return _buildReadOnlyField("Apellido Paterno del Paciente", userPaternalSurname);
  }

  Widget _textViewMaternalSurname() {
    return _buildReadOnlyField("Apellido Materno del Paciente", userMaternalSurname);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: label,
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
              filled: true,
              prefixIcon: const Icon(Icons.person),
            ),
            controller: TextEditingController(text: value),
          ),
        ),
      ],
    );
  }

  Widget _email(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Correo Electronico',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Ingrese su Correo Electronico',
              border: const OutlineInputBorder(),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
        ],
      ),
    );
  }

  Widget _speciality(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Especialidad',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          isLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<String>(
            value: specialityContoller.text.isEmpty ? null : specialityContoller.text,
            items: _specialities.map((String speciality) {
              return DropdownMenuItem<String>(
                value: speciality,
                child: Text(speciality),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                specialityContoller.text = newValue ?? '';
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione la Especialidad',
              hintStyle: const TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
              border: const OutlineInputBorder(),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.quiz),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Telefono',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Ingrese su telefono',
              border: const OutlineInputBorder(),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.phone),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateOfBirth(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha de Nacimiento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: dateOfBirthController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Ingrese su Fecha de Nacimiento',
              border: const OutlineInputBorder(),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                int age = DateTime.now().year - pickedDate.year;
                if (age < 0) {
                  return;
                }
                dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buttonLoadDNI(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: _fetchPatientData,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.lightBlue,
        ),
        child: const Text(
          "Cargar Datos",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _fetchPatientData() async {
    setState(() {
      errorMessage = '';
      userName = '';
      userPaternalSurname = '';
      userMaternalSurname = '';
    });

    final String dni = dniController.text;
    final ApiService apiService = ApiService('https://api.apis.net.pe/v2');

    try {
      final data = await apiService.fetchDNI(token, dni);
      setState(() {
        userName = data['nombres'] ?? 'No disponible';
        userPaternalSurname = data['apellidoPaterno'] ?? 'No disponible';
        userMaternalSurname = data['apellidoMaterno'] ?? 'No disponible';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar datos';
      });
    }
  }

  Widget _inputMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dirección',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _showMapDialog(context),
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(
                  text: selectedLocation != null
                      ? 'Ubicación: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}'
                      : 'Ubicación no disponible',
                ),
                decoration: InputDecoration(
                  labelText: 'Seleccionar Ubicación',
                  hintText: 'Toca para seleccionar la ubicación en el mapa',
                  border: const OutlineInputBorder(),
                  fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(Icons.map),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMapDialog(BuildContext context) {
    markers.add(Marker(
      markerId: const MarkerId("Ubicación Seleccionada"),
      position: selectedLocation!,
      infoWindow: const InfoWindow(title: "Ubicación Seleccionada"),
    ));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Ubicación'),
          content: SizedBox(
            height: 400,
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setState) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation!,
                    zoom: 14,
                  ),
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                  },
                  onTap: (LatLng position) {
                    setState(() {
                      selectedLocation = position;
                      markers.clear();
                      markers.add(Marker(
                        markerId: const MarkerId("Ubiación Seleccionada"),
                        position: selectedLocation!,
                        infoWindow: const InfoWindow(title: "Ubicación Seleccionada"),
                      ));
                    });
                    _updateLocationTextField(position);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _updateLocationTextField(LatLng position) {
    setState(() {
      String formattedLocation = 'Ubicación: ${position.latitude}, ${position.longitude}';
      locationController.text = formattedLocation;
    });
  }

  Widget _listViewMedico(BuildContext context) {
    return FutureBuilder<int>(
      future: countDocuments("PersonalMedico"),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          int count = snapshot.data ?? 0;

          return ListView.builder(
            itemCount: count,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: _getPersonalMedicoByIndex(index),
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> optionSnapshot) {
                  if (optionSnapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (optionSnapshot.hasError) {
                    return Center(child: Text("Error: ${optionSnapshot.error}"));
                  } else if (optionSnapshot.hasData && optionSnapshot.data != null) {
                    String name = optionSnapshot.data!['nombre'] ?? "No disponible";
                    String phone = optionSnapshot.data!['Telefono'] ?? "No disponible";
                    String speciality = optionSnapshot.data!['Especialidad'] ?? "No disponible";
                    String email = optionSnapshot.data!['correoElectronico'] ?? "No disponible";

                    if (searchQuery.isNotEmpty && !name.toLowerCase().contains(searchQuery)) {
                      return Container();
                    }

                    String imagePath = "$name.png";

                    return GestureDetector(
                      onTap: () {
                      },
                      child: _buildImageCard(imagePath, name, phone, speciality, email),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildImageCard(String image, String name, String phone, String speciality, String email) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            FutureBuilder<String>(
              future: _getImageUrl(image),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 90,
                    height: 90,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    width: 90,
                    height: 90,
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      snapshot.data!,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: Colors.blueGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Colors.blueGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.medical_services,
                        color: Colors.deepPurple,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          speciality,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurple,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listViewPatient(BuildContext context) {
    return FutureBuilder<int>(
      future: countDocuments("Pacientes"),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          int count = snapshot.data ?? 0;

          return ListView.builder(
            itemCount: count,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: _getPacienteByIndex(index),
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> optionSnapshot) {
                  if (optionSnapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (optionSnapshot.hasError) {
                    return Center(child: Text("Error: ${optionSnapshot.error}"));
                  } else if (optionSnapshot.hasData && optionSnapshot.data != null) {
                    String name = optionSnapshot.data!['nombres'] ?? "No disponible";
                    String phone = optionSnapshot.data!['Telefono'] ?? "No disponible";
                    String state = optionSnapshot.data!['estado'] ?? "No disponible";
                    String email = optionSnapshot.data!['correoElectronico'] ?? "No disponible";

                    if (searchQuery.isNotEmpty && !name.toLowerCase().contains(searchQuery)) {
                      return Container();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPatient(
                              name: name,
                              phone: phone,
                              state: state,
                              email: email,
                            ),
                          ),
                        );
                      },
                      child: _buildImageCardPatient(name, phone, state, email),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildImageCardPatient(String name, String phone, String state, String email) {
    Color primaryColor = state.toLowerCase() == "cuenta activa" ? Colors.green : Colors.red;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: Colors.white,
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),

              ),
              margin: const EdgeInsets.only(left: 10),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(Icons.email, color: primaryColor, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.phone, color: primaryColor, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Estado del paciente con icono
                    Row(
                      children: [
                        Icon(Icons.account_circle, color: primaryColor, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          state,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
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

  Widget _listViewApoimment(BuildContext context) {
    return FutureBuilder<int>(
      future: countDocuments("CitaMedica"),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          int count = snapshot.data ?? 0;

          return ListView.builder(
            itemCount: count,
            itemBuilder: (BuildContext context, int index) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: _getCitaByIndex(index),
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> optionSnapshot) {
                  if (optionSnapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (optionSnapshot.hasError) {
                    return Center(child: Text("Error: ${optionSnapshot.error}"));
                  } else if (optionSnapshot.hasData && optionSnapshot.data != null) {
                    String code = optionSnapshot.data!['codigo'] ?? "No disponible";
                    String dni = optionSnapshot.data!['dni'] ?? "No disponible";
                    String state = optionSnapshot.data!['estado'] ?? "No disponible";
                    String date = optionSnapshot.data!['fechaCita'] ?? "No disponible";
                    String topic = optionSnapshot.data!['Asunto'] ?? "No disponible";

                    if (searchQuery.isNotEmpty && !state.toLowerCase().contains(searchQuery)) {
                      return Container();
                    }

                    Color color;
                    if (state.toLowerCase() == "aprobado") {
                      color = Colors.green;
                    } else if (state.toLowerCase() == "en revisión") {
                      color = Colors.red;
                    } else {
                      color = Colors.yellow;
                    }

                    return GestureDetector(
                      onTap: () async {
                        bool updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAppointment(
                              code: code,
                              dni: dni,
                              state: state,
                              date: date,
                              topic: topic,
                            ),
                          ),
                        );

                        if (updated) {
                          setState(() {});
                        }
                      },
                      child: _buildImageCardAppoiment(code, dni, state, date, color),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildImageCardAppoiment(String code, String dni, String state, String date, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 12,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 120,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.blueAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // DNI con ícono
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dni,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(
                        state.toLowerCase() == "aprobado"
                            ? Icons.check_circle
                            : state.toLowerCase() == "en revisión"
                            ? Icons.hourglass_empty
                            : Icons.error_outline,
                        color: state.toLowerCase() == "aprobado"
                            ? Colors.green
                            : state.toLowerCase() == "en revisión"
                            ? Colors.red
                            : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: state.toLowerCase() == "aprobado"
                                ? Colors.green
                                : state.toLowerCase() == "en revisión"
                                ? Colors.red
                                : Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _getPersonalMedicoByIndex(int index) async {
    try {
      final CollectionReference personalMedicoRef = FirebaseFirestore.instance.collection('PersonalMedico');

      QuerySnapshot querySnapshot = await personalMedicoRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        if (index < querySnapshot.docs.length) {
          return querySnapshot.docs[index].data() as Map<String, dynamic>;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getPacienteByIndex(int index) async {
    try {
      final CollectionReference personalMedicoRef = FirebaseFirestore.instance.collection('Pacientes');

      QuerySnapshot querySnapshot = await personalMedicoRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        if (index < querySnapshot.docs.length) {
          return querySnapshot.docs[index].data() as Map<String, dynamic>;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getCitaByIndex(int index) async {
    try {
      final CollectionReference personalMedicoRef = FirebaseFirestore.instance.collection('CitaMedica');

      QuerySnapshot querySnapshot = await personalMedicoRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        if (index < querySnapshot.docs.length) {
          return querySnapshot.docs[index].data() as Map<String, dynamic>;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> addPatientToFirestore(String dni) async {
    try {
      Map<String, dynamic> patientData = {
        'nombres': userName,
        'apellidoPaterno': userPaternalSurname,
        'apellidoMaterno': userMaternalSurname,
        'correoElectronico': email,
        'Telefono': phone,
        'Fecha de Nacimiento': dateOfBirthController.text,
        'direccion': {
          'latitude': selectedLocation?.latitude,
          'longitude': selectedLocation?.longitude,
        },
        'estado': "Cuenta Activa",
      };

      await FirebaseFirestore.instance.collection('Pacientes').doc(dni).set(patientData);

    } catch (e) {
      return;
    }
  }

  Widget _buttonLoadPatient(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () async {
          await _fetchPatientData();

          if (userName.isNotEmpty) {
            String dni = dniController.text;
            await addPatientToFirestore(dni);
          } else {
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.lightBlue,
        ),
        child: const Text(
          "Cargar y Guardar",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> addStaffToFirestore(String dni) async {
    try {
      Map<String, dynamic> patientData = {
        'nombres': userName,
        'apellidoPaterno': userPaternalSurname,
        'apellidoMaterno': userMaternalSurname,
        'correoElectronico': email,
        'Telefono': phone,
        'Fecha de Nacimiento': dateOfBirthController.text,
        'direccion': {
          'latitude': selectedLocation?.latitude,
          'longitude': selectedLocation?.longitude,
        },
        'estado': "Cuenta Activa",
      };

      await FirebaseFirestore.instance.collection('Pacientes').doc(dni).set(patientData);


    } catch (e) {
      return;
    }
  }

  Widget _buttonLoadMedicalStaff(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () async {
          await _fetchPatientData();

          if (userName.isNotEmpty) {
            String dni = dniController.text;
            await addStaffToFirestore(dni);
          } else {
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.lightBlue,
        ),
        child: const Text(
          "Cargar y Guardar",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}
