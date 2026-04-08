import 'package:equatable/equatable.dart';

/// An abstract base class for all domain-layer Use Cases.
///
/// Every use case represents a single business task and must implement
/// the [call] method. This ensures a consistent interface across the domain.
///
/// [T] is the return type of the use case.
/// [Params] is the parameter type required to execute the use case.
abstract class UseCase<T, Params> {
  /// Executes the business logic for this use case.
  Future<T> call(Params params);
}

/// A parameter class used when a use case does not require any input.
class NoParams extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
