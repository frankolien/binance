import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/square_repository.dart';
import '../bloc/square_bloc.dart';
import 'square_post_card.dart';

class SquareFeed extends StatelessWidget {
  const SquareFeed({super.key, required this.category});

  final SquareCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SquareBloc>(
      key: ValueKey(category),
      create: (_) => getIt<SquareBloc>(param1: category)
        ..add(const SquareLoadRequested()),
      child: const _SquareFeedView(),
    );
  }
}

class _SquareFeedView extends StatefulWidget {
  const _SquareFeedView();

  @override
  State<_SquareFeedView> createState() => _SquareFeedViewState();
}

class _SquareFeedViewState extends State<_SquareFeedView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      context.read<SquareBloc>().add(const SquareLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SquareBloc, SquareState>(
      builder: (context, state) {
        return switch (state) {
          SquareInitial() || SquareLoading() => const _LoadingView(),
          SquareLoaded(:final posts) when posts.isEmpty => const _EmptyView(),
          SquareLoaded() => RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SquareBloc>()
                    .add(const SquareRefreshRequested());
              },
              child: ListView.builder(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    state.posts.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i >= state.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2))),
                    );
                  }
                  return SquarePostCard(post: state.posts[i]);
                },
              ),
            ),
          SquareError(:final failure) => _ErrorView(
              message: failure.message,
              onRetry: () => context
                  .read<SquareBloc>()
                  .add(const SquareLoadRequested()),
            ),
        };
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 64,
        height: 64,
        child: Lottie.asset(AppAssets.lottieLoadingYellow, repeat: true),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text('No posts yet', style: theme.textTheme.bodyMedium),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
