import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Catalog extends StatefulWidget {
  const Catalog({super.key});

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  late Future<List<dynamic>> productos;

  final List<Map<String, dynamic>> frutas = [
    {
      'nombre': 'Manzana',
      'icono': FontAwesomeIcons.appleWhole,
    },
    {
      'nombre': 'Banano',
      'icono': FontAwesomeIcons.seedling,
    },
    {
      'nombre': 'Piña',
      'icono': FontAwesomeIcons.leaf,
    },
    {
      'nombre': 'Mango',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Papaya',
      'icono': FontAwesomeIcons.seedling,
    },
    {
      'nombre': 'Sandía',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Melón',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Naranja',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Mandarina',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Limón',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Fresa',
      'icono': FontAwesomeIcons.seedling,
    },
    {
      'nombre': 'Uva',
      'icono': FontAwesomeIcons.seedling,
    },
    {
      'nombre': 'Pera',
      'icono': FontAwesomeIcons.appleWhole,
    },
    {
      'nombre': 'Kiwi',
      'icono': FontAwesomeIcons.lemon,
    },
    {
      'nombre': 'Coco',
      'icono': FontAwesomeIcons.seedling,
    },
  ];

  @override
  void initState() {
    super.initState();
    productos = cargarProductos();
  }

  Future<List<dynamic>> cargarProductos() async {
    final response = await http.get(
      Uri.parse(
        'https://jsonplaceholder.typicode.com/posts',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('No se pudo cargar la información');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Frutas',
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<List<dynamic>>(
        future: productos,

        builder: (context, snapshot) {
          // Mientras se cargan los datos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Si ocurre un error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar la información.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            );
          }

          // Datos recibidos correctamente
          final listaProductos = snapshot.data!;

          final cantidadProductos =
              listaProductos.length < frutas.length
                  ? listaProductos.length
                  : frutas.length;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: cantidadProductos,

            itemBuilder: (context, index) {
              final producto = listaProductos[index];

              final int id = producto['id'];

              final String nombre =
                  frutas[index]['nombre'];

              final FaIconData icono = frutas[index]['icono'];

              final int precio = id * 500;

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(10),

                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,

                      child: FaIcon(
                        icono,
                        size: 25,
                      ),
                    ),

                    title: Text(
                      nombre,

                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),

                      child: Text(
                        'Precio: ₡$precio',

                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    trailing: const FaIcon(
                      FontAwesomeIcons.basketShopping,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}