// lib/screens/catalog_screen.dart — versión OPTIMIZADA con compute()

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/catalog_generator.dart';

// Top-level function requerida por compute() — NO puede ser método de clase
List<Product> _parseProducts(String jsonString) {
  final List<dynamic> raw = jsonDecode(jsonString) as List;
  return raw
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList();
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  bool _loading = false;

  // ✅ compute() ejecuta _parseProducts en un Isolate separado
  Future<void> _loadCatalogOptimized() async {
    setState(() => _loading = true);

    dev.Timeline.startSync('generateJson');
    final jsonString = generateCatalogJson(1000);
    dev.Timeline.finishSync();

    // El UI thread permanece libre para renderizar animaciones
    dev.Timeline.startSync('compute_parseProducts');
    final products = await compute(_parseProducts, jsonString);
    dev.Timeline.finishSync();

    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo — Unidad 8'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(
        child: Text(
          'Presiona el botón para cargar el catálogo',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (ctx, i) => ListTile(
          leading: CircleAvatar(
            child: Text('${_products[i].id}'),
          ),
          title: Text(_products[i].name),
          subtitle: Text('\$${_products[i].price}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCatalogOptimized,
        tooltip: 'Cargar catálogo optimizado',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}