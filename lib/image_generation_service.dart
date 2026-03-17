import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageGenerationService {
  // static const String apiKey = '';
  static final String? apiKey = dotenv.env['HF_TOKEN'];

  static Future<Uint8List> generateImage(String prompt) async {
    final url = Uri.parse(
        'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'inputs': prompt,
      'options': {
        'wait_for_model': true,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return response.bodyBytes; // ✅ returns raw image bytes
      } else {
        debugPrint(
            'Failed to generate image: ${response.statusCode} - ${response.body} - ${response.reasonPhrase}');
        return Uint8List(0);
      }
    } catch (e) {
      debugPrint('Error generating image: $e');
      return Uint8List(0);
    }
  }
}