// ✅ Drawer modernizado y compatible con la nueva versión de tu app SIBA
// ----------------------------------------------------------------------
// Explicación tipo estudiante:
// Este es el menú lateral que aparece al abrir la app. Permite navegar
// entre categorías, ver resultados y abrir documentos ICA. También
// muestra iconos y estilos modernos coherentes con toda la app.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/indicator_list.dart';
import '../screens/resultados_screen.dart'; // ✅ Ajustado al archivo real

class MenuDrawer extends StatelessWidget {
  final String species;

  MenuDrawer({super.key, required this.species});

  // ✅ Lista de secciones del menú
  final categories = [
    {'title': 'Recursos', 'code': 'recursos'},
    {'title': 'Animal', 'code': 'animal'},
    {'title': 'Gestión', 'code': 'gestion'},
    {'title': 'Resultados', 'code': 'resultados'},
    {'title': 'Documentos ICA', 'code': 'about'},
    {'title': 'Ver resultados guardados', 'code': 'saved'},
  ];

  Future<void> _openPDF(String url) async {
    final Uri pdfUrl = Uri.parse(url);
    if (!await launchUrl(pdfUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el PDF: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      surfaceTintColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // ✅ Header moderno
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SIBA - Bienestar Animal',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Metodología ICA · Versión 1.0',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Opciones del menú
            Expanded(
              child: ListView(
                children: categories.map((c) {
                  return ListTile(
                    leading: _getIcon(c['code']!),
                    title: Text(
                      c['title']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      switch (c['code']) {
                        case 'recursos':
                        case 'animal':
                        case 'gestion':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IndicatorList(
                                category: c['code']!,
                                categoryTitle: c['title']!,
                                species: species,
                              ),
                            ),
                          );
                          break;

                        case 'resultados':
                        case 'saved':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultadosScreen(),
                            ),
                          );
                          break;

                        case 'about':
                          _showAboutMenu(context);
                          break;
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Íconos más modernos y coherentes con SIBA
  Icon _getIcon(String code) {
    switch (code) {
      case 'recursos':
        return const Icon(Icons.home_repair_service, color: Colors.teal);
      case 'animal':
        return const Icon(Icons.pets, color: Colors.orange);
      case 'gestion':
        return const Icon(Icons.settings_suggest, color: Colors.blueGrey);
      case 'resultados':
        return const Icon(Icons.assessment, color: Colors.green);
      case 'saved':
        return const Icon(Icons.save_alt, color: Colors.deepPurple);
      case 'about':
        return const Icon(Icons.picture_as_pdf, color: Colors.redAccent);
      default:
        return const Icon(Icons.circle);
    }
  }

  // ✅ Diálogo de documentos ICA
  void _showAboutMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Documentos ICA'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Metodología EBA Porcinos 3.0'),
                onTap: () {
                  Navigator.pop(context);
                  _openPDF(
                    'https://www.ica.gov.co/getattachment/...pdf',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Resolución ICA 0254 de 2024'),
                onTap: () {
                  Navigator.pop(context);
                  _openPDF(
                    'https://www.ica.gov.co/getattachment/...pdf',
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
