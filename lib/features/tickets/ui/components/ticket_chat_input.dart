import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// A reusable chat input component for typing, attaching files, and handling @mentions.
class TicketChatInput extends StatefulWidget {
  final Function(String?, PlatformFile?, List<String>?) onSendMessage;
  final bool isSending;
  final bool isEnabled;
  final List<Map<String, dynamic>> mentionableUsers;

  const TicketChatInput({
    super.key,
    required this.onSendMessage,
    this.isSending = false,
    this.isEnabled = true,
    this.mentionableUsers = const [],
  });

  @override
  State<TicketChatInput> createState() => _TicketChatInputState();
}

class _TicketChatInputState extends State<TicketChatInput> {
  final TextEditingController _controller = TextEditingController();
  PlatformFile? _selectedFile;

  // Mention State Variables
  bool _showMentionMenu = false;
  String _mentionSearch = '';
  final List<String> _selectedMentions = [];

  /// Processes text input dynamically to open the floating mention menu
  void _onTextChanged(String text) {
    final cursorPosition = _controller.selection.baseOffset;
    if (cursorPosition >= 0) {
      final textBeforeCursor = text.substring(0, cursorPosition);
      
      // Match "@" followed by text until the cursor
      final match = RegExp(r'@([a-zA-Z0-9_À-ÿ.\-@]*)$').firstMatch(textBeforeCursor);
      
      if (match != null) {
        setState(() {
          _showMentionMenu = true;
          _mentionSearch = match.group(1) ?? '';
        });
      } else {
        setState(() {
          _showMentionMenu = false;
        });
      }
    }
  }

  /// Inserts the selected user into the text field and registers their ID
  void _insertMention(Map<String, dynamic> user) {
    final text = _controller.text;
    final cursorPosition = _controller.selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);
    final textAfterCursor = text.substring(cursorPosition);
    
    // Remove the search query substring and replace with formatted name without spaces
    final textBeforeMention = textBeforeCursor.replaceFirst(RegExp(r'@[a-zA-Z0-9_À-ÿ.\-@]*$'), '');
    final mentionText = '@${user['name'].toString().replaceAll(RegExp(r'\s+'), '')} ';
    
    _controller.text = textBeforeMention + mentionText + textAfterCursor;
    _controller.selection = TextSelection.collapsed(offset: textBeforeMention.length + mentionText.length);
    
    // Store the ID safely
    final String userId = user['id'].toString();
    if (!_selectedMentions.contains(userId)) {
      _selectedMentions.add(userId);
    }
    
    setState(() {
      _showMentionMenu = false;
    });
  }

  /// Filters the available members based on current search input
  List<Map<String, dynamic>> get _filteredMentions {
    if (_mentionSearch.isEmpty) return widget.mentionableUsers;
    return widget.mentionableUsers.where((u) {
      final name = u['name'].toString().toLowerCase();
      return name.contains(_mentionSearch.toLowerCase());
    }).toList();
  }

  Future<void> _pickFile() async {
    if (!widget.isEnabled || widget.isSending) return;
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.single.name.isNotEmpty) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  void _removeFile() => setState(() => _selectedFile = null);

  void _submit() {
    final text = _controller.text.trim();
    if ((text.isNotEmpty || _selectedFile != null) && !widget.isSending && widget.isEnabled) {
      widget.onSendMessage(
        text.isNotEmpty ? text : null, 
        _selectedFile,
        _selectedMentions.isNotEmpty ? List.from(_selectedMentions) : null
      );
      _controller.clear();
      setState(() {
        _selectedFile = null;
        _showMentionMenu = false;
        _selectedMentions.clear();
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
            // --- INÍCIO DO FLOATING MENTION MENU ---
            if (_showMentionMenu)
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.1))
                  ],
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: _filteredMentions.isEmpty 
                  ? Padding(
                      padding: const EdgeInsets.all(16), 
                      child: Text('No members found.', style: TextStyle(color: colorScheme.onSurfaceVariant))
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredMentions.length,
                      itemBuilder: (ctx, i) {
                        final user = _filteredMentions[i];
                        final isCustomer = user['role'] == 'customer';
                        
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.alternate_email, size: 16, color: colorScheme.primary),
                          title: Text(user['name']?.toString() ?? '', style: const TextStyle(fontSize: 14)),
                          trailing: Text(
                            user['role']?.toString().toUpperCase() ?? '', 
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: isCustomer ? Colors.green : colorScheme.primary
                            )
                          ),
                          onTap: () => _insertMention(user),
                        );
                      }
                    ),
              ),
            // --- FIM DO FLOATING MENTION MENU ---

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
                        _selectedFile!.name,
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
                    onChanged: _onTextChanged, 
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: widget.isEnabled ? 'Type a message (use @ to mention)...' : 'Chat is locked.',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
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
                            child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
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