import 'package:aplicativoehealth/optionsmedical.dart'; // Asegúrate de tener esta página disponible.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePageMedical extends StatelessWidget {
  final String dni;
  final String names;
  final String paternalsurname;
  final String maternalsurname;
  final String image;
  final String specialty;
  final String birthday;

  const HomePageMedical({
    super.key,
    required this.dni,
    required this.names,
    required this.paternalsurname,
    required this.maternalsurname,
    required this.specialty,
    required this.image,
    required this.birthday,
  });

  Future<String> _getImageUrl(String image) async {
    final ref = FirebaseStorage.instance.ref().child(image);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bienvenido, Dr. $names",
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
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 100,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _textviewOptions(),
            const SizedBox(height: 20),
            Expanded(child: _listView(context)),
          ],
        ),
      ),
    );
  }

  Future<int> countDocuments(String collectionPath) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionPath).get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _getAllOptions() async {
    CollectionReference medicoOptions = FirebaseFirestore.instance.collection('OpcionesMedicos');
    QuerySnapshot querySnapshot = await medicoOptions.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> _getOptionByIndex(int index) async {
    List<Map<String, dynamic>> options = await _getAllOptions();
    if (index >= 0 && index < options.length) {
      return options[index];
    }
    return null;
  }

  Widget _listView(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<int>(
        future: countDocuments("OpcionesMedicos"),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            int count = snapshot.data ?? 0;
            return ListView.builder(
              scrollDirection: Axis.vertical,
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
                      String title = optionSnapshot.data!['title'] ?? "Titulo No Disponible";
                      String imagePath = "$title.png";

                      return GestureDetector(
                        onTap: () {
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity, // Deja que el ancho sea flexible
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
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
                    colors: [Colors.deepPurple, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
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
                    Flexible(  // Esto permite que el texto se ajuste
                      child: Text(
                        nameOption,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // Esto evitará desbordamientos si el texto es largo
                      ),
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

  Widget _textviewOptions() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.redAccent],
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
            'Opciones del Médico',
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
}
