abstract class Failure {
  final String message;

  const Failure(this.message);
}

class AuthFailure extends Failure {
  final String code;

  const AuthFailure(this.code, String message) : super(message);
}
