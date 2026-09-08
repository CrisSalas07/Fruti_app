import 'package:flutter/material.dart';
import 'package:frutiapp_web/catalog.dart';
import 'package:frutiapp_web/models/access_record.dart';
import 'package:frutiapp_web/services/access_log_service.dart';
import 'package:frutiapp_web/services/preferences_service.dart';
import 'package:frutiapp_web/screens/binnacle_screen.dart';

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

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BinnacleScreen(logService: logService),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver bitácora'),
                    ),
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
