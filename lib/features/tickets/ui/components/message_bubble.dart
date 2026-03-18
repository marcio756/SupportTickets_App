import 'package:flutter/material.dart';
import '../../models/ticket_message.dart';
import 'attachment_preview.dart';

/// Renders a single chat bubble for a ticket message, with mention highlighting capabilities.
class MessageBubble extends StatelessWidget {
  final TicketMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  /// Formats the DateTime to a readable hour/minute string.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Parses the message text and highlights any @mentions to mimic Discord UI style.
  Widget _buildMessageContent(BuildContext context, String text, bool isMe, ColorScheme colorScheme) {
    // Regex matches @Name and @email formats
    final RegExp mentionRegex = RegExp(r'@([a-zA-Z0-9_À-ÿ.\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_À-ÿ]+)');
    final matches = mentionRegex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      );
    }

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      
      // The Mention Highlight Block
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isMe ? Colors.white : colorScheme.primary,
          backgroundColor: isMe 
              ? Colors.white.withValues(alpha: 0.2) 
              : colorScheme.primaryContainer.withValues(alpha: 0.5),
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
          height: 1.3,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isFromMe;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: Text(
                message.userName,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.message.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildMessageContent(context, message.message, isMe, colorScheme),
                  ),
                
                if (message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AttachmentPreview(
                      attachmentPath: message.attachmentUrl!,
                      isFromMe: isMe,
                    ),
                  ),

                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}