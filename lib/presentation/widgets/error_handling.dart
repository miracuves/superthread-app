import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cards/card_bloc.dart';
import '../bloc/notes/note_bloc.dart';
import '../bloc/boards/board_bloc.dart';
import '../bloc/search/search_bloc.dart';

class ErrorHandlingWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final Widget? child;

  const ErrorHandlingWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return ErrorOverlay(
        error: error,
        onRetry: onRetry,
        child: child!,
      );
    }

    return ErrorView(
      error: error,
      onRetry: onRetry,
    );
  }
}

class ErrorOverlay extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final Widget child;

  const ErrorOverlay({
    super.key,
    required this.error,
    this.onRetry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 16,
          right: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onRetry,
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(error),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getErrorMessage(error),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return Icons.wifi_off;
    } else if (error.contains('timeout')) {
      return Icons.timer_off;
    } else if (error.contains('401') || error.contains('403')) {
      return Icons.lock;
    } else if (error.contains('404')) {
      return Icons.search_off;
    } else if (error.contains('500')) {
      return Icons.dns;
    }
    return Icons.error_outline;
  }

  String _getErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'No internet connection. Please check your network settings and try again.';
    } else if (error.contains('timeout')) {
      return 'Connection timeout. The server is taking too long to respond. Please try again.';
    } else if (error.contains('401')) {
      return 'Authentication required. Please log in to continue.';
    } else if (error.contains('403')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    } else if (error.contains('404')) {
      return 'The requested resource was not found.';
    } else if (error.contains('500')) {
      return 'Server error occurred. Please try again later.';
    }
    return error;
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;

  const LoadingWidget({
    super.key,
    this.message,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress)
            const CircularProgressIndicator()
          else
            const SizedBox(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ConnectivityBanner extends StatelessWidget {
  final bool isOnline;

  const ConnectivityBanner({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text(
            'Offline - Changes will sync when connection is restored',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checking connection...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class BlocListenerWrapper<T extends BlocBase<S>, S> extends StatelessWidget {
  final Widget child;
  final void Function(S state)? listener;
  final BlocWidgetBuilder<S>? builder;

  const BlocListenerWrapper({
    super.key,
    required this.child,
    this.listener,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<T, S>(
      listener: (context, state) {
        if (listener != null) listener!(state);
      },
      child: BlocBuilder<T, S>(
        builder: (context, state) {
          if (builder != null) {
            return builder!(context, state);
          }
          return child;
        },
      ),
    );
  }
}

class MultiBlocErrorHandler extends StatelessWidget {
  final Widget child;

  const MultiBlocErrorHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CardBloc, CardState>(
          listener: (context, state) {
            _handleCardState(context, state);
          },
        ),
        BlocListener<NoteBloc, NoteState>(
          listener: (context, state) {
            _handleNoteState(context, state);
          },
        ),
        BlocListener<BoardBloc, BoardState>(
          listener: (context, state) {
            _handleBoardState(context, state);
          },
        ),
        BlocListener<SearchBloc, SearchState>(
          listener: (context, state) {
            _handleSearchState(context, state);
          },
        ),
      ],
      child: child,
    );
  }

  void _handleCardState(BuildContext context, CardState state) {
    if (state is CardOperationFailure) {
      _showErrorSnackBar(context, state.error);
    } else if (state is CardOperationSuccess) {
      _showSuccessSnackBar(context, state.message);
    }
  }

  void _handleNoteState(BuildContext context, NoteState state) {
    if (state is NoteOperationFailure) {
      _showErrorSnackBar(context, state.error);
    } else if (state is NoteOperationSuccess) {
      _showSuccessSnackBar(context, state.message);
    }
  }

  void _handleBoardState(BuildContext context, BoardState state) {
    if (state is BoardOperationFailure) {
      _showErrorSnackBar(context, state.error);
    } else if (state is BoardOperationSuccess) {
      _showSuccessSnackBar(context, state.message);
    }
  }

  void _handleSearchState(BuildContext context, SearchState state) {
    if (state is SearchError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class CustomSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;

  const CustomSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.begin = const Offset(0, 1),
    this.end = Offset.zero,
  });

  @override
  State<CustomSlideTransition> createState() => _CustomSlideTransitionState();
}

class _CustomSlideTransitionState extends State<CustomSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}