import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/domain/repositories/catalog_repository.dart';

/// Caso de uso: observar catálogo de tiendas en tiempo real.
class WatchStoresUseCase {
  WatchStoresUseCase(this._repository);

  final CatalogRepository _repository;

  Stream<List<StoreEntity>> call({String? city}) =>
      _repository.watchStores(city: city);
}
