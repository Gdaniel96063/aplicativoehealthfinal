import 'package:aplicativoehealth/apidniservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final String token = 'apis-token-11318.g9mI92LSxEnTqzAvDPUytMmSRRQvs5qv';
  final TextEditingController dnicontroller = TextEditingController();
  final TextEditingController namesController = TextEditingController();
  final TextEditingController paternalSurnameController = TextEditingController();
  final TextEditingController maternalSurnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  String userName = "";
  String userPaternalSurname = "";
  String userMaternalSurname = "";

  String? errorMessage;
  String? passwordErrorMessage;
  String? generalErrorMessage;

  LatLng? selectedLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _loadDatePatient() async {
    setState(() {
      errorMessage = '';
      userName = '';
      userPaternalSurname = '';
      userMaternalSurname = '';
    });

    final String dni = dnicontroller.text;
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

  Future<void> _selectBirthDate(BuildContext context) async {
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
        birthDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  Future<void> _register(BuildContext context) async {
    setState(() {
      errorMessage = null;
      passwordErrorMessage = null;
      generalErrorMessage = null;
    });

    if (dnicontroller.text.isEmpty || dnicontroller.text.length != 8) {
      setState(() {
        errorMessage = 'DNI inválido. Debe tener 8 dígitos.';
      });
      return;
    }

    else if (emailController.text.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(emailController.text)) {
      setState(() {
        errorMessage = 'Correo electrónico inválido.';
      });
      return;
    }

    else if (phoneController.text.isEmpty || phoneController.text.length < 9) {
      setState(() {
        errorMessage = 'Número de teléfono inválido.';
      });
      return;
    }

    else if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      setState(() {
        passwordErrorMessage = 'La contraseña debe tener al menos 6 caracteres.';
      });
      return;
    } else if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        passwordErrorMessage = 'Las contraseñas no coinciden.';
      });
      return;
    }

    else if (birthDateController.text.isEmpty) {
      setState(() {
        errorMessage = 'Debe seleccionar una fecha de nacimiento.';
      });
      return;
    }

    else if (selectedLocation == null) {
      setState(() {
        errorMessage = 'Debe seleccionar una ubicación.';
      });
      return;
    }

    try {
      Map<String, dynamic> patientData = {
        'dni': dnicontroller.text,
        'nombres': userName,
        'apellidoPaterno': userPaternalSurname,
        'apellidoMaterno': userMaternalSurname,
        'correoElectronico': emailController.text,
        'Telefono': phoneController.text,
        'Fecha de Nacimiento': birthDateController.text,
        'contraseña': passwordController.text,
        'direccion': {
          'latitude': selectedLocation?.latitude,
          'longitude': selectedLocation?.longitude,
        },
        'estado': "Cuenta Activa",
      };

      await FirebaseFirestore.instance.collection('Pacientes').doc(dnicontroller.text).set(patientData);

    } catch (e) {
      setState(() {
        generalErrorMessage = 'Error al registrar al usuario. Por favor, intenta nuevamente.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00C9FF),
                  Color(0xFF92FE9D),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(),
                    _inputFieldDNI(),
                    _textViewNames(),
                    _textViewPaternalSurname(),
                    _textViewMaternalSurname(),
                    _inputFieldEmail(),
                    _inputFieldPhone(),
                    _inputFieldLocation(),
                    _inputFieldBirthDate(),
                    _inputFieldPassword(),
                    if (passwordErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: _errorMessage(passwordErrorMessage!),
                      ),
                    _inputFieldConfirmPassword(),
                    _registerButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _header() {
    return Column(
      children: [
        const Center(
          child: Text(
            "Registro de Usuario",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontFamily: 'RobotoSlab',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Crea una cuenta para continuar",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _inputFieldDNI() {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            controller: dnicontroller,
            label: 'DNI',
            hint: 'Ingresa tu DNI',
            keyboardType: TextInputType.number,
            icon: Icons.person,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            _loadDatePatient();
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor: Colors.blueAccent,
            elevation: 5,
          ),
          child: const Text(
            "Cargar Datos",  // Aquí se cambia el texto del botón
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }


  Widget _textViewNames() {
    return _buildReadOnlyField("Nombres", userName);
  }

  Widget _textViewPaternalSurname() {
    return _buildReadOnlyField("Apellido Paterno", userPaternalSurname);
  }

  Widget _textViewMaternalSurname() {
    return _buildReadOnlyField("Apellido Materno", userMaternalSurname);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12.0),
        TextField(
          enabled: false,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            labelText: label,
            hintText: "Sin modificar",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.blueAccent.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.blueAccent,
                width: 2.5,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _inputFieldEmail() {
    return _buildInputField(
      controller: emailController,
      label: 'Correo Electrónico',
      hint: 'Ingresa tu correo electrónico',
      keyboardType: TextInputType.emailAddress,
      icon: Icons.email,
    );
  }

  Widget _inputFieldPhone() {
    return _buildInputField(
      controller: phoneController,
      label: 'Teléfono',
      hint: 'Ingresa tu teléfono',
      keyboardType: TextInputType.phone,
      icon: Icons.phone,
    );
  }

  Widget _inputFieldLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12.0),
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
                hintText: 'Toca para seleccionar la ubicación en el mapa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.blueAccent.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                fillColor: Colors.grey[100],
                filled: true,
                prefixIcon: const Icon(
                  Icons.map,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _inputFieldBirthDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12.0),
        GestureDetector(
          child: TextField(
            readOnly: true,
            controller: birthDateController,
            onTap: () async { _selectBirthDate(context); },
            decoration: InputDecoration(
              labelText: 'Fecha de Nacimiento',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.blueAccent.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2.5,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Colors.blueAccent,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputFieldPassword() {
    return _buildInputField(
      controller: passwordController,
      label: 'Contraseña',
      hint: 'Ingresa tu contraseña',
      obscureText: true,
      icon: Icons.lock,
    );
  }

  Widget _inputFieldConfirmPassword() {
    return _buildInputField(
      controller: confirmPasswordController,
      label: 'Confirmar Contraseña',
      hint: 'Confirma tu contraseña',
      obscureText: true,
      icon: Icons.lock_outline,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12.0),
        GestureDetector(
          onTap: onTap,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.blueAccent.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2.5,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: icon != null ? Icon(icon, color: Colors.blueAccent) : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _registerButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30.0),
        ElevatedButton(
          onPressed: () => _register(context),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.blueAccent,
            elevation: 10,
            shadowColor: Colors.blue.withOpacity(0.5),
          ),
          child: const Text(
            "Registrar",
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _errorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  }
}
