import 'package:aplicativoehealth/viewappointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Options extends StatefulWidget {
  final String title;
  final String dni;

  const Options({super.key, required this.title, required this.dni});

  @override
  OptionsState createState() => OptionsState();
}

class OptionsState extends State<Options> {

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  Future<int> countDocuments(String collectionPath) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionPath).get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> _getCitaByIndex(int index) async {
    try {
      final CollectionReference personalMedicoRef = FirebaseFirestore.instance.collection('CitaMedica');

      QuerySnapshot querySnapshot = await personalMedicoRef
          .where('dni', isEqualTo: widget.dni).where('estado', isEqualTo: 'Aprobado')
          .get();

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

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (widget.title) {
      case "Listado Citas Médicas":
        content = _buildOption1Content(context);
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

  Widget _buildDefaultContent() {
    return const Center(child: Text("Contenido no disponible"));
  }

}
