import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class PreferenceService {
  static const String _keyProfile = 'user_profile_json';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyNotifications = 'notifications';

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProfile);
    if (jsonStr == null) return UserProfile.defaultProfile();
    try {
      return UserProfile.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return UserProfile.defaultProfile();
    }
  }

  // Backward compatibility wrapper (optional but good for transition)
  Future<void> setUserProfile({
    required String name,
    required String role,
    required String salary,
    required String preference,
  }) async {
    final current = await getUserProfile();
    final updated = UserProfile(
      name: name,
      role: role,
      bio: current.bio,
      targetSalary: salary,
      workPreference: preference,
      experience: current.experience,
      education: current.education,
    );
    await saveUserProfile(updated);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<bool> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }
}
