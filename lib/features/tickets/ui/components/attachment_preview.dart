import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';

/// A reusable UI component that displays an attachment link or preview.
/// Handles the URL formatting and external launching.
class AttachmentPreview extends StatelessWidget {
  final String attachmentPath;
  final bool isFromMe;

  /// Initializes the AttachmentPreview.
  /// 
  /// [attachmentPath] The relative or absolute path of the attachment.
  /// [isFromMe] Boolean to adjust the styling based on sender.
  const AttachmentPreview({
    super.key,
    required this.attachmentPath,
    required this.isFromMe,
  });

  /// Constructs the full absolute URL for the attachment.
  String get _fullUrl {
    if (attachmentPath.startsWith('http')) {
      return attachmentPath;
    }
    return '${ApiClient.hostUrl}$attachmentPath';
  }

  /// Attempts to launch the attachment URL in the default browser/viewer.
  Future<void> _openAttachment(BuildContext context) async {
    final Uri url = Uri.parse(_fullUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o anexo.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir anexo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAttachment(context),
      child: Container(
        margin: const EdgeInsets.only(top: 8.0, bottom: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isFromMe ? Colors.white.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isFromMe ? Colors.white30 : Colors.blue.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              size: 16,
              color: isFromMe ? Colors.white : Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Ver Ficheiro Anexo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFromMe ? Colors.white : Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}