import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leksis/database/database_helpers.dart';
import '../../l10n/app_localizations.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _totalWords = 0;
  int _learnedWords = 0;
  int _toLearnWords = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final allWords = await DatabaseHelper.instance.getWordsOverview();
    
    setState(() {
      _totalWords = allWords.length;
      _learnedWords = allWords.where((w) => w.isLearned).length;
      _toLearnWords = _totalWords - _learnedWords;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.appActivity,
          style: GoogleFonts.philosopher(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatCard(
                    loc.words,
                    _totalWords.toString(),
                    Icons.library_books_rounded,
                    colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    loc.learned,
                    _learnedWords.toString(),
                    Icons.star_rounded,
                    colorScheme.tertiary,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    loc.notLearned,
                    _toLearnWords.toString(),
                    Icons.star_border_rounded,
                    colorScheme.secondary,
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      loc.activityAndProgress,
                      style: GoogleFonts.firaSans(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.firaSans(
                      fontSize: 16,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.firaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
