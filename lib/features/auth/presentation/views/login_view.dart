import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/widgets/custom_text_field.dart';
import 'package:logit/core/widgets/primary_button.dart';
import 'package:logit/features/auth/domain/usecases/login_usecase/login_usecase.dart';
import 'package:logit/features/auth/presentation/providers/login_view_provider/login_view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(loginViewProviderProvider, (previous, next) {
      next.loginStatus.maybeWhen(
        success: (_) => context.go(RoutePaths.tasks),
        failure: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(loginViewProviderProvider.notifier)
        .login(
          LoginParams(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewProviderProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 42),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue with LogIt.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hint: 'Minimum 6 characters',
                isPassword: true,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Login',
                isLoading: loginState.loginStatus.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No account yet?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.signup),
                    child: const Text('Create one'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
