import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// A reusable chat input component for typing, attaching files, and sending messages.
class TicketChatInput extends StatefulWidget {
  final Function(String?, File?) onSendMessage;
  final bool isSending;
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
  File? _selectedFile;

  /// Prompts the user to pick a file from their device.
  Future<void> _pickFile() async {
    if (!widget.isEnabled || widget.isSending) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  /// Removes the currently selected file.
  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  /// Submits the text and/or file to the parent callback.
  void _submit() {
    final text = _controller.text.trim();
    if ((text.isNotEmpty || _selectedFile != null) && !widget.isSending && widget.isEnabled) {
      widget.onSendMessage(text.isNotEmpty ? text : null, _selectedFile);
      _controller.clear();
      setState(() {
        _selectedFile = null;
      });
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_file, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _removeFile,
                      child: Icon(Icons.close, size: 16, color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: canInteract ? colorScheme.onSurfaceVariant : colorScheme.onSurface.withValues(alpha: 0.3),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: canInteract,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: widget.isEnabled ? 'Escreva uma mensagem...' : 'Ticket fechado/pendente.',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: canInteract ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: widget.isEnabled ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: widget.isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.send, color: widget.isEnabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant, size: 20),
                    onPressed: canInteract ? _submit : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}