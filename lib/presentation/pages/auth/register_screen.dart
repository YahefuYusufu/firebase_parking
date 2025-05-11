import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_event.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personalNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    personalNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Please accept the terms and conditions'), backgroundColor: Theme.of(context).colorScheme.error));
        return;
      }

      // Add the SignUpRequested event
      context.read<AuthBloc>().add(
        SignUpRequested(
          email: emailController.text.trim(),
          password: passwordController.text,
          name: nameController.text.trim(),
          personalNumber: personalNumberController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New User Registration'), centerTitle: true, leading: IconButton(icon: Icon(MdiIcons.arrowLeft), onPressed: () => Navigator.pop(context))),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
          } else if (state is Authenticated) {
            // Show success message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: const Text('Registration successful!'), backgroundColor: theme.colorScheme.primary, duration: const Duration(seconds: 3)));

            // Navigate to home screen after successful registration
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, '/home');
              }
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        if (isDark)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.primary)),
                            child: Column(
                              children: [
                                Icon(MdiIcons.accountPlus, color: theme.colorScheme.primary, size: 40),
                                const SizedBox(height: 16),
                                Text(
                                  'SYSTEM: NEW USER CREATION',
                                  style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Source Code Pro', fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()), shape: BoxShape.circle),
                                child: Icon(MdiIcons.accountPlus, color: theme.colorScheme.primary, size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text('Create ParkOS Account', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ],
                          ),
                        const SizedBox(height: 16),

                        // Command line prefix in dark mode
                        if (isDark)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text('> Please enter the following details:', style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary)),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              'Enter your details to create an account',
                              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(MdiIcons.emailOutline), prefixText: isDark ? '> ' : null),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Name Field
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(MdiIcons.accountOutline), prefixText: isDark ? '> ' : null),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Personal Number Field
                        TextFormField(
                          controller: personalNumberController,
                          decoration: InputDecoration(labelText: 'Personal Number', prefixIcon: Icon(MdiIcons.identifier), prefixText: isDark ? '> ' : null),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your personal number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(MdiIcons.lockOutline),
                            prefixText: isDark ? '> ' : null,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? MdiIcons.eyeOffOutline : MdiIcons.eyeOutline, color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(MdiIcons.lockCheckOutline),
                            prefixText: isDark ? '> ' : null,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? MdiIcons.eyeOffOutline : MdiIcons.eyeOutline, color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Terms and Conditions - Terminal style in dark mode
                        Container(
                          padding: isDark ? const EdgeInsets.all(8) : null,
                          decoration: isDark ? BoxDecoration(border: Border.all(color: theme.colorScheme.primary.withAlpha((0.5 * 255).round()))) : null,
                          child: Row(
                            children: [
                              Checkbox(
                                value: acceptTerms,
                                onChanged: (bool? value) {
                                  setState(() {
                                    acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: theme.colorScheme.primary,
                              ),
                              Expanded(
                                child: Text(
                                  'I agree to the Terms of Service and Privacy Policy',
                                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()), fontFamily: isDark ? 'Source Code Pro' : null),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleRegister,
                            child:
                                state is AuthLoading
                                    ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary, strokeWidth: 2),
                                    )
                                    : Text(
                                      isDark ? 'CREATE_NEW_USER' : 'Create Account',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: isDark ? 'Source Code Pro' : null, letterSpacing: isDark ? 1 : null),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isDark ? "[ Existing user? " : "Already have an account? ",
                              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()), fontFamily: isDark ? 'Source Code Pro' : null),
                            ),
                            TextButton(
                              onPressed:
                                  state is AuthLoading
                                      ? null
                                      : () {
                                        // Go back to login screen
                                        Navigator.pop(context);
                                      },
                              child: Text(isDark ? 'RETURN_TO_LOGIN ]' : 'Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: isDark ? 'Source Code Pro' : null)),
                            ),
                          ],
                        ),

                        // System status in dark mode
                        if (isDark)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              '[ SYSTEM STATUS: READY | NEW USER REGISTRATION MODULE ACTIVE ]',
                              style: TextStyle(fontFamily: 'Source Code Pro', fontSize: 10, color: theme.colorScheme.primary.withAlpha((0.7 * 255).round())),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
