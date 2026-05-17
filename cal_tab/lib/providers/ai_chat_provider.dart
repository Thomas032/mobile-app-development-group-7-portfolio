import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/services/gemini_ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AiChatRole { user, model }

class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final AiChatRole role;
  final String content;
  final DateTime createdAt;

  AiChatMessage copyWith({String? content}) {
    return AiChatMessage(
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.error,
  });

  final List<AiChatMessage> messages;
  final bool isStreaming;
  final String? error;

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isStreaming,
    Object? error = _sentinel,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const Object _sentinel = Object();
}

/// Override in tests with a fake.
typedef GeminiAiServiceFactory = GeminiAiService Function(String apiKey);

final geminiAiServiceFactoryProvider = Provider<GeminiAiServiceFactory>((ref) {
  return (apiKey) => GeminiAiService(apiKey: apiKey);
});

class AiChatController extends Notifier<AiChatState> {
  @override
  AiChatState build() {
    return const AiChatState();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isStreaming) {
      return;
    }

    final apiKey = ref.read(aiApiKeyControllerProvider).value;
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(
        error: 'Add your Gemini API key in Settings to start chatting.',
      );
      return;
    }

    final profile = ref.read(profileSetupControllerProvider).profile;
    if (profile == null) {
      state = state.copyWith(
        error: 'Finish onboarding before chatting with the assistant.',
      );
      return;
    }

    final selectedDate = ref.read(selectedLogDateProvider);
    final logState = ref.read(dailyLogControllerProvider);
    final entries = logState.entriesForDate(selectedDate);
    final summary = logState.summaryFor(date: selectedDate, profile: profile);
    final systemContext = _buildSystemContext(
      profile: profile,
      date: selectedDate,
      entries: entries,
      caloriesConsumed: summary.caloriesConsumed,
      caloriesLeft: summary.caloriesLeft,
      proteinConsumed: summary.proteinConsumedGrams,
      carbsConsumed: summary.carbsConsumedGrams,
      fatConsumed: summary.fatConsumedGrams,
      fiberConsumed: summary.fiberConsumedGrams,
    );

    final history = state.messages
        .map(
          (m) => ChatTurn(
            role: m.role == AiChatRole.user ? 'user' : 'model',
            content: m.content,
          ),
        )
        .toList();

    final userMessage = AiChatMessage(
      role: AiChatRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );
    final placeholder = AiChatMessage(
      role: AiChatRole.model,
      content: '',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, placeholder],
      isStreaming: true,
      error: null,
    );

    final service = ref.read(geminiAiServiceFactoryProvider)(apiKey);
    final buffer = StringBuffer();

    try {
      await for (final chunk in service.sendMessage(
        userMessage: trimmed,
        history: history,
        systemContext: systemContext,
      )) {
        buffer.write(chunk);
        final updated = [...state.messages];
        updated[updated.length - 1] = updated.last.copyWith(
          content: buffer.toString(),
        );
        state = state.copyWith(messages: updated);
      }
      if (buffer.isEmpty) {
        // Drop the empty placeholder so the UI doesn't show a blank bubble.
        final trimmedMessages = [...state.messages]..removeLast();
        state = state.copyWith(
          messages: trimmedMessages,
          isStreaming: false,
          error: 'Gemini returned an empty response.',
        );
        return;
      }
      state = state.copyWith(isStreaming: false);
    } catch (e) {
      final withoutPlaceholder = [...state.messages]..removeLast();
      state = state.copyWith(
        messages: withoutPlaceholder,
        isStreaming: false,
        error: e is AiServiceException ? e.message : 'Chat request failed: $e',
      );
    }
  }

  void clear() {
    state = const AiChatState();
  }

  void dismissError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);

String _buildSystemContext({
  required UserProfile profile,
  required DateTime date,
  required List<MealEntry> entries,
  required int caloriesConsumed,
  required int caloriesLeft,
  required double proteinConsumed,
  required double carbsConsumed,
  required double fatConsumed,
  required double fiberConsumed,
}) {
  final macros = profile.macroTargets;
  final mealsByType = <String, List<String>>{};
  for (final entry in entries) {
    mealsByType
        .putIfAbsent(entry.mealType.name, () => [])
        .add(entry.foodItem.name);
  }
  final mealsLine = mealsByType.isEmpty
      ? 'No meals logged yet today.'
      : mealsByType.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('; ');

  return [
    "You are CalTab's nutrition coach. Answer concisely and helpfully. "
        'Use the profile and today\'s intake below for context.',
    '',
    'Profile:',
    '- Goal: ${profile.goalType.name}, calorie target: ${profile.calorieGoal} kcal',
    '- Macro targets: P${macros.proteinGrams.toStringAsFixed(0)}/C${macros.carbsGrams.toStringAsFixed(0)}/F${macros.fatGrams.toStringAsFixed(0)}/Fiber${macros.fiberGrams.toStringAsFixed(0)} g',
    '- Age ${profile.age}, weight ${profile.weightKg.toStringAsFixed(1)}kg, height ${profile.heightCm.toStringAsFixed(0)}cm, activity ${profile.activityLevel.name}',
    '',
    'Today (${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}):',
    '- Consumed: $caloriesConsumed kcal ($caloriesLeft left)',
    '- Protein ${proteinConsumed.toStringAsFixed(0)}/${macros.proteinGrams.toStringAsFixed(0)}g, '
        'Carbs ${carbsConsumed.toStringAsFixed(0)}/${macros.carbsGrams.toStringAsFixed(0)}g, '
        'Fat ${fatConsumed.toStringAsFixed(0)}/${macros.fatGrams.toStringAsFixed(0)}g, '
        'Fiber ${fiberConsumed.toStringAsFixed(0)}/${macros.fiberGrams.toStringAsFixed(0)}g',
    '- Meals: $mealsLine',
  ].join('\n');
}
