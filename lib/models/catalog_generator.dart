// lib/models/catalog_generator.dart

String generateCatalogJson(int count) {
  final items = List.generate(
    count,
        (i) => '{"id":$i,"name":"Producto $i","price":${(i * 1.5).toStringAsFixed(2)}}',
  );
  return '[${items.join(',')}]';
}