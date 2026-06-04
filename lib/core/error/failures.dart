import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'An unexpected error occurred']);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet Connection']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid Input']);
}
