import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickmarket/core/constants/app_strings.dart';
import 'package:quickmarket/core/errors/failures.dart';
import 'package:quickmarket/domain/entities/user_role.dart';
import 'package:quickmarket/presentation/providers/di_providers.dart';
import 'package:quickmarket/presentation/providers/session_providers.dart';

/// Perfil, rol demo y cierre de sesión.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  bool _loading = false;
  String? _loadedForUserId;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: profileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Cargando perfil...'),
            );
          }
          if (_loadedForUserId != user.id) {
            _name.text = user.displayName;
            _phone.text = user.phone ?? '';
            _city.text = user.city ?? '';
            _loadedForUserId = user.id;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text(AppStrings.notificationsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/notifications'),
              ),
              const Divider(),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre visible',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _city,
                decoration: const InputDecoration(
                  labelText: 'Ciudad (tiendas cercanas)',
                  hintText: 'Ej: Bogotá',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        try {
                          await ref
                              .read(updateUserProfileUseCaseProvider)
                              .call(
                                uid: user.id,
                                displayName: _name.text,
                                phone: _phone.text,
                                city: _city.text.trim().isEmpty
                                    ? null
                                    : _city.text.trim(),
                              );
                          if (context.mounted) {
                            setState(() => _loadedForUserId = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil actualizado')),
                            );
                          }
                        } on Failure catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message)),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: const Text('Guardar cambios'),
              ),
              const SizedBox(height: 24),
              Text(
                'Rol actual: ${user.role.name}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (!user.isDriver)
                OutlinedButton.icon(
                  onPressed: () async {
                    setState(() => _loading = true);
                    try {
                      await ref.read(authRepositoryProvider).updateRole(
                            uid: user.id,
                            role: UserRole.driver,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Modo repartidor activado. Ve a la pestaña Reparto.',
                            ),
                          ),
                        );
                      }
                    } on Failure catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('Activar modo repartidor (demo)'),
                ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await ref.read(signOutUseCaseProvider).call();
                        if (context.mounted) context.go('/login');
                      },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
              const SizedBox(height: 8),
              Text(
                'UID: ${FirebaseAuth.instance.currentUser?.uid ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
