import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserData(UserModel user);
  Future<UserModel?> getCachedUserData();
  Future<void> clearUserData();
  Future<bool> isAuthenticated();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl(this.storageService);

  @override
  Future<void> saveUserData(UserModel user) async {
    try {
      final userData = user.toJson();
      await storageService.saveUserDataSecure(userData);
    } catch (e) {
      throw const CacheException('Error al guardar datos de usuario');
    }
  }

  @override
  Future<UserModel?> getCachedUserData() async {
    try {
      final userData = await storageService.getUserDataSecure();
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw const CacheException('Error al obtener datos de usuario');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      await storageService.clearAllUserData();
    } catch (e) {
      throw const CacheException('Error al limpiar datos de usuario');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await storageService.isAuthenticated();
    } catch (e) {
      return false;
    }
  }
}