import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';
import '../utils/constants.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;

  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(
        key: AppConstants.authTokenKey,
        value: token,
      );
    } catch (e) {
      throw const CacheException('Error al guardar token de autenticación');
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.authTokenKey);
    } catch (e) {
      throw const CacheException('Error al obtener token de autenticación');
    }
  }

  Future<void> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.authTokenKey);
    } catch (e) {
      throw const CacheException('Error al eliminar token de autenticación');
    }
  }

  Future<void> saveUserDataSecure(Map<String, dynamic> userData) async {
    try {
      final userDataJson = jsonEncode(userData);
      await _secureStorage.write(
        key: AppConstants.userDataKey,
        value: userDataJson,
      );
    } catch (e) {
      throw const CacheException('Error al guardar datos de usuario');
    }
  }

  Future<Map<String, dynamic>?> getUserDataSecure() async {
    try {
      final userDataJson = await _secureStorage.read(key: AppConstants.userDataKey);
      if (userDataJson != null) {
        return jsonDecode(userDataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw const CacheException('Error al obtener datos de usuario');
    }
  }

  Future<void> removeUserDataSecure() async {
    try {
      await _secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw const CacheException('Error al eliminar datos de usuario');
    }
  }

  Future<void> clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw const CacheException('Error al limpiar almacenamiento seguro');
    }
  }

  // ======================= SHARED PREFERENCES =======================

  // Save user type (patient/doctor)
  Future<void> saveUserType(String userType) async {
    try {
      await _sharedPreferences.setString(AppConstants.userTypeKey, userType);
    } catch (e) {
      throw const CacheException('Error al guardar tipo de usuario');
    }
  }

  // Get user type
  String? getUserType() {
    try {
      return _sharedPreferences.getString(AppConstants.userTypeKey);
    } catch (e) {
      throw const CacheException('Error al obtener tipo de usuario');
    }
  }

  // Remove user type
  Future<void> removeUserType() async {
    try {
      await _sharedPreferences.remove(AppConstants.userTypeKey);
    } catch (e) {
      throw const CacheException('Error al eliminar tipo de usuario');
    }
  }

  // Save any string value
  Future<void> saveString(String key, String value) async {
    try {
      await _sharedPreferences.setString(key, value);
    } catch (e) {
      throw CacheException('Error al guardar $key');
    }
  }

  // Get string value
  String? getString(String key) {
    try {
      return _sharedPreferences.getString(key);
    } catch (e) {
      throw CacheException('Error al obtener $key');
    }
  }

  // Save boolean value
  Future<void> saveBool(String key, bool value) async {
    try {
      await _sharedPreferences.setBool(key, value);
    } catch (e) {
      throw CacheException('Error al guardar $key');
    }
  }

  // Get boolean value
  bool? getBool(String key) {
    try {
      return _sharedPreferences.getBool(key);
    } catch (e) {
      throw CacheException('Error al obtener $key');
    }
  }

  // Save integer value
  Future<void> saveInt(String key, int value) async {
    try {
      await _sharedPreferences.setInt(key, value);
    } catch (e) {
      throw CacheException('Error al guardar $key');
    }
  }

  // Get integer value
  int? getInt(String key) {
    try {
      return _sharedPreferences.getInt(key);
    } catch (e) {
      throw CacheException('Error al obtener $key');
    }
  }

  // Clear all shared preferences
  Future<void> clearSharedPreferences() async {
    try {
      await _sharedPreferences.clear();
    } catch (e) {
      throw const CacheException('Error al limpiar preferencias');
    }
  }

  // ======================= FAVORITES METHODS =======================

  // Save favorite doctors list
  Future<void> saveFavoriteDoctors(List<String> doctorIds) async {
    try {
      final favoritesJson = jsonEncode(doctorIds);
      await _sharedPreferences.setString(AppConstants.favoriteDoctorsKey, favoritesJson);
    } catch (e) {
      throw const CacheException('Error al guardar doctores favoritos');
    }
  }

  // Get favorite doctors list
  Future<List<String>> getFavoriteDoctors() async {
    try {
      final favoritesJson = _sharedPreferences.getString(AppConstants.favoriteDoctorsKey);
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      throw const CacheException('Error al obtener doctores favoritos');
    }
  }

  // Add doctor to favorites
  Future<void> addFavoriteDoctor(String doctorId) async {
    try {
      final currentFavorites = await getFavoriteDoctors();
      if (!currentFavorites.contains(doctorId)) {
        currentFavorites.add(doctorId);
        await saveFavoriteDoctors(currentFavorites);
      }
    } catch (e) {
      throw const CacheException('Error al agregar doctor a favoritos');
    }
  }

  // Remove doctor from favorites
  Future<void> removeFavoriteDoctor(String doctorId) async {
    try {
      final currentFavorites = await getFavoriteDoctors();
      currentFavorites.remove(doctorId);
      await saveFavoriteDoctors(currentFavorites);
    } catch (e) {
      throw const CacheException('Error al quitar doctor de favoritos');
    }
  }

  // Check if doctor is favorite
  Future<bool> isDoctorFavorite(String doctorId) async {
    try {
      final favorites = await getFavoriteDoctors();
      return favorites.contains(doctorId);
    } catch (e) {
      return false;
    }
  }

  // Toggle doctor favorite status
  Future<bool> toggleFavoriteDoctor(String doctorId) async {
    try {
      final isFavorite = await isDoctorFavorite(doctorId);
      if (isFavorite) {
        await removeFavoriteDoctor(doctorId);
        return false;
      } else {
        await addFavoriteDoctor(doctorId);
        return true;
      }
    } catch (e) {
      throw const CacheException('Error al cambiar estado de favorito');
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    try {
      await _sharedPreferences.remove(AppConstants.favoriteDoctorsKey);
    } catch (e) {
      throw const CacheException('Error al limpiar favoritos');
    }
  }

  // ======================= UTILITY METHODS =======================

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final userType = getUserType();
      final userData = await getUserDataSecure();
      return userType != null && userData != null;
    } catch (e) {
      return false;
    }
  }

  // Limpiar todos los datos del usuario (logout)
  Future<void> clearAllUserData() async {
    try {
      await Future.wait([
        clearSecureStorage(),
        removeUserType(),
      ]);
    } catch (e) {
      throw const CacheException('Error al limpiar datos de usuario');
    }
  }
}