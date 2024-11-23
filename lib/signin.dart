import 'package:aplicativoehealth/homepageadmin.dart';
import 'package:aplicativoehealth/homepagemedical.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicativoehealth/signup.dart';
import 'package:aplicativoehealth/homepage.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final TextEditingController dnicontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  String? errorMessage;
  String? passwordErrorMessage;
  String? generalErrorMessage;

  bool isAdmin = false; // Nuevo campo para controlar el estado del checkbox

  @override
  void initState() {
    super.initState();
    _hideBottomNavBar();
  }

  void _hideBottomNavBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _signIn(context) async {
    String dni = dnicontroller.text.trim();
    String password = passwordcontroller.text;

    if (dni.length != 8) {
      setState(() {
        errorMessage = "El DNI debe tener 8 dígitos";
        generalErrorMessage = null;
      });
      return;
    } else {
      setState(() {
        errorMessage = null;
      });
    }

    if (password.length < 6) {
      setState(() {
        passwordErrorMessage = "La contraseña debe tener mínimo 6 caracteres";
        generalErrorMessage = null;
      });
      return;
    } else {
      setState(() {
        passwordErrorMessage = null;
      });
    }

    try {
      String collectionName = isAdmin ? 'PersonalMedico' : 'Pacientes';

      CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
      DocumentSnapshot userDoc = await collection.doc(dni).get();

      if (userDoc.exists) {
        if (userDoc['contraseña'] == password) {
          if (isAdmin) {
            String role = userDoc['rol'] ?? ''; // 'role' puede ser 'admin' o 'medico'

            if (role == 'administrador') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageAdmin(
                    dni: dni,
                    names: userDoc['nombres'],
                    paternalsurname: userDoc['apellidoPaterno'],
                    maternalsurname: userDoc['apellidoMaterno'],
                    birthday: userDoc['fechaNacimiento'],
                    specialty: userDoc['Especialidad'],
                    image: userDoc['image'],
                  ),
                ),
              );
            } else if (role == 'médico') {
              // Si es un médico, lo enviamos a la página de médico
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageMedical( // Aquí debes definir una página distinta para los médicos si es necesario
                    dni: dni,
                    names: userDoc['nombres'],
                    paternalsurname: userDoc['apellidoPaterno'],
                    maternalsurname: userDoc['apellidoMaterno'],
                    birthday: userDoc['fechaNacimiento'],
                    specialty: userDoc['Especialidad'],
                    image: userDoc['image'],
                  ),
                ),
              );
            } else {
              setState(() {
                generalErrorMessage = "Rol de usuario no válido.";
              });
            }
          } else {
            // Si no es un admin, simplemente lo enviamos a la página del paciente
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  dni: dni,
                  names: userDoc['nombres'],
                  paternalsurname: userDoc['apellidoPaterno'],
                  maternalsurname: userDoc['apellidoMaterno'],
                  birthday: userDoc['fechaNacimiento'],
                  phone: userDoc['Telefono'],
                  email: userDoc['correoElectronico'],
                ),
              ),
            );
          }
        } else {
          setState(() {
            generalErrorMessage = "DNI o contraseña incorrectos";
          });
        }
      } else {
        setState(() {
          generalErrorMessage = "DNI o contraseña incorrectos";
        });
      }
    } catch (e) {
      setState(() {
        generalErrorMessage = "Error al acceder al servidor: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
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
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(),
                    _inputFieldDNI(),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _errorMessage(errorMessage!),
                      ),
                    _inputFieldPassword(),
                    if (passwordErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _errorMessage(passwordErrorMessage!),
                      ),
                    if (generalErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _errorMessage(generalErrorMessage!),
                      ),
                    _adminCheckbox(), // Agregamos el checkbox
                    _button(),
                    _navigateToSignUp(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _header() {
    return Column(
      children: [
        const Center(
          child: Text(
            "Inicio de Sesión",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontFamily: 'RobotoSlab',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Accede a tu cuenta para continuar",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _inputFieldDNI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        TextField(
          controller: dnicontroller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.length != 8) {
              setState(() {
                errorMessage = "El DNI debe tener 8 dígitos";
              });
            } else {
              setState(() {
                errorMessage = null;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'DNI',
            hintText: 'Ingresa tu DNI',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.5),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
          ),
        ),
      ],
    );
  }

  Widget _inputFieldPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        TextField(
          controller: passwordcontroller,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: "Contraseña",
            hintText: 'Ingresa tu contraseña',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.5),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
          ),
        ),
      ],
    );
  }

  Widget _adminCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isAdmin,
          onChanged: (value) {
            setState(() {
              isAdmin = value ?? false;
            });
          },
        ),
        const Text(
          "¿Eres parte del personal médico?",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ],
    );
  }

  Widget _button() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40.0),
        ElevatedButton(
          onPressed: () => _signIn(context),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blueAccent,
            elevation: 10,
            shadowColor: Colors.blue.withOpacity(0.5),
          ),
          child: const Text(
            "Iniciar Sesión",
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _errorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    );
  }

  Widget _navigateToSignUp() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUp()),
        );
      },
      child: const Text(
        "¿No tienes cuenta? Regístrate aquí",
        style: TextStyle(color: Colors.blueAccent, fontSize: 16),
      ),
    );
  }
}
