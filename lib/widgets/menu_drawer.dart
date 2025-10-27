// lib/widgets/menu_drawer.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/indicator_list.dart';
import '../screens/results_page.dart';

class MenuDrawer extends StatelessWidget {
  final String species;
  final categories = [
    {'title': 'Recursos', 'code': 'recursos'},
    {'title': 'Animal', 'code': 'animal'},
    {'title': 'Gestión', 'code': 'gestion'},
    {'title': 'Resultados', 'code': 'resultados'},
    {'title': 'Acerca de', 'code': 'about'},
    {'title': 'Guardar cambios', 'code': 'save'},
    {'title': 'Ver resultados guardados', 'code': 'saved'},
  ];

  MenuDrawer({super.key, required this.species});

  Future<void> _openPDF(String url) async {
    final Uri pdfUrl = Uri.parse(url);
    if (!await launchUrl(pdfUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el PDF: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.pinkAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bienestar Porcino',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Metodología ICA - Versión 3.0',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ...categories.map((c) {
              return ListTile(
                leading: _getIcon(c['code']!),
                title: Text(c['title']!),
                onTap: () {
                  Navigator.pop(context);

                  switch (c['code']) {
                    case 'recursos':
                    case 'animal':
                    case 'gestion':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndicatorList(
                            category: c['code']!,
                            categoryTitle: c['title']!,
                            species: species,
                          ),
                        ),
                      );
                      break;

                    case 'resultados':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsPage(species: species),
                        ),
                      );
                      break;

                    case 'about':
                      _showAboutMenu(context);
                      break;

                    case 'save':
                      _showSavedDialog(context);
                      break;

                    case 'saved':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsPage(species: species),
                        ),
                      );
                      break;
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Icon _getIcon(String code) {
    switch (code) {
      case 'recursos':
        return const Icon(Icons.home_repair_service);
      case 'animal':
        return const Icon(Icons.pets);
      case 'gestion':
        return const Icon(Icons.settings_suggest);
      case 'resultados':
        return const Icon(Icons.assessment);
      case 'about':
        return const Icon(Icons.picture_as_pdf);
      case 'save':
        return const Icon(Icons.save_alt);
      case 'saved':
        return const Icon(Icons.history);
      default:
        return const Icon(Icons.circle);
    }
  }

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
                      'https://www.ica.gov.co/getattachment/Areas/Pecuaria/Servicios/Inocuidad-en-las-Cadenas-Agroalimentarias/Bienestar-Animal/Metodologia-EBA-Porcinos-3-0-pdf_N22.pdf.aspx?lang=es-CO');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Resolución ICA 0254 de 2024'),
                onTap: () {
                  Navigator.pop(context);
                  _openPDF(
                      'https://www.ica.gov.co/getattachment/Normatividad/Resoluciones-ICA/2024/Resolucion-0254-2024.pdf.aspx');
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

  void _showSavedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambios guardados'),
        content:
            const Text('Se han guardado todos los resultados correctamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          )
        ],
      ),
    );
  }
}
