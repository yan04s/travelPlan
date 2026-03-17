import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

class ApiService {
  // ─────────────────────────────────────────────────────────────
  // TASK 3: Firebase AI Logic — gemini-2.0-flash
  // ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getTravelRecommendation({
    required String destination,
    required int tripDuration,
    required double budget,
    required int participants,
    required String travelType,
  }) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );

    final prompt = '''
You are a professional travel consultant. Based on the following travel parameters, 
generate a detailed personalised travel recommendation.

Travel Parameters:
- Destination: $destination
- Trip Duration: $tripDuration days
- Total Budget: RM $budget
- Number of Participants: $participants
- Travel Style: $travelType

Respond ONLY with a valid JSON object (no markdown, no code blocks, no extra text) with this exact structure:
{
  "summary": "A 2-3 sentence exciting overview of the trip",
  "highlights": ["attraction 1", "attraction 2", "attraction 3"],
  "dailyBudgetPerPerson": 123.45,
  "accommodation": "Recommended accommodation type and area",
  "transport": "Best transport options",
  "mustTryFood": ["food 1", "food 2", "food 3"],
  "bestTimeToVisit": "Month or season recommendation",
  "tips": ["tip 1", "tip 2", "tip 3"],
  "itinerary": [
    {"day": 1, "title": "Arrival & Orientation", "activities": "Morning: arrival. Afternoon: explore city centre. Evening: welcome dinner."}
  ]
}
''';

    final response = await model.generateContent([Content.text(prompt)]);

    final rawText = response.text ?? '{}';
    final cleanText = rawText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    return jsonDecode(cleanText) as Map<String, dynamic>;
  }
}