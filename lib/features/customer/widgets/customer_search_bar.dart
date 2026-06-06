import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CustomerSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onVoiceTap;

  const CustomerSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onVoiceTap,
  });

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final SpeechToText _speech = SpeechToText();
  late final TextEditingController _internalController;

  bool _isListening = false;
  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    // Do not initialize speech_to_text here.
    // Microphone permission must be requested only after the user taps the mic button.
    _internalController = TextEditingController();
  }

  @override
  void dispose() {
    _speech.stop();
    _internalController.dispose();
    super.dispose();
  }

  Future<void> _handleVoiceSearch() async {
    if (widget.onVoiceTap != null) {
      widget.onVoiceTap!();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    try {
      // This is the first point where microphone permission can be requested.
      // It runs only after the mic button is tapped.
      final bool available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;

          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.permanent
                    ? 'Microphone permission is required for voice search.'
                    : 'Voice search could not start. Please try again.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );

      if (!available) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice search is not available on this device.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _isListening = true);

      await _speech.listen(
        listenMode: ListenMode.search,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 2),
        onResult: (result) {
          final recognizedWords = result.recognizedWords.trim();

          if (recognizedWords.isNotEmpty) {
            _effectiveController.text = recognizedWords;
            _effectiveController.selection = TextSelection.fromPosition(
              TextPosition(offset: _effectiveController.text.length),
            );
            widget.onChanged?.call(recognizedWords);
          }

          if (result.finalResult && mounted) {
            setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice search could not start. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 16, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFFFF7A00),
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _effectiveController,
                onChanged: widget.onChanged,
                cursorColor: const Color(0xFFFF7A00),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Listening...'
                      : 'Search restaurants, meals or areas...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  color: Color(0xFF241A14),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: _handleVoiceSearch,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _isListening
                      ? const Color(0xFFFF7A00)
                      : const Color(0xFFFFF0E4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isListening
                      ? Icons.graphic_eq_rounded
                      : Icons.mic_none_rounded,
                  color: _isListening ? Colors.white : const Color(0xFFFF7A00),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
