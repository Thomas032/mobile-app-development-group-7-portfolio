import 'package:cal_tab/providers/ai_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isStreaming,
  });

  final AiChatMessage message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUser = message.role == AiChatRole.user;
    final bg = isUser ? colors.primary : colors.surfaceContainerHigh;
    final fg = isUser ? colors.onPrimary : colors.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.content.isEmpty && isStreaming)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fg.withValues(alpha: 0.7),
                  ),
                )
              else if (isUser)
                Text(message.content, style: TextStyle(color: fg, height: 1.35))
              else
                MarkdownBody(
                  data: message.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(
                        p: TextStyle(color: fg, height: 1.35),
                        listBullet: TextStyle(color: fg, height: 1.35),
                        strong: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.bold,
                        ),
                        em: TextStyle(color: fg, fontStyle: FontStyle.italic),
                        code: TextStyle(
                          color: fg,
                          backgroundColor: colors.surfaceContainerHighest,
                          fontFamily: 'monospace',
                        ),
                      ),
                ),
              if (isStreaming && message.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fg.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
