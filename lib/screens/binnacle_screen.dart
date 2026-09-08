import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:web/web.dart' as web;
import 'package:frutiapp_web/models/access_record.dart';
import 'package:frutiapp_web/services/access_log_service.dart';

class BinnacleScreen extends StatefulWidget {
  final AccessLogService logService;

  const BinnacleScreen({super.key, required this.logService});

  @override
  State<BinnacleScreen> createState() => _BinnacleScreenState();
}

class _BinnacleScreenState extends State<BinnacleScreen> {
  String filter = 'all';

  int get totalRecords => widget.logService.records.length;

  int get totalSuccess =>
      widget.logService.records.where((r) => r.success).length;

  double get successRate {
    if (totalRecords == 0) {
      return 0;
    }
    return (totalSuccess / totalRecords) * 100;
  }

  List<AccessRecord> get filteredRecords {
    if (filter == 'Success') {
      return widget.logService.records.where((r) => r.success).toList();
    }
    if (filter == 'Failed') {
      return widget.logService.records.where((r) => !r.success).toList();
    }
    return widget.logService.records;
  }

  Future<void> importBitacora() async {
    const typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file == null) return;

    try {
      final content = await file.readAsString();

      widget.logService.importJson(content);

      setState(() {});
    } on FormatException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('JSON inválido: ${e.message}')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo leer el archivo')),
      );
    }
  }

  void downloadJson(String contenido, String nombreArchivo) {
    final base64 = base64Encode(utf8.encode(contenido));

    web.HTMLAnchorElement()
      ..href = 'data:application/json;base64,$base64'
      ..setAttribute('download', nombreArchivo)
      ..click();
  }

  void exportBitacora() {
    final data = filteredRecords.map((r) => r.toJson()).toList();

    final content = const JsonEncoder.withIndent(' ').convert(data);

    String nameFile;

    if (filter == 'Success') {
      nameFile = 'bitacora_accesos_exitosos.json';
    } else if (filter == 'Failed') {
      nameFile = 'bitacora_accesos_fallidos.json';
    } else {
      nameFile = 'bitacora_accesos_todos.json';
    }

    downloadJson(content, nameFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de accesos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: filter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Todos')),
                DropdownMenuItem(value: 'Success', child: Text('Exitosos')),
                DropdownMenuItem(value: 'Failed', child: Text('Fallidos')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  filter = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Text('Total de accesos: $totalRecords'),
            Text('Tasa de accesos exitosos: ${successRate.toStringAsFixed(1)}%'),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRecords.length,
                itemBuilder: (context, index) {
                  final r = filteredRecords[index];

                  return ListTile(
                    leading: Icon(
                      r.success ? Icons.check_circle : Icons.cancel,
                    ),
                    title: Text(r.user.isEmpty ? '(sin usuario)' : r.user),
                    subtitle: Text(r.dateTime.toString()),
                    trailing: Text(r.success ? 'OK' : 'FALLÓ'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: exportBitacora,
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar JSON'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: importBitacora,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar JSON'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}