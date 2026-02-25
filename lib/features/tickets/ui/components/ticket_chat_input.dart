import 'package:flutter/material.dart';

/// A reusable chat input component for typing and sending messages.
class TicketChatInput extends StatefulWidget {
  /// Callback triggered when the user submits a message.
  final Function(String) onSendMessage;
  
  /// Indicates if a message is currently being sent, disabling the input.
  final bool isSending;

  /// Indicates if the input is globally enabled (e.g. ticket is not closed).
  final bool isEnabled;

  const TicketChatInput({
    super.key,
    required this.onSendMessage,
    this.isSending = false,
    this.isEnabled = true,
  });

  @override
  State<TicketChatInput> createState() => _TicketChatInputState();
}

class _TicketChatInputState extends State<TicketChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isSending && widget.isEnabled) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !widget.isSending && widget.isEnabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: canInteract,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: widget.isEnabled 
                      ? 'Escreva uma mensagem...' 
                      : 'O ticket não está In Progress.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: canInteract ? Colors.grey.shade100 : Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: widget.isEnabled ? Colors.blueAccent : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: widget.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: canInteract ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}