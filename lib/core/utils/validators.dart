import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Ingrese un email válido';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    
    if (password.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no puede tener más de ${AppConstants.maxPasswordLength} caracteres';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (name.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    return null;
  }
  
  // Phone validation
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    // Basic phone validation (adjust as needed)
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Ingrese un teléfono válido';
    }
    
    return null;
  }
  
  // Date validation
  static String? validateBirthDate(DateTime? date) {
    if (date == null) {
      return 'La fecha de nacimiento es requerida';
    }
    
    final now = DateTime.now();
    final age = now.year - date.year;
    
    if (age < 0 || age > 120) {
      return 'Ingrese una fecha de nacimiento válida';
    }
    
    return null;
  }
  
  // Rating validation (1-5)
  static String? validateRating(double? rating) {
    if (rating == null) {
      return 'La calificación es requerida';
    }
    
    if (rating < 1 || rating > 5) {
      return 'La calificación debe estar entre 1 y 5';
    }
    
    return null;
  }
  
  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
}