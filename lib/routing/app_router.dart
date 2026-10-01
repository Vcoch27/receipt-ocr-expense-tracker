import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/expense_item.dart';
import '../models/parsed_expense.dart';
import '../l10n/l10n.dart';
import '../screens/analytics_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/expense_detail_screen.dart';
import '../screens/expense_history_screen.dart';
import '../screens/review_screen.dart';
import '../screens/scanner_screen.dart';

class ReviewArgs {
  const ReviewArgs({this.draft, this.existing});
  final ParsedExpense? draft;
  final ExpenseItem? existing;
}

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          _AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
        GoRoute(
          path: '/expenses',
          builder: (_, _) => const ExpenseHistoryScreen(),
        ),
        GoRoute(path: '/analytics', builder: (_, _) => const AnalyticsScreen()),
      ],
    ),
    GoRoute(path: '/scan', builder: (_, _) => const ScannerScreen()),
    GoRoute(
      path: '/review',
      builder: (_, state) => ReviewScreen(
        args: state.extra is ReviewArgs
            ? state.extra! as ReviewArgs
            : const ReviewArgs(),
      ),
    ),
    GoRoute(
      path: '/expense/:id',
      builder: (_, state) => ExpenseDetailScreen(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.pageUnavailable)),
    body: Center(child: Text(context.l10n.pageNotFound)),
  ),
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final index = switch (location) {
      '/expenses' => 1,
      '/analytics' => 2,
      _ => 0,
    };
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => context.go(switch (value) {
          1 => '/expenses',
          2 => '/analytics',
          _ => '/',
        }),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: context.l10n.history,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: context.l10n.insights,
          ),
        ],
      ),
    );
  }
}
