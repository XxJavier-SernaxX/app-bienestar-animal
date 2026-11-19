// lib/screens/login_page.dart
// -----------------------------------------------------------------------------
// PANTALLA DE INICIO DE SESIÓN EDITORIAL · SISTEMA DE BIENESTAR ANIMAL (SIBA)
// Granja Experimental UFPSO · Ocaña, Norte de Santander
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Javier Mauricio Serna Osorio');
  final TextEditingController _codeController =
      TextEditingController(text: '0192546');

  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF263F30),
              onPrimary: Colors.white,
              onSurface: Color(0xFF353A35),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe el nombre del evaluador.'),
          backgroundColor: Color(0xFFB96E4B),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userCode', _codeController.text.trim());

    final now = DateTime.now();
    final String today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final String dateToSave = _selectedDate == null
        ? today
        : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    await prefs.setString('selectedDate', dateToSave);

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isSaving = false);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/species');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Oficial SIBA
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8ECE6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF263F30).withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icono.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.pets, size: 40, color: Color(0xFF263F30)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Títulos Editoriales
                  const Text(
                    'SIBA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Color(0xFF263F30),
                    ),
                  ),
                  const Text(
                    'Sistema de Bienestar Animal · UFPSO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A8279),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF496B4D).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Resolución 136 de 2020 · Porcinos y Aves',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF263F30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tarjeta Limpia de Formulario
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8ECE6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identificación del Evaluador',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF263F30),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Los registros se firman con tu nombre y código institucional.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF7A8279)),
                        ),
                        const SizedBox(height: 18),

                        // Campo de Nombre
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF353A35)),
                          decoration: InputDecoration(
                            labelText: 'Nombre del Evaluador',
                            labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7A8279)),
                            prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF496B4D)),
                            filled: true,
                            fillColor: const Color(0xFFF8F9F5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE8ECE6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE8ECE6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF263F30), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Campo de Código
                        TextField(
                          controller: _codeController,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF353A35)),
                          decoration: InputDecoration(
                            labelText: 'Código / Cédula',
                            labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7A8279)),
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF496B4D)),
                            filled: true,
                            fillColor: const Color(0xFFF8F9F5),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE8ECE6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE8ECE6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF263F30), width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Selección de Fecha
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9F5),
                              border: Border.all(color: const Color(0xFFE8ECE6)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF496B4D)),
                                    const SizedBox(width: 10),
                                    Text(
                                      _selectedDate == null
                                          ? 'Fecha: Hoy (Automática)'
                                          : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF353A35)),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF7A8279)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Botón de Inicio
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF263F30),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Iniciar Auditoría de Campo',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Indicador de Tolerancia Offline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8ECE6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF496B4D)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Modo Offline-First · Guarda en SQLite y auto-sincroniza',
                            style: TextStyle(fontSize: 11, color: Color(0xFF7A8279)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
