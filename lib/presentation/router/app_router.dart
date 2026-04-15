import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/domain/entities/store_entity.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';
import 'package:quickmarket/presentation/router/go_router_refresh.dart';
import 'package:quickmarket/presentation/screens/auth/login_screen.dart';
import 'package:quickmarket/presentation/screens/auth/register_screen.dart';
import 'package:quickmarket/presentation/screens/catalog/product_detail_args.dart';
import 'package:quickmarket/presentation/screens/catalog/product_detail_screen.dart';
import 'package:quickmarket/presentation/screens/catalog/search_screen.dart';
import 'package:quickmarket/presentation/screens/catalog/store_detail_screen.dart';
import 'package:quickmarket/presentation/screens/checkout/cart_screen.dart';
import 'package:quickmarket/presentation/screens/checkout/checkout_screen.dart';
import 'package:quickmarket/presentation/screens/home/home_screen.dart';
import 'package:quickmarket/presentation/screens/notifications/notifications_screen.dart';
import 'package:quickmarket/presentation/screens/orders/order_confirmation_screen.dart';
import 'package:quickmarket/presentation/screens/orders/order_detail_screen.dart';
import 'package:quickmarket/presentation/screens/splash/splash_screen.dart';

/// Configuración central de rutas (GoRouter + Riverpod).
final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final refresh = GoRouterRefreshStream(authRepo.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final loc = state.matchedLocation;
      final user = FirebaseAuth.instance.currentUser;
      final isPublic =
          loc == '/splash' || loc == '/login' || loc == '/register';
      if (user == null && !isPublic) {
        return '/login';
      }
      if (user != null && (loc == '/login' || loc == '/register')) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/store/:storeId',
        builder: (context, state) {
          final id = state.pathParameters['storeId']!;
          final extra = state.extra is StoreEntity ? state.extra! as StoreEntity : null;
          return StoreDetailScreen(storeId: id, initialStore: extra);
        },
      ),
      GoRoute(
        path: '/product/:storeId/:productId',
        builder: (context, state) {
          final sid = state.pathParameters['storeId']!;
          final pid = state.pathParameters['productId']!;
          final args = state.extra is ProductDetailArgs
              ? state.extra! as ProductDetailArgs
              : null;
          return ProductDetailScreen(
            storeId: sid,
            productId: pid,
            args: args,
          );
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/confirmation/:orderId',
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderConfirmationScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/orders/tracking/:orderId',
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
