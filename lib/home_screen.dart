import 'package:flutter/material.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tripDuration = 3;
  double _travelBudget = 1000;
  int _numParticipants = 1;
  String _destination = '';
  String _travelType = 'Mid-Range';

  final TextEditingController _destinationController = TextEditingController();
  final List<String> _travelTypes = ['Budget', 'Mid-Range', 'Luxury'];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  // Map budgetLabel to the matching travelType string
  String _budgetSuggestedType(double v) {
    if (v < 1500) return 'Budget';
    if (v < 6000) return 'Mid-Range';
    return 'Luxury';
  }

  // Called when slider drag ends — show dialog if suggestion differs
  void _onBudgetChangeEnd(double v) {
    final suggested = _budgetSuggestedType(v);
    if (suggested != _travelType) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Text(_travelTypeEmoji(suggested),
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text('Change Travel Type?',
                  style: TextStyle(fontSize: 17)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF333333), height: 1.5),
              children: [
                const TextSpan(text: 'Your budget of '),
                TextSpan(
                  text: 'RM ${v.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' suits a '),
                TextSpan(
                  text: suggested,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _budgetColor(v),
                  ),
                ),
                const TextSpan(
                    text: ' trip.\n\nWould you like to update your travel type to match?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep current',
                  style: TextStyle(color: Color(0xFF888888))),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _travelType = suggested);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Switch to $suggested',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _generatePlan() {
    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a destination!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          tripDuration: _tripDuration,
          travelBudget: _travelBudget,
          numParticipants: _numParticipants,
          destination: _destinationController.text.trim(),
          travelType: _travelType,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String label,
    required String subtitle,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1A73E8), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          Row(
            children: [
              _circleButton(Icons.remove, onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$value',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _circleButton(Icons.add, onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1A73E8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: const Color(0xFF1A73E8),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '✈️  Travel Planner',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              titlePadding: const EdgeInsetsDirectional.only(
                start: 15,
                bottom: 16,
              ),
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Configure your dream trip',
                            style:
                                TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Destination ──────────────────────────────────
                _buildSectionTitle('📍  Destination'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _destinationController,
                    onChanged: (v) => setState(() => _destination = v),
                    decoration: InputDecoration(
                      hintText: 'e.g. Kyoto, Japan',
                      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          color: Color(0xFF1A73E8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Trip Duration ─────────────────────────────────
                _buildSectionTitle('📅  Trip Duration (days)'),
                _buildCounterCard(
                  label: '$_tripDuration Days',
                  subtitle: 'How long is your trip?',
                  value: _tripDuration,
                  icon: Icons.calendar_today_outlined,
                  onDecrement: () => setState(
                      () => _tripDuration = (_tripDuration - 1).clamp(1, 30)),
                  onIncrement: () => setState(
                      () => _tripDuration = (_tripDuration + 1).clamp(1, 30)),
                ),
                const SizedBox(height: 20),

                // ── Travel Budget ─────────────────────────────────
                _buildSectionTitle('💰  Travel Budget (RM)'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.wallet_outlined,
                                color: Color(0xFF1A73E8), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'RM ${_travelBudget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ]),
                          Text(
                            _budgetLabel(_travelBudget),
                            style: TextStyle(
                              color: _budgetColor(_travelBudget),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _travelBudget,
                        min: 200,
                        max: 20000,
                        divisions: 198,
                        activeColor: const Color(0xFF1A73E8),
                        // Update value while dragging
                        onChanged: (v) =>
                            setState(() => _travelBudget = v),
                        // ── Show dialog when user releases the slider ──
                        onChangeEnd: _onBudgetChangeEnd,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('RM 200',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          Text('RM 20,000',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Number of Participants ────────────────────────
                _buildSectionTitle('👥  Number of Participants'),
                _buildCounterCard(
                  label:
                      '$_numParticipants ${_numParticipants == 1 ? "Person" : "People"}',
                  subtitle: 'How many travellers?',
                  value: _numParticipants,
                  icon: Icons.people_outline,
                  onDecrement: () => setState(() =>
                      _numParticipants = (_numParticipants - 1).clamp(1, 20)),
                  onIncrement: () => setState(() =>
                      _numParticipants = (_numParticipants + 1).clamp(1, 20)),
                ),
                const SizedBox(height: 20),

                // ── Type of Travel ────────────────────────────────
                _buildSectionTitle('🏷️  Type of Travel'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: _travelTypes.map((type) {
                      final selected = _travelType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _travelType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF1A73E8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _travelTypeEmoji(type),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF555555),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Generate Button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _generatePlan,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text(
                      'Generate My Travel Plan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _budgetLabel(double v) {
    if (v < 1500) return 'Budget trip';
    if (v < 6000) return 'Mid-range trip';
    return 'Luxury trip';
  }

  Color _budgetColor(double v) {
    if (v < 1500) return Colors.green;
    if (v < 6000) return Colors.orange;
    return Colors.purple;
  }

  String _travelTypeEmoji(String type) {
    switch (type) {
      case 'Budget':
        return '🎒';
      case 'Mid-Range':
        return '🏨';
      case 'Luxury':
        return '💎';
      default:
        return '✈️';
    }
  }
}