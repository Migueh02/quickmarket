import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/presentation/providers/catalog_providers.dart';
import 'package:quickmarket/presentation/screens/catalog/catalog_home_screen.dart';
import 'package:quickmarket/presentation/screens/driver/driver_screen.dart';
import 'package:quickmarket/presentation/screens/orders/order_history_screen.dart';
import 'package:quickmarket/presentation/screens/profile/profile_screen.dart';
import 'package:quickmarket/presentation/providers/session_providers.dart';

/// Contenedor principal con navegación inferior (Material 3).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabIndexProvider);
    final isDriver = ref.watch(userProfileProvider).value?.isDriver ?? false;

    final pages = <Widget>[
      const CatalogHomeScreen(),
      const OrderHistoryScreen(),
      if (isDriver) const DriverScreen() else const _DriverLockedTab(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index.clamp(0, pages.length - 1),
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index.clamp(0, pages.length - 1),
        onDestinationSelected: (i) {
          ref.read(shellTabIndexProvider.notifier).state = i;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Tiendas',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.delivery_dining_outlined),
            selectedIcon: Icon(Icons.delivery_dining),
            label: 'Reparto',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Invita a activar el rol repartidor desde Perfil.
class _DriverLockedTab extends StatelessWidget {
  const _DriverLockedTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              AppStrings.driverTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ve a Perfil y pulsa "Activar modo repartidor (demo)" '
              'para acceder al tablero de entregas.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
