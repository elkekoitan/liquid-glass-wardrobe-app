import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:fitcheck_app/models/gemini_payloads.dart';
import 'package:fitcheck_app/services/gemini_service.dart';

void main() {
  late List<GenerateContentResponse> responses;
  late GeminiService service;
  late Directory tmpDir;

  setUp(() {
    responses = <GenerateContentResponse>[];
    service = GeminiService(
      apiKey: 'test-key',
      overrideGenerator: (prompt) async {
        expect(prompt, isNotEmpty);
        return responses.removeAt(0);
      },
    );
    tmpDir = Directory.systemTemp.createTempSync('gemini_service_test');
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  group('generateModelImage', () {
    test('returns data url from candidate image', () async {
      final bytes = Uint8List.fromList(List<int>.generate(8, (index) => index));
      final file = File('${tmpDir.path}/input.png')..writeAsBytesSync(bytes);

      responses.add(
        GenerateContentResponse(<Candidate>[
          Candidate(
            Content.multi(<Part>[DataPart('image/png', bytes)]),
            const <SafetyRating>[],
            null,
            FinishReason.stop,
            null,
          ),
        ], null),
      );

      final result = await service.generateModelImage(
        GeminiModelRequest(userImage: file),
      );

      expect(result.imageDataUrl, startsWith('data:image/png;base64,'));
      final encoded = result.imageDataUrl.split(',').last;
      expect(base64Decode(encoded), bytes);
    });

    test('throws GeminiFailure when response is blocked', () async {
      final file = File('${tmpDir.path}/blocked.png')
        ..writeAsBytesSync(<int>[0, 1, 2]);

      responses.add(
        GenerateContentResponse(
          const <Candidate>[],
          PromptFeedback(
            BlockReason.safety,
            'Blocked for safety',
            const <SafetyRating>[],
          ),
        ),
      );

      expect(
        () => service.generateModelImage(GeminiModelRequest(userImage: file)),
        throwsA(isA<GeminiFailure>()),
      );
    });
  });

  group('generateErrorSurface', () {
    test('returns surface from failure when provided', () async {
      const surface = GeminiErrorSurface(
        code: 'custom',
        title: 'Blocked',
        message: 'Nope',
        severity: GeminiErrorSeverity.warning,
      );

      final failure = GeminiFailure(
        code: 'blocked',
        message: 'error',
        surface: surface,
      );

      final result = await service.generateErrorSurface(
        GeminiErrorSurfaceRequest(operation: 'model_image', error: failure),
      );

      expect(result, same(surface));
    });

    test('builds fallback surface when failure missing', () async {
      final result = await service.generateErrorSurface(
        GeminiErrorSurfaceRequest(
          operation: 'garment_blend',
          error: StateError('boom'),
          highContrast: true,
        ),
      );

      expect(result.title, 'Try-On Paused');
      expect(result.code, 'garment_blend_fallback');
      expect(result.actionLabel, isNotEmpty);
    });
  });
}
