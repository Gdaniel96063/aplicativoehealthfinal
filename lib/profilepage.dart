import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String names;
  final String paternalsurname;
  final String maternalsurname;
  final String birthday;

  const ProfilePage({
    required this.names,
    required this.paternalsurname,
    required this.maternalsurname,
    required this.birthday,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10, // Desenfoque
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/user.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildProfileInfo(
                  icon: Icons.person,
                  title: 'Nombre:',
                  info: '$names $paternalsurname $maternalsurname',
                ),
                const SizedBox(height: 20),
                _buildProfileInfo(
                  icon: Icons.cake,
                  title: 'Fecha de Nacimiento:',
                  info: birthday,
                ),
                const SizedBox(height: 40),
                _buildProfileInfo(
                  icon: Icons.location_on,
                  title: 'Dirección:',
                  info: 'Calle Ejemplo 123',
                ),
                const SizedBox(height: 20),
                _buildProfileInfo(
                  icon: Icons.email,
                  title: 'Correo electrónico:',
                  info: 'ejemplo@dominio.com',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo({
    required IconData icon,
    required String title,
    required String info,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blueAccent,
          size: 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                info,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}