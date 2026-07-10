import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});

  factory ServerException.fromSupabase(dynamic error) {
    final message = _parseSupabaseError(error);
    return ServerException(message);
  }

  static String _parseSupabaseError(dynamic error) {
    if (error is PostgrestException) {
      return error.message;
    }
    if (error is Map && error.containsKey('message')) {
      return error['message'] as String;
    }
    if (error is Map && error.containsKey('error')) {
      return error['error'] as String;
    }
    if (error is Map && error.containsKey('code')) {
      return 'Error de base de datos (código: ${error['code']})';
    }
    return 'Error en el servidor. Intente de nuevo.';
  }
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Sin conexión a internet. Verifique su conexión.',
  ]);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso no encontrado.']);
}
