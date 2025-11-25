import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Login
  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data user yang terdaftar
    String? storedEmail = prefs.getString('user_email');
    String? storedPassword = prefs.getString('user_password');

    if (storedEmail == email && storedPassword == password) {
      // Simpan status login
      await prefs.setBool('is_logged_in', true);
      return true;
    }
    return false;
  }

  // Register
  static Future<bool> register(String email, String password, String username) async {
    final prefs = await SharedPreferences.getInstance();

    // Cek apakah sudah terdaftar
    String? existingEmail = prefs.getString('user_email');
    if (existingEmail != null) {
      return false; // Sudah terdaftar
    }

    // Simpan data user
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
    await prefs.setString('user_name', username);
    await prefs.setBool('is_logged_in', true);

    return true;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }

  // Check apakah sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Get user data
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'bio': prefs.getString('user_bio') ?? '',
      'phone': prefs.getString('user_phone') ?? '',
      'photo': prefs.getString('user_photo') ?? '',
    };
  }

  // Update user data
  static Future<void> updateUserData({
    String? name,
    String? bio,
    String? phone,
    String? photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('user_name', name);
    if (bio != null) await prefs.setString('user_bio', bio);
    if (phone != null) await prefs.setString('user_phone', phone);
    if (photo != null) await prefs.setString('user_photo', photo);
  }
}