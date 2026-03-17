import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'image_generation_service.dart';

class ResultScreen extends StatefulWidget {
  final int tripDuration;
  final double travelBudget;
  final int numParticipants;
  final String destination;
  final String travelType;

  const ResultScreen({
    super.key,
    required this.tripDuration,
    required this.travelBudget,
    required this.numParticipants,
    required this.destination,
    required this.travelType,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Task 2: image bytes future
  late Future<Uint8List> _posterFuture;
  // Task 3: recommendation future
  late Future<Map<String, dynamic>> _recommendationFuture;

  @override
  void initState() {
    super.initState();

    // Task 2: build prompt and call HuggingFace image API
    final imagePrompt =
        'A stunning travel destination poster for ${widget.destination}, '
        '${widget.travelType} travel experience, ${widget.tripDuration} days trip, '
        'beautiful landscape photography style, vibrant colors, '
        'cinematic lighting, professional tourism advertisement, 4k ultra detailed';

    _posterFuture = ImageGenerationService.generateImage(imagePrompt);

    // Task 3: call Firebase AI Logic (Gemini)
    _recommendationFuture = ApiService.getTravelRecommendation(
      destination: widget.destination,
      tripDuration: widget.tripDuration,
      budget: widget.travelBudget,
      participants: widget.numParticipants,
      travelType: widget.travelType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A73E8),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              // ── Task 2: AI-Generated Travel Poster (HuggingFace) ──
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Uint8List>(
                    future: _posterFuture,
                    builder: (ctx, snapshot) {
                      // Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          color: const Color(0xFF0D47A1),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  '🎨 Generating your travel poster...',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Error or empty bytes
                      final bytes = snapshot.data;
                      if (snapshot.hasError ||
                          bytes == null ||
                          bytes.isEmpty) {
                        return Container(
                          color: const Color(0xFF1A73E8),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_outlined,
                                    color: Colors.white54, size: 60),
                                SizedBox(height: 8),
                                Text('Poster unavailable',
                                    style:
                                        TextStyle(color: Colors.white54)),
                              ],
                            ),
                          ),
                        );
                      }

                      // ✅ Display image from raw bytes using Image.memory
                      return Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    },
                  ),

                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),

                  // Destination label
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.destination,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                        ),
                        Text(
                          '${widget.tripDuration} days • ${widget.travelType} • ${widget.numParticipants} pax',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Task 3 + Task 4: Recommendations ──────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildBudgetSummaryCard(),
                const SizedBox(height: 16),

                FutureBuilder<Map<String, dynamic>>(
                  future: _recommendationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCard();
                    }
                    if (snapshot.hasError) {
                      return _buildErrorCard(snapshot.error.toString());
                    }
                    if (!snapshot.hasData) {
                      return _buildErrorCard('No data received.');
                    }
                    return _buildRecommendations(snapshot.data!);
                  },
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('💰', 'Budget',
              'RM ${widget.travelBudget.toStringAsFixed(0)}'),
          _divider(),
          _statItem('📅', 'Duration', '${widget.tripDuration} days'),
          _divider(),
          _statItem('👥', 'People', '${widget.numParticipants} pax'),
          _divider(),
          _statItem('🏷️', 'Style', widget.travelType),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE0E0E0));

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF1A73E8)),
          SizedBox(height: 16),
          Text(
            '🤖 AI is crafting your personalised travel recommendation...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          const Text('Failed to load recommendations',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 4),
          Text(error,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecommendations(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['summary'] != null) ...[
          _sectionHeader('✨ Trip Summary'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(accent: const Color(0xFF1A73E8)),
            child: Text(data['summary'],
                style: const TextStyle(fontSize: 15, height: 1.5)),
          ),
          const SizedBox(height: 16),
        ],
        if (data['highlights'] != null) ...[
          _sectionHeader('🌟 Top Highlights'),
          _buildChipList(List<String>.from(data['highlights']),
              const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
          const SizedBox(height: 16),
        ],
        if (data['dailyBudgetPerPerson'] != null) ...[
          _sectionHeader('💸 Budget Breakdown'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _budgetRow('Daily per person',
                    'RM ${(data['dailyBudgetPerPerson'] as num).toStringAsFixed(2)}'),
                const Divider(height: 16),
                _budgetRow('Total for ${widget.numParticipants} pax',
                    'RM ${widget.travelBudget.toStringAsFixed(0)}'),
                if (data['accommodation'] != null) ...[
                  const Divider(height: 16),
                  _infoRow(Icons.hotel_outlined, 'Accommodation',
                      data['accommodation']),
                ],
                if (data['transport'] != null) ...[
                  const Divider(height: 16),
                  _infoRow(Icons.directions_bus_outlined, 'Transport',
                      data['transport']),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (data['itinerary'] != null &&
            (data['itinerary'] as List).isNotEmpty) ...[
          _sectionHeader('🗓️ Day-by-Day Itinerary'),
          ...(data['itinerary'] as List).map((day) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('D${day['day']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day['title'] ?? 'Day ${day['day']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(day['activities'] ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (data['mustTryFood'] != null) ...[
          _sectionHeader('🍜 Must-Try Food'),
          _buildChipList(List<String>.from(data['mustTryFood']),
              const Color(0xFFFFF3E0), const Color(0xFFE65100)),
          const SizedBox(height: 16),
        ],
        if (data['bestTimeToVisit'] != null) ...[
          _sectionHeader('📆 Best Time to Visit'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined,
                    color: Color(0xFFFFA000), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(data['bestTimeToVisit'],
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (data['tips'] != null) ...[
          _sectionHeader('💡 Travel Tips'),
          ...(data['tips'] as List).map((tip) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Expanded(
                        child: Text(tip,
                            style: const TextStyle(
                                fontSize: 14, height: 1.4))),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style:
              const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChipList(
      List<String> items, Color bg, Color textColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item,
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
              ))
          .toList(),
    );
  }

  Widget _budgetRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF666666))),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF1A73E8), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Color(0xFF333333), fontSize: 13),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration({Color? accent}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: accent != null
          ? Border(left: BorderSide(color: accent, width: 4))
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}