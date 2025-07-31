import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';
import '../utils/constants.dart';

/// Servicio de almacenamiento que maneja datos sensibles y preferencias
/// Utiliza SecureStorage para datos críticos y SharedPreferences para configuraciones
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;

  // ======================= SECURE STORAGE =======================
  
  // Save auth token securely
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

  // Get auth token
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.authTokenKey);
    } catch (e) {
      throw const CacheException('Error al obtener token de autenticación');
    }
  }

  // Remove auth token
  Future<void> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.authTokenKey);
    } catch (e) {
      throw const CacheException('Error al eliminar token de autenticación');
    }
  }

  // Save user data securely (sensitive information)
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

  // Get user data from secure storage
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

  // Remove user data from secure storage
  Future<void> removeUserDataSecure() async {
    try {
      await _secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw const CacheException('Error al eliminar datos de usuario');
    }
  }

  // Clear all secure storage
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