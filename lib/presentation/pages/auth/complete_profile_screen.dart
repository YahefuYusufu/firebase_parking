// lib/presentation/pages/auth/complete_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_event.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personalNumberController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    personalNumberController.dispose();
    super.dispose();
  }

  void _handleProfileCompletion() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(CompleteProfileRequested(name: nameController.text.trim(), personalNumber: personalNumberController.text.trim()));
    }
  }

  void _showLogoutConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder:
          (context) => AlertDialog(
            title: Text(isDark ? 'PROFILE REQUIRED' : 'Profile Required', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
            content: Text(
              isDark
                  ? '> To use ParkOS, you must complete your profile. Do you want to logout instead?'
                  : 'To use ParkOS, you must complete your profile information. Would you like to log out instead?',
              style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text(
                  isDark ? 'CONTINUE SETUP' : 'Continue Setup',
                  style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Log out
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(isDark ? 'LOGOUT' : 'Log Out', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ignore: deprecated_member_use
    return WillPopScope(
      // Intercept back button presses
      onWillPop: () async {
        _showLogoutConfirmation();
        return false; // Don't allow immediate back navigation
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Complete Your Profile'), centerTitle: true, leading: IconButton(icon: Icon(MdiIcons.arrowLeft), onPressed: _showLogoutConfirmation)),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
            } else if (state is Authenticated) {
              // Profile completed successfully, navigate to home
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (state is Unauthenticated) {
              // User logged out, navigate to login
              Navigator.of(context).pushReplacementNamed('/');
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
                                  Icon(MdiIcons.accountEdit, color: theme.colorScheme.primary, size: 40),
                                  const SizedBox(height: 16),
                                  Text(
                                    'PROFILE_SETUP_REQUIRED',
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
                                  child: Icon(MdiIcons.accountEdit, color: theme.colorScheme.primary, size: 40),
                                ),
                                const SizedBox(height: 16),
                                Text('Complete Your Profile', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Instructions
                          Text(
                            isDark ? '> Please provide the following information to complete your profile setup:' : 'Please enter your details to complete your account setup.',
                            style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                            textAlign: isDark ? TextAlign.left : TextAlign.center,
                          ),
                          const SizedBox(height: 32),

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
                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading ? null : _handleProfileCompletion,
                              child:
                                  state is AuthLoading
                                      ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary, strokeWidth: 2),
                                      )
                                      : Text(
                                        isDark ? 'COMPLETE_PROFILE_SETUP' : 'Complete Profile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: isDark ? 'Source Code Pro' : null,
                                          letterSpacing: isDark ? 1 : null,
                                        ),
                                      ),
                            ),
                          ),

                          // System status in dark mode
                          if (isDark)
                            Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: Text(
                                '[ SYSTEM STATUS: AWAITING USER INPUT | PROFILE SETUP REQUIRED FOR SYSTEM ACCESS ]',
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
      ),
    );
  }
}
