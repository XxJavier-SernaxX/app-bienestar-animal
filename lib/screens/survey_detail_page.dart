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

  Future<void> _takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveResponse() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      if (_rating == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione una calificación')),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        // Preparar datos para guardar
        final response = {
          'indicatorId': widget.stepName.toLowerCase().replaceAll(' ', '_'),
          'indicatorTitle': widget.stepName,
          'score': _getRatingScore(_rating!),
          'timestamp': DateTime.now().toIso8601String(),
          'observaciones': _observaciones,
          'species': widget.species,
        };

        // Guardar en la base de datos
        await DatabaseHelper.instance.insertResponse(response);

        // TODO: Si se necesita guardar la foto, implementar almacenamiento
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Encuesta guardada correctamente ✅')),
        );
        Navigator.pop(context, true); // Devuelve que se completó
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

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
      appBar: AppBar(title: Text(widget.stepName)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${widget.species} - ${widget.stepName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            
            // Calificación
            DropdownButtonFormField<String>(
              value: _rating,
              decoration: const InputDecoration(
                labelText: 'Calificación',
                border: OutlineInputBorder(),
                filled: true,
              ),
              hint: const Text('Seleccione una calificación'),
              items: [
                'Excelente',
                'Bueno',
                'Regular',
                'Deficiente',
                'Malo'
              ].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              validator: (value) =>
                value == null ? 'Por favor seleccione una calificación' : null,
              onChanged: (value) => setState(() => _rating = value),
            ),
            
            const SizedBox(height: 20),
            
            // Observaciones
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
                filled: true,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) =>
                value?.isEmpty ?? true ? 'Por favor ingrese observaciones' : null,
              onSaved: (value) => _observaciones = value,
            ),
            
            const SizedBox(height: 20),

            // Foto
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto de evidencia'),
              onPressed: _isSaving ? null : _takePhoto,
            ),
            
            if (_photo != null) ...[
              const SizedBox(height: 10),
              Image.file(_photo!, height: 200, fit: BoxFit.cover),
            ],
            
            const SizedBox(height: 24),
            
            // Botón guardar
            ElevatedButton.icon(
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Icon(Icons.check_circle),
              label: Text(_isSaving ? 'Guardando...' : 'GUARDAR EVALUACIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _isSaving ? null : _saveResponse,
            ),
          ],
        ),
      ),
    );
  }
}
