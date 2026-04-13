import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  PREMIUM HELPER
//  Tracks show frequency: on login (always) +
//  up to 3 additional times per calendar day.
//  Resets automatically at midnight.
// ─────────────────────────────────────────────

class PremiumHelper {
  static const _keyDate      = 'premium_last_date';
  static const _keyCount     = 'premium_show_count';
  static const _keyIsPremium = 'is_premium';
  static const int maxPerDay = 3; // in-app triggers (excluding login)

  // ── Is this user already premium? ────────

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  // ── Call this after a successful payment ─

  static Future<void> setPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
  }

  // ── Should the sheet appear right now? ───
  //
  //  onLogin = true  → show unconditionally (login trigger)
  //                    still increments today's count
  //  onLogin = false → show only if count < maxPerDay today

  static Future<bool> shouldShow({bool onLogin = false}) async {
    if (await isPremium()) return false;

    final prefs  = await SharedPreferences.getInstance();
    final today  = _todayKey();
    final saved  = prefs.getString(_keyDate) ?? '';
    final count  = saved == today ? (prefs.getInt(_keyCount) ?? 0) : 0;

    if (onLogin || count < maxPerDay) {
      await prefs.setString(_keyDate,  today);
      await prefs.setInt(_keyCount, count + 1);
      return true;
    }
    return false;
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
