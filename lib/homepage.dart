import 'package:aplicativoehealth/options.dart';
import 'package:aplicativoehealth/viewdoctor.dart';
import 'package:aplicativoehealth/viewillness.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String dni;
  final String names;
  final String paternalsurname;
  final String maternalsurname;
  final String birthday;
  final String phone;
  final String email;

  const HomePage({
    required this.dni,
    required this.names,
    required this.paternalsurname,
    required this.maternalsurname,
    required this.birthday,
    required this.phone,
    required this.email,
    super.key,
  });

  Future<String> _getImageUrl(String image) async {
    final ref = FirebaseStorage.instance.ref().child(image);
    return await ref.getDownloadURL();
  }

  Future<List<Map<String, dynamic>>> _getAllOptions() async {
    CollectionReference administradoroption = FirebaseFirestore.instance.collection('OpcionesPaciente');
    QuerySnapshot querySnapshot = await administradoroption.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> _getOptionByIndex(int index) async {
    List<Map<String, dynamic>> options = await _getAllOptions();
    if (index >= 0 && index < options.length) {
      return options[index];
    }
    return null;
  }

  Future<int> countDocuments(String collectionPath) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionPath).get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _getAllDoctors() async {
    CollectionReference doctorCollection = FirebaseFirestore.instance.collection('PersonalMedico');
    QuerySnapshot querySnapshot = await doctorCollection.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> _getDoctorByIndex(int index) async {
    List<Map<String, dynamic>> doctors = await _getAllDoctors();
    if (index >= 0 && index < doctors.length) {
      return doctors[index];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getAllIllness() async {
    CollectionReference administradoroption = FirebaseFirestore.instance.collection('Enfermedades');
    QuerySnapshot querySnapshot = await administradoroption.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> _getIlnessByIndex(int index) async {
    List<Map<String, dynamic>> options = await _getAllIllness();
    if (index >= 0 && index < options.length) {
      return options[index];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bienvenido de Nuevo!\n$names",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            shadows: [
              Shadow(
                offset: Offset(1.0, 3.0),
                blurRadius: 5.0,
                color: Color(0x55000000),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 100,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _textviewOptions(context),
            const SizedBox(height: 20),
            _listView(context),
            const SizedBox(height: 30),
            _textviewDoctors(context),
            const SizedBox(height: 20),
            _doctorListView(context),
            const SizedBox(height: 20),
            _textviewIllness(context),
            const SizedBox(height: 20),
            _illnessListView(context),
          ],
        ),
      ),
    );
  }

  Widget _listView(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<int>(
        future: countDocuments("OpcionesPaciente"),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            int count = snapshot.data ?? 0;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getOptionByIndex(index),
                  builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> optionSnapshot) {
                    if (optionSnapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (optionSnapshot.hasError) {
                      return const Center(child: Text("Nombre no Disponible"));
                    } else if (optionSnapshot.hasData && optionSnapshot.data != null) {
                      String title = optionSnapshot.data!['nombre'] ?? "Titulo No Disponible";
                      String imagePath = "$title.png";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Options(title: title, dni: dni),
                            ),
                          );
                        },
                        child: _buildImageCard(imagePath, title),
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
      ),
    );
  }

  Widget _buildImageCard(String image, String nameOption) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      margin: const EdgeInsets.all(12),
      color: Colors.white,
      child: IntrinsicWidth(
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: _getImageUrl(image),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        snapshot.data!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nameOption,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textviewOptions(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: const Text(
            'Opciones de Paciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 5.0,
                  color: Color(0x55000000),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textviewDoctors(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: const Text(
            'Personal Médico',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 5.0,
                  color: Color(0x55000000),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _doctorListView(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<int>(
        future: countDocuments("PersonalMedico"),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            int count = snapshot.data ?? 0;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getDoctorByIndex(index),
                  builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> doctorSnapshot) {
                    if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (doctorSnapshot.hasError) {
                      return const Center(child: Text("Nombre no Disponible"));
                    } else if (doctorSnapshot.hasData && doctorSnapshot.data != null) {
                      String doctorName = doctorSnapshot.data!['nombre'] ?? "Nombre no Disponible";
                      String doctorSpecialty = doctorSnapshot.data!['Especialidad'] ?? "Especialidad no disponible";
                      String doctorImage = doctorSnapshot.data!['imagen'] ?? "$doctorName.png";
                      String doctorDate = doctorSnapshot.data!['horario'] ?? "Horario No Disponible";
                      String doctorDescription = doctorSnapshot.data!['descripcion'] ?? "Descripcion No Disponible";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewDoctor(
                                doctorName: doctorName,
                                doctorSpecialty: doctorSpecialty,
                                doctorImage: doctorImage,
                                doctorDate: doctorDate,
                                doctorDescription: doctorDescription,
                              ),
                            ),
                          );
                        },
                        child: _buildDoctorCard(doctorImage, doctorName, doctorSpecialty),
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
      ),
    );
  }

  Widget _buildDoctorCard(String image, String name, String specialty) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      margin: const EdgeInsets.all(12),
      color: Colors.white,
      child: IntrinsicWidth(
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: _getImageUrl(image),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        snapshot.data!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                specialty,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textviewIllness(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 2,
            ),
          ),
          child: const Text(
            'Enfermedades Generales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 5.0,
                  color: Color(0x55000000),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _illnessListView(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<int>(
        future: countDocuments("Enfermedades"),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            int count = snapshot.data ?? 0;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getIlnessByIndex(index),
                  builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Nombre no Disponible"));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      String illnessName = snapshot.data!['nombre'] ?? "Nombre no Disponible";
                      String illnessImage = snapshot.data!['imagen'] ?? "$illnessName.png";
                      String illnessDescription = snapshot.data!['descripcion'] ?? "No Disponible";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewIllness(
                                illnessName: illnessName,
                                illnessDescription: illnessDescription,
                                illnessImage: illnessImage,
                              ),
                            ),
                          );
                        },
                        child: _buildIllnessCard(illnessImage, illnessName),
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
      ),
    );
  }


  Widget _buildIllnessCard(String image, String name) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      margin: const EdgeInsets.all(12),
      color: Colors.white,
      child: IntrinsicWidth(
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: _getImageUrl(image),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        snapshot.data!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
