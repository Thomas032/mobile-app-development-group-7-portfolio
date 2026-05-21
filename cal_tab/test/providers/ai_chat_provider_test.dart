import 'dart:async';
import 'dart:typed_data';

import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/providers/ai_chat_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:cal_tab/services/gemini_ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_user_profile_repository.dart';
import '../fakes/in_memory_secure_key_value_store.dart';

void main() {
  group('AiChatController', () {
    test('appends messages and toggles streaming on success', () async {
      final fake = _FakeGeminiAiService(chunks: const ['Hello', ' world!']);
      final container = await _container(serviceFactory: (_) => fake);

      await container
          .read(aiChatControllerProvider.notifier)
          .sendMessage('Hi');

      final state = container.read(aiChatControllerProvider);
      expect(state.messages, hasLength(2));
      expect(state.messages.first.role, AiChatRole.user);
      expect(state.messages.last.role, AiChatRole.model);
      expect(state.messages.last.content, 'Hello world!');
      expect(state.isStreaming, isFalse);
      expect(state.error, isNull);
    });

    test('records an error when the service throws', () async {
      final fake = _FakeGeminiAiService(
        error: const AiServiceException('boom'),
      );
      final container = await _container(serviceFactory: (_) => fake);

      await container
          .read(aiChatControllerProvider.notifier)
          .sendMessage('Hi');

      final state = container.read(aiChatControllerProvider);
      expect(state.messages.where((m) => m.role == AiChatRole.model), isEmpty);
      expect(state.isStreaming, isFalse);
      expect(state.error, 'boom');
    });

    test('rejects send when no API key is configured', () async {
      final container = await _container(
        apiKey: null,
        serviceFactory: (_) => _FakeGeminiAiService(),
      );

      await container
          .read(aiChatControllerProvider.notifier)
          .sendMessage('Hi');

      final state = container.read(aiChatControllerProvider);
      expect(state.messages, isEmpty);
      expect(state.error, contains('Settings'));
    });
  });
}

Future<ProviderContainer> _container({
  required GeminiAiServiceFactory serviceFactory,
  String? apiKey = 'fake-key',
}) async {
  final secure = InMemorySecureKeyValueStore();
  if (apiKey != null) await secure.write('gemini_api_key_v1', apiKey);

  final container = ProviderContainer(
    overrides: [
      secureKeyValueStoreProvider.overrideWithValue(secure),
      userProfileRepositoryProvider.overrideWith(
        (ref) async => FakeUserProfileRepository(initialProfile: _profile),
      ),
      geminiAiServiceFactoryProvider.overrideWithValue(serviceFactory),
    ],
  );
  addTearDown(container.dispose);

  await container.read(aiApiKeyControllerProvider.future);
  await container
      .read(profileSetupControllerProvider.notifier)
      .loadSavedProfile();
  return container;
}

class _FakeGeminiAiService implements GeminiAiService {
  _FakeGeminiAiService({this.chunks = const [], this.error});

  final List<String> chunks;
  final Object? error;

  @override
  String get apiKey => 'fake';

  @override
  String get modelId => 'fake';

  @override
  Stream<String> sendMessage({
    required String userMessage,
    required List<ChatTurn> history,
    required String systemContext,
  }) async* {
    if (error != null) throw error!;
    for (final c in chunks) {
      yield c;
    }
  }

  @override
  Future<SnapEstimate> estimateFoodFromImage(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) {
    throw UnimplementedError();
  }
}

const _profile = UserProfile(
  id: 'local-user',
  age: 30,
  heightCm: 175,
  weightKg: 70,
  gender: Gender.male,
  activityLevel: ActivityLevel.moderatelyActive,
  goalType: GoalType.maintain,
  calorieGoal: 2200,
  macroTargets: MacroTargets(
    proteinGrams: 126,
    carbsGrams: 260,
    fatGrams: 63,
    fiberGrams: 30,
  ),
);
