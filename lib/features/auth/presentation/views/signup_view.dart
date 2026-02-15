import 'package:clean_sample/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:clean_sample/core/widgets/custom_text_field.dart';
import 'package:clean_sample/features/auth/presentation/views/login_view.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text('Sign up to get started', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 32),
              const CustomTextField(label: 'Full Name', hint: 'Enter your full name', keyboardType: TextInputType.name),
              const SizedBox(height: 24),
              const CustomTextField(label: 'Email', hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              const CustomTextField(label: 'Password', hint: 'Enter your password', isPassword: true),
              const SizedBox(height: 24),
              const CustomTextField(label: 'Confirm Password', hint: 'Confirm your password', isPassword: true),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Sign Up',
                onPressed: () {
                  // Navigate to Login or Home after signup
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
                    },
                    child: const Text(
                      'Login',
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
