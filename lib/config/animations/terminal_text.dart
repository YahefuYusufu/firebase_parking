import 'package:flutter/material.dart';
import 'dart:async';

class TerminalText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int typingSpeed; // in milliseconds
  final bool infiniteLoop;
  final int pauseBetweenLoops; // in milliseconds

  const TerminalText({required this.text, this.style, this.typingSpeed = 50, this.infiniteLoop = false, this.pauseBetweenLoops = 1500, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TerminalTextState createState() => _TerminalTextState();
}

class _TerminalTextState extends State<TerminalText> {
  String _displayedText = '';
  late Timer _timer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();

    // Blinking cursor timer
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startTypingAnimation() {
    int charIndex = 0;

    _timer = Timer.periodic(Duration(milliseconds: widget.typingSpeed), (timer) {
      if (charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText = widget.text.substring(0, charIndex + 1);
            charIndex++;
          });
        }
      } else {
        _timer.cancel();

        if (widget.infiniteLoop) {
          // Wait for a while and then clear the text to restart
          Future.delayed(Duration(milliseconds: widget.pauseBetweenLoops), () {
            if (mounted) {
              setState(() {
                _displayedText = '';
              });

              // Wait a moment before restarting typing
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _startTypingAnimation();
                }
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(_displayedText + (_showCursor ? "|" : " "), style: widget.style ?? TextStyle(fontFamily: 'Source Code Pro', color: theme.colorScheme.primary));
  }
}
