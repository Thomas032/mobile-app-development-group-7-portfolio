import 'package:cal_tab/providers/ai_chat_provider.dart';
import 'package:cal_tab/widgets/ai/chat_input_bar.dart';
import 'package:cal_tab/widgets/ai/empty_chat_hint.dart';
import 'package:cal_tab/widgets/ai/message_bubble.dart';
import 'package:flutter/material.dart';

class ChatLayout extends StatelessWidget {
  const ChatLayout({
    super.key,
    required this.chatState,
    required this.inputController,
    required this.scrollController,
    required this.onSend,
    required this.onClear,
    required this.onDismissError,
  });

  final AiChatState chatState;
  final TextEditingController inputController;
  final ScrollController scrollController;
  final Future<void> Function() onSend;
  final VoidCallback onClear;
  final VoidCallback onDismissError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'AI Assistant',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (chatState.messages.isNotEmpty)
                TextButton.icon(
                  onPressed: chatState.isStreaming ? null : onClear,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear'),
                ),
            ],
          ),
        ),
        if (chatState.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              color: colors.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colors.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss',
                      icon: Icon(Icons.close, color: colors.onErrorContainer),
                      onPressed: onDismissError,
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: chatState.messages.isEmpty
              ? const EmptyChatHint()
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatState.messages[index];
                    return MessageBubble(
                      message: message,
                      isStreaming:
                          chatState.isStreaming &&
                          index == chatState.messages.length - 1 &&
                          message.role == AiChatRole.model,
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: ChatInputBar(
              controller: inputController,
              isStreaming: chatState.isStreaming,
              onSend: onSend,
            ),
          ),
        ),
      ],
    );
  }
}
