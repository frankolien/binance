import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/square_repository.dart';
import '../widgets/square_empty_tab.dart';
import '../widgets/square_feed.dart';

@RoutePage()
class SquarePage extends StatelessWidget {
  const SquarePage({super.key});

  static const _tabs = [
    'Discover',
    'Following',
    'Hot',
    'News',
    'Academy',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.lightSurface,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.lightLine),
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.lightTextPrimary,
                  indicatorWeight: 3,
                  labelColor: AppColors.lightTextPrimary,
                  unselectedLabelColor: AppColors.lightTextTertiary,
                  labelStyle: theme.textTheme.titleMedium,
                  unselectedLabelStyle: theme.textTheme.titleMedium,
                  tabs: [for (final t in _tabs) Tab(text: t)],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    SquareFeed(category: SquareCategory.discover),
                    SquareEmptyTab(
                      icon: Icons.person_outline,
                      title: 'No one to follow yet',
                      subtitle: 'Sign in to follow creators you care about.',
                    ),
                    SquareFeed(category: SquareCategory.hot),
                    SquareFeed(category: SquareCategory.news),
                    SquareEmptyTab(
                      icon: Icons.school_outlined,
                      title: 'Academy coming soon',
                      subtitle: 'Learn-to-earn courses will appear here.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _ComposeFab(),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Text(
            'Square',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
            color: AppColors.lightTextPrimary,
          ),
        ],
      ),
    );
  }
}

class _ComposeFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Shell's Scaffold uses extendBody: true for Lite, so this inner Scaffold
    // bleeds under the bottom nav. Lift the FAB above the 80px nav.
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton(
        backgroundColor: AppColors.brandYellow,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 2,
        shape: const CircleBorder(),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Composer coming soon')),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
