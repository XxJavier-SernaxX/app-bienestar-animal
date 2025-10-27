// lib/screens/indicator_detail.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class IndicatorDetail extends StatefulWidget {
  final String indicatorName;
  final String category;

  const IndicatorDetail({
    Key? key,
    required this.indicatorName,
    required this.category,
  }) : super(key: key);

  @override
  State<IndicatorDetail> createState() => _IndicatorDetailState();
}

class _IndicatorDetailState extends State<IndicatorDetail> {
  int? selectedScore;
  File? _image;

  final Map<int, String> scoreLabels = {
    100: 'Cumple completamente',
    55: 'Más del 50% cumple',
    20: 'Hasta el 50% cumple',
    0: 'No cumple',
  };

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _image = File(photo.path));
    }
  }

  Future<void> _saveResult() async {
    if (selectedScore == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = '${widget.category}_${widget.indicatorName}';
    final result = {
      'score': selectedScore,
      'photo': _image?.path,
    };

    prefs.setString(key, jsonEncode(result));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resultado guardado correctamente ✅')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.indicatorName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccione una calificación:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...scoreLabels.entries.map((entry) {
              return RadioListTile<int>(
                title: Text('${entry.key} puntos - ${entry.value}'),
                value: entry.key,
                groupValue: selectedScore,
                onChanged: (value) => setState(() => selectedScore = value),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto'),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              Image.file(_image!, height: 150, fit: BoxFit.cover),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveResult,
              child: const Text('Guardar resultado'),
            ),
          ],
        ),
      ),
    );
  }
}
