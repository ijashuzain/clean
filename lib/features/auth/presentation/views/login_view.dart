import 'package:clean_sample/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:clean_sample/core/widgets/custom_text_field.dart';
import 'package:clean_sample/features/auth/domain/usecases/login_usecase/login_usecase.dart';
import 'package:clean_sample/features/auth/presentation/providers/login_view_provider/login_view_provider.dart';
import 'package:clean_sample/features/auth/presentation/views/signup_view.dart';
import 'package:clean_sample/features/task/presentation/views/task_list_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewProviderProvider);

    ref.listen(loginViewProviderProvider, (previous, next) {
      next.loginStatus.maybeWhen(
        success: (data) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskListView()));
        },
        failure: (message) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
        orElse: () {},
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text('Please sign in to continue', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Login',
                isLoading: loginState.loginStatus.isLoading,
                onPressed: () {
                  ref
                      .read(loginViewProviderProvider.notifier)
                      .login(LoginParams(email: _emailController.text, password: _passwordController.text));
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupView()));
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
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
