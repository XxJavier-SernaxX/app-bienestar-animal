// ✅ Pantalla moderna de detalle de cada paso del formulario
// ---------------------------------------------------------------
// Explicación sencilla:
// Aquí el usuario responde un paso específico del formulario (por ejemplo,
// "Comederos", "Hidratación", etc).
// Debe:
//  ✅ Escoger una calificación (Excelente, Bueno, etc.)
//  ✅ Escribir observaciones
//  ✅ Tomar una foto opcional
//  ✅ Guardar todo en la base de datos
//
// Todo está con el mismo estilo moderno de SIBA.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/database_helper.dart';

class SurveyDetailPage extends StatefulWidget {
  final String stepName;
  final String species;

  const SurveyDetailPage({
    super.key,
    required this.stepName,
    required this.species,
  });

  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  final _formKey = GlobalKey<FormState>();

  String? _rating;
  String? _observaciones;
  File? _photo;

  final picker = ImagePicker();
  bool _isSaving = false;

  // ✅ Tomar foto con la cámara
  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  // ✅ Guardar todo en la base de datos
  Future<void> _saveResponse() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.save();

    if (_rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes elegir una calificación')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = {
        'indicatorId': widget.stepName.toLowerCase().replaceAll(' ', '_'),
        'indicatorTitle': widget.stepName,
        'score': _getRatingScore(_rating!),
        'timestamp': DateTime.now().toIso8601String(),
        'observaciones': _observaciones,
        'species': widget.species,
        'photo': _photo?.path,
      };

      await DatabaseHelper.instance.insertResponse(response);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Guardado correctamente')),
      );

      Navigator.pop(context, true); // Para marcar como completado en la lista
    } catch (e) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  // ✅ Convertir rating a número
  int _getRatingScore(String rating) {
    switch (rating) {
      case 'Excelente':
        return 5;
      case 'Bueno':
        return 4;
      case 'Regular':
        return 3;
      case 'Deficiente':
        return 2;
      case 'Malo':
        return 1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,

      // ✅ Barra superior moderna
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 3,
        title: Text(
          widget.stepName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ✅ Cuerpo principal
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            // ----------------------------------------------------
            // ✅ Título superior
            // ----------------------------------------------------
            Text(
              '${widget.species} — ${widget.stepName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------
            // ✅ Dropdown moderno de calificación
            // ----------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _rating,
                decoration: const InputDecoration(
                  labelText: 'Calificación',
                  border: InputBorder.none,
                ),
                items: const [
                  'Excelente',
                  'Bueno',
                  'Regular',
                  'Deficiente',
                  'Malo'
                ].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                validator: (value) =>
                    value == null ? 'Seleccione una calificación' : null,
                onChanged: (value) => setState(() => _rating = value),
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------
            // ✅ Observaciones modernas
            // ----------------------------------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  border: InputBorder.none,
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese observaciones' : null,
                onSaved: (value) => _observaciones = value,
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------
            // ✅ Botón para tomar foto
            // ----------------------------------------------------
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _takePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Tomar foto de evidencia',
                style: TextStyle(color: Colors.white),
              ),
            ),

            if (_photo != null) ...[
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _photo!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 30),

            // ----------------------------------------------------
            // ✅ Botón guardar grande
            // ----------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveResponse,
                icon: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? 'Guardando...' : 'GUARDAR EVALUACIÓN',
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
