import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../auth/data/models/user.dart';
import '../providers/aliado_providers.dart';

class DistribuidoresListScreen extends ConsumerStatefulWidget {
  const DistribuidoresListScreen({super.key});

  @override
  ConsumerState<DistribuidoresListScreen> createState() =>
      _DistribuidoresListScreenState();
}

class _DistribuidoresListScreenState
    extends ConsumerState<DistribuidoresListScreen> {
  final _searchCtrl = TextEditingController();
  final _debounce = _Debouncer();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(distribuidoresListProvider);
    final hPad = Responsive.horizontalPadding(context);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPad,
                AppSpacing.md,
                hPad,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  _debounce.run(() {
                    ref.read(distribuidoresSearchProvider.notifier).state = v;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                    .read(distribuidoresSearchProvider.notifier)
                                    .state =
                                '';
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(distribuidoresListProvider),
                child: AsyncValueWidget<List<User>>(
                  value: asyncList,
                  data: (list) {
                    if (list.isEmpty) {
                      return const EmptyView(
                        icon: Icons.people_outline,
                        title: 'Sin distribuidores',
                        subtitle:
                            'Aún no tienes distribuidores asignados. Crea el primero con el botón +.',
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 100),
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => _DistribuidorCard(user: list[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        // FAB para crear
        Positioned(
          right: hPad,
          bottom: hPad,
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/aliado/usuarios/crear'),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add),
            label: const Text('Nuevo'),
          ),
        ),
      ],
    );
  }
}

class _DistribuidorCard extends StatelessWidget {
  final User user;
  const _DistribuidorCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => context.push('/aliado/usuarios/${user.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nombreCompleto,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Debouncer {
  DateTime? _last;
  void run(
    VoidCallback fn, {
    Duration delay = const Duration(milliseconds: 400),
  }) {
    _last = DateTime.now();
    final callTime = _last;
    Future.delayed(delay, () {
      if (_last == callTime) fn();
    });
  }

  void dispose() {}
}
