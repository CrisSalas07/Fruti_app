import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:web/web.dart' as web;
import 'package:frutiapp_web/catalog.dart';
import 'package:frutiapp_web/models/access_record.dart';
import 'package:frutiapp_web/service/access_log_service.dart';
import 'package:frutiapp_web/service/preferences_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final logService = AccessLogService();
  final preferencesService = PreferencesService();

  String filter = 'all';
  int get totalRecords => logService.records.length;

  int get totalSuccess => logService.records.where((r) => r.success).length;

  double get successRate {
    if (totalRecords == 0) {
      return 0;
    }

    return (totalSuccess / totalRecords) * 100;
  }

  bool remember = false;
  bool obscurePassword = true;

  void validateAccess() {
    final user = userController.text.trim();
    final password = passwordController.text;

    final userDefault = user == 'admin@gmail.com' && password == '123456';

    logService.add(
      AccessRecord(
        user: user,
        dateTime: DateTime.now(),
        success: userDefault,
        origin: 'web',
      ),
    );
    setState(() {});

    if (userDefault) {
      if (remember) {
        preferencesService.saveUser(user);
      } else {
        preferencesService.clearUser();
      }

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
      final content = await file.readAsString();

      logService.importJson(content);

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

  List<AccessRecord> get filteredRecords {
    if (filter == 'Success') {
      return logService.records.where((r) => r.success).toList();
    }

    if (filter == 'Failed') {
      return logService.records.where((r) => !r.success).toList();
    }

    return logService.records;
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final rememberedUser = await preferencesService.loadUserRemembered();

    if (rememberedUser == null) {
      return;
    }

    setState(() {
      userController.text = rememberedUser;
      remember = true;
    });
  }

  @override
  void dispose() {
    userController.dispose();
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
                    controller: userController,

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

                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingrese su contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),

                    obscureText: obscurePassword,

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
                        value: remember,

                        onChanged: (value) {
                          setState(() {
                            remember = value ?? false;
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
                    value: filter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'Success',
                        child: Text('Exitosos'),
                      ),
                      DropdownMenuItem(
                        value: 'Failed',
                        child: Text('Fallidos'),
                      ),
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

                  Text(
                    'Tasa de accesos exitosos: ${successRate.toStringAsFixed(1)}%',
                  ),

                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final r = filteredRecords[index];

                      return ListTile(
                        leading: Icon(
                          r.success ? Icons.check_circle : Icons.cancel,
                        ),
                        title: Text(
                          r.user.isEmpty ? '(sin usuario)' : r.user,
                        ),
                        subtitle: Text(r.dateTime.toString()),
                        trailing: Text(r.success ? 'OK' : 'FALLÓ'),
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