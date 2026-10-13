import 'package:flutter/material.dart';

/// Shows [message] in a snack bar, replacing any that is already visible.
void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
