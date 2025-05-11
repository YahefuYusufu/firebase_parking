import 'package:firebase_parking/config/animations/terminal_text.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/widgets/logo/park_bot_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool showText = false;
  bool showBootSequence = false;
  bool checkingAuth = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Force immediate display of UI elements
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Color(0xFF121212)));

    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    // Start animation sequence immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  void _startAnimation() async {
    // Show text almost immediately
    await Future.delayed(const Duration(milliseconds: 1));
    if (!mounted) return;
    setState(() => showText = true);

    // Start boot sequence right after
    await Future.delayed(const Duration(milliseconds: 1));
    if (!mounted) return;
    setState(() => showBootSequence = true);

    // Allow sufficient time to display boot sequence
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // Show authentication check
    setState(() => checkingAuth = true);

    // Allow time for auth check message to be displayed
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Fade out animation
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate based on authentication state
    if (mounted) {
      _navigateBasedOnAuthState();
    }
  }

  void _navigateBasedOnAuthState() {
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      // User is authenticated, navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (authState is ProfileIncomplete) {
      // User is authenticated but profile not complete
      Navigator.of(context).pushReplacementNamed('/complete_profile');
    } else {
      // User is not authenticated, navigate to login
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Listen for authentication state changes
        // Only navigate if we're already checking auth (animation completed)
        if (checkingAuth && _fadeController.isCompleted) {
          _navigateBasedOnAuthState();
        }
      },
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _fadeAnimation.value,
            child: Scaffold(
              // Hardcode background color to match native splash
              backgroundColor: const Color(0xFF121212),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display logo immediately
                      const AlienCarLogo(size: 120, animate: false),
                      const SizedBox(height: 40),

                      // App name
                      if (showText)
                        TerminalText(
                          text: "ParkOS v1.0",
                          typingSpeed: 40, // Slightly faster typing
                          style: TextStyle(fontFamily: 'Source Code Pro', fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        )
                      else
                        // Static placeholder to prevent layout shift
                        Text("", style: TextStyle(fontFamily: 'Source Code Pro', fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),

                      const SizedBox(height: 40),

                      // Boot sequence text
                      if (showBootSequence)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TerminalText(
                              text: "> Initializing system modules...",
                              typingSpeed: 12, // Even faster typing
                              style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TerminalText(
                              text: "> Loading parking database...",
                              typingSpeed: 12,
                              style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TerminalText(
                              text: "> Enabling security protocols...",
                              typingSpeed: 12,
                              style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TerminalText(
                              text: "> System ready. Welcome to ParkOS.",
                              typingSpeed: 12,
                              style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary, fontSize: 14),
                            ),
                            if (checkingAuth) ...[
                              const SizedBox(height: 12),
                              TerminalText(
                                text: "> Checking authentication status...",
                                typingSpeed: 12,
                                style: TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                    ],
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
