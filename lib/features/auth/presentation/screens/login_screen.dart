import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/snack_bar.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _minPasswordLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  /// Fields only show errors once the user has tried to sign in.
  var _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < _minPasswordLength) {
      return 'Use at least $_minPasswordLength characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading) return;

    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showSnackBar(
          context,
          error is Failure
              ? error.message
              : 'Could not sign in. Please try again.',
        );
      }
    });

    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AutofillGroup(
                      // Demo credentials are not worth offering to save in
                      // the system password manager.
                      onDisposeAction: AutofillContextAction.cancel,
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Wordmark(),
                            const SizedBox(height: 40),
                            Text(
                              'Sign in',
                              style: theme.textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your daily read on business and the economy.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 32),
                            const _FieldLabel('Email'),
                            TextFormField(
                              controller: _emailController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.email],
                              validator: _validateEmail,
                              decoration: const InputDecoration(
                                hintText: 'name@company.com',
                              ),
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel('Password'),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText:
                                    'At least $_minPasswordLength characters',
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            FilledButton(
                              onPressed: _submit,
                              child: isLoading
                                  ? SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Demo access: any email and a password with at '
                              'least $_minPasswordLength characters.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ExcludeSemantics(
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'N',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('News Intelligence', style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
