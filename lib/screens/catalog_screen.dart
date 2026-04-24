// lib/screens/catalog_screen.dart — con Firebase Performance

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/catalog_generator.dart';

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

  Future<void> _loadCatalogWithTracing() async {
    setState(() => _loading = true);

    // Inicia traza personalizada de Firebase Performance
    final trace = FirebasePerformance.instance.newTrace('catalog_load');
    await trace.start();

    dev.Timeline.startSync('generateJson');
    final jsonString = generateCatalogJson(1000);
    dev.Timeline.finishSync();

    dev.Timeline.startSync('compute_parseProducts');
    final products = await compute(_parseProducts, jsonString);
    dev.Timeline.finishSync();

    // Agrega métrica custom a la traza
    trace.setMetric('product_count', products.length);
    await trace.stop();

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
        onPressed: _loadCatalogWithTracing,
        tooltip: 'Cargar catálogo con Firebase',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}