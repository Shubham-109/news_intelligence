import 'package:flutter/material.dart';

import '../error/failure.dart';

/// Centered icon, title and message with an optional action below.
///
/// Covers empty, idle and error states so they look the same on every screen.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  /// Error state for anything a provider can throw, with a retry button.
  factory MessageView.error(
    Object error, {
    Key? key,
    required VoidCallback onRetry,
  }) {
    final (icon, title) = switch (error) {
      NetworkFailure() => (Icons.wifi_off_rounded, 'No connection'),
      RateLimitFailure() => (Icons.hourglass_top_rounded, 'Too many requests'),
      ApiKeyFailure() => (Icons.vpn_key_outlined, 'API key needed'),
      _ => (Icons.error_outline_rounded, 'Something went wrong'),
    };

    return MessageView(
      key: key,
      icon: icon,
      title: title,
      message: error is Failure
          ? error.message
          : 'An unexpected error occurred. Please try again.',
      action: OutlinedButton(
        onPressed: onRetry,
        child: const Text('Try again'),
      ),
    );
  }

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: mutedColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
              ),
              if (action case final action?) ...[
                const SizedBox(height: 24),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
