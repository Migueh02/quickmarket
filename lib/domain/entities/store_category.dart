/// Categoría de negocio de la tienda (catálogo QuickMarket).
enum StoreCategory {
  food('food', 'Comida'),
  pharmacy('pharmacy', 'Farmacia'),
  supermarket('supermarket', 'Supermercado');

  const StoreCategory(this.firestoreValue, this.label);
  final String firestoreValue;
  final String label;

  static StoreCategory fromFirestore(String? raw) {
    return StoreCategory.values.firstWhere(
      (e) => e.firestoreValue == raw,
      orElse: () => StoreCategory.food,
    );
  }
}
