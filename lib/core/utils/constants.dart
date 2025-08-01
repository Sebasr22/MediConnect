class AppConstants {
  // API Configuration (sin /api en el path)
  static const String baseUrl = 'http://164.92.126.218:3000';
  static const String apiBaseUrl = baseUrl;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String userTypeKey = 'user_type';
  static const String favoriteDoctorsKey = 'favorite_doctors';
  
  // User Types
  static const String userTypePatient = 'patient';
  static const String userTypeDoctor = 'doctor';
  
  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Error Messages
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado';
  static const String serverErrorMessage = 'Error del servidor. Intente más tarde';
  static const String noInternetMessage = 'Sin conexión a internet';
  
  // Success Messages
  static const String loginSuccessMessage = 'Inicio de sesión exitoso';
  static const String registrationSuccessMessage = 'Registro exitoso';
  static const String profileUpdateSuccessMessage = 'Perfil actualizado exitosamente';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Configuration
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
}