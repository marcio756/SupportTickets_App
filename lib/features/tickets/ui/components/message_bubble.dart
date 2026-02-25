import 'package:flutter/material.dart';
import '../../models/ticket_message.dart';
import 'attachment_preview.dart';

/// Renders a single chat bubble for a ticket message.
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
                    child: Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                      ),
                    ),
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