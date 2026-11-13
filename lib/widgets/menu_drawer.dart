// lib/widgets/menu_drawer.dart
// -----------------------------------------------------------------------------
// DRAWER OFICIAL SIBA - SISTEMA DE BIENESTAR ANIMAL (UFPSO)
// -----------------------------------------------------------------------------
// Incluye:
// - Navegación por categorías de la Resolución 136 de 2020.
// - Acceso directo a documentos normativos oficiales con URLs reales del ICA y MinAgricultura.
// - Botón de sincronización offline-first con Supabase.
// - Enlace al Panel Web de Administración en Vercel.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/indicator_list.dart';
import '../screens/resultados_screen.dart';
import '../services/supabase_sync_service.dart';

class MenuDrawer extends StatelessWidget {
  final String species;

  MenuDrawer({super.key, required this.species});

  // Lista de secciones del menú
  final List<Map<String, String>> categories = [
    {'title': 'Recursos y Alojamiento', 'code': 'recursos'},
    {'title': 'Salud y Condición Animal', 'code': 'animal'},
    {'title': 'Gestión y Bioseguridad', 'code': 'gestion'},
    {'title': 'Resultados e Índices', 'code': 'resultados'},
    {'title': 'Ver Evaluaciones Guardadas', 'code': 'saved'},
    {'title': 'Sincronizar con Nube (Supabase)', 'code': 'sync'},
    {'title': 'Documentos Oficiales ICA / MADR', 'code': 'normativa'},
    {'title': 'Panel Web Administrador (Vercel)', 'code': 'admin_web'},
  ];

  Future<void> _openURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('No se pudo abrir la URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      surfaceTintColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header institucional moderno
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004D40), Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          species.toLowerCase().contains('ave') ? '🐔' : '🐷',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'SIBA · Bienestar Animal',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Granja Experimental UFPSO',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Res. 136 de 2020 · Metodología ICA',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de opciones
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: categories.map((c) {
                  return ListTile(
                    dense: true,
                    leading: _getIcon(c['code']!),
                    title: Text(
                      c['title']!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

                        case 'sync':
                          _triggerSync(context);
                          break;

                        case 'normativa':
                          _showNormativaModal(context);
                          break;

                        case 'admin_web':
                          // Abre el panel administrativo web en el navegador
                          _openURL('https://siba-admin-ufpso.vercel.app');
                          break;
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            // Pie institucional
            Container(
              padding: const EdgeInsets.all(12),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'UFPSO · GRIITEM · 2026',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getIcon(String code) {
    switch (code) {
      case 'recursos':
        return const Icon(Icons.home_repair_service_rounded, color: Color(0xFF00897B));
      case 'animal':
        return const Icon(Icons.pets_rounded, color: Colors.orange);
      case 'gestion':
        return const Icon(Icons.shield_outlined, color: Colors.indigo);
      case 'resultados':
        return const Icon(Icons.analytics_rounded, color: Colors.teal);
      case 'saved':
        return const Icon(Icons.folder_shared_rounded, color: Colors.deepPurple);
      case 'sync':
        return const Icon(Icons.cloud_sync_rounded, color: Colors.blue);
      case 'normativa':
        return const Icon(Icons.menu_book_rounded, color: Colors.redAccent);
      case 'admin_web':
        return const Icon(Icons.open_in_browser_rounded, color: Color(0xFF2E7D32));
      default:
        return const Icon(Icons.circle);
    }
  }

  // Ejecuta la sincronización con Supabase y muestra retroalimentación visual
  void _triggerSync(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Sincronizando evaluaciones con la nube...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await SupabaseSyncService.instance.syncPendingData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result['status'] == 'complete' ? const Color(0xFF2E7D32) : Colors.orange.shade800,
          content: Text(
            result['status'] == 'complete'
                ? '✅ Sincronización exitosa: ${result['synced']} registros subidos.'
                : '📶 Sin conexión a Internet. Los datos se guardaron localmente en SQLite.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Diálogo con las URLs OFICIALES y reales de la normativa colombiana
  void _showNormativaModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('Normativa Oficial ICA / MADR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPdfItem(
                  title: 'Resolución 136 de 2020 (MADR)',
                  subtitle: 'Manual de Bienestar en Porcinos y Especies Mayores',
                  url: 'https://www.minagricultura.gov.co/Normatividad/Resoluciones/Resoluci%C3%B3n%20No.%20000136%20de%202020.pdf',
                  context: context,
                ),
                const Divider(),
                _buildPdfItem(
                  title: 'Metodología EBA Porcinos 3.0 (ICA)',
                  subtitle: 'Instrumento oficial de evaluación en granja',
                  url: 'https://www.ica.gov.co/noticias/ica-metodologia-evaluacion-bienestar-porcino',
                  context: context,
                ),
                const Divider(),
                _buildPdfItem(
                  title: 'Resolución 253 de 2020 (MADR)',
                  subtitle: 'Manual de Bienestar en Aves de Postura',
                  url: 'https://www.minagricultura.gov.co/Normatividad/Resoluciones/Resoluci%C3%B3n%20No.%20000253%20de%202020.pdf',
                  context: context,
                ),
                const Divider(),
                _buildPdfItem(
                  title: 'Cartilla de Bienestar en Aves (Fenavi / ICA)',
                  subtitle: 'Guía técnica de alojamiento y confort avícola',
                  url: 'https://fenavi.org/wp-content/uploads/2021/03/Cartilla-Bienestar-Animal-Aves-Postura.pdf',
                  context: context,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPdfItem({
    required String title,
    required String subtitle,
    required String url,
    required BuildContext context,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(Icons.file_open_rounded, color: Colors.redAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.teal),
      onTap: () {
        Navigator.pop(context);
        _openURL(url);
      },
    );
  }
}
