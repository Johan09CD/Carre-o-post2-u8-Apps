// lib/screens/catalog_screen.dart — versión BLOQUEANTE (para profiling)

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/catalog_generator.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  bool _loading = false;

  // ❌ parse en main thread — bloquea el UI thread durante el JSON parsing
  Future<void> _loadCatalogBlocking() async {
    setState(() => _loading = true);

    dev.Timeline.startSync('generateJson');
    final jsonString = generateCatalogJson(1000);
    dev.Timeline.finishSync();

    dev.Timeline.startSync('jsonDecode');
    final List<dynamic> raw = jsonDecode(jsonString) as List;
    dev.Timeline.finishSync();

    dev.Timeline.startSync('mapToProducts');
    final products = raw
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
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
          leading: CircleAvatar(child: Text('${_products[i].id}')),
          title: Text(_products[i].name),
          subtitle: Text('\$${_products[i].price}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCatalogBlocking,
        tooltip: 'Cargar catálogo',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}