// lib/widgets/menu_drawer.dart
// -----------------------------------------------------------------------------
// DRAWER EDITORIAL SIBA - SISTEMA DE BIENESTAR ANIMAL (UFPSO)
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/indicator_list.dart';
import '../screens/resultados_screen.dart';
import '../services/supabase_sync_service.dart';

class MenuDrawer extends StatelessWidget {
  final String species;

  MenuDrawer({super.key, required this.species});

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
      debugPrint('No se pudo abrir la URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8F9F5),
      child: SafeArea(
        child: Column(
          children: [
            // Header institucional editorial
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF263F30), // Verde bosque profundo
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/icono.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            species.toLowerCase().contains('ave') ? '🐔' : '🐷',
                            style: const TextStyle(fontSize: 22),
                          ),
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
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'Granja Experimental UFPSO',
                              style: TextStyle(
                                color: Color(0xFF8BA77B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      species.toLowerCase().contains('ave')
                          ? 'Módulo Aves · Resolución 253/2020'
                          : 'Módulo Porcinos · Resolución 136/2020',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF353A35),
                      ),
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
                              builder: (_) => const ResultadosScreen(),
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
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE8ECE6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'UFPSO · GRIITEM · 2026',
                    style: TextStyle(fontSize: 11, color: Color(0xFF7A8279), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(String code) {
    switch (code) {
      case 'recursos':
        return const Icon(Icons.home_repair_service_outlined, color: Color(0xFF263F30), size: 20);
      case 'animal':
        return const Icon(Icons.pets_outlined, color: Color(0xFF496B4D), size: 20);
      case 'gestion':
        return const Icon(Icons.shield_outlined, color: Color(0xFF263F30), size: 20);
      case 'resultados':
        return const Icon(Icons.analytics_outlined, color: Color(0xFF496B4D), size: 20);
      case 'saved':
        return const Icon(Icons.folder_open_outlined, color: Color(0xFF263F30), size: 20);
      case 'sync':
        return const Icon(Icons.cloud_sync_outlined, color: Color(0xFF496B4D), size: 20);
      case 'normativa':
        return const Icon(Icons.menu_book_outlined, color: Color(0xFFB96E4B), size: 20);
      case 'admin_web':
        return const Icon(Icons.open_in_browser_rounded, color: Color(0xFF263F30), size: 20);
      default:
        return const Icon(Icons.circle, size: 20);
    }
  }

  void _triggerSync(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
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
          backgroundColor: result['status'] == 'complete'
              ? const Color(0xFF263F30)
              : const Color(0xFFB96E4B),
          content: Text(
            result['status'] == 'complete'
                ? '✅ Sincronización exitosa: ${result['synced']} registros subidos.'
                : '📶 Sin conexión. Registros resguardados en SQLite local.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showNormativaModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.menu_book_rounded, color: Color(0xFF263F30)),
              SizedBox(width: 8),
              Text(
                'Normativa Oficial ICA / MinAg',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF263F30)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _normativaTile(
                  icon: '🐷',
                  title: 'Resolución 136 de 2020 (MinAgricultura)',
                  subtitle: 'Manual de condiciones de bienestar animal para la especie porcina.',
                  url: 'https://www.minagricultura.gov.co/Normatividad/Resoluciones/Resoluci%C3%B3n%20No.%20000136%20de%202020.pdf',
                ),
                const Divider(height: 16, color: Color(0xFFE8ECE6)),
                _normativaTile(
                  icon: '📋',
                  title: 'Metodología EBA Porcinos 3.0 (ICA)',
                  subtitle: 'Protocolo de rúbricas para comederos, bebederos y confort en granja.',
                  url: 'https://www.ica.gov.co/noticias/ica-metodologia-evaluacion-bienestar-porcino',
                ),
                const Divider(height: 16, color: Color(0xFFE8ECE6)),
                _normativaTile(
                  icon: '🐔',
                  title: 'Resolución 253 de 2020 (Aves de Postura)',
                  subtitle: 'Directrices técnicas de bienestar para gallinas ponedoras.',
                  url: 'https://www.minagricultura.gov.co/Normatividad/Resoluciones/Resoluci%C3%B3n%20No.%20000253%20de%202020.pdf',
                ),
                const Divider(height: 16, color: Color(0xFFE8ECE6)),
                _normativaTile(
                  icon: '🥚',
                  title: 'Cartilla Fenavi & ICA (Aves de Postura)',
                  subtitle: 'Manual de nidales, bebederos y ventilación.',
                  url: 'https://fenavi.org/wp-content/uploads/2021/03/Cartilla-Bienestar-Animal-Aves-Postura.pdf',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Color(0xFF263F30), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _normativaTile({
    required String icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF263F30))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF7A8279))),
      trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF496B4D)),
      onTap: () => _openURL(url),
    );
  }
}
