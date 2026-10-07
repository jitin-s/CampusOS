/// Domain error representations adhering to Clean Architecture principles.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'A server error occurred. Please try again.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No network connection detected.']);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failed. Please check credentials.',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Requested resource was not found.']);
}
