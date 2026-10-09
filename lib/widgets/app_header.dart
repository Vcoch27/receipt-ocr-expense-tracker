import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../main.dart';
import '../services/expense_database.dart';
import '../state/expense_providers.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(localeProvider).languageCode.toUpperCase();
    return AppBar(
      toolbarHeight: 68,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/brand/receipt-mark.png', width: 38, height: 38),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<Locale>(
          tooltip: context.l10n.language,
          icon: Text(
            language,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          onSelected: (locale) =>
              ref.read(localeProvider.notifier).state = locale,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: const Locale('vi'),
              child: Text(context.l10n.vietnamese),
            ),
            PopupMenuItem(
              value: const Locale('en'),
              child: Text(context.l10n.english),
            ),
          ],
        ),
        PopupMenuButton<ThemeMode>(
          tooltip: context.l10n.appearance,
          icon: const Icon(Icons.brightness_6_outlined),
          onSelected: (mode) =>
              ref.read(themeModeProvider.notifier).state = mode,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: ThemeMode.system,
              child: Text(context.l10n.systemTheme),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: Text(context.l10n.lightMode),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Text(context.l10n.darkMode),
            ),
          ],
        ),
        PopupMenuButton<String>(
          tooltip: 'Dữ liệu demo',
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            final repo = ref.read(expenseRepositoryProvider);
            if (repo is ExpenseDatabase) {
              if (value == 'seed') {
                await repo.seedDemoData();
                ref.invalidate(expensesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã nạp đầy đủ dữ liệu demo!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else if (value == 'clear') {
                await repo.clearAll();
                ref.invalidate(expensesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa dữ liệu!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'seed',
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Nạp dữ liệu demo'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Xóa tất cả'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
