import 'package:flutter/material.dart';
import 'package:frutiapp_web/service/access_log_service.dart';
import 'package:file_selector/file_selector.dart';

import 'dart:convert';

import 'package:web/web.dart' as web;

import 'catalog.dart';

import 'package:frutiapp_web/access_record.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Donde el Verdugo de la fruta',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  final logService = AccessLogService();

  String filtro = 'Todos';
  int get totalRegistros => logService.records.length;

  int get totalExitosos => logService.records.where((r) => r.exitoso).length;

  double get tasaExito {
    if (totalRegistros == 0) {
      return 0;
    }

    return (totalExitosos / totalRegistros) * 100;
  }

  bool recordar = false;

  void validateAccess() {
    final usuario = usuarioController.text.trim();
    final password = passwordController.text;

    final exitoso = usuario == 'admin@gmail.com' && password == '123456';

    logService.add(
      AccessRecord(
        usuario: usuario,
        fechaHora: DateTime.now(),
        exitoso: exitoso,
        origen: 'web',
      ),
    );
    setState(() {});

    if (exitoso) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Acceso autorizado')));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Catalog()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
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
      final contenido = await file.readAsString();

      logService.importJson(contenido);

      setState(() {});
    } on FormatException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('JSON inválido: ${e.message}')));
    } catch (_) {
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
    final data = registrosFiltrados.map((r) => r.toJson()).toList();

    final contenido = const JsonEncoder.withIndent(' ').convert(data);

    String nombreArchivo;

    if (filtro == 'Exitosos') {
      nombreArchivo = 'bitacora_accesos_exitosos.json';
    } else if (filtro == 'Fallidos') {
      nombreArchivo = 'bitacora_accesos_fallidos.json';
    } else {
      nombreArchivo = 'bitacora_accesos_todos.json';
    }

    downloadJson(contenido, nombreArchivo);
  }

  List<AccessRecord> get registrosFiltrados {
    if (filtro == 'Exitosos') {
      return logService.records.where((r) => r.exitoso).toList();
    }

    if (filtro == 'Fallidos') {
      return logService.records.where((r) => !r.exitoso).toList();
    }

    return logService.records;
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donde el Verdugo de la fruta')),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),

            child: Form(
              key: _formKey,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bienvenido a Donde el Verdugo de la fruta',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: usuarioController,

                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      hintText: 'Ingrese su usuario',
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su usuario';
                      }

                      if (!value.contains('@')) {
                        return 'Por favor ingrese un usuario válido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: passwordController,

                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingrese su contraseña',
                      border: OutlineInputBorder(),
                    ),

                    obscureText: true,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }

                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: recordar,

                        onChanged: (value) {
                          setState(() {
                            recordar = value ?? false;
                          });
                        },
                      ),

                      const Text('Recordarme'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          validateAccess();
                        }
                      },

                      child: const Text('Ingresar'),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Bitácora de accesos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: filtro,
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'Exitosos',
                        child: Text('Exitosos'),
                      ),
                      DropdownMenuItem(
                        value: 'Fallidos',
                        child: Text('Fallidos'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        filtro = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  Text('Total de accesos: $totalRegistros'),

                  Text(
                    'Tasa de accesos exitosos: ${tasaExito.toStringAsFixed(1)}%',
                  ),

                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: registrosFiltrados.length,
                    itemBuilder: (context, index) {
                      final r = registrosFiltrados[index];

                      return ListTile(
                        leading: Icon(
                          r.exitoso ? Icons.check_circle : Icons.cancel,
                        ),
                        title: Text(
                          r.usuario.isEmpty ? '(sin usuario)' : r.usuario,
                        ),
                        subtitle: Text(r.fechaHora.toString()),
                        trailing: Text(r.exitoso ? 'OK' : 'FALLÓ'),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
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
          ),
        ),
      ),
    );
  }
}
