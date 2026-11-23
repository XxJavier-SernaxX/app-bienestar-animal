// lib/screens/species_selection.dart
// -----------------------------------------------------------------------------
// SELECCIÓN EDITORIAL DE LÍNEA PRODUCTIVA · SIBA
// Porcinos (Res. 136/2020) & Aves de Postura (Res. 253/2020)
// Granja Experimental UFPSO
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/menu_drawer.dart';
import '../services/supabase_sync_service.dart';
import '../helpers/database_helper.dart';

class SpeciesSelectionPage extends StatefulWidget {
  const SpeciesSelectionPage({super.key});

  @override
  State<SpeciesSelectionPage> createState() => _SpeciesSelectionPageState();
}

class _SpeciesSelectionPageState extends State<SpeciesSelectionPage> {
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    _checkPendingSync();
  }

  Future<void> _checkPendingSync() async {
    try {
      final pending = await DatabaseHelper.instance.getPendingToSync();
      if (mounted) {
        setState(() {
          _pendingSyncCount = pending.length;
        });
      }
    } catch (_) {}
  }

  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'Evaluador UFPSO';
    final code = prefs.getString('userCode') ?? '0000000';
    String date = prefs.getString('selectedDate') ?? '';

    if (date.isEmpty) {
      final now = DateTime.now();
      date =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      await prefs.setString('selectedDate', date);
    }

    return {'name': name, 'code': code, 'date': date};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9F5),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF263F30)),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9F5),
          drawer: MenuDrawer(species: 'General'),
          appBar: AppBar(
            backgroundColor: const Color(0xFF263F30),
            elevation: 0,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                tooltip: 'Menú principal',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: const Text(
              "Línea de Producción",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Sincronizar SQLite con Nube',
                icon: Stack(
                  children: [
                    const Icon(Icons.cloud_sync_outlined, color: Colors.white),
                    if (_pendingSyncCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB96E4B),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Text(
                            '$_pendingSyncCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comprobando conexión y sincronizando...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  final res = await SupabaseSyncService.instance.syncPendingData();
                  await _checkPendingSync();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: res['status'] == 'complete'
                            ? const Color(0xFF263F30)
                            : const Color(0xFFB96E4B),
                        content: Text(
                          res['status'] == 'complete'
                              ? '✅ Sincronizado: ${res['synced']} registros en la nube.'
                              : '📶 Sin conexión. Registros resguardados en SQLite local.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          body: Column(
            children: [
              // Franja Editorial del Evaluador Activo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE8ECE6))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF496B4D),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "Granja Experimental UFPSO",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A8279),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user['name']!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263F30),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Fecha de campo",
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                        Text(
                          user['date']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF353A35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de las Dos Especies Oficiales
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      "Selecciona la especie a evaluar:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A8279),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ---------------- TARJETA PORCINOS ----------------
                    _EditorialSpeciesCard(
                      imagePath: 'assets/porcino1.jpg',
                      speciesName: 'Porcinos',
                      subtitle: 'Ceba, Gestación y Maternidad',
                      normativeTag: 'Resolución 136 de 2020',
                      indicatorsCount: '37 Indicadores · EBA Porcinos 3.0',
                      primaryColor: const Color(0xFF263F30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                title: const Text("Bienestar Porcino · UFPSO", style: TextStyle(color: Colors.white, fontSize: 16)),
                                backgroundColor: const Color(0xFF263F30),
                                leading: Builder(
                                  builder: (ctx) => IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                    tooltip: 'Regresar a selección de especie',
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ),
                                actions: [
                                  Builder(
                                    builder: (ctx) => IconButton(
                                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                                      tooltip: 'Menú de auditoría',
                                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                                    ),
                                  ),
                                ],
                              ),
                              drawer: MenuDrawer(species: 'Porcinos'),
                              body: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Image.asset(
                                      'assets/porcino1.jpg',
                                      height: 220,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF496B4D).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Resolución 136 de 2020 · ICA',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF263F30),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Auditoría de Bienestar Porcino",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF263F30),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Evalúa comederos tolva, flujo en chupones a 45°, condición corporal, confort térmico y registros sanitarios.",
                                            style: TextStyle(fontSize: 14, color: Color(0xFF353A35), height: 1.4),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: Builder(
                                              builder: (bContext) => ElevatedButton.icon(
                                                icon: const Icon(Icons.assignment_outlined),
                                                label: const Text("Abrir Menú de Auditoría ☰"),
                                                onPressed: () {
                                                  Scaffold.of(bContext).openDrawer();
                                                },
                                              ),
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
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ---------------- TARJETA AVES DE POSTURA ----------------
                    _EditorialSpeciesCard(
                      imagePath: 'assets/aves1.png',
                      speciesName: 'Aves de Postura',
                      subtitle: 'Gallinas ponedoras en piso / pastoreo',
                      normativeTag: 'Resolución 253 de 2020',
                      indicatorsCount: '25 Indicadores · Fenavi & ICA',
                      primaryColor: const Color(0xFF496B4D),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                title: const Text("Bienestar Avícola · UFPSO", style: TextStyle(color: Colors.white, fontSize: 16)),
                                backgroundColor: const Color(0xFF263F30),
                                leading: Builder(
                                  builder: (ctx) => IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                    tooltip: 'Regresar a selección de especie',
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ),
                                actions: [
                                  Builder(
                                    builder: (ctx) => IconButton(
                                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                                      tooltip: 'Menú de auditoría',
                                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                                    ),
                                  ),
                                ],
                              ),
                              drawer: MenuDrawer(species: 'Aves de Postura'),
                              body: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Image.asset(
                                      'assets/aves1.png',
                                      height: 220,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 220,
                                        color: const Color(0xFFE8ECE6),
                                        child: const Icon(Icons.egg_outlined, size: 60, color: Color(0xFF496B4D)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB96E4B).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Resolución 253 de 2020 · Fenavi',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB96E4B),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Auditoría de Aves de Postura",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF263F30),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Evalúa disponibilidad de nidales (1/5 aves), líneas de niple con copa, estado del plumaje, calidad de cama y ventilación.",
                                            style: TextStyle(fontSize: 14, color: Color(0xFF353A35), height: 1.4),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: Builder(
                                              builder: (bContext) => ElevatedButton.icon(
                                                icon: const Icon(Icons.assignment_outlined),
                                                label: const Text("Abrir Menú de Auditoría ☰"),
                                                onPressed: () {
                                                  Scaffold.of(bContext).openDrawer();
                                                },
                                              ),
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
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // Tarjeta Informativa de Sincronización
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8ECE6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF496B4D).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shield_outlined, color: Color(0xFF263F30), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Auditoría Digital Certificada",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF263F30)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _pendingSyncCount > 0
                                      ? "$_pendingSyncCount evaluación(es) pendiente(s) de sincronizar."
                                      : "Toda la base local está respaldada y al día.",
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF7A8279)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditorialSpeciesCard extends StatelessWidget {
  final String imagePath;
  final String speciesName;
  final String subtitle;
  final String normativeTag;
  final String indicatorsCount;
  final Color primaryColor;
  final VoidCallback onTap;

  const _EditorialSpeciesCard({
    required this.imagePath,
    required this.speciesName,
    required this.subtitle,
    required this.normativeTag,
    required this.indicatorsCount,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen Fotográfica
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE8ECE6),
                      child: Icon(Icons.pets, size: 50, color: primaryColor),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        normativeTag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido Editorial
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speciesName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: Color(0xFF263F30),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF7A8279)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          indicatorsCount,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8ECE6)),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF263F30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
