import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/data/datasources/auth_remote_data_source.dart';
import 'package:quickmarket/data/datasources/firestore_catalog_data_source.dart';
import 'package:quickmarket/data/datasources/firestore_delivery_data_source.dart';
import 'package:quickmarket/data/datasources/firestore_notifications_data_source.dart';
import 'package:quickmarket/data/datasources/firestore_orders_data_source.dart';
import 'package:quickmarket/data/repositories/auth_repository_impl.dart';
import 'package:quickmarket/data/repositories/firestore_catalog_repository.dart';
import 'package:quickmarket/data/repositories/delivery_repository_impl.dart';
import 'package:quickmarket/data/repositories/notification_repository_impl.dart';
import 'package:quickmarket/data/repositories/order_repository_impl.dart';
import 'package:quickmarket/domain/repositories/auth_repository.dart';
import 'package:quickmarket/domain/repositories/catalog_repository.dart';
import 'package:quickmarket/domain/repositories/delivery_repository.dart';
import 'package:quickmarket/domain/repositories/notification_repository.dart';
import 'package:quickmarket/domain/repositories/order_repository.dart';
import 'package:quickmarket/domain/usecases/advance_delivery_status_usecase.dart';
import 'package:quickmarket/domain/usecases/assign_driver_usecase.dart';
import 'package:quickmarket/domain/usecases/get_user_profile_usecase.dart';
import 'package:quickmarket/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:quickmarket/domain/usecases/mark_notification_read_usecase.dart';
import 'package:quickmarket/domain/usecases/place_order_usecase.dart';
import 'package:quickmarket/domain/usecases/register_with_email_usecase.dart';
import 'package:quickmarket/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:quickmarket/domain/usecases/sign_out_usecase.dart';
import 'package:quickmarket/domain/usecases/update_user_profile_usecase.dart';
import 'package:quickmarket/domain/usecases/watch_stores_usecase.dart';

// --- Firebase singletons ---

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// --- Data sources ---

final firestoreNotificationsDataSourceProvider =
    Provider<FirestoreNotificationsDataSource>(
  (ref) => FirestoreNotificationsDataSource(
    ref.watch(firebaseFirestoreProvider),
  ),
);

final firestoreOrdersDataSourceProvider =
    Provider<FirestoreOrdersDataSource>(
  (ref) => FirestoreOrdersDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
    notifications: ref.watch(firestoreNotificationsDataSourceProvider),
  ),
);

final firestoreDeliveryDataSourceProvider =
    Provider<FirestoreDeliveryDataSource>(
  (ref) => FirestoreDeliveryDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
    notifications: ref.watch(firestoreNotificationsDataSourceProvider),
  ),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  ),
);

final firestoreCatalogDataSourceProvider =
    Provider<FirestoreCatalogDataSource>(
  (ref) => FirestoreCatalogDataSource(
    ref.watch(firebaseFirestoreProvider),
  ),
);

// --- Repositorios ---

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
  ),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => FirestoreCatalogRepository(
    ref.watch(firestoreCatalogDataSourceProvider),
  ),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => FirestoreOrderRepository(
    ref.watch(firestoreOrdersDataSourceProvider),
  ),
);

final deliveryRepositoryProvider = Provider<DeliveryRepository>(
  (ref) => DeliveryRepositoryImpl(
    ref.watch(firestoreDeliveryDataSourceProvider),
  ),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    ref.watch(firestoreNotificationsDataSourceProvider),
  ),
);

// --- Casos de uso ---

final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>(
  (ref) => SignInWithEmailUseCase(ref.watch(authRepositoryProvider)),
);

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmailUseCase>(
  (ref) => RegisterWithEmailUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => GetUserProfileUseCase(ref.watch(authRepositoryProvider)),
);

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>(
  (ref) => UpdateUserProfileUseCase(ref.watch(authRepositoryProvider)),
);

final watchStoresUseCaseProvider = Provider<WatchStoresUseCase>(
  (ref) => WatchStoresUseCase(ref.watch(catalogRepositoryProvider)),
);

final placeOrderUseCaseProvider = Provider<PlaceOrderUseCase>(
  (ref) => PlaceOrderUseCase(ref.watch(orderRepositoryProvider)),
);

final assignDriverUseCaseProvider = Provider<AssignDriverUseCase>(
  (ref) => AssignDriverUseCase(ref.watch(deliveryRepositoryProvider)),
);

final advanceDeliveryStatusUseCaseProvider =
    Provider<AdvanceDeliveryStatusUseCase>(
  (ref) => AdvanceDeliveryStatusUseCase(ref.watch(deliveryRepositoryProvider)),
);

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>(
  (ref) =>
      MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider)),
);

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>(
  (ref) => MarkAllNotificationsReadUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);
