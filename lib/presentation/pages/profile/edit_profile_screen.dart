// lib/presentation/pages/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_event.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController personalNumberController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    nameController = TextEditingController(text: user.name);
    personalNumberController = TextEditingController(text: user.personalNumber);
    emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    personalNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(CompleteProfileRequested(name: nameController.text.trim(), personalNumber: personalNumberController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDark ? 'EDIT USER PROFILE' : 'Edit Profile'),
        centerTitle: true,
        leading: IconButton(icon: Icon(MdiIcons.arrowLeft), onPressed: () => Navigator.pop(context)),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error));
          } else if (state is Authenticated) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Profile updated successfully!'), backgroundColor: theme.colorScheme.primary));

            // Navigate back to profile screen
            Navigator.pop(context);
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
                                  'USER PROFILE MODIFICATION',
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
                              Text('Update Your Profile', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ],
                          ),
                        const SizedBox(height: 24),

                        // Email field (read-only)
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(MdiIcons.emailOutline),
                            prefixText: isDark ? '> ' : null,
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          readOnly: true, // Email can't be changed
                          enabled: false,
                        ),
                        const SizedBox(height: 16),

                        // Name field
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(MdiIcons.accountOutline),
                            prefixText: isDark ? '> ' : null,
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Personal Number field
                        TextFormField(
                          controller: personalNumberController,
                          decoration: InputDecoration(
                            labelText: 'Personal Number',
                            prefixIcon: Icon(MdiIcons.identifier),
                            prefixText: isDark ? '> ' : null,
                            border: const OutlineInputBorder(),
                          ),
                          style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your personal number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Update button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleUpdateProfile,
                            child:
                                state is AuthLoading
                                    ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary, strokeWidth: 2),
                                    )
                                    : Text(
                                      isDark ? 'UPDATE_PROFILE' : 'Update Profile',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: isDark ? 'Source Code Pro' : null, letterSpacing: isDark ? 1 : null),
                                    ),
                          ),
                        ),

                        // System message for dark mode
                        if (isDark)
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Text(
                              '[ SYSTEM: PROFILE MODIFICATION MODULE ACTIVE ]',
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
