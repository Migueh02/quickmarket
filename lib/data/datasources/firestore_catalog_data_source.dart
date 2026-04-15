import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickmarket/core/constants/firestore_paths.dart';
import 'package:quickmarket/data/models/product_model.dart';
import 'package:quickmarket/data/models/store_model.dart';

/// Lectura del catálogo de tiendas y productos en Firestore.
class FirestoreCatalogDataSource {
  FirestoreCatalogDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<StoreModel>> watchStores({String? city}) {
    Query<Map<String, dynamic>> q =
        _firestore.collection(FirestorePaths.stores);
    if (city != null && city.trim().isNotEmpty) {
      q = q.where('city', isEqualTo: city.trim());
    }
    return q.snapshots().map((snap) {
      final list = snap.docs.map(StoreModel.fromFirestore).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  Future<({List<ProductModel> items, String? nextCursor})> fetchProductsPage({
    required String storeId,
    int limit = 20,
    String? cursorProductId,
  }) async {
    final col =
        _firestore.collection(FirestorePaths.productsCol(storeId));
    Query<Map<String, dynamic>> query = col.orderBy('name');
    if (cursorProductId != null && cursorProductId.isNotEmpty) {
      final last = await col.doc(cursorProductId).get();
      if (last.exists) {
        query = query.startAfterDocument(last);
      }
    }
    final snap = await query.limit(limit).get();
    final items = snap.docs
        .map((d) => ProductModel.fromFirestore(d, storeId: storeId))
        .toList();
    final hasMore = snap.docs.length == limit;
    final next = hasMore ? snap.docs.last.id : null;
    return (items: items, nextCursor: next);
  }

  Future<List<ProductModel>> searchProducts({
    required String query,
    String? city,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    Query<Map<String, dynamic>> sq =
        _firestore.collection(FirestorePaths.stores);
    if (city != null && city.trim().isNotEmpty) {
      sq = sq.where('city', isEqualTo: city.trim());
    }
    final storeSnaps = await sq.get();
    final futures = storeSnaps.docs.map((doc) async {
      final sid = doc.id;
      final snap = await _firestore
          .collection(FirestorePaths.productsCol(sid))
          .limit(100)
          .get();
      return snap.docs
          .map((d) => ProductModel.fromFirestore(d, storeId: sid))
          .toList();
    });
    final chunks = await Future.wait(futures);
    final merged = <ProductModel>[];
    for (final chunk in chunks) {
      for (final m in chunk) {
        if (m.name.toLowerCase().contains(q) ||
            m.subcategory.toLowerCase().contains(q)) {
          merged.add(m);
        }
      }
    }
    merged.sort((a, b) => a.name.compareTo(b.name));
    return merged.take(120).toList();
  }
}
