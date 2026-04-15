/// Helpers para parsear valores de Firestore con tolerancia a tipos.
///
/// En Firestore Console es común insertar números como string por error
/// (ej. `"4.7"` en lugar de `4.7`). Estos parsers evitan que la UI caiga a 0
/// silenciosamente.
abstract final class FirestoreParsers {
  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static int toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static String toStringSafe(dynamic value, {String fallback = ''}) {
    if (value is String) return value;
    if (value == null) return fallback;
    return value.toString();
  }
}

