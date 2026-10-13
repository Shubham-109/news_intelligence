import 'package:flutter/material.dart';

/// Shows [message] in a snack bar, replacing any that is already visible.
///
/// Plain confirmations clear quickly; messages with an action such as Undo
/// stay a little longer so there is time to use it.
void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: Duration(seconds: action == null ? 3 : 5),
      ),
    );
}
