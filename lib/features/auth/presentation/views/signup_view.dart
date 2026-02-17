import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/widgets/custom_text_field.dart';
import 'package:logit/core/widgets/primary_button.dart';
import 'package:logit/features/auth/domain/usecases/signup_usecase/signup_usecase.dart';
import 'package:logit/features/auth/presentation/providers/signup_view_provider/signup_view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(signupViewProviderProvider, (previous, next) {
      next.signupStatus.maybeWhen(
        success: (_) => context.go(RoutePaths.tasks),
        failure: (message) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message))),
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    ref
        .read(signupViewProviderProvider.notifier)
        .signup(
          SingupParams(
            name: _nameController.text,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupViewProviderProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get started with your own LogIt workspace.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                label: 'Name',
                hint: 'Your full name',
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Password',
                hint: 'Minimum 6 characters',
                isPassword: true,
                controller: _passwordController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              CustomTextField(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                isPassword: true,
                controller: _confirmPasswordController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: 'Create Account',
                isLoading: signupState.signupStatus.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already registered?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RoutePaths.login),
                    child: const Text('Login'),
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
