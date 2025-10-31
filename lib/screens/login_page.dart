// 🐷 Pantalla de inicio de sesión (Login Page) para la app SIBA
// ---------------------------------------------------------------
// Esta pantalla permite que el usuario escriba su nombre y (si quiere)
// elegir una fecha. Si el usuario NO elige fecha, se guarda
// automáticamente la fecha actual.
//
// Explicación en palabras simples:
// ✅ Fondo suave con degradado
// ✅ Logo centrado (assets/icono.png)
// ✅ Caja blanca con campos ordenados
// ✅ Botón grande para continuar
// ✅ Se guardan los datos para usarlos en la siguiente pantalla

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controlador para leer el texto del nombre
  final TextEditingController _nameController = TextEditingController();

  // Aquí guardamos la fecha que el usuario escoja (si decide hacerlo)
  DateTime? _selectedDate;

  // Esto es solo para mostrar un indicador mientras guarda los datos
  bool _isSaving = false;

  // ---------------------------------------------------------------
  // Función para abrir el calendario y permitir escoger la fecha
  // ---------------------------------------------------------------
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha actual por defecto
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ---------------------------------------------------------------
  // Función que guarda el nombre y la fecha, y avanza a la siguiente pantalla
  // ---------------------------------------------------------------
  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();

    // Validación simple: si el nombre está vacío, mostramos un mensaje
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe tu nombre')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();

    // Guardamos el nombre
    await prefs.setString('userName', name);

    // Si el usuario NO escogió fecha → ponemos la de hoy
    final now = DateTime.now();
    final String today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Guardar fecha seleccionada o la fecha automática
    final String dateToSave = _selectedDate == null
        ? today
        : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    await prefs.setString('selectedDate', dateToSave);

    // Simulamos que está cargando un momento
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isSaving = false);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/species');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------------------------------------------------
      // TÍTULO SUPERIOR
      // ---------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text('SIBA - Bienestar Animal'),
        centerTitle: true,
      ),

      // ---------------------------------------------------------------
      // FONDO CON DEGRADADO VERDE SUAVE
      // ---------------------------------------------------------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),

                // ---------------------------------------------------------------
                // CONTENIDO PRINCIPAL
                // ---------------------------------------------------------------
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo centrado (coloca tu icono aquí)
                    Image.asset(
                      'assets/icono.png',
                      height: 90,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Bienvenido a SIBA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // -------------------------- CAMPO DEL NOMBRE --------------------------
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tu nombre',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // -------------------------- CAMPO DE FECHA --------------------------
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Selecciona una fecha (opcional)'
                                  : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today,
                                color: Colors.teal, size: 22),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // -------------------------- BOTÓN PRINCIPAL --------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Continuar',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Tu información se guarda solo en este dispositivo.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
