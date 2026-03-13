import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  static const String _launchCountKey = 'launch_count';
  static const String _ratedKey = 'has_rated';

  Future<bool> shouldShowRating() async {
    final prefs = await SharedPreferences.getInstance();

    // If they already saw it once, don't show again
    if (prefs.getBool('rating_prompt_seen') == true) {
      return false;
    }

    final launchCount = prefs.getInt(_launchCountKey) ?? 0;
    final newCount = launchCount + 1;
    await prefs.setInt(_launchCountKey, newCount);

    // Show on the 2nd launch (which is "once after the first launch")
    if (newCount == 2) {
      await prefs.setBool('rating_prompt_seen', true);
      return true;
    }

    return false;
  }

  // In rating_service.dart - add this method
  Future<bool> shouldShowRatingForTesting() async {
    final prefs = await SharedPreferences.getInstance();

    // For testing, always return true
    return true;
  }

  Future<void> setRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rating_prompt_seen', true);
    await prefs.setBool(_ratedKey, true);
  }

  Future<void> setLater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rating_prompt_seen', true);
  }
}
