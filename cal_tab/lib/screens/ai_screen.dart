import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/providers/ai_chat_provider.dart';
import 'package:cal_tab/widgets/ai/chat_layout.dart';
import 'package:cal_tab/widgets/ai/error_state.dart';
import 'package:cal_tab/widgets/ai/no_api_key_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(aiApiKeyControllerProvider);
    final chatState = ref.watch(aiChatControllerProvider);

    ref.listen(aiChatControllerProvider, (_, next) {
      if (next.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return SafeArea(
      child: apiKeyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AiErrorState(message: 'Could not load settings: $e'),
        data: (apiKey) {
          if (apiKey == null || apiKey.isEmpty) {
            return const NoApiKeyState();
          }
          return ChatLayout(
            chatState: chatState,
            inputController: _inputController,
            scrollController: _scrollController,
            onSend: _send,
            onClear: () => ref.read(aiChatControllerProvider.notifier).clear(),
            onDismissError: () =>
                ref.read(aiChatControllerProvider.notifier).dismissError(),
          );
        },
      ),
    );
  }

  Future<void> _send() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    await ref.read(aiChatControllerProvider.notifier).sendMessage(text);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
