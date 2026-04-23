  // services/auth_service.dart
  // Service untuk menangani autentikasi pengguna.
  // Token JWT disimpan menggunakan flutter_secure_storage (terenkripsi)
  // agar tidak mudah dibaca oleh pihak tidak bertanggung jawab.

  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

  /// Key untuk menyimpan token di secure storage
  const String _kTokenKey = 'auth_token';
  const String _kUsernameKey = 'username';

  class AuthService {
    // flutter_secure_storage menggunakan Android Keystore / iOS Keychain
    // Data yang disimpan otomatis terenkripsi — JAUH lebih aman dari SharedPreferences
    final _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    /// Melakukan login simulasi.
    /// Di aplikasi nyata, ini akan mengirim POST request ke server
    /// dan menerima JWT token sebagai respons.
    ///
    /// Return: true jika login berhasil, false jika gagal
    Future<bool> login(String email, String password) async {
      // Simulasi validasi login (di aplikasi nyata: POST ke API auth)
      await Future.delayed(const Duration(seconds: 2));

      if (email.isNotEmpty && password.length >= 6) {
        // Simulasi token JWT yang diterima dari server
        const fakeToken =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMSIsImlhdCI6MTcxMzYwMDAwMH0.fake_signature';

        // Simpan token secara aman ke encrypted storage
        await _storage.write(key: _kTokenKey, value: fakeToken);
        await _storage.write(key: _kUsernameKey, value: email);
        return true;
      }
      return false;
    }

    /// Logout: menghapus semua data sesi dari secure storage
    Future<void> logout() async {
      await _storage.delete(key: _kTokenKey);
      await _storage.delete(key: _kUsernameKey);
    }

    /// Mengambil token dari secure storage untuk digunakan di HTTP header
    /// Contoh: Authorization: Bearer {token}
    Future<String?> getToken() async {
      return await _storage.read(key: _kTokenKey);
    }

    /// Mengecek apakah pengguna sudah login (token tersedia)
    Future<bool> isLoggedIn() async {
      final token = await _storage.read(key: _kTokenKey);
      return token != null && token.isNotEmpty;
    }

    /// Mengambil username yang sedang login
    Future<String?> getUsername() async {
      return await _storage.read(key: _kUsernameKey);
    }
  }
