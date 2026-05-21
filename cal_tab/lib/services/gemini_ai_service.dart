import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

class AiServiceException implements Exception {
  const AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SnapEstimate {
  const SnapEstimate({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
    this.notes,
    this.confidence,
  });

  final String name;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final String? notes;
  final double? confidence;
}

class ChatTurn {
  const ChatTurn({required this.role, required this.content});

  /// Either 'user' or 'model'.
  final String role;
  final String content;
}

const _defaultModelId = 'gemini-2.5-flash';

const String _snap2CalPrompt =
    'You are a nutrition estimator. Look at this food photo and respond with ONLY a JSON object (no markdown, no commentary) matching this schema: '
    '{"name": "<short food name>", "calories_kcal_per_100g": <int>, "protein_g_per_100g": <num>, '
    '"carbs_g_per_100g": <num>, "fat_g_per_100g": <num>, "fiber_g_per_100g": <num>, '
    '"confidence": <0..1>, "notes": "<optional, short>"}. '
    'If the image does not contain food, respond with: {"error": "no_food"}.';

class GeminiAiService {
  GeminiAiService({required this.apiKey, this.modelId = _defaultModelId});

  final String apiKey;
  final String modelId;

  GenerativeModel _modelWith({Content? systemInstruction}) {
    return GenerativeModel(
      model: modelId,
      apiKey: apiKey,
      systemInstruction: systemInstruction,
    );
  }

  Stream<String> sendMessage({
    required String userMessage,
    required List<ChatTurn> history,
    required String systemContext,
  }) async* {
    final model = _modelWith(systemInstruction: Content.text(systemContext));
    final contents = <Content>[
      for (final turn in history) Content(turn.role, [TextPart(turn.content)]),
      Content.text(userMessage),
    ];

    try {
      final stream = model.generateContentStream(contents);
      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } on GenerativeAIException catch (e) {
      throw AiServiceException('Gemini request failed: ${e.message}');
    }
  }

  Future<SnapEstimate> estimateFoodFromImage(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final model = _modelWith();
    try {
      final response = await model.generateContent([
        Content.multi([TextPart(_snap2CalPrompt), DataPart(mimeType, bytes)]),
      ]);
      final raw = response.text;
      if (raw == null || raw.trim().isEmpty) {
        throw const AiServiceException('Gemini returned an empty response.');
      }
      return parseSnapEstimate(raw);
    } on GenerativeAIException catch (e) {
      throw AiServiceException('Gemini vision request failed: ${e.message}');
    }
  }
}

/// Parses Gemini's Snap2Cal JSON response. Public for unit testing.
SnapEstimate parseSnapEstimate(String raw) {
  final stripped = _stripCodeFences(raw).trim();
  final Map<String, dynamic> json;
  try {
    final decoded = jsonDecode(stripped);
    if (decoded is! Map<String, dynamic>) {
      throw const AiServiceException('Gemini response was not a JSON object.');
    }
    json = decoded;
  } on FormatException catch (e) {
    throw AiServiceException('Could not parse Gemini JSON: ${e.message}');
  }

  if (json['error'] != null) {
    throw AiServiceException(
      json['error'] == 'no_food'
          ? 'No food detected in the photo. Try another shot.'
          : 'Gemini reported an error: ${json['error']}',
    );
  }

  final name = (json['name'] as String?)?.trim();
  final calories = _asNum(json['calories_kcal_per_100g']);
  if (name == null || name.isEmpty || calories == null) {
    throw const AiServiceException(
      'Gemini response missing required fields (name, calories).',
    );
  }

  return SnapEstimate(
    name: name,
    caloriesPer100g: calories.round(),
    proteinPer100g: _asNum(json['protein_g_per_100g'])?.toDouble() ?? 0,
    carbsPer100g: _asNum(json['carbs_g_per_100g'])?.toDouble() ?? 0,
    fatPer100g: _asNum(json['fat_g_per_100g'])?.toDouble() ?? 0,
    fiberPer100g: _asNum(json['fiber_g_per_100g'])?.toDouble() ?? 0,
    confidence: _asNum(json['confidence'])?.toDouble(),
    notes: (json['notes'] as String?)?.trim().isEmpty == true
        ? null
        : json['notes'] as String?,
  );
}

String _stripCodeFences(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('```')) {
    return trimmed;
  }
  // Strip the opening fence (and an optional language tag).
  final firstNewline = trimmed.indexOf('\n');
  if (firstNewline == -1) {
    return trimmed;
  }
  var body = trimmed.substring(firstNewline + 1);
  if (body.endsWith('```')) {
    body = body.substring(0, body.length - 3);
  }
  return body.trim();
}

num? _asNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
