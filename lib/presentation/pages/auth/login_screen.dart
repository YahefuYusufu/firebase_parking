import 'package:firebase_parking/config/animations/terminal_text.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_event.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/widgets/logo/park_bot_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignInRequested(email: emailController.text.trim(), password: passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
          } else if (state is Authenticated) {
            // Navigate to home screen
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is ProfileIncomplete) {
            // Navigate to profile completion screen
            Navigator.pushReplacementNamed(context, '/complete_profile');
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.transparent : theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.primary, width: isDark ? 2 : 1),
                            ),
                            child: AlienCarLogo(size: 60, animate: true),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title - Terminal Style for Dark Mode
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.colorScheme.primary), bottom: BorderSide(color: theme.colorScheme.primary))),
                          child: TerminalText(
                            text: 'ParkOS Login Terminal',
                            infiniteLoop: true,
                            pauseBetweenLoops: 2000,
                            typingSpeed: 120,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Source Code Pro', color: theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle - Terminal Style
                        Text(
                          '> Enter credentials to access the system',
                          style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Source Code Pro', color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(MdiIcons.emailOutline), prefixText: isDark ? '> ' : null),
                          style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.onSurface),
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
                          style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.onSurface),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleLogin,
                            child:
                                state is AuthLoading
                                    ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary, strokeWidth: 2),
                                    )
                                    : Text('ACCESS SYSTEM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Source Code Pro')),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register Option - Terminal Style
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: isDark ? BoxDecoration(border: Border.all(color: theme.colorScheme.primary.withAlpha((0.5 * 255).round()))) : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("New user? ", style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()))),
                              TextButton(
                                onPressed:
                                    state is AuthLoading
                                        ? null
                                        : () {
                                          // Navigate to register screen
                                          Navigator.pushNamed(context, '/register');
                                        },
                                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                                child: Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Source Code Pro', letterSpacing: 1)),
                              ),
                            ],
                          ),
                        ),

                        // Version info - Terminal style footer
                        const SizedBox(height: 24),
                        Text(
                          'ParkOS v1.0.0 | System Ready',
                          style: TextStyle(fontFamily: 'Source Code Pro', fontSize: 12, color: theme.colorScheme.onSurface.withAlpha((0.5 * 255).round())),
                          textAlign: TextAlign.center,
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
