// lib/screens/resultados_screen.dart
// -----------------------------------------------------------------------------
// PANTALLA EDITORIAL DE RESULTADOS · SIBA
// Consolidación de rúbricas de campo bajo Resolución 136 y 253 de 2020
// Exportación a Excel (.xlsx) y sincronización con Supabase Cloud
// -----------------------------------------------------------------------------

import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../services/supabase_sync_service.dart';
import 'export_service.dart';

class ResultadosScreen extends StatefulWidget {
  final String? species;

  const ResultadosScreen({super.key, this.species});

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  List<Map<String, dynamic>> resultados = [];
  bool _isLoading = true;
  bool _isExporting = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadResults().then((_) {
      _syncWithCloud(silent: true);
    });
  }

  Future<void> _syncWithCloud({bool silent = false}) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF263F30),
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Subiendo auditoría y fotos a Supabase...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final res = await SupabaseSyncService.instance.syncPendingData(forceAll: true);
      if (mounted) {
        final isOk = res['status'] == 'complete' || (res['status'] == 'ok' && (res['synced'] ?? 0) > 0);
        if (!silent || isOk) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: isOk ? const Color(0xFF263F30) : const Color(0xFFB96E4B),
              content: Text(
                isOk
                    ? '✅ ¡Auditoría subida a Supabase! (${res['synced']} indicadores sincronizados). Ya visible en Vercel.'
                    : (res['message'] ?? 'Modo fuera de línea. Guardado en SQLite.'),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB96E4B),
            content: Text('Error al sincronizar: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final all = await DatabaseHelper.instance.getAllResponses();

    final filtered = widget.species == null
        ? all
        : all.where((e) {
            if (e['species'] == null) return false;
            final dbSp = e['species'].toString().toLowerCase();
            final filterSp = widget.species!.toLowerCase();
            return dbSp == filterSp || dbSp.contains(filterSp) || filterSp.contains(dbSp);
          }).toList();

    setState(() {
      resultados = filtered;
      _isLoading = false;
    });
  }

  double _promedio() {
    if (resultados.isEmpty) return 0;
    final total = resultados.fold<double>(0, (sum, e) => sum + (e['score'] ?? 0));
    return total / resultados.length;
  }

  Map<String, dynamic> _interpretacion(double p) {
    if (p >= 80) {
      return {
        'txt': 'Excelente (Cumplimiento Sobresaliente)',
        'color': const Color(0xFF263F30),
        'bg': const Color(0xFFEBF4EC),
        'border': const Color(0xFFC4DFC8),
      };
    }
    if (p >= 60) {
      return {
        'txt': 'Bueno (Cumplimiento Aceptable)',
        'color': const Color(0xFF5B6B1E),
        'bg': const Color(0xFFF5F7EB),
        'border': const Color(0xFFDCE3BE),
      };
    }
    if (p >= 40) {
      return {
        'txt': 'Regular (Requiere Acciones Correctivas)',
        'color': const Color(0xFF8F5310),
        'bg': const Color(0xFFFDF4E7),
        'border': const Color(0xFFF3D2A7),
      };
    }
    return {
      'txt': 'Crítico (Alerta Sanitaria Inmediata)',
      'color': const Color(0xFF9E3725),
      'bg': const Color(0xFFFAF0EE),
      'border': const Color(0xFFEBC3BC),
    };
  }

  Future<void> _exportExcel() async {
    setState(() => _isExporting = true);
    try {
      final speciesToExport = widget.species ?? 'general';
      final path = await ExportService.exportToExcel(speciesToExport);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF263F30),
            content: Text('✅ Sábana Excel generada exitosamente en:\n$path'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB96E4B),
            content: Text('Error exportando Excel: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promedio = _promedio();
    final interp = _interpretacion(promedio);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF263F30),
        elevation: 0,
        title: const Text(
          "Resultados de Auditoría",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Sincronizar con Supabase Cloud',
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
            onPressed: _isSyncing ? null : () => _syncWithCloud(silent: false),
          ),
          IconButton(
            tooltip: 'Exportar a Excel',
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _isExporting ? null : _exportExcel,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF263F30)))
          : resultados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE8ECE6)),
                        ),
                        child: const Icon(Icons.assignment_outlined, size: 40, color: Color(0xFF7A8279)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Sin auditorías guardadas aún",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF263F30)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Las evaluaciones realizadas en campo aparecerán aquí.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF7A8279)),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tarjeta Editorial de Índice Global
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8ECE6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Índice Global IGBA",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7A8279),
                                  letterSpacing: 0.5,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: interp['bg'],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: interp['border']),
                                ),
                                child: Text(
                                  interp['txt'].toString().split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: interp['color'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                promedio.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF263F30),
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "/ 100 puntos",
                                style: TextStyle(fontSize: 14, color: Color(0xFF7A8279)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            interp['txt'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: interp['color'],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFE8ECE6)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${resultados.length} indicador(es) evaluados",
                                style: const TextStyle(fontSize: 11, color: Color(0xFF7A8279)),
                              ),
                              GestureDetector(
                                onTap: _exportExcel,
                                child: Row(
                                  children: const [
                                    Icon(Icons.table_chart_outlined, size: 14, color: Color(0xFF263F30)),
                                    SizedBox(width: 4),
                                    Text(
                                      "Descargar Excel",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF263F30),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Detalle de Indicadores Evaluados",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263F30),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lista de Indicadores Evaluados
                    ...resultados.map((r) {
                      final score = (r['score'] ?? 0).toDouble();
                      final hasPhoto = r['photo'] != null && r['photo'].toString().isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8ECE6)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Miniatura de foto o icono
                            Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF8F9F5),
                                border: Border.all(color: const Color(0xFFE8ECE6)),
                                image: hasPhoto
                                    ? DecorationImage(
                                        image: FileImage(File(r['photo'])),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: !hasPhoto
                                  ? const Icon(Icons.photo_camera_outlined, size: 24, color: Color(0xFF7A8279))
                                  : null,
                            ),

                            const SizedBox(width: 14),

                            // Contenido del indicador
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r['indicatorTitle'] ?? 'Indicador sin título',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF263F30),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: score >= 80
                                              ? const Color(0xFFEBF4EC)
                                              : (score >= 50 ? const Color(0xFFFDF4E7) : const Color(0xFFFAF0EE)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "${score.toInt()} pts",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: score >= 80
                                                ? const Color(0xFF235933)
                                                : (score >= 50 ? const Color(0xFF8F5310) : const Color(0xFF9E3725)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Especie: ${r['species'] ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF7A8279)),
                                  ),
                                  if (r['observaciones'] != null && r['observaciones'].toString().trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        "\"${r['observaciones']}\"",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF353A35),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF263F30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload_rounded, size: 22),
                        label: Text(
                          _isSyncing
                              ? "Subiendo auditoría a Supabase..."
                              : "☁ Sincronizar con Supabase Cloud",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: _isSyncing ? null : () => _syncWithCloud(silent: false),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        "Al sincronizar, las notas y fotos quedarán visibles en Vercel.",
                        style: TextStyle(fontSize: 11, color: Color(0xFF7A8279)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }
}
